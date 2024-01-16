//
//  Card.swift
//
//
//  Created by Evan Anderson on 1/14/24.
//

import Foundation

package final class Card : Hashable {
    package static func == (left: Card, right: Card) -> Bool {
        return left.id == right.id
    }
    
    let id:UUID
    let number:CardNumber
    var face:CardFace
    
    init(id: UUID = UUID(), number: CardNumber, face: CardFace) {
        self.id = id
        self.number = number
        self.face = face
    }
    
    package func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
