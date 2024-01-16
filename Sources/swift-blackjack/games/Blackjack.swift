//
//  Blackjack.swift
//  
//
//  Created by Evan Anderson on 1/15/24.
//

import Foundation

package final class Blackjack : CasinoGame, CardCountable {
    var minimum_bet : Int { 1 }
    var maximum_bet : Int { 100 }
    
    private(set) var number_of_decks:Int
    private(set) var unplayed:[Card]
    private(set) var discarded:[Card]
    
    let house:BlackjackHand = BlackjackHand(player: nil, type: CardHolderType.house, wagers: [:])
    
    var players:[Player]
    private(set) var active_hand_index:Int
    var hands:[BlackjackHand]
    
    package init(decks: [Deck], players: [Player]) {
        number_of_decks = decks.count
        unplayed = decks.flatMap({ $0.cards }).shuffled()
        discarded = []
        
        self.players = players
        active_hand_index = 0
        self.hands = []
    }
    
    var in_play : [Card] {
        return hands.flatMap({ $0.cards })
    }
    
    func running_count(_ strategy: CountStrategy, facing: Set<CardFace>) -> Float {
        return strategy.count(in_play, facing: facing) + strategy.count(discarded, facing: [.down, .up])
    }
    func true_count(_ strategy: CountStrategy, facing: Set<CardFace>) -> Float {
        return running_count(strategy, facing: facing) / Float(number_of_decks)
    }
    func count(_ strategy: CountStrategy, type: DeckType) -> Float {
        switch type {
        case .unplayed: return strategy.count(unplayed, facing: [.up])
        case .in_play: return strategy.count(in_play, facing: [.up])
        case .discarded: return strategy.count(discarded, facing: [.up])
        }
    }
}
extension Blackjack {
    func draw_for_everyone() {
        for hand in hands {
            let (card, result):(Card, BlackjackCardDrawResult) = draw(hand: hand)
        }
    }
    
    var active_hand : BlackjackHand {
        return hands[active_hand_index]
    }
    func reset() {
        for hand in hands {
            discard(hand)
        }
        hands.removeAll()
        house.is_valid = true
    }
    func discard(_ hand: BlackjackHand) {
        for card in hand.cards {
            card.face = .up
        }
        discarded.append(contentsOf: hand.cards)
        hand.cards = []
        hand.is_valid = false
    }
}

extension Blackjack {
    func get_next_hand() -> (index: Int, hand: BlackjackHand) {
        var next_index:Int = active_hand_index + 1
        let hands_count:Int = hands.count
        next_index = next_index >= hands_count ? 0 : next_index
        while next_index != 0 && next_index < hands_count {
            let hand:BlackjackHand = hands[next_index]
            if hand.is_valid && hand.allows_more_cards {
                break
            }
            next_index += 1
        }
        return (next_index, hands[next_index])
    }
    func next_hand() {
        let (index, hand):(Int, BlackjackHand) = get_next_hand()
        active_hand_index = index
    }
    
    func perform_action(player: Player, action: BlackjackAction, wager: Int) -> BlackjackCardDrawResult? {
        let hand:BlackjackHand = active_hand
        
        switch action {
        case .stay:
            stay(hand)
            return nil
        case .hit:
            let (_, result):(Card, BlackjackCardDrawResult) = draw(hand: hand)
            switch result {
            case .blackjack:
                blackjack(hand)
                return .blackjack
            case .twenty_one:
                twenty_one(hand)
                return .twenty_one
            case .busted:
                busted(hand)
                return .busted
            default:
                return .added
            }
            
        case .insurance:
            insurance(hand)
            break
        case .surrender:
            surrender(hand)
            break
        case .split:
            break
        case .double_down:
            double_down(player: player, wager: wager, hand: hand)
            return .doubled_down
        }
        return nil
    }
    
