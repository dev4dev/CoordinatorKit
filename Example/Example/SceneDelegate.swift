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

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        // Use this method to optionally configure and attach the UIWindow `window` to the provided UIWindowScene `scene`.
        // If using a storyboard, the `window` property will automatically be initialized and attached to the scene.
        // This delegate does not imply the connecting scene or session are new (see `application:configurationForConnectingSceneSession` instead).
        guard let scene = (scene as? UIWindowScene) else { return }

        let win = UIWindow(windowScene: scene)
        // Example #1
        AppCoordinator.shared.configure(with: win, starter: AppStarter.self)

        // Example #2
//        AppCoordinator.shared.configure(with: win, coordinator: RootCoordinator())

        // Example #3
//        AppCoordinator.shared.configure(with: win) { appCoordinator in
//            let op = {
//                if UserDefaults.standard.bool(forKey: "user") {
//                    appCoordinator.present(coordinator: RootCoordinator(), animated: true)
//                } else {
//                    appCoordinator.present(coordinator: InventoryCoordinator(), animated: true)
//                }
//            }
//
//            op()
//            NotificationCenter.default.publisher(for: .userChanged)
//                .sink { _ in
//                    op()
//                }
//                .store(in: &subscriptions)
//        }

        window = win
    }
}
