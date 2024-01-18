//
//  BlackjackHand.swift
//
//
//  Created by Evan Anderson on 1/15/24.
//

import Foundation

package final class BlackjackHand : CardHolder, Hashable {
    
    package static func == (left: BlackjackHand, right: BlackjackHand) -> Bool {
        return left.id == right.id
    }
    
    let id:UUID
    let player:Player?
    let type:CardHolderType
    var cards:[Card]
    var is_valid:Bool
    var allows_more_cards:Bool
    var is_insured:Bool
    var wagers:[Player:Int]
    
    package init(
        id: UUID = UUID(),
        player: Player?,
        type: CardHolderType,
        cards: [Card] = [],
        is_valid: Bool = true,
        allows_more_cards: Bool = true,
        is_insured: Bool = false,
        wagers: [Player:Int]
    ) {
        self.id = id
        self.player = player
        self.type = type
        self.cards = cards
        self.is_valid = is_valid
        self.allows_more_cards = allows_more_cards
        self.is_insured = is_insured
        self.wagers = wagers
    }
    
    package func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    var name : String {
        return is_house ? "House" : player!.name + " (hand \(id)"
    }
    var is_house : Bool {
        return type == .house
    }
    
    func scores() -> Set<Int> {
        let aces:Set<Card> = cards.filter_set({ $0.number == .ace })
        if aces.count != 0 {
            let minimum:Int = cards.filter_set({ !aces.contains($0) }).reduce(0, { $0 + $1.number.score(game: .blackjack) })
            let aces_count:Int = aces.count
            
            var scores:Set<Int> = [minimum + aces_count]
            for i in 0..<aces_count {
                let elevens:Int = aces_count - i
                scores.insert(minimum + (aces_count - elevens) + (elevens * 11))
            }
            return scores
        } else {
            return [ cards.reduce(0, { $0 + $1.number.score(game: .blackjack) }) ]
        }
    }
}

extension BlackjackHand {
    var can_split : Bool {
        let number:Int = cards[0].number.score(game: .blackjack)
        return cards.allSatisfy({ $0.number.score(game: .blackjack) == number })
    }
}
