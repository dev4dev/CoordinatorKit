//
//  File.swift
//  
//
//  Created by Alex Antonyuk on 04.10.2020.
//

import UIKit

extension UINavigationController {

    /// Pop last view controller from the navigation stack, with animation and completion block
    /// Use CATransaction to provide a completion block when the animation is complete
    /// - parameter completion: callback block to execute after pop operation is complete
    public func popViewController(animated: Bool = true, _ completion: (() -> Void)?) {
        CATransaction.begin()
        CATransaction.setCompletionBlock(completion)
        self.popViewController(animated: animated)
        CATransaction.commit()
    }

    public func pushViewController(_ vc: UIViewController, animated: Bool = true, _ completion: (() -> Void)?) {
        CATransaction.begin()
        CATransaction.setCompletionBlock(completion)
        self.pushViewController(vc, animated: animated)
        CATransaction.commit()
    }
}

public extension UINavigationController {
    /// to connect tabBarItem from RootViewController to Container
    override var tabBarItem: UITabBarItem! {
        get {
            viewControllers.first?.tabBarItem
        }
        set {
            viewControllers.first?.tabBarItem = newValue
        }
    }
}
