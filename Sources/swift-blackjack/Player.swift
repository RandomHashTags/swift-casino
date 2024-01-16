//
//  Player.swift
//
//
//  Created by Evan Anderson on 1/14/24.
//

import Foundation
import ConsoleKit

package final class Player : Hashable {
    package static func == (left: Player, right: Player) -> Bool {
        return left.id == right.id
    }
    
    let id:UUID
    let name:String
    
    private(set) var balance:Int
    private(set) var data_blackjack:BlackjackData
    
    var communication_type:PlayerCommunicationType
    
    package init(
        id: UUID = UUID(),
        name: String,
        
        balance: Int,
        data_blackjack: BlackjackData,
        
        communication_type: PlayerCommunicationType
    ) {
        self.id = id
        self.name = name
        self.balance = balance
        self.data_blackjack = data_blackjack
        self.communication_type = communication_type
    }
    
    package func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

extension Player {
    func bet_placed(game: GameType, _ wager: Int) {
        balance -= wager
        switch game {
        case .blackjack:
            data_blackjack.bet_placed(wager)
            break
        }
    }
    
    func bet_won(game: GameType, _ wager: Int) {
        balance += wager
        switch game {
        case .blackjack:
            data_blackjack.bet_won(wager)
            break
        }
    }
    
    func bet_pushed(game: GameType, _ wager: Int) {
        balance += wager
        switch game {
        case .blackjack:
            data_blackjack.bet_pushed(wager)
            break
        }
    }
    
    func bet_insured(game: GameType, _ wager: Int) {
        balance -= wager
        switch game {
        case .blackjack:
            data_blackjack.bet_insured(wager)
            break
        }
    }
    
    func bet_surrendered(game: GameType, recovered wager: Int) {
        balance += wager
        switch game {
        case .blackjack:
            data_blackjack.bet_surrendered(recovered: wager)
            break
        }
    }
}

extension Player {
    func prompt(test: String, response: @escaping (String) -> Void) {
        switch communication_type {
        case .command_line_interface:
            break
        case .user_interface:
            break
        }
    }
}
