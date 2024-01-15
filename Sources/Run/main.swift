//
//  main.swift
//
//
//  Created by Evan Anderson on 1/14/24.
//

import Foundation
import swift_blackjack
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
    Hand(player: nil, type: CardHolderType.house, wager: 0),
]
var players:[Player] = []
for i in 1...player_count {
    let player:Player = Player(name: "Player\(i)", balance: 200)
    players.append(player)
    hands.append(Hand(player: player, type: CardHolderType.player, wager: 0))
}

let table:Table = Table(
    terminal: terminal,
    game: game,
    decks: decks,
    hands: hands
)

table.play_round()
