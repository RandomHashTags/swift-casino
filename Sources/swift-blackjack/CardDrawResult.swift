//
//  CardDrawResult.swift
//
//
//  Created by Evan Anderson on 1/14/24.
//

import Foundation

enum CardDrawResult {
    case blackjack(CardDrawResult.Blackjack)
}

extension CardDrawResult {
    enum Blackjack {
        case added
        case busted
        case blackjack
        case twenty_one
    }
}
