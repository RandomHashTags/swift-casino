//
//  Table.swift
//
//
//  Created by Evan Anderson on 1/14/24.
//

import ConsoleKit

package final class Table {
    
    let terminal:Terminal
    private(set) var game:GameType
    private(set) var numberOfDecks:Int
    private(set) var unplayed:[Card]
    private(set) var discarded:[Card]
    
    /// [player : number of hands]
    private(set) var players:[Player:Int]
    private(set) var hands:[Hand]
    
    package init(terminal: Terminal, game: GameType, decks: [Deck], players: [Player:Int]) {
        self.terminal = terminal
        self.game = game
        self.unplayed = decks.flatMap({ $0.cards })
        numberOfDecks = decks.count
        self.players = players
        self.discarded = []
        self.hands = []
    }
    
    var inPlay : [Card] {
        return hands.flatMap({ $0.cards })
    }
    
    
    func reset() {
        print("shuffled in the discarded cards")
        unplayed.append(contentsOf: discarded)
        unplayed.shuffle()
        discarded = []
    }
    
    func drawForEveryone() {
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
            let drewString:String = hand.name + " drew: " + card.number.name + ". Scores: \(scores)."
            if hand.isHouse {
                switch hand.cards.count {
                case 2:
                    card.face = .down
                    string = hand.name + " drew: *UNKNOWN*."
                case 3:
                    blackjackRevealHouse()
                    fallthrough
                default:
                    string = drewString
                    break
                }
            } else {
                string = drewString
            }
            
            if scores.contains(21) {
                if hand.cards.count == 2 {
                    string += " (blackjack!)"
                    result = .blackjack(.blackjack)
                } else {
                    string += " (21!)"
                    result = .blackjack(.twentyOne)
                }
            } else if scores.min() ?? 21 > 21 {
                string += " (busted!)"
                discard(hand: hand)
                result = .blackjack(.busted)
            } else {
                result = .blackjack(.added)
            }
        }
        print(string)
        return (card, result)
    }
    
    func endRound() {
        switch game {
        case .blackjack:
            endRoundBlackjack()
        }
        
        discard()
        askToPlayAnotherRound()
    }
    func askToPlayAnotherRound() {
        let acceptableResponses:Set<String> = ["yes", "y", "no", "n"]
        let question:String = "\nPlay another round? [y/n]"
        var response:String = getResponse(question).lowercased()
        while !acceptableResponses.contains(response) {
            response = getResponse(question).lowercased()
        }
        switch response {
        case "yes", "y":
            playRound()
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
    }
    func discard() {
        for hand in hands.filter({ $0.isValid }) {
            discard(hand: hand)
        }
    }
    
    func runningCount(_ strategy: CountStrategy, facing: Set<CardFace>) -> Float {
        return strategy.count(inPlay, facing: facing) + strategy.count(discarded, facing: [.down, .up])
    }
    func trueCount(_ strategy: CountStrategy, facing: Set<CardFace>) -> Float {
        return runningCount(strategy, facing: facing) / Float(numberOfDecks)
    }
    func count(_ strategy: CountStrategy, type: DeckType) -> Float {
        switch type {
        case .unplayed:  return strategy.count(unplayed, facing: [.up])
        case .inPlay:    return strategy.count(inPlay, facing: [.up])
        case .discarded: return strategy.count(discarded, facing: [.up])
        }
    }
}

extension Table {
    private func blackjackRevealHouse() {
        let hand:Hand = hands[0]
        guard hand.cards[1].face == .down else { return }
        hand.cards[1].face = .up
        print(hand.name + " revealed: " + hand.cards[1].number.name + ".")
    }
    func endRoundBlackjack() {
        let house:Hand = hands[0]
        // everyone that didn't bust, and not house
        let validHands:Set<Hand> = hands.filterSet({ $0.type != .house && $0.isValid })
        if house.isValid {
            // check who won, lost, and pushed
            let houseScores:Set<Int> = house.scores(game: game)
            let maxHouseScore:Int = houseScores.filter({ $0 <= 21 }).max()!
            
            var validHandResults:[Hand:GameResult.Blackjack] = [:]
            for hand in validHands {
                let score:Int = hand.scores(game: game).filter({ $0 <= 21 }).max()!
                validHandResults[hand] = score == maxHouseScore ? .push : score < maxHouseScore ? .lost : .won
            }
            
            let winningHands:[Hand:GameResult.Blackjack] = validHandResults.filter({ $0.value == .won })
            for (hand, _) in winningHands {
                print("hand " + hand.name + " WON with > score of \(maxHouseScore)")
            }
            
            let pushedHands:[Hand:GameResult.Blackjack] = validHandResults.filter({ $0.value == .push })
            for (hand, _) in pushedHands {
                print("hand " + hand.name + " PUSHED with == score of \(maxHouseScore)")
            }
            
            let losingHands:[Hand:GameResult.Blackjack] = validHandResults.filter({ $0.value == .lost })
            for (hand, _) in losingHands {
                print("hand " + hand.name + " LOST with < score of \(maxHouseScore)")
            }
        } else {
            // every valid hand won
            for hand in validHands {
                print("hand " + hand.name + " WON due to house busting")
            }
        }
    }
}

package extension Table {
    func playRound() {
        hands.removeAll()
        for (player, number_of_hands) in players {
            for _ in 0..<number_of_hands {
                let hand:Hand = Hand(player: player, type: CardHolderType.player, wagers: [player : 0])
                hands.append(hand)
            }
        }
        guard let playerIndex:Int = hands.firstIndex(where: { $0.type != .house }) else {
            print("need at least one player to play")
            return
        }
        unplayed.shuffle()
        
        switch game {
        case .blackjack:
            drawForEveryone()
            drawForEveryone()
            
            if hands[0].scores(game: game).contains(21) {
                print("House drew blackjack!")
                endRound()
                return
            }
        }
        performNextAction(handIndex: playerIndex)
    }
    
    private func performNextAction(handIndex: Int) {
        if hands.count == 1 && hands[0].isHouse {
            askToPlayAnotherRound()
            return
        }
        
        let hand:Hand = hands[handIndex]
        guard hand.type != .house else {
            let scores:Set<Int> = hand.scores(game: game)
            switch game {
            case .blackjack:
                if scores.first(where: { $0 >= 17 && $0 <= 21 }) != nil {
                    blackjackRevealHouse()
                    endRound()
                } else {
                    let (card, result):(Card, CardDrawResult) = draw(hand: hand)
                    switch result {
                    case .blackjack(.busted):
                        endRound()
                    default:
                        performNextAction(handIndex: handIndex)
                    }
                }
            }
            return
        }
        var nextIndex:Int = (handIndex + 1) % hands.count
        guard hand.isValid else {
            performNextAction(handIndex: nextIndex)
            return
        }
        
        let text:String = hand.name + ": Stay or Hit? (s/h) [true count=\(trueCount(.blackjack(.highLow), facing: [.up]))]"
        let action:String = getResponse(text)
        switch action.prefix(1).lowercased() {
        case "s":
            break
        case "h":
            let (card, result):(Card, CardDrawResult) = draw(hand: hand)
            switch result {
            case .blackjack(.busted):
                break
            default:
                nextIndex = handIndex
            }
        default:
            performNextAction(handIndex: handIndex)
        }
        performNextAction(handIndex: nextIndex)
    }
}

extension Table {
    func getResponse(_ string: String) -> String {
        return terminal.ask(ConsoleText(stringLiteral: string))
    }
}
