//
//  CardDrawResult.swift
//
//
//  Created by Evan Anderson on 1/14/24.
//

enum CardDrawResult {
    case blackjack(CardDrawResult.Blackjack)
}

extension CardDrawResult {
    enum Blackjack {
        case added
        case busted
        case blackjack
        case twentyOne
    }
}
