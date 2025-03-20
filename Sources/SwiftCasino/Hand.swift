//
//  Hand.swift
//
//
//  Created by Evan Anderson on 1/14/24.
//

#if canImport(FoundationEssentials)
import FoundationEssentials
#elseif canImport(Foundation)
import Foundation
#endif

package final class Hand : CardHolder, Hashable {
    
    package static func == (left: Hand, right: Hand) -> Bool {
        return left.id == right.id
    }
    
    let id:UUID
    let player:Player?
    let type:CardHolderType
    var cards:[Card]
    var isValid:Bool
    var wagers:[Player:Int]
    
    package init(id: UUID = UUID(), player: Player?, type: CardHolderType, cards: [Card] = [], isValid: Bool = true, wagers: [Player:Int]) {
        self.id = id
        self.player = player
        self.type = type
        self.cards = cards
        self.isValid = isValid
        self.wagers = wagers
    }
    
    package func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    var name : String {
        return isHouse ? "House" : player!.name
    }
    var isHouse : Bool {
        return type == .house
    }
    
    func scores(game: GameType) -> Set<Int> {
        switch game {
        case .blackjack:
            let aces:Set<Card> = cards.filterSet({ $0.number == .ace })
            if aces.count != 0 {
                let minimum:Int = cards.filterSet({ !aces.contains($0) }).reduce(0, { $0 + $1.number.score(game: game) })
                let acesCount:Int = aces.count
                
                var scores:Set<Int> = [minimum + acesCount]
                for i in 0..<acesCount {
                    let elevens:Int = acesCount - i
                    scores.insert(minimum + (acesCount - elevens) + (elevens * 11))
                }
                return scores
            } else {
                return [ cards.reduce(0, { $0 + $1.number.score(game: game) }) ]
            }
        }
    }
}
