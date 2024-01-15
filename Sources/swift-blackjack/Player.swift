//
//  Player.swift
//
//
//  Created by Evan Anderson on 1/14/24.
//

import Foundation

package final class Player : Hashable {
    package static func == (left: Player, right: Player) -> Bool {
        return left.id == right.id
    }
    
    let id:UUID
    let name:String
    private(set) var balance:Int
    
    package init(id: UUID = UUID(), name: String, balance: Int) {
        self.id = id
        self.name = name
        self.balance = balance
    }
    
    package func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
