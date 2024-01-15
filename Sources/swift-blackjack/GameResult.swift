//
//  GameResult.swift
//
//
//  Created by Evan Anderson on 1/15/24.
//

import Foundation

enum GameResult {
    case blackjack(GameResult.Blackjack)
}

extension GameResult {
    enum Blackjack {
        case won
        case lost
        case push
    }
}
