//
//  BlackjackAction.swift
//
//
//  Created by Evan Anderson on 1/15/24.
//

enum BlackjackAction {
    case hit
    case stay
    
    case insurance
    case surrender
    case split
    case doubleDown
    
    var keyboardPrimary : Character {
        switch self {
        case .hit: return "1"
        case .stay: return "2"
            
        case .doubleDown: return "4"
        case .split: return "5"
        case .insurance: return "6"
        
        case .surrender: return "0"
        }
    }
}
