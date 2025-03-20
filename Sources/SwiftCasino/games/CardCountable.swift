//
//  CardCountable.swift
//
//
//  Created by Evan Anderson on 1/15/24.
//

protocol CardCountable {
    func runningCount(_ strategy: CountStrategy, facing: Set<CardFace>) -> Float
    func trueCount(_ strategy: CountStrategy, facing: Set<CardFace>) -> Float
    func count(_ strategy: CountStrategy, type: DeckType) -> Float
}
