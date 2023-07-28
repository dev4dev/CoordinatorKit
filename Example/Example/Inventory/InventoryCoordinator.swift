//
//  InventoryCoordinator.swift
//  Example
//
//  Created by Alex Antonyuk on 05.10.2020.
//

import UIKit
import CoordinatorKit

final class InventoryCoordinator: BaseCoordinator<UIViewController, Void> {
    init() {
        super.init(keyViewController: InventoryViewController().navigated(style: .fullScreen))
    }
}

