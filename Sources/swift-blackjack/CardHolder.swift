//
//  CardHolder.swift
//
//
//  Created by Evan Anderson on 1/14/24.
//

import Foundation

protocol CardHolder {
    var cards : [Card] { get set }
    
    func count(_ strategy: CountStrategy) -> Float
}

extension CardHolder {
    func count(_ strategy: CountStrategy) -> Float {
        return strategy.count(cards)
    }
}
