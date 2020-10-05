//
//  File.swift
//  
//
//  Created by Alex Antonyuk on 05.10.2020.
//

import Foundation

@propertyWrapper
public struct Once<Value> {

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
                fatalError("Property can be set only once!")
            }
        }
    }
}
