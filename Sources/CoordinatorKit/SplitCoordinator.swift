//
//  SplitCoordinator.swift
//  CoordinatorKit
//
//  Created by Alex Antonyuk on 29.03.2025.
//

import UIKit

// MARK: - SplitCoordinator
@available(iOS 14.0, *)
@available(*, message: "Under development")
open class SplitCoordinator<ResponseData>: BaseCoordinator<UISplitViewController, ResponseData> {
    public init() {
        super.init(keyViewController: UISplitViewController())
    }

    public private(set) var primaryCoordinator: Coordinator?
    public private(set) var secondaryCoordinator: Coordinator?

    override public var presented: Coordinator? {
        if let childCoord = children.last {
            return childCoord
        } else {
            return primaryCoordinator?.presented ?? secondaryCoordinator?.presented
        }
    }

    public func setPrimaryCoordinator(_ primary: Coordinator) {
        primaryCoordinator = primary
        connectDeInit(for: primary)
        primary.parent = self

        typedViewController.setViewController(primary.keyViewController, for: .primary)
        (primary as? CoordinatorInternal)?._didMoveToParent()
    }

    public func setSecondaryCoordinator(_ secondary: Coordinator) {
        secondaryCoordinator = secondary
        connectDeInit(for: secondary)
        secondary.parent = self

        typedViewController.setViewController(secondary.keyViewController, for: .secondary)
        (secondary as? CoordinatorInternal)?._didMoveToParent()
    }
}

