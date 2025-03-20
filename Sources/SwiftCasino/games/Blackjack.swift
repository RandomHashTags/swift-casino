//
//  Blackjack.swift
//  
//
//  Created by Evan Anderson on 1/15/24.
//

package final class Blackjack : CasinoGame, CardCountable {
    var minimumBet : Int { 1 }
    var maximumBet : Int { 100 }
    
    private(set) var numberOfDecks:Int
    private(set) var unplayed:[Card]
    private(set) var discarded:[Card]
    
    let house:BlackjackHand = BlackjackHand(player: nil, type: CardHolderType.house, wagers: [:])
    
    var players:[Player]
    private(set) var activeHandIndex:Int
    var hands:[BlackjackHand]
    
    package init(decks: [Deck], players: [Player]) {
        numberOfDecks = decks.count
        unplayed = decks.flatMap({ $0.cards }).shuffled()
        discarded = []
        
        self.players = players
        activeHandIndex = 0
        self.hands = []
    }
    
    var inPlay : [Card] {
        return hands.flatMap({ $0.cards })
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
extension Blackjack {
    func drawForEveryone() {
        for hand in hands {
            let (card, result):(Card, BlackjackCardDrawResult) = draw(hand: hand)
        }
    }
    
    var activeHand : BlackjackHand {
        return hands[activeHandIndex]
    }

    func reset() {
        for hand in hands {
            discard(hand)
        }
        hands.removeAll()
        house.isValid = true
    }
    func discard(_ hand: BlackjackHand) {
        for card in hand.cards {
            card.face = .up
        }
        discarded.append(contentsOf: hand.cards)
        hand.cards = []
        hand.isValid = false
    }
}

extension Blackjack {
    func getNextHand() -> (index: Int, hand: BlackjackHand) {
        var nextIndex:Int = activeHandIndex + 1
        let handsCount:Int = hands.count
        nextIndex = nextIndex >= handsCount ? 0 : nextIndex
        while nextIndex != 0 && nextIndex < handsCount {
            let hand:BlackjackHand = hands[nextIndex]
            if hand.isValid && hand.allowsMoreCards {
                break
            }
            nextIndex += 1
        }
        return (nextIndex, hands[nextIndex])
    }
    func nextHand() {
        let (index, hand):(Int, BlackjackHand) = getNextHand()
        activeHandIndex = index
        
        guard let player = hand.player else { return }
        Task {
            await processPlayerAction(player: player)
        }
    }
    func processPlayerAction(player: Player) async -> BlackjackCardDrawResult? {
        let action:String = await player.ask("NEXT ACTION??")
        return performAction(player: player, action: BlackjackAction.stay, wager: 0)
    }
    
    func performAction(player: Player, action: BlackjackAction, wager: Int) -> BlackjackCardDrawResult? {
        let hand:BlackjackHand = activeHand
        
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
            case .twentyOne:
                twentyOne(hand)
                return .twentyOne
            case .busted:
                busted(hand)
                return .busted
            default:
                return .added
            }
            
        case .insurance:
            insurance(hand)
        case .surrender:
            surrender(hand)
        case .split:
            split(hand)
        case .doubleDown:
            doubleDown(player: player, wager: wager, hand: hand)
            return .doubledDown
        }
        return nil
    }
    
    func blackjack(_ hand: BlackjackHand) {
        nextHand()
    }
    func twentyOne(_ hand: BlackjackHand) {
        nextHand()
    }
    func stay(_ hand: BlackjackHand) {
        nextHand()
    }
    func busted(_ hand: BlackjackHand) {
        discard(hand)
        nextHand()
    }
    func insurance(_ hand: BlackjackHand) {
        guard house.cards.first(where: { $0.number == .ace && $0.face == .up }) != nil, !hand.isInsured else { return }
        let player:Player = hand.player!
        
        hand.isInsured = true
        hand.player!.betInsured(game: .blackjack, hand.wagers[player]!)
    }
    func surrender(_ hand: BlackjackHand) {
        for (player, wager) in hand.wagers {
            player.betSurrendered(game: .blackjack, recovered: wager/2)
        }
        discard(hand)
        nextHand()
    }
    func split(_ hand: BlackjackHand) {
        guard hand.canSplit, let player:Player = hand.player, let wager:Int = hand.wagers[player] else { return }
        
        let card:Card = hand.cards.removeLast()
        let hand:BlackjackHand = BlackjackHand(player: player, type: hand.type, cards: [card], wagers: hand.wagers)
        
        player.betPlaced(game: .blackjack, wager)
        hands.insert(hand, at: activeHandIndex)
        
        print(hand.name + " split")
        let (_, _):(Card, BlackjackCardDrawResult) = draw(hand: hand)
        let (_, _):(Card, BlackjackCardDrawResult) = draw(hand: hands[activeHandIndex+1])
    }
    func doubleDown(player: Player, wager: Int, hand: BlackjackHand) {
        guard hand.allowsMoreCards else { return }
        
        let (_, _):(Card, BlackjackCardDrawResult) = draw(hand: hand)
        hand.allowsMoreCards = false
        if hand.wagers[player] == nil {
            hand.wagers[player] = wager
        } else {
            hand.wagers[player]! += wager
        }
    }
}
extension Blackjack {
    func incorporateDiscarded() {
        print("Blackjack;incorporateDiscarded;shuffled in the discarded cards")
        unplayed.append(contentsOf: discarded)
        unplayed.shuffle()
        discarded = []
    }
    
