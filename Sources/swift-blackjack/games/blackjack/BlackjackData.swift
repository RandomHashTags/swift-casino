//
//  BlackjackData.swift
//
//
//  Created by Evan Anderson on 1/15/24.
//

import Foundation

package final class BlackjackData : Codable {
    private(set) var wagered:Int, pushed:Int, surrendered:Int, insured: Int, winnings:Int
    private(set) var bets_placed:Int, bets_won:Int, bets_pushed:Int, bets_insured: Int, bets_surrendered:Int
    
    package init(
        wagered: Int,
        pushed: Int,
        surrendered: Int,
        insured: Int,
        winnings: Int,
        
        bets_placed: Int,
        bets_won: Int,
        bets_pushed: Int,
        bets_insured: Int,
        bets_surrendered: Int
    ) {
        self.wagered = wagered
        self.pushed = pushed
        self.surrendered = surrendered
        self.insured = insured
        self.winnings = winnings
        self.bets_placed = bets_placed
        self.bets_won = bets_won
        self.bets_pushed = bets_pushed
        self.bets_insured = bets_insured
        self.bets_surrendered = bets_surrendered
    }
    
    var lost : Int {
        return wagered - surrendered - winnings
    }
    
    var bets_lost : Int {
        return bets_placed - bets_won - bets_surrendered
    }
    
    func bet_placed(_ wager: Int) {
        wagered += wager
        bets_placed += 1
    }
    
    func bet_won(_ wager: Int) {
        winnings += wager
        bets_won += 1
    }
    
    func bet_pushed(_ wager: Int) {
        pushed += wager
        bets_pushed += 1
    }
    
    func bet_insured(_ wager: Int) {
        insured += wager
        bets_insured += 1
    }
    
    func bet_surrendered(recovered wager: Int) {
        surrendered += wager
        bets_surrendered += 1
    }
}
