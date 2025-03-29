//
//  Utils.swift
//  Example
//
//  Created by Alex Antonyuk on 29.03.2025.
//

import UIKit
import Then

public extension UIViewController {
    /// Return current ViewController wrapped into a Navigation Controller
    /// - Returns: Navigation Controlle
    func navigated<K: UINavigationController>(klass: K.Type = K.self, style: UIModalPresentationStyle?) -> UINavigationController {
        klass.init(rootViewController: self).then {
            if let style = style {
                $0.modalPresentationStyle = style
            }
        }
    }

    func smartDismiss(animated: Bool, completion: (() -> Void)? = nil) {
        if let nc = navigationController {
            if nc.viewControllers.count == 1 {
                // if the only vc in navcontroller, then dismiss navcontroller
                nc.dismiss(animated: animated, completion: completion)
            } else if nc.topViewController == self {
                // otherwise pop controller
                nc.popViewController(animated: animated, completion)
            }
        } else {
            // dismiss controller
            dismiss(animated: animated, completion: completion)
        }
    }
}

extension UINavigationController {
    /// Pop last view controller from the navigation stack, with animation and completion block
    /// Use CATransaction to provide a completion block when the animation is complete
    /// - parameter completion: callback block to execute after pop operation is complete
    public func popViewController(animated: Bool = true, _ completion: (() -> Void)? = nil) {
        CATransaction.begin()
        CATransaction.setCompletionBlock(completion)
        self.popViewController(animated: animated)
        CATransaction.commit()
    }
}

public extension UIStackView {
    @discardableResult
    func verticalFlowSetup(spacing: CGFloat = 0.0) -> UIStackView {
        axis = .vertical
        alignment = .fill
        distribution = .fill
        self.spacing = spacing
        return self
    }

    @discardableResult
    func horizontalFlowSetup(spacing: CGFloat = 0.0) -> UIStackView {
        axis = .horizontal
        alignment = .fill
        distribution = .fill
        self.spacing = spacing
        return self
    }
}

public extension Collection where Element: UIView {
    func stackify(_ setup: (UIStackView) -> Void) -> UIStackView {
        let stackView = UIStackView(arrangedSubviews: Array(self))
        setup(stackView)
        return stackView
    }
}
