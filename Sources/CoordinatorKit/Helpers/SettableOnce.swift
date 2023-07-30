//
//  SettableOnce.swift
//  
//
//  Created by Alex Antonyuk on 05.10.2020.
//

import Foundation

/// Allows to limit a var to be set only once
@propertyWrapper
public struct SettableOnce<Value> {

    private var innerValue: Value?

    public init() {

    }

    public var wrappedValue: Value? {
        get {
            innerValue
        }
        set {
            if innerValue == nil {
                innerValue = newValue
            } else {
                assertionFailure("Property can be set only once!")
            }
        }
    }
}
