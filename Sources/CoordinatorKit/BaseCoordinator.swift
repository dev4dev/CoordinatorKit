//
//  BaseCoordinator.swift
//  CoordinatorKit
//
//  Created by Alex Antonyuk on 29.03.2025.
//

import Combine
import UIKit

// MARK: - BaseCoordintor
/// A Base Coordinator which should be inherited
/// You need to specify generic parameters for it:
/// - 1: KeyController - a type of key controller. Usually it can be UIViewController, or specific.
/// - 2: ResponseData - a type of returning data if your coordinator should return anything on its completion
open class BaseCoordinator<KeyController: UIViewController, ResponseData>: Coordinator, CoordinatorInternal {
    public var keyViewController: UIViewController {
        typedViewController
    }

    public fileprivate(set) var children: [Coordinator] = []

    @Weakify
    public var typedViewController: KeyController
    open var presentationController: PresentationController {
        .init(viewController: keyViewController)
    }

    /// Parent coordinator
    public weak var parent: Coordinator?

    /// Top coordinator being presented by this coordinator
    public var presented: Coordinator? {
        var result = children.last

        while let coordinator = result?.presented {
            result = coordinator
        }

        return result
    }

    // MARK: - Internal
    // swiftlint:disable:next identifier_name
    @SettableOnce var _onDeinit: (() -> Void)?

    func _didMoveToParent() {
        _typedViewController.weakify()
    }

    // swiftlint:disable:next identifier_name
    func _remove(coordinator: Coordinator) {
        guard let index = children.firstIndex(where: { $0 === coordinator }) else { return }
        children.remove(at: index)
        (coordinator as? CoordinatorInternal)?._notifyDismissEvents()
    }

    func _notifyDismissEvents() {
        dismissCallback?()
        dismissSubject.send()
        dismissSubject.send(completion: .finished)
    }
    // MARK: -

    /// Callback to pass value from the coordinator on its completion
    public var completionCallback: ((ResponseData) -> Void)?
    private let completionSubject: PassthroughSubject<ResponseData, Never> = .init()
    /// Publisher to pass value from the coordinator on its completion
    public var completionPublisher: AnyPublisher<ResponseData, Never> {
        completionSubject.eraseToAnyPublisher()
    }

    /// Callback to observe coordinator dismission
    public var dismissCallback: (() -> Void)?
    private let dismissSubject: PassthroughSubject<Void, Never> = .init()
    /// Publisher to observe coordinator dismission
    public var dismissPublisher: AnyPublisher<Void, Never> {
        dismissSubject.eraseToAnyPublisher()
    }

    public init(keyViewController: KeyController) {
        self._typedViewController = .init(wrappedValue: keyViewController)
        makeConnectionToViewControllerLifecycle()
    }

    private func makeConnectionToViewControllerLifecycle() {
        typedViewController.setDeinitNotification { [weak self] in
            self?._onDeinit?()
        }
    }

    deinit {
        // Add a Breakpoint whose action is Debugger Command is:
        //      po NSString(format: "--- deinit: @\"<%@>\"", String(reflecting: self))
    }

    private func present(controller: UIViewController, style: PresentationStyle, completion: @escaping () -> Void = {}) {
        switch style {
        case let .modal(parameters):
            presentModal(vc: controller, parameters: parameters, completion: completion)
        case .push:
            presentationController.push(controller, animated: true)
        case let .pushOrModal(parameters: parameters):
            if let navigationController = presentationController.navigationController {
                navigationController.pushViewController(controller, animated: true)
            } else {
                presentModal(vc: presentationController.viewController, parameters: parameters, completion: completion)
            }
        }
    }

    /// Make the passed coordinator remove itself from the parent
    /// - Parameter coordinator: Coordinator
    func connectDeInit(for coordinator: Coordinator) {
        (coordinator as? CoordinatorInternal)?._onDeinit = { [weak self, unowned coordinator] in
            self?._remove(coordinator: coordinator)
        }
    }

    /// Complete coordinator
    ///
    /// Will send response data to a receiver
    /// - Parameters:
    ///   - shouldDismiss: Indicates whether the coordinator should dismiss on completion or not. Default: `true`
    ///   - data: Result data to be returned
    ///   - animated: Should dismissal be animated. Default: `true`
    ///   - completion: Completion callback
    public func complete(dismiss shouldDismiss: Bool = true, data: ResponseData, animated: Bool = true, _ completion: (() -> Void)? = nil) {
        let sendData: (ResponseData) -> Void = { data in
            self.completionCallback?(data)
            self.completionSubject.send(data)
        }

        let action = {
            sendData(data)
            completion?()
        }

        if shouldDismiss {
            dismiss(animated: animated) {
                action()
                self.completionSubject.send(completion: .finished)
            }
        } else {
            action()
        }
    }

    /// Dismiss coordinator
    ///
    /// - Parameters:
    ///   - animated: Animated
    ///   - completion: Completion callback
    public func dismiss(animated: Bool, _ completion: (() -> Void)?) {
        keyViewController.dismissAllPresentedControllers(animated: false) {
            if let navigationController = self.keyViewController.navigationController {
                // if the controller is the only controller in NavController then dismiss this nav controller
                if navigationController.viewControllers.first == self.keyViewController {
                    navigationController.dismiss(animated: animated, completion: completion)
                } else {
                    // Otherwise remove all the controllers up to the controller that is previous to the current
                    if let index = navigationController.viewControllers.firstIndex(of: self.keyViewController) {
                        let previous = navigationController.viewControllers[index - 1]
                        navigationController.popToViewController(previous, animated: animated, completion)
                    } else {
                        // We are in NavController that doesn't have the current one in it
                        assertionFailure("Inconsistent state: Basically impossible")
                    }
                }
            } else {
                self.keyViewController.dismiss(animated: animated, completion: completion)
            }
        }
    }

    public func popChildCoordinator(animated: Bool, _ completion: @escaping () -> Void = {}) {
        children.last?.dismiss(animated: animated, completion)
    }

    private func presentModal(vc: UIViewController, parameters: PresentationStyle.ModalParameters, completion: @escaping () -> Void = {}) {
        if parameters.navigated {
            let navigationController = UINavigationController(rootViewController: vc)
            parameters.apply(to: navigationController)
            presentationController.modal(navigationController, animated: parameters.animated)
        } else {
            parameters.apply(to: vc)
            presentationController.modal(vc, animated: parameters.animated)
        }
    }

    public func present(coordinator: any Coordinator, style: PresentationStyle) {
        guard !children.contains(where: { $0 === coordinator }) else { return }
        guard (coordinator as? CoordinatorInternal)?._onDeinit == nil else {
            assertionFailure("onDeinit should be nil. Was this coordinator presented before?")
            return
        }
        connectDeInit(for: coordinator)
        children.append(coordinator)

        coordinator.parent = self
        present(controller: coordinator.keyViewController, style: style)
        (coordinator as? CoordinatorInternal)?._didMoveToParent()
    }
}

public extension BaseCoordinator where ResponseData == Void {
    func complete(animated: Bool = true, _ completion: (() -> Void)? = nil) {
        complete(data: Void(), animated: animated, completion)
    }
}
