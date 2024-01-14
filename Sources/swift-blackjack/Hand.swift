//
//  Hand.swift
//
//
//  Created by Evan Anderson on 1/14/24.
//

import Foundation

package final class Hand : CardHolder, Hashable {
    
    package static func == (left: Hand, right: Hand) -> Bool {
        return left.id == right.id
    }
    
    let id:UUID
    let name:String
    let type:CardHolderType
    var cards:[Card]
    
    package init(id: UUID = UUID(), name: String, type: CardHolderType, cards: [Card]) {
        self.id = id
        self.name = name
        self.type = type
        self.cards = cards
    }
    
    package func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    func scores(game: GameType) -> Set<Int> {
        switch game {
        case .blackjack:
            let aces:Set<Card> = cards.filter_set({ $0.number == .ace })
            if aces.count != 0 {
                let minimum:Int = cards.filter_set({ !aces.contains($0) }).reduce(0, { $0 + $1.number.score(game: game) })
                let aces_count:Int = aces.count
                
                var scores:Set<Int> = [minimum + aces_count]
                for i in 0..<aces_count {
                    let elevens:Int = aces_count - i
                    scores.insert(minimum + (aces_count - elevens) + (elevens * 11))
                }
                return scores
            } else {
                return [ cards.reduce(0, { $0 + $1.number.score(game: game) }) ]
            }
        }
    }
}
