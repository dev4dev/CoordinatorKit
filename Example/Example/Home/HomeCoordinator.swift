//
//  HomeCoordinator.swift
//  Example
//
//  Created by Alex Antonyuk on 05.10.2020.
//

import UIKit
import CoordinatorKit
import Combine

enum SettingsStyle {
    case modalNav
    case modalRaw
    case push
    case multi
    case mixed
}

final class HomeCoordinator: BaseCoordinator<UIViewController, Void> {
    private var subscriptions: Set<AnyCancellable> = .init()

    init() {
        let vc = HomeViewController()
        super.init(keyViewController: vc.navigated(style: .fullScreen))
        vc.action = { [unowned self] in
            self.settings(style: $0)
        }

    }

    private func settings(style: SettingsStyle) {
        let c = SettingsCoordinator()
        c.completionCallback = { _ in 
            print("DONE")
        }
        c.completionPublisher.sink {
            print("DONE PUB")
        }.store(in: &subscriptions)
        c.dismissCallback = {
            print("DISMISSED")
        }
        c.dismissPublisher.sink {
            print("DISMISSED PUB")
        }.store(in: &subscriptions)
        switch style {
        case .modalNav:
            // modal in nav controller
            present(coordinator: c, style: .modal(parameters: .init(navigated: true, animated: true)))
        case .modalRaw:
            // modal raw
            present(coordinator: c, style: .modal(parameters: .init(navigated: false, animated: true)))
        case .push:
            // push
            present(coordinator: c, style: .push)
        case .multi:
            let c = MultiCoordinator()
            present(coordinator: c, style: .push)
        case .mixed:
            let c = MixedCoordinator()
            present(coordinator: c, style: .push)
        }
    }
}
