//
//  Collection++.swift
//  Accord
//
//  Created by evelyn on 2022-02-18.
//

import Combine
import Foundation

extension Collection where Element: Identifiable {
    func generateKeyMap() -> [Element.ID: Int] {
        enumerated().lazy
            .compactMap { [$1.id: $0] }
            .reduce(into: [:]) { result, next in
                result.merge(next) { _, rhs in rhs }
            }
    }
}

extension Dictionary {
    func filterValues(isIncluded: (Self.Value) throws -> Bool) rethrows -> Self {
        try filter { try isIncluded($0.value) }
    }
}

extension Collection {
    func jsonString() throws -> String? {
        let data = try JSONSerialization.data(withJSONObject: self, options: [])
        let jsonString = String(data: data, encoding: .utf8)
        return jsonString
    }

    var arrayLiteral: [Self.Element] {
        Array(self)
    }
}

extension ArraySlice {
    typealias LiteralType = [Self.Element]
    func literal() -> LiteralType {
        LiteralType(self)
    }
}

extension Slice {
    func literal() -> Base {
        base
    }
}

extension Array where Element: Identifiable {
    subscript(keyed id: Self.Element.ID, keyMap: [Self.Element.ID: Int]? = nil) -> Self.Element? {
        get {
            let keys = keyMap ?? generateKeyMap()
            guard let element = keys[id] else { return nil }
            return self[element]
        }
        set {
            let keys = keyMap ?? generateKeyMap()
            guard let element = keys[id], let newValue = newValue else { return }
            self[element] = newValue
        }
    }

    subscript(indexOf id: Self.Element.ID, keyMap: [Self.Element.ID: Int]? = nil) -> Int? {
        let keys = keyMap ?? generateKeyMap()
        return keys[id]
    }
}
