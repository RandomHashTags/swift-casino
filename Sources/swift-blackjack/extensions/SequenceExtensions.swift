//
//  SequenceExtensions.swift
//
//
//  Created by Evan Anderson on 1/14/24.
//

import Foundation

extension Sequence {
    func count(where transform: (Element) -> Bool) -> Int {
        return reduce(0, { $0 + (transform($1) ? 1 : 0) })
    }
}

extension Sequence where Element : Hashable {
    func filter_set(_ transform: (Element) throws -> Bool) rethrows -> Set<Element> {
        var set:Set<Element> = []
        for element in self {
            if try transform(element) {
                set.insert(element)
            }
        }
        return set
    }
}

extension Array {
    func get(_ index: Int) -> Element? {
        return index < count ? self[index] : nil
    }
}
