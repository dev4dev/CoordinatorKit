//
//  SceneDelegate.swift
//  Example
//
//  Created by Alex Antonyuk on 05.10.2020.
//

import UIKit

final class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?
    let coordinator = RootCoordinator()

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        // Use this method to optionally configure and attach the UIWindow `window` to the provided UIWindowScene `scene`.
        // If using a storyboard, the `window` property will automatically be initialized and attached to the scene.
        // This delegate does not imply the connecting scene or session are new (see `application:configurationForConnectingSceneSession` instead).
        guard let scene = (scene as? UIWindowScene) else { return }

        let win = UIWindow(windowScene: scene)
        coordinator.makeRootCoordinator(window: win)
        window = win
    }
}

