//
//  SceneDelegate.swift
//  Example
//
//  Created by Alex Antonyuk on 05.10.2020.
//

import UIKit
import CoordinatorKit
import Combine

final class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    private var subscriptions: Set<AnyCancellable> = .init()
    var window: UIWindow?
//    let coordinator = RootCoordinator()
//    var coordinator: AppCoordinator?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        // Use this method to optionally configure and attach the UIWindow `window` to the provided UIWindowScene `scene`.
        // If using a storyboard, the `window` property will automatically be initialized and attached to the scene.
        // This delegate does not imply the connecting scene or session are new (see `application:configurationForConnectingSceneSession` instead).
        guard let scene = (scene as? UIWindowScene) else { return }

        let win = UIWindow(windowScene: scene)
//        coordinator.makeRootCoordinator(window: win)
        AppCoordinator.shared.configure(with: win) { [weak self] coordinator in
            self?.setup(coordinator: coordinator)
        }
        window = win

        NotificationCenter.default.publisher(for: .userChanged)
            .sink { [weak self] _ in
                self?.setup(coordinator: .shared)
            }
            .store(in: &subscriptions)
    }

    private func setup(coordinator: AppCoordinator) {
        if UserDefaults.standard.bool(forKey: "user") {
            coordinator.present(coordinator: RootCoordinator())
        } else {
            coordinator.present(coordinator: InventoryCoordinator())
        }
    }
}

