//
//  CardCountable.swift
//
//
//  Created by Evan Anderson on 1/15/24.
//

import Foundation

protocol CardCountable {
    func running_count(_ strategy: CountStrategy, facing: Set<CardFace>) -> Float
    func true_count(_ strategy: CountStrategy, facing: Set<CardFace>) -> Float
    func count(_ strategy: CountStrategy, type: DeckType) -> Float
}
