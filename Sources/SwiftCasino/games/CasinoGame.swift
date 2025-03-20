//
//  CasinoGame.swift
//
//
//  Created by Evan Anderson on 1/15/24.
//

protocol CasinoGame {
    var minimumBet : Int { get }
    var maximumBet : Int { get }
    
    var players : [Player] { get }
    
    /// `[Player : [wager for hand]]`
    func roundStart(wagers: [Player:[Int]])
    func roundEnd()
}
