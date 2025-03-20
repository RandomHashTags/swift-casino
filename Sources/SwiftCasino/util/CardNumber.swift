//
//  CardNumber.swift
//
//
//  Created by Evan Anderson on 1/14/24.
//

enum CardNumber : Int, CaseIterable {
    case ace = 1
    case two
    case three
    case four
    case five
    case six
    case seven
    case eight
    case nine
    case ten
    case jack
    case queen
    case king
    
    var name : String {
        let string:String = "\(self)"
        return string[string.startIndex].uppercased() + string[string.index(after: string.startIndex)...].lowercased()
    }
    
    func score(game: GameType) -> Int {
        switch game {
        case .blackjack:
            switch self {
            case .jack, .queen, .king: return 10
            default: return rawValue
            }
        }
    }
    
    func scores(game: GameType) -> Set<Int> {
        switch self {
        case .ace: return [1, 11]
        default: return [score(game: game)]
        }
    }
}
