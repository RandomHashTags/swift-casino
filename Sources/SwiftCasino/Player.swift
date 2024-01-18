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
    
    private(set) var terminal:Terminal!
    private(set) var communication_type:PlayerCommunicationType
    
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
        set_communication_type(communication_type)
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

private extension Player {
    func terminal_ask(_ string: String) async -> String {
        return await withCheckedContinuation { continuation in
            let response:String = terminal.ask(ConsoleText(stringLiteral: string))
            continuation.resume(returning: response)
        }
    }
}

extension Player {
    func set_communication_type(_ type: PlayerCommunicationType) {
        communication_type = type
        switch type {
        case .command_line_interface:
            terminal = Terminal()
            break
        case .user_interface:
            terminal = nil
            break
        }
    }
    
    func ask(_ string: String) async -> String {
        switch communication_type {
        case .command_line_interface:
            return await terminal_ask(string)
        case .user_interface:
            return "???"
        }
    }
}
