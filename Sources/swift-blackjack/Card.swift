//
//  Card.swift
//
//
//  Created by Evan Anderson on 1/14/24.
//

import Foundation

package struct Card : Hashable {
    let id:UUID
    let number:CardNumber
    let face:CardFace
    
    init(id: UUID = UUID(), number: CardNumber, face: CardFace) {
        self.id = id
        self.number = number
        self.face = face
    }
}
