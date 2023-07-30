//
//  AppStarter.swift
//  Example
//
//  Created by Alex Antonyuk on 30.07.2023.
//

import Foundation
import CoordinatorKit
import Combine

final class AppStarter: AppStartConfigurator {
    private var subscriptions: Set<AnyCancellable> = .init()

    init(coordinator: AppCoordinator) {
        setup(coordinator: coordinator)

        NotificationCenter.default.publisher(for: .userChanged)
            .sink { [weak self] _ in
                self?.setup(coordinator: .shared)
            }
            .store(in: &subscriptions)
    }

    private func setup(coordinator: AppCoordinator) {
        if UserDefaults.standard.bool(forKey: "user") {
            coordinator.present(coordinator: RootCoordinator(), animated: true)
        } else {
            coordinator.present(coordinator: InventoryCoordinator(), animated: true)
        }
    }
}
