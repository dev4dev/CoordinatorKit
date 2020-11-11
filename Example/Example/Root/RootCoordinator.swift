//
//  RootCoordinator.swift
//  Example
//
//  Created by Alex Antonyuk on 05.10.2020.
//

import UIKit
import CoordinatorKit

final class RootCoordinator: TabCoordinator<Void> {
    override func start(style: PresentationStyle) {
        let vc = UITabBarController()
        setupTabs(controller: vc, coordinators: [
            HomeCoordinator(),
            InventoryCoordinator()
        ])

        present(controller: vc, style: style)
    }
}
