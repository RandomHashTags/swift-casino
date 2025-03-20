//
//  main.swift
//
//
//  Created by Evan Anderson on 1/14/24.
//

import SwiftCasino
import ConsoleKitTerminal

let terminal:Terminal = Terminal()

let game:GameType = GameType.blackjack

let deckCount:Int = Int(terminal.ask("How many decks?"))!
var decks:[Deck] = [Deck]()
for _ in 0..<deckCount {
    decks.append(Deck.normal)
}

let playerCount:Int = Int(terminal.ask("How many players?"))!

var hands:[Hand] = [
    Hand(player: nil, type: CardHolderType.house, wagers: [:]),
]
var players:[Player] = []
var wagers:[Player:[Int]] = [:]
for i in 1...playerCount {
    let player:Player = Player(
        name: "Player\(i)",
        balance: 200,
        dataBlackjack: BlackjackData(
            wagered: 0,
            pushed: 0,
            surrendered: 0,
            insured: 0,
            winnings: 0,
            betsPlaced: 0,
            betsWon: 0,
            betsPushed: 0,
            betsInsured: 0,
            betsSurrendered: 0
        ),
        communicationType: PlayerCommunicationType.commandLineInterface
    )
    players.append(player)
    wagers[player] = [1]
}

let blackjack:Blackjack = Blackjack(decks: decks, players: players)
blackjack.roundStart(wagers: wagers)
