//
//  SettingsCoordinator.swift
//  Example
//
//  Created by Alex Antonyuk on 05.10.2020.
//

import UIKit
import CoordinatorKit

final class SettingsCoordinator: BaseCoordinator<UIViewController, Void> {
    deinit {
        print("☠️ dead \(self)")
    }

    override func start(style: PresentationStyle) {
        let vc = SettingsViewController()
        vc.completionCallback = { [unowned self] in
            self.complete()
        }
        present(controller: vc, style: style)
    }
}
