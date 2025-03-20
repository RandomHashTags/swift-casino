//
//  SequenceExtensions.swift
//
//
//  Created by Evan Anderson on 1/14/24.
//

extension Sequence {
    @inlinable
    func count(where transform: (Element) -> Bool) -> Int {
        return reduce(0, { $0 + (transform($1) ? 1 : 0) })
    }
}

extension Sequence where Element : Hashable {
    @inlinable
    func filterSet(_ transform: (Element) throws -> Bool) rethrows -> Set<Element> {
        var set:Set<Element> = []
        for element in self {
            if try transform(element) {
                set.insert(element)
            }
        }
        return set
    }
}

extension Collection {
    @inlinable
    func get(_ index: Index) -> Element? {
        return index >= startIndex && index < endIndex ? self[index] : nil
    }
}
