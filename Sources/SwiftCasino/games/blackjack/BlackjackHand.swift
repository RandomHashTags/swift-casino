//
//  BlackjackHand.swift
//
//
//  Created by Evan Anderson on 1/15/24.
//

#if canImport(FoundationEssentials)
import FoundationEssentials
#elseif canImport(Foundation)
import Foundation
#endif

package final class BlackjackHand : CardHolder, Hashable {
    
    package static func == (left: BlackjackHand, right: BlackjackHand) -> Bool {
        return left.id == right.id
    }
    
    let id:UUID
    let player:Player?
    let type:CardHolderType
    var cards:[Card]
    var isValid:Bool
    var allowsMoreCards:Bool
    var isInsured:Bool
    var wagers:[Player:Int]
    
    package init(
        id: UUID = UUID(),
        player: Player?,
        type: CardHolderType,
        cards: [Card] = [],
        isValid: Bool = true,
        allowsMoreCards: Bool = true,
        isInsured: Bool = false,
        wagers: [Player:Int]
    ) {
        self.id = id
        self.player = player
        self.type = type
        self.cards = cards
        self.isValid = isValid
        self.allowsMoreCards = allowsMoreCards
        self.isInsured = isInsured
        self.wagers = wagers
    }
    
    package func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    var name : String {
        return isHouse ? "House" : player!.name + " (hand \(id)"
    }
    var isHouse : Bool {
        return type == .house
    }
    
    func scores() -> Set<Int> {
        let aces:Set<Card> = cards.filterSet({ $0.number == .ace })
        if aces.count != 0 {
            let minimum:Int = cards.filterSet({ !aces.contains($0) }).reduce(0, { $0 + $1.number.score(game: .blackjack) })
            let acesCount:Int = aces.count
            
            var scores:Set<Int> = [minimum + acesCount]
            for i in 0..<acesCount {
                let elevens:Int = acesCount - i
                scores.insert(minimum + (acesCount - elevens) + (elevens * 11))
            }
            return scores
        } else {
            return [ cards.reduce(0, { $0 + $1.number.score(game: .blackjack) }) ]
        }
    }
}

extension BlackjackHand {
    var canSplit : Bool {
        let number:Int = cards[0].number.score(game: .blackjack)
        return cards.allSatisfy({ $0.number.score(game: .blackjack) == number })
    }
}
