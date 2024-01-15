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
    Hand(name: "House", type: CardHolderType.house, wager: 0),
]
for i in 1...player_count {
    hands.append(Hand(name: "Player\(i)", type: CardHolderType.player, wager: 0))
}

let table:Table = Table(
    terminal: terminal,
    game: game,
    decks: decks,
    hands: hands
)

table.play_round()
