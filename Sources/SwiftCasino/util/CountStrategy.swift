//
//  CountStrategy.swift
//  
//
//  Created by Evan Anderson on 1/14/24.
//

enum CountStrategy : Hashable, CountStrategyProtocol {
    static let allCases: [CountStrategy] = {
        return [
            CountStrategy.blackjack(.highLow),
            CountStrategy.blackjack(.omegaII)
        ]
    }()
    
    case blackjack(CountStrategy.Blackjack)
    
    func count(_ cards: [Card], facing: Set<CardFace>) -> Float {
        switch self {
        case .blackjack(let blackjackStrategy):
            return blackjackStrategy.count(cards, facing: facing)
        }
    }
}

protocol CountStrategyProtocol : CaseIterable {
    func count(_ cards: [Card], facing: Set<CardFace>) -> Float
}

extension CountStrategy {
    enum Blackjack : CountStrategyProtocol {
        case highLow
        case omegaII
        case wongHalves
        
        func count(_ cards: [Card], facing: Set<CardFace>) -> Float {
            let cards:[Card] = cards.filter({ facing.contains($0.face) })
            switch self {
            case .highLow:
                var value:Float = 0
                for card in cards {
                    let numberValue:Float
                    switch card.number {
                    case .ace, .jack, .queen, .king:
                        numberValue = -1
                    case .two, .three, .four, .five, .six:
                        numberValue = 1
                    default:
                        numberValue = 0
                    }
                    value += numberValue
                }
                return value
            case .omegaII:
                var value:Float = 0
                for card in cards {
                    let numberValue:Float
                    switch card.number {
                    case .two, .three, .seven:
                        numberValue = 1
                    case .four, .five, .six:
                        numberValue = 2
                    case .nine:
                        numberValue = -1
                    case .eight, .ace:
                        numberValue = 0
                    default:
                        numberValue = -2
                    }
                    value += numberValue
                }
                return value
            case .wongHalves:
                var value:Float = 0
                for card in cards {
                    let numberValue:Float
                    switch card.number {
                    case .three, .four, .six:
                        numberValue = 1
                    case .two, .seven:
                        numberValue = 0.5
                    case .five:
                        numberValue = 1.5
                    case .eight:
                        numberValue = 0
                    case .nine:
                        numberValue = -0.5
                    default:
                        numberValue = -1
                    }
                    value += numberValue
                }
                return value
            }
        }
    }
}
