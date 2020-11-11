//
//  DeinitObserver.swift
//
//
//  Created by Alex Antonyuk on 17.02.2020.
//

import Foundation
import ObjectiveC.runtime

final class DeinitObserver {
    let callback: () -> Void
    init(_ callback: @escaping () -> Void) {
        self.callback = callback
    }

    deinit {
        callback()
    }

    func attach(to object: NSObject) {
        objc_setAssociatedObject(object, "deinitObservable", self, .OBJC_ASSOCIATION_RETAIN)
    }
}

extension NSObject {
    func setDeinitNotification(_ notification: @escaping () -> Void) {
        DeinitObserver(notification).attach(to: self)
    }
}
