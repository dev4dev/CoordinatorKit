//
//  MultiCoordinator.swift
//  Example
//
//  Created by Alex Antonyuk on 08.07.2021.
//

import UIKit
import CoordinatorKit

final class MixedCoordinator: BaseCoordinator<UIViewController, Void> {
    override func start(style: PresentationStyle) {
        let vc = MixedViewController()
        vc.close = { [unowned self] in
            self.dismiss(animated: true)
        }
        present(controller: vc, style: style)
    }
}
