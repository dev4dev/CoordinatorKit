//
//  RootCoordinator.swift
//  Example
//
//  Created by Alex Antonyuk on 05.10.2020.
//

import UIKit
import CoordinatorKit

final class RootCoordinator: TabCoordinator<Void> {

    override init() {
        super.init()
        
        setupTabs(coordinators: [
            HomeCoordinator(),
            InventoryCoordinator()
        ])
    }
}