    func draw(hand: BlackjackHand) -> (card: Card, result: BlackjackCardDrawResult) {
        if unplayed.isEmpty {
            incorporateDiscarded()
        }
        
        let card:Card = unplayed.removeFirst()
        card.face = .up
        hand.cards.append(card)
        
        var string:String
        let scores:Set<Int> = hand.scores()
        let drewString:String = hand.name + " drew: " + card.number.name + ". Scores: \(scores)."
        if hand.isHouse {
            switch hand.cards.count {
            case 2:
                card.face = .down
                string = hand.name + " drew: *UNKNOWN*."
            case 3:
                revealHouse()
                fallthrough
            default:
                string = drewString
                break
            }
        } else {
            string = drewString
        }
        
        let result:BlackjackCardDrawResult
        if scores.contains(21) {
            if hand.cards.count == 2 {
                string += " (blackjack!)"
                result = .blackjack
            } else {
                string += " (21!)"
                result = .twentyOne
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
    
    private func revealHouse() {
        guard house.cards[1].face == .down else { return }
        house.cards[1].face = .up
        print(house.name + " revealed: " + house.cards[1].number.name + ".")
    }
}

extension Blackjack {
    package func roundStart(wagers: [Player:[Int]]) {
        activeHandIndex = 0
        hands = [house]
        
        for (player, playerWagers) in wagers {
            for playerWager in playerWagers {
                let hand:BlackjackHand = BlackjackHand(player: player, type: CardHolderType.player, wagers: [player : playerWager])
                player.betPlaced(game: .blackjack, playerWager)
                hands.append(hand)
            }
        }
        drawForEveryone()
        drawForEveryone()
        
        if house.scores().contains(21) {
            print("House drew blackjack!")
            roundEnd()
        }
    }
}

extension Blackjack {
    func roundEnd() {
        let hands:[BlackjackHand] = hands.filter({ $0.type != .house && $0.isValid })
        
        let house:BlackjackHand = house
        if house.isValid {
            // check who won, lost, and pushed
            let maxHouseScore:Int = house.scores().filter({ $0 <= 21 }).max()!
            
            var validHandResults:[BlackjackHand:GameResult.Blackjack] = [:]
            for hand in hands {
                let score:Int = hand.scores().filter({ $0 <= 21 }).max()!
                validHandResults[hand] = score == maxHouseScore ? .push : score < maxHouseScore ? .lost : .won
            }
            
            let winningHands:[BlackjackHand:GameResult.Blackjack] = validHandResults.filter({ $0.value == .won })
            for (hand, _) in winningHands {
                print("hand " + hand.name + " WON with > score of \(maxHouseScore)")
                for (player, wager) in hand.wagers {
                    player.betWon(game: .blackjack, wager)
                }
            }
            
            let pushedHands:[BlackjackHand:GameResult.Blackjack] = validHandResults.filter({ $0.value == .push })
            for (hand, _) in pushedHands {
                print("hand " + hand.name + " PUSHED with == score of \(maxHouseScore)")
                for (player, wager) in hand.wagers {
                    player.betPushed(game: .blackjack, wager)
                }
            }
            
            let losingHands:[BlackjackHand:GameResult.Blackjack] = validHandResults.filter({ $0.value == .lost })
            for (hand, _) in losingHands {
                print("hand " + hand.name + " LOST with < score of \(maxHouseScore)")
            }
        } else {
            // every valid hand won
            for hand in hands {
                print("hand " + hand.name + " WON due to house busting")
                for (player, wager) in hand.wagers {
                    player.betWon(game: .blackjack, wager)
                }
            }
        }
        reset()
    }
}
