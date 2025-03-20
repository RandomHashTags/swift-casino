//
//  Player.swift
//
//
//  Created by Evan Anderson on 1/14/24.
//

#if canImport(FoundationEssentials)
import FoundationEssentials
#elseif canImport(Foundation)
import Foundation
#endif

import ConsoleKit

package final class Player : Hashable {
    package static func == (left: Player, right: Player) -> Bool {
        return left.id == right.id
    }
    
    let id:UUID
    let name:String
    
    private(set) var balance:Int
    private(set) var dataBlackjack:BlackjackData
    
    private(set) var terminal:Terminal!
    private(set) var communicationType:PlayerCommunicationType
    
    package init(
        id: UUID = UUID(),
        name: String,
        
        balance: Int,
        dataBlackjack: BlackjackData,
        
        communicationType: PlayerCommunicationType
    ) {
        self.id = id
        self.name = name
        self.balance = balance
        self.dataBlackjack = dataBlackjack
        self.communicationType = communicationType
        setCommunicationType(communicationType)
    }
    
    package func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

extension Player {
    func betPlaced(game: GameType, _ wager: Int) {
        balance -= wager
        switch game {
        case .blackjack:
            dataBlackjack.betPlaced(wager)
        }
    }
    
    func betWon(game: GameType, _ wager: Int) {
        balance += wager
        switch game {
        case .blackjack:
            dataBlackjack.betWon(wager)
        }
    }
    
    func betPushed(game: GameType, _ wager: Int) {
        balance += wager
        switch game {
        case .blackjack:
            dataBlackjack.betPushed(wager)
        }
    }
    
    func betInsured(game: GameType, _ wager: Int) {
        balance -= wager
        switch game {
        case .blackjack:
            dataBlackjack.betInsured(wager)
        }
    }
    
    func betSurrendered(game: GameType, recovered wager: Int) {
        balance += wager
        switch game {
        case .blackjack:
            dataBlackjack.betSurrendered(recovered: wager)
        }
    }
}

private extension Player {
    func terminalAsk(_ string: String) async -> String {
        return await withCheckedContinuation { continuation in
            let response:String = terminal.ask(ConsoleText(stringLiteral: string))
            continuation.resume(returning: response)
        }
    }
}

extension Player {
    func setCommunicationType(_ type: PlayerCommunicationType) {
        communicationType = type
        switch type {
        case .commandLineInterface:
            terminal = Terminal()
        case .userInterface:
            terminal = nil
        }
    }
    
    func ask(_ string: String) async -> String {
        switch communicationType {
        case .commandLineInterface:
            return await terminalAsk(string)
        case .userInterface:
            return "???"
        }
    }
}
