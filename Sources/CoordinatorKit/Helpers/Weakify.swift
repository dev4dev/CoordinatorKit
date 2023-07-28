//
//  Weakify.swift
//  
//
//  Created by Alex Antonyuk on 27.07.2023.
//

import Foundation

@propertyWrapper
public final class Weakify<T: AnyObject> {
    public var wrappedValue: T {
        if let strongVar {
            return strongVar
        } else if let weakVar {
            return weakVar
        } else {
            fatalError("Something went really wrong, reconsider your choice")
        }
    }
    private var strongVar: T?
    private weak var weakVar: T?

    public init(wrappedValue: T) {
        self.strongVar = wrappedValue
    }

    var isWeakened: Bool {
        weakVar != nil
    }

    func weakify() {
        guard !isWeakened else { return }

        weakVar = strongVar
        strongVar = nil
    }

    public var projectedValue: Weakify<T> {
        self
    }
}
