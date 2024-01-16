//
//  CasinoGame.swift
//
//
//  Created by Evan Anderson on 1/15/24.
//

import Foundation

protocol CasinoGame {
    var minimum_bet : Int { get }
    var maximum_bet : Int { get }
    
    var players : [Player] { get }
    
    /// `[Player : [wager for hand]]`
    func round_start(wagers: [Player:[Int]])
    func round_end()
}
