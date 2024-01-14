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
            if unplayed.isEmpty {
                reset()
            }
            
            let card:Card = unplayed.removeFirst()
            hand.cards.append(card)
            
            print(hand.name + " drew: " + card.number.name + " (scores: \(hand.scores(game: game)))")
        }
    }
    
    func draw(hand: Hand) -> (card: Card, result: CardDrawResult) {
        if unplayed.isEmpty {
            reset()
        }
        
        let card:Card = unplayed.removeFirst()
        hand.cards.append(card)
        
        let scores:Set<Int> = hand.scores(game: game)
        var string:String = hand.name + " drew: " + card.number.name + " (scores: \(scores))"
        
        var result:CardDrawResult
        switch game {
        case .blackjack:
            result = .blackjack(.added)
            if scores.contains(21) {
                string += " (blackjack!)"
            } else if scores.min() ?? 21 > 21 {
                string += " (busted!)"
                discard(hand: hand)
                result = .blackjack(.busted)
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
        
        let acceptable_responses:Set<String> = ["y", "yes", "no", "n"]
        let question:String = "Play another round? (yes/no [y/n])"
        var response:String = terminal.ask(ConsoleText(stringLiteral: question)).lowercased()
        while !acceptable_responses.contains(response) {
            response = terminal.ask(ConsoleText(stringLiteral: question)).lowercased()
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
        guard hand.type != .house else { return }
        discarded.append(contentsOf: hand.cards)
        guard let index:Int = hands.firstIndex(where: { $0 == hand }) else { return }
        hands.remove(at: index)
    }
    func discard() {
        for hand in hands {
            discarded.append(contentsOf: hand.cards)
            hand.cards = []
        }
    }
    
    func running_count(_ strategy: CountStrategy) -> Float {
        return strategy.count(in_play) + strategy.count(discarded)
    }
    func true_count(_ strategy: CountStrategy) -> Float {
        return running_count(strategy) / Float(number_of_decks)
    }
    func count(_ strategy: CountStrategy, type: DeckType) -> Float {
        switch type {
        case .unplayed: return strategy.count(unplayed)
        case .in_play: return strategy.count(in_play)
        case .discarded: return strategy.count(discarded)
        }
    }
}

extension Table {
    func end_round_blackjack() {
        let house_scores:Set<Int> = hands[0].scores(game: game)
        let non_house_hands:Set<Hand> = hands.filter_set({ $0.type != .house })
        if house_scores.min() ?? 21 > 21 { // house busted
            // everyone that didn't bust, wins
            for hand in non_house_hands {
                print("hand " + hand.name + " WON due to house busting")
            }
        } else if let max_house_score:Int = house_scores.filter({ $0 <= 21 }).max() {
            // everyone that didn't bust, and has a score equal to or greater than house wins
            let winning_hands:Set<Hand> = non_house_hands.filter({ $0.scores(game: game).count(where: { $0 <= 21 && $0 >= max_house_score }) > 0 })
            for hand in winning_hands {
                print("hand " + hand.name + " WON with >= score of \(max_house_score)")
            }
            let losing_hands:Set<Hand> = non_house_hands.filter_set({ !winning_hands.contains($0) })
            for hand in losing_hands {
                print("hand " + hand.name + " LOST with < score of \(max_house_score)")
            }
        }
    }
}

package extension Table {
    func play_round() {
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
        guard let hand:Hand = hands.get(hand_index) else { return }
        guard hand.type != .house else {
            let scores:Set<Int> = hand.scores(game: game)
            switch game {
            case .blackjack:
                if scores.first(where: { $0 >= 17 }) != nil {
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
        let text:String = hand.name + ": Stay or Hit? (s/h) [true count=\(true_count(.blackjack(.high_low)))]"
        let action:String = terminal.ask(ConsoleText(stringLiteral: text))
        
        var next_index:Int = (hand_index + 1) % hands.count
        switch action.prefix(1).lowercased() {
        case "s":
            break
        case "h":
            let (card, result):(Card, CardDrawResult) = draw(hand: hand)
            switch result {
            case .blackjack(.busted):
                next_index = hand_index
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
