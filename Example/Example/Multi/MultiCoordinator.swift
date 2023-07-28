//
//  MultiCoordinator.swift
//  Example
//
//  Created by Alex Antonyuk on 08.07.2021.
//

import UIKit
import CoordinatorKit

final class MultiCoordinator: BaseCoordinator<UIViewController, Void> {
    deinit {
        print("☠️ dead \(self)")
    }

    init() {
        let vc = MultiViewController()
        super.init(keyViewController: vc)

        vc.close = { [unowned self] in
            self.dismiss(animated: true)
        }
    }
}
