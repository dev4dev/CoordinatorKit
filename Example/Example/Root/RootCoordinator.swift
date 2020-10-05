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
        present(coordinators: [
            HomeCoordinator(),
            InventoryCoordinator()
        ], style: style)
    }
}
