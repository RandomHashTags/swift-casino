//
//  CountStrategy.swift
//  
//
//  Created by Evan Anderson on 1/14/24.
//

import Foundation

enum CountStrategy : Hashable, CountStrategyProtocol {
    static let allCases: [CountStrategy] = {
        return [
            CountStrategy.blackjack(.high_low),
            CountStrategy.blackjack(.omega_ii)
        ]
    }()
    
    case blackjack(CountStrategy.Blackjack)
    
    func count(_ cards: [Card]) -> Float {
        switch self {
        case .blackjack(let blackjack_strategy):
            return blackjack_strategy.count(cards)
        }
    }
}

protocol CountStrategyProtocol : CaseIterable {
    func count(_ cards: [Card]) -> Float
}

extension CountStrategy {
    enum Blackjack : CountStrategyProtocol {
        case high_low
        case omega_ii
        case wong_halves
        
        func count(_ cards: [Card]) -> Float {
            switch self {
            case .high_low:
                var value:Float = 0
                for card in cards {
                    let number_value:Float
                    switch card.number {
                    case .ace, .jack, .queen, .king:
                        number_value = -1
                        break
                    case .two, .three, .four, .five, .six:
                        number_value = 1
                        break
                    default:
                        number_value = 0
                        break
                    }
                    value += number_value
                }
                return value
            case .omega_ii:
                var value:Float = 0
                for card in cards {
                    let number_value:Float
                    switch card.number {
                    case .two, .three, .seven:
                        number_value = 1
                        break
                    case .four, .five, .six:
                        number_value = 2
                        break
                    case .nine:
                        number_value = -1
                        break
                    case .eight, .ace:
                        number_value = 0
                        break
                    default:
                        number_value = -2
                        break
                    }
                    value += number_value
                }
                return value
            case .wong_halves:
                var value:Float = 0
                for card in cards {
                    let number_value:Float
                    switch card.number {
                    case .three, .four, .six:
                        number_value = 1
                        break
                    case .two, .seven:
                        number_value = 0.5
                        break
                    case .five:
                        number_value = 1.5
                        break
                    case .eight:
                        number_value = 0
                        break
                    case .nine:
                        number_value = -0.5
                        break
                    default:
                        number_value = -1
                        break
                    }
                    value += number_value
                }
                return value
            }
        }
    }
}
