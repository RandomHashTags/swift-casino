//
//  CardHolder.swift
//
//
//  Created by Evan Anderson on 1/14/24.
//

protocol CardHolder {
    var cards : [Card] { get set }
    
    func count(_ strategy: CountStrategy, facing: Set<CardFace>) -> Float
}

extension CardHolder {
    func count(_ strategy: CountStrategy, facing: Set<CardFace>) -> Float {
        return strategy.count(cards, facing: facing)
    }
}
