//
//  Deck.swift
//
//
//  Created by Evan Anderson on 1/14/24.
//

package struct Deck {
    let cards:[Card]
}

package extension Deck {
    static let normal : Deck = {
        let cards:[Card] = CardNumber.allCases.flatMap({ number in
            let card:Card = Card(number: number, face: CardFace.down)
            return (0..<4).map({ _ in card })
        })
        return Deck(cards: cards)
    }()
}
