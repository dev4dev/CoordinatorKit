//
//  CoordinatorProtocols.swift
//  CoordinatorKit
//
//  Created by Alex Antonyuk on 29.03.2025.
//

import UIKit

// swiftlint:disable identifier_name
@MainActor
protocol CoordinatorInternal: AnyObject {
    /// Service callback, shouldn't be used from a client code
    var _onDeinit: (() -> Void)? { get set }


    /// Remove coordinator. Shouldn't be called directly
    /// - Parameter coordinator: Coordinator to remove
    func _remove(coordinator: Coordinator)

    /// Called after coordinator is presented. Do not call it manually
    func _didMoveToParent()

    func _notifyDismissEvents()
}
// swiftlint:enable identifier_name

@MainActor
public protocol CoreCoordinator: AnyObject {
    /// Presentation controller to be used as a parameter in child coordinators presentation methods
    var presentationController: PresentationController { get }

    /// Top coordinator being presented by this coordinator
    var presented: Coordinator? { get }
}


public protocol Coordinator: CoreCoordinator {

    /// Key ViewController of a Coordinator
    var keyViewController: UIViewController { get }

    /// Parent coordinator
    var parent: Coordinator? { get set }

    /// Children Coordinators
    var children: [Coordinator] { get }

    /// Presents child coordinators
    /// - Parameters:
    ///   - coordinator: Child coordinator to present
    ///   - style: Presentation style
    ///
    ///         let loginCoordinator = LoginCoordinator()
    ///         loginCoordinator.completionCallback = { userInfo in
    ///             print("DONE: \(userInfo)")
    ///         }
    ///         present(coordinator: loginCoordinator, style: .push)
    ///
    func present(coordinator: Coordinator, style: PresentationStyle)

    /// Dismiss coordinator
    /// - Parameters:
    ///   - animated: Animated
    ///   - completion: Completion callback
    func dismiss(animated: Bool, _ completion: (() -> Void)?)

    /// Pop child coordinator
    /// - Parameters:
    ///   - animated: Animated
    ///   - completion: Completion callback
    func popChildCoordinator(animated: Bool, _ completion: @escaping () -> Void)
}

public extension Coordinator {

    /// Dismiss coordinator
    /// - Parameter animated: Animated
    func dismiss(animated: Bool) {
        dismiss(animated: animated, nil)
    }
}

// MARK: -
@MainActor
public protocol AppStartConfigurator {
    init(coordinator: AppCoordinator)
}
