//
//  File.swift
//  
//
//  Created by Alex Antonyuk on 04.10.2020.
//

import Foundation

extension Array {
    subscript(safeIndex safeIndex: Index) -> Element? {
        guard safeIndex < count && safeIndex >= 0 else { return nil }
        return self[safeIndex]
    }
}
