//
//  Dictionary.swift
//  concurrent-expiring-cache
//
//  Created by Severyn-Wsevolod on 03.04.2024.
//

import Foundation

extension Dictionary {
    @inlinable mutating func removeIf(condition: (Self.Element) -> Bool) {
        for (key, _) in filter(condition) { removeValue(forKey: key) }
    }
}
