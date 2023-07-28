//
//  Coordinator.swift
//
//
//  Created by Alex Antonyuk on 17.02.2020.
//

import UIKit
import Combine

public enum PresentationStyle {
    public struct ModalParameters {
        let presentation: UIModalPresentationStyle
        let transition: UIModalTransitionStyle
        let navigated: Bool
        let animated: Bool
        // swiftlint:disable:next weak_delegate
        let transitioningDelegate: UIViewControllerTransitioningDelegate?

        func apply(to viewController: UIViewController) {
            viewController.modalPresentationStyle = presentation
            viewController.modalTransitionStyle = transition
            viewController.transitioningDelegate = transitioningDelegate
        }

        public init(navigated: Bool = false,
                    animated: Bool = true,
                    presentation: UIModalPresentationStyle = .fullScreen,
                    transition: UIModalTransitionStyle = .coverVertical,
                    delegate: UIViewControllerTransitioningDelegate? = nil) {
            self.navigated = navigated
            self.animated = animated
            self.presentation = presentation
            self.transition = transition
            self.transitioningDelegate = delegate
        }

        public static func custom(delegate: UIViewControllerTransitioningDelegate) -> ModalParameters {
            .init(navigated: false, presentation: .custom, delegate: delegate)
        }
    }
    case modal(parameters: ModalParameters)
    case push
    case pushOrModal(parameters: ModalParameters)
}

public enum PresentationController {
    case regular(UIViewController)
    case navigation(UINavigationController)
    case tab(UITabBarController)
    case split(UISplitViewController)

    public var viewController: UIViewController {
        switch self {
        case .navigation(let viewController): return viewController
        case .regular(let viewController): return viewController
        case .split(let viewController): return viewController
        case .tab(let viewController): return viewController
        }
    }

    public var navigationController: UINavigationController? {
        switch self {
        case .navigation(let navigationController): return navigationController
        case .regular(let viewController): return viewController.navigationController
        case .split(let viewController): return viewController.navigationController
        case .tab(let viewController): return viewController.navigationController
        }
    }

    public var tabBarController: UITabBarController? {
        switch self {
        case .navigation, .regular, .split: return nil
        case .tab(let tabBarController): return tabBarController
        }
    }

    public var splitController: UISplitViewController? {
        switch self {
        case .navigation, .regular, .tab: return nil
        case .split(let splitViewController): return splitViewController
        }
    }

    public func modal(_ modalVC: UIViewController, animated: Bool, completion: (() -> Void)? = nil) {
        viewController.present(modalVC, animated: animated, completion: completion)
    }

    public func push(_ viewController: UIViewController, animated: Bool, completion: (() -> Void)? = nil) {
        guard let navigationController = navigationController else {
            fatalError("There is no navigationController in stack")
        }

        navigationController.pushViewController(viewController, animated: animated, completion)
    }
}

public extension PresentationController {
    init(auto viewController: UIViewController) {
        if let navigationController = viewController.navigationController {
            self = .navigation(navigationController)
        } else if let navigationController = viewController as? UINavigationController {
            self = .navigation(navigationController)
        } else if let tabBarController = viewController.tabBarController {
            self = .tab(tabBarController)
        } else if let splitViewController = viewController.splitViewController {
            self = .split(splitViewController)
        } else {
            self = .regular(viewController)
        }
    }
}

// swiftlint:disable identifier_name
private protocol CoordinatorInternal: AnyObject {
    /// Service callback, shouldn't be used from a client code
    var _onDeinit: (() -> Void)? { get set }


    /// Remove coordinator. Shouldn't be called directly
    /// - Parameter coordinator: Coordinator to remove
    func _remove(coordinator: Coordinator)

    /// Called after coordinator is presented. Do not call it manually
    func _didMoveToParent()
}
// swiftlint:enable identifier_name

public protocol Coordinator: AnyObject {

    var keyViewController: UIViewController { get }

    /// Presentation controller to be used as a parameter in child coordinators presentation methods
    var presentationController: PresentationController { get }

    /// Parent coordinator
    var parent: Coordinator? { get set }

    /// Children Coordinators
    var children: [Coordinator] { get }

    /// Top coordinator being presented by this coordinator
    var presented: Coordinator? { get }

    /// Presents child coordinators
    /// - Parameters:
    ///   - coordinator: Child coordinator to present
    ///   - style: Presentation style
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
        switch keyViewController {
        case let viewController as UINavigationController:
            return .navigation(viewController)
        case let viewController as UISplitViewController:
            return .split(viewController)
        default:
            if let navigationController = keyViewController.navigationController {
                return .navigation(navigationController)
            } else {
                return .regular(keyViewController)
            }
        }
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
    @Once var _onDeinit: (() -> Void)?

    func _didMoveToParent() {
        _typedViewController.weakify()
    }

