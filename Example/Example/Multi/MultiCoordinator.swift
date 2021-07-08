//
//  MultiCoordinator.swift
//  Example
//
//  Created by Alex Antonyuk on 08.07.2021.
//

import UIKit
import CoordinatorKit

final class MultiCoordinator: BaseCoordinator<UIViewController, Void> {
    override func start(style: PresentationStyle) {
        let vc = MultiViewController()
        vc.close = { [unowned self] in
            self.dismiss(animated: true)
        }
        present(controller: vc, style: style)
    }
}
