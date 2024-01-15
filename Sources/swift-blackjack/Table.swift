//
//  Table.swift
//
//
//  Created by Evan Anderson on 1/14/24.
//

import Foundation
import ConsoleKit

package final class Table {
    
    let terminal:Terminal
    private(set) var game:GameType
    private(set) var number_of_decks:Int
    private(set) var unplayed:[Card]
    private(set) var discarded:[Card]
    
    private(set) var hands:[Hand]
    
    package init(terminal: Terminal, game: GameType, decks: [Deck], hands: [Hand]) {
        self.terminal = terminal
        self.game = game
        self.unplayed = decks.flatMap({ $0.cards })
        number_of_decks = decks.count
        self.discarded = []
        self.hands = hands
    }
    
    var in_play : [Card] {
        return hands.flatMap({ $0.cards })
    }
    
    
    func reset() {
        print("shuffled in the discarded cards")
        unplayed.append(contentsOf: discarded)
        unplayed.shuffle()
        discarded = []
    }
    
    func draw_for_everyone() {
        for hand in hands {
            let (card, result):(Card, CardDrawResult) = draw(hand: hand)
        }
    }
    
    func draw(hand: Hand) -> (card: Card, result: CardDrawResult) {
        if unplayed.isEmpty {
            reset()
        }
        
        let card:Card = unplayed.removeFirst()
        hand.cards.append(card)
        
        var string:String
        let result:CardDrawResult
        switch game {
        case .blackjack:
            card.face = .up
            let scores:Set<Int> = hand.scores(game: game)
            let drew_string:String = hand.name + " drew: " + card.number.name + ". Scores: \(scores)."
            if hand.is_house {
                switch hand.cards.count {
                case 2:
                    card.face = .down
                    string = hand.name + " drew: *UNKNOWN*."
                    break
                case 3:
                    blackjack_reveal_house()
                    fallthrough
                default:
                    string = drew_string
                    break
                }
            } else {
                string = drew_string
            }
            
            if scores.contains(21) {
                if hand.cards.count == 2 {
                    string += " (blackjack!)"
                    result = .blackjack(.blackjack)
                } else {
                    string += " (21!)"
                    result = .blackjack(.twenty_one)
                }
            } else if scores.min() ?? 21 > 21 {
                string += " (busted!)"
                discard(hand: hand)
                result = .blackjack(.busted)
            } else {
                result = .blackjack(.added)
            }
            break
        }
        print(string)
        return (card, result)
    }
    
    func end_round() {
        switch game {
        case .blackjack:
            end_round_blackjack()
            break
        }
        
        discard()
        ask_to_play_another_round()
    }
    func ask_to_play_another_round() {
        let acceptable_responses:Set<String> = ["yes", "y", "no", "n"]
        let question:String = "\nPlay another round? [y/n]"
        var response:String = get_response(question).lowercased()
        while !acceptable_responses.contains(response) {
            response = get_response(question).lowercased()
        }
        switch response {
        case "yes", "y":
            play_round()
            break
        case "no", "n":
            break
        default:
            break
        }
    }
    
    func discard(hand: Hand) {
        for card in hand.cards {
            card.face = .up
        }
        discarded.append(contentsOf: hand.cards)
        hand.is_valid = false
        hand.cards = []
    }
    func discard() {
        for hand in hands.filter({ $0.is_valid }) {
            discard(hand: hand)
        }
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

extension Table {
    private func blackjack_reveal_house() {
        let hand:Hand = hands[0]
        guard hand.cards[1].face == .down else { return }
        hand.cards[1].face = .up
        print(hand.name + " revealed: " + hand.cards[1].number.name + ".")
    }
    func end_round_blackjack() {
        let house:Hand = hands[0]
        // everyone that didn't bust, and not house
        let valid_hands:Set<Hand> = hands.filter_set({ $0.type != .house && $0.is_valid })
        if house.is_valid {
            // check who won, lost, and pushed
            let house_scores:Set<Int> = house.scores(game: game)
            let max_house_score:Int = house_scores.filter({ $0 <= 21 }).max()!
            
            var valid_hand_results:[Hand:GameResult.Blackjack] = [:]
            for hand in valid_hands {
                let score:Int = hand.scores(game: game).filter({ $0 <= 21 }).max()!
                valid_hand_results[hand] = score == max_house_score ? .push : score < max_house_score ? .lost : .won
            }
            
            let winning_hands:[Hand:GameResult.Blackjack] = valid_hand_results.filter({ $0.value == .won })
            for (hand, _) in winning_hands {
                print("hand " + hand.name + " WON with > score of \(max_house_score)")
            }
            
            let pushed_hands:[Hand:GameResult.Blackjack] = valid_hand_results.filter({ $0.value == .push })
            for (hand, _) in pushed_hands {
                print("hand " + hand.name + " PUSHED with == score of \(max_house_score)")
            }
            
            let losing_hands:[Hand:GameResult.Blackjack] = valid_hand_results.filter({ $0.value == .lost })
            for (hand, _) in losing_hands {
                print("hand " + hand.name + " LOST with < score of \(max_house_score)")
            }
        } else {
            // every valid hand won
            for hand in valid_hands {
                print("hand " + hand.name + " WON due to house busting")
            }
        }
    }
}

package extension Table {
    func play_round() {
        for hand in hands {
            hand.is_valid = true
        }
        guard let player_index:Int = hands.firstIndex(where: { $0.type != .house }) else {
            print("need at least one player to play")
            return
        }
        unplayed.shuffle()
        
        switch game {
        case .blackjack:
            draw_for_everyone()
            draw_for_everyone()
            
            if hands[0].scores(game: game).contains(21) {
                print("House drew blackjack!")
                end_round()
                return
            }
            break
        }
        perform_next_action(hand_index: player_index)
    }
    
    private func perform_next_action(hand_index: Int) {
        if hands.count == 1 && hands[0].is_house {
            ask_to_play_another_round()
            return
        }
        
        let hand:Hand = hands[hand_index]
        guard hand.type != .house else {
            let scores:Set<Int> = hand.scores(game: game)
            switch game {
            case .blackjack:
                if scores.first(where: { $0 >= 17 && $0 <= 21 }) != nil {
                    blackjack_reveal_house()
                    end_round()
                } else {
                    let (card, result):(Card, CardDrawResult) = draw(hand: hand)
                    switch result {
                    case .blackjack(.busted):
                        end_round()
                        return
                    default:
                        perform_next_action(hand_index: hand_index)
                        break
                    }
                }
                break
            }
            return
        }
        var next_index:Int = (hand_index + 1) % hands.count
        guard hand.is_valid else {
            perform_next_action(hand_index: next_index)
            return
        }
        
        let text:String = hand.name + ": Stay or Hit? (s/h) [true count=\(true_count(.blackjack(.high_low), facing: [.up]))]"
        let action:String = get_response(text)
        switch action.prefix(1).lowercased() {
        case "s":
            break
        case "h":
            let (card, result):(Card, CardDrawResult) = draw(hand: hand)
            switch result {
            case .blackjack(.busted):
                break
            default:
                next_index = hand_index
                break
            }
            break
        default:
            perform_next_action(hand_index: hand_index)
            return
        }
        perform_next_action(hand_index: next_index)
    }
}

extension Table {
    func get_response(_ string: String) -> String {
        return terminal.ask(ConsoleText(stringLiteral: string))
    }
}
