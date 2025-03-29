//
//  TabCoordinator.swift
//  CoordinatorKit
//
//  Created by Alex Antonyuk on 29.03.2025.
//

import UIKit

// MARK: - TabCoordinator
open class TabCoordinator<ResponseData>: BaseCoordinator<UITabBarController, ResponseData> {
    private var tabCoordinators: [Coordinator] = []

    public init() {
        super.init(keyViewController: UITabBarController())
    }

    public var activeCoordinator: Coordinator? {
        guard typedViewController.selectedIndex != NSNotFound else { return nil }
        let activeChild = tabCoordinators[safeIndex: typedViewController.selectedIndex]
        return activeChild
    }

    override public var presented: Coordinator? {
        if let childCoord = children.last {
            return childCoord
        } else {
            return activeCoordinator?.presented
        }
    }

    /// Method used for setting up Tab Controller tabs from Coordinators
    /// - Parameters:
    ///   - controller: Tab Controller Instance
    ///   - coordinators: Child coordinators
    public func setupTabs(coordinators: [Coordinator]) {
        let vcs = coordinators.compactMap { coordinator -> UIViewController? in
            guard tabCoordinators.first(where: { $0 === coordinator}) == nil else { return nil }
            connectDeInit(for: coordinator)
            tabCoordinators.append(coordinator)

            coordinator.parent = self
            let result = coordinator.keyViewController
            (coordinator as? CoordinatorInternal)?._didMoveToParent()
            return result
        }

        typedViewController.viewControllers = vcs
    }
}
