//
//  BlackjackData.swift
//
//
//  Created by Evan Anderson on 1/15/24.
//

package final class BlackjackData : Codable {
    private(set) var wagered:Int, pushed:Int, surrendered:Int, insured: Int, winnings:Int
    private(set) var betsPlaced:Int, betsWon:Int, betsPushed:Int, betsInsured: Int, betsSurrendered:Int
    
    package init(
        wagered: Int,
        pushed: Int,
        surrendered: Int,
        insured: Int,
        winnings: Int,
        
        betsPlaced: Int,
        betsWon: Int,
        betsPushed: Int,
        betsInsured: Int,
        betsSurrendered: Int
    ) {
        self.wagered = wagered
        self.pushed = pushed
        self.surrendered = surrendered
        self.insured = insured
        self.winnings = winnings
        self.betsPlaced = betsPlaced
        self.betsWon = betsWon
        self.betsPushed = betsPushed
        self.betsInsured = betsInsured
        self.betsSurrendered = betsSurrendered
    }
    
    var lost : Int {
        return wagered - surrendered - winnings
    }
    
    var betsLost : Int {
        return betsPlaced - betsWon - betsSurrendered
    }
    
    func betPlaced(_ wager: Int) {
        wagered += wager
        betsPlaced += 1
    }
    
    func betWon(_ wager: Int) {
        winnings += wager
        betsWon += 1
    }
    
    func betPushed(_ wager: Int) {
        pushed += wager
        betsPushed += 1
    }
    
    func betInsured(_ wager: Int) {
        insured += wager
        betsInsured += 1
    }
    
    func betSurrendered(recovered wager: Int) {
        surrendered += wager
        betsSurrendered += 1
    }
}
