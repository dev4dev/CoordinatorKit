//
//  AppCoordinator.swift
//  CoordinatorKit
//
//  Created by Alex Antonyuk on 29.03.2025.
//

import UIKit

/// A coordinator that serves a role of a root coordinator to use for presenting other coordinators
@MainActor
public final class AppCoordinator: CoreCoordinator {

    public static let shared: AppCoordinator = .init()

    private var configurator: (any AppStartConfigurator)?

    public var presentationController: PresentationController {
        guard let viewController = presented?.keyViewController else {
            preconditionFailure("You need to present coordinator first")
        }

        return .init(viewController: viewController)
    }

    private init() {
        // no-op
    }

    private unowned var window: UIWindow?

    /// Configure AppCoordinator
    /// - Parameters:
    ///   - window: The main app Window
    ///   - starter: A type that configures app startup
    public func configure(with window: UIWindow, starter: any AppStartConfigurator.Type) {
        self.window = window
        configurator = starter.init(coordinator: self)
    }

    /// Configure AppCoordinator
    /// - Parameters:
    ///   - window: The main app Window
    ///   - setup: Closure where an initial coordinator should be presented
    public func configure(with window: UIWindow, setup: (AppCoordinator) -> Void) {
        self.window = window
        setup(self)
    }

    /// Configure AppCoordinator
    /// - Parameters:
    ///   - window: The main app Window
    ///   - coordinator: Root coordinator
    public func configure<C: Coordinator>(with window: UIWindow, coordinator: C) {
        self.window = window

        present(coordinator: coordinator, animated: true)
    }

    /// Active root coodinator, which keyViewController is set as rootViewController on the window
    public var presented: Coordinator?

    /// Present coordinator. KeyViewController from the coordinator will be set as a rootViewController on the window
    /// - Parameters:
    ///   - coordinator: Coordinator
    ///   - animated: Animated
    public func present(coordinator: Coordinator, animated: Bool) {
        if let presented {
            // If there is already presented coordinator, then notify it before removing
            (presented as? CoordinatorInternal)?._notifyDismissEvents()
        }

        self.presented = coordinator

        if let window {
            UIView.transition(with: window, duration: animated ? 0.35 : 0.0, options: .transitionCrossDissolve, animations: {
                window.rootViewController = coordinator.keyViewController
            })
        }

        (coordinator as? CoordinatorInternal)?._didMoveToParent()
        window?.makeKeyAndVisible()
    }
}
