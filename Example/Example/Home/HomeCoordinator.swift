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
}

final class HomeCoordinator: BaseCoordinator<UIViewController, Void> {
    private var subscriptions: Set<AnyCancellable> = .init()

    override func start(style: PresentationStyle) {
        let vc = HomeViewController()
        vc.action = { [unowned self] in
            self.settings(style: $0)
        }
        present(controller: vc.navigated(), style: style)
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

        }
    }
}
