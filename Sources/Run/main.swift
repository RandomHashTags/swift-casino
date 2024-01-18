//
//  main.swift
//
//
//  Created by Evan Anderson on 1/14/24.
//

import Foundation
import SwiftCasino
import ConsoleKitTerminal

let terminal:Terminal = Terminal()

let game:GameType = GameType.blackjack

let deck_count:Int = Int(terminal.ask("How many decks?"))!
var decks:[Deck] = [Deck]()
for _ in 0..<deck_count {
    decks.append(Deck.normal)
}

let player_count:Int = Int(terminal.ask("How many players?"))!

var hands:[Hand] = [
    Hand(player: nil, type: CardHolderType.house, wagers: [:]),
]
var players:[Player] = []
var wagers:[Player:[Int]] = [:]
for i in 1...player_count {
    let player:Player = Player(
        name: "Player\(i)",
        balance: 200,
        data_blackjack: BlackjackData(
            wagered: 0,
            pushed: 0,
            surrendered: 0,
            insured: 0,
            winnings: 0,
            bets_placed: 0,
            bets_won: 0,
            bets_pushed: 0,
            bets_insured: 0,
            bets_surrendered: 0
        ),
        communication_type: PlayerCommunicationType.command_line_interface
    )
    players.append(player)
    wagers[player] = [1]
}

let blackjack:Blackjack = Blackjack(decks: decks, players: players)
blackjack.round_start(wagers: wagers)
