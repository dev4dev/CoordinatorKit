//
//  MultiCoordinator.swift
//  Example
//
//  Created by Alex Antonyuk on 08.07.2021.
//

import UIKit
import CoordinatorKit

final class MixedCoordinator: BaseCoordinator<UIViewController, Void> {
    init() {
        let vc = MixedViewController()
        super.init(keyViewController: vc)

        vc.close = { [unowned self] in
            self.dismiss(animated: true)
        }
    }
}