    // swiftlint:disable:next identifier_name
    func _remove(coordinator: Coordinator) {
        guard let index = children.firstIndex(where: { $0 === coordinator }) else { return }
        children.remove(at: index)
        (coordinator as? BaseCoordinator)?.notifyDismissEvents()
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
        let done = {
            (self.parent as? CoordinatorInternal)?._remove(coordinator: self)
            completion?()
        }

        self.keyViewController.dismissAllPresentedControllers(animated: false) {
            if let navigationController = self.keyViewController.navigationController {
                if navigationController.viewControllers.first == self.keyViewController {
                    navigationController.dismiss(animated: animated, completion: done)
                } else {
                    if let index = navigationController.viewControllers.firstIndex(of: self.keyViewController) {
                        let previous = navigationController.viewControllers[index - 1]
                        navigationController.popToViewController(previous, animated: animated, done)
                    } else {
                        assertionFailure("Inconsistent state: Basically impossible")
                    }
                }
            } else {
                self.keyViewController.dismiss(animated: animated, completion: done)
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

    public func present(coordinator: Coordinator, style: PresentationStyle) {
        guard !children.contains(where: { $0 === coordinator }) else { return }
        guard (coordinator as? CoordinatorInternal)?._onDeinit == nil else {
            fatalError("onDeinit shouldn't be set manually")
        }
        (coordinator as? CoordinatorInternal)?._onDeinit = { [weak self, unowned coordinator] in
            self?._remove(coordinator: coordinator)
        }
        children.append(coordinator)

        coordinator.parent = self
        present(controller: coordinator.keyViewController, style: style)
        (coordinator as? CoordinatorInternal)?._didMoveToParent()
    }

    public func makeRootCoordinator(window: UIWindow) {
        window.rootViewController = keyViewController
        window.makeKeyAndVisible()
        _didMoveToParent()
    }

    // MARK: - Private
    private func notifyDismissEvents() {
        dismissCallback?()
        dismissSubject.send()
        dismissSubject.send(completion: .finished)
    }
}

public extension BaseCoordinator where ResponseData == Void {
    func complete(animated: Bool = true, _ completion: (() -> Void)? = nil) {
        complete(data: Void(), animated: animated, completion)
    }
}

// MARK: - TabCoordinator
open class TabCoordinator<ResponseData>: BaseCoordinator<UITabBarController, ResponseData> {
    private var tabCoordinators: [Coordinator] = []

    public init() {
        super.init(keyViewController: UITabBarController())
    }

    public var activeCoordinator: Coordinator? {
        guard typedViewController.selectedIndex != NSNotFound else { return nil }
        let activeChild = tabCoordinators[safeIndex: typedViewController.selectedIndex]
        return activeChild
    }

    override public var presented: Coordinator? {
        if let childCoord = children.last {
            return childCoord
        } else {
            return activeCoordinator?.presented
        }
    }

    /// Method used for setting up Tab Controller tabs from Coordinators
    /// - Parameters:
    ///   - controller: Tab Controller Instance
    ///   - coordinators: Child coordinators
    public func setupTabs(coordinators: [Coordinator]) {
        let vcs = coordinators.compactMap { coordinator -> UIViewController? in
            guard tabCoordinators.first(where: { $0 === coordinator}) == nil else { return nil }
            (coordinator as? CoordinatorInternal)?._onDeinit = { [weak self, unowned coordinator] in
                self?._remove(coordinator: coordinator)
            }
            tabCoordinators.append(coordinator)

            coordinator.parent = self
            let result = coordinator.keyViewController
            (coordinator as? CoordinatorInternal)?._didMoveToParent()
            return result
        }

        typedViewController.viewControllers = vcs
    }
}

// MARK: - SplitCoordinator
@available(iOS 14.0, *)
open class SplitCoordinator<ResponseData>: BaseCoordinator<UISplitViewController, ResponseData> {
    public init() {
        super.init(keyViewController: UISplitViewController())
    }

    public private(set) var primaryCoordinator: Coordinator?
    public private(set) var secondaryCoordinator: Coordinator?

    override public var presented: Coordinator? {
        if let childCoord = children.last {
            return childCoord
        } else {
            return primaryCoordinator?.presented ?? secondaryCoordinator?.presented
        }
    }

    public func setPrimaryCoordinator(_ primary: Coordinator) {
        primaryCoordinator = primary
        (primary as? CoordinatorInternal)?._onDeinit = { [weak self, unowned primary] in
            self?._remove(coordinator: primary)
        }

        primary.parent = self
        typedViewController.setViewController(primary.keyViewController, for: .primary)
        (primary as? CoordinatorInternal)?._didMoveToParent()
    }

    public func setSecondaryCoordinator(_ secondary: Coordinator) {
        secondaryCoordinator = secondary
        (secondary as? CoordinatorInternal)?._onDeinit = { [weak self, unowned secondary] in
            self?._remove(coordinator: secondary)
        }

        secondary.parent = self
        typedViewController.setViewController(secondary.keyViewController, for: .secondary)
        (secondary as? CoordinatorInternal)?._didMoveToParent()
    }
}