    func blackjack(_ hand: BlackjackHand) {
        next_hand()
    }
    func twenty_one(_ hand: BlackjackHand) {
        next_hand()
    }
    func stay(_ hand: BlackjackHand) {
        next_hand()
    }
    func busted(_ hand: BlackjackHand) {
        discard(hand)
        next_hand()
    }
    func insurance(_ hand: BlackjackHand) {
        guard house.cards.first(where: { $0.number == .ace && $0.face == .up }) != nil, !hand.is_insured else { return }
        let player:Player = hand.player!
        
        hand.is_insured = true
        hand.player!.bet_insured(game: .blackjack, hand.wagers[player]!)
    }
    func surrender(_ hand: BlackjackHand) {
        for (player, wager) in hand.wagers {
            player.bet_surrendered(game: .blackjack, recovered: wager/2)
        }
        discard(hand)
        next_hand()
    }
    func double_down(player: Player, wager: Int, hand: BlackjackHand) {
        guard hand.allows_more_cards else { return }
        
        let (_, _):(Card, BlackjackCardDrawResult) = draw(hand: hand)
        hand.allows_more_cards = false
        if hand.wagers[player] == nil {
            hand.wagers[player] = wager
        } else {
            hand.wagers[player]! += wager
        }
    }
}
extension Blackjack {
    func incorporate_discarded() {
        print("Blackjack;incorporate_discarded;shuffled in the discarded cards")
        unplayed.append(contentsOf: discarded)
        unplayed.shuffle()
        discarded = []
    }
    
    func draw(hand: BlackjackHand) -> (card: Card, result: BlackjackCardDrawResult) {
        if unplayed.isEmpty {
            incorporate_discarded()
        }
        
        let card:Card = unplayed.removeFirst()
        card.face = .up
        hand.cards.append(card)
        
        var string:String
        let scores:Set<Int> = hand.scores()
        let drew_string:String = hand.name + " drew: " + card.number.name + ". Scores: \(scores)."
        if hand.is_house {
            switch hand.cards.count {
            case 2:
                card.face = .down
                string = hand.name + " drew: *UNKNOWN*."
                break
            case 3:
                reveal_house()
                fallthrough
            default:
                string = drew_string
                break
            }
        } else {
            string = drew_string
        }
        
        let result:BlackjackCardDrawResult
        if scores.contains(21) {
            if hand.cards.count == 2 {
                string += " (blackjack!)"
                result = .blackjack
            } else {
                string += " (21!)"
                result = .twenty_one
            }
        } else if scores.min() ?? 21 > 21 {
            string += " (busted!)"
            discard(hand)
            result = .busted
        } else {
            result = .added
        }
        print(string)
        return (card, result)
    }
    
    private func reveal_house() {
        guard house.cards[1].face == .down else { return }
        house.cards[1].face = .up
        print(house.name + " revealed: " + house.cards[1].number.name + ".")
    }
}

extension Blackjack {
    package func round_start(wagers: [Player:[Int]]) {
        active_hand_index = 0
        hands = [house]
        
        for (player, player_wagers) in wagers {
            for player_wager in player_wagers {
                let hand:BlackjackHand = BlackjackHand(player: player, type: CardHolderType.player, wagers: [player : player_wager])
                player.bet_placed(game: .blackjack, player_wager)
                hands.append(hand)
            }
        }
        draw_for_everyone()
        draw_for_everyone()
        
        if house.scores().contains(21) {
            print("House drew blackjack!")
            round_end()
        }
    }
}

extension Blackjack {
    func round_end() {
        let hands:[BlackjackHand] = hands.filter({ $0.is_valid })
        
        if house.is_valid {
            // check who won, lost, and pushed
            let max_house_score:Int = house.scores().filter({ $0 <= 21 }).max()!
            
            var valid_hand_results:[BlackjackHand:GameResult.Blackjack] = [:]
            for hand in hands {
                let score:Int = hand.scores().filter({ $0 <= 21 }).max()!
                valid_hand_results[hand] = score == max_house_score ? .push : score < max_house_score ? .lost : .won
            }
            
            let winning_hands:[BlackjackHand:GameResult.Blackjack] = valid_hand_results.filter({ $0.value == .won })
            for (hand, _) in winning_hands {
                print("hand " + hand.name + " WON with > score of \(max_house_score)")
                for (player, wager) in hand.wagers {
                    player.bet_won(game: .blackjack, wager)
                }
            }
            
            let pushed_hands:[BlackjackHand:GameResult.Blackjack] = valid_hand_results.filter({ $0.value == .push })
            for (hand, _) in pushed_hands {
                print("hand " + hand.name + " PUSHED with == score of \(max_house_score)")
                for (player, wager) in hand.wagers {
                    player.bet_pushed(game: .blackjack, wager)
                }
            }
            
            let losing_hands:[BlackjackHand:GameResult.Blackjack] = valid_hand_results.filter({ $0.value == .lost })
            for (hand, _) in losing_hands {
                print("hand " + hand.name + " LOST with < score of \(max_house_score)")
            }
        } else {
            // every valid hand won
            for hand in hands {
                print("hand " + hand.name + " WON due to house busting")
                for (player, wager) in hand.wagers {
                    player.bet_won(game: .blackjack, wager)
                }
            }
        }
        reset()
    }
}
