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
        // swiftlint:disable weak_delegate
        let transitioningDelegate: UIViewControllerTransitioningDelegate?

        func apply(to viewController: UIViewController) {
            viewController.modalPresentationStyle = presentation
            viewController.modalTransitionStyle = transition
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
    case app(UIWindow)
    case modal(parameters: ModalParameters)
    case push
    case pushOrModal(parameters: ModalParameters)
    case tab(UITabBarController)
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

public protocol Coordinator: AnyObject {

    /// Presentation controller to be used as a parameter in child coordinators presentation methods
    var presentationController: PresentationController { get }

    /// Parent coordinator
    var parent: Coordinator? { get set }

    /// Children Coordinators
    var children: [Coordinator] { get }

    // swiftlint:disable identifier_name
    /// Service callback, shouldn't be used from a client code
    var _onDeinit: (() -> Void)? { get set }
    // swiftlint:enable identifier_name

    /// Top coordinator being presented by this coordinator
    var presented: Coordinator? { get }

    /// Method which starts a coordinator, should be overriden in a subclass
    /// - Parameter style: Presentation style, just pass it as a parameter to present method
    func start(style: PresentationStyle)

    /// Presents child coordinators
    /// - Parameters:
    ///   - coordinator: Child coordinator to present
    ///   - style: Presentation style
    func present(coordinator: Coordinator, style: PresentationStyle)

    // swiftlint:disable identifier_name
    /// Remove coordinator. Shouldn't be called directly
    /// - Parameter coordinator: Coordinator to remove
    func _remove(coordinator: Coordinator)
    // swiftlint:enable identifier_name

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
open class BaseCoordinator<KeyController: UIViewController, ResponseData>: Coordinator {
    public fileprivate(set) var children: [Coordinator] = []
    public weak var keyViewController: KeyController? {
        didSet {
            keyViewController?.setDeinitNotification { [weak self] in
                self?._onDeinit?()
            }
        }
    }
    open var presentationController: PresentationController {
        switch keyViewController {
        case let viewController as UINavigationController:
            return .navigation(viewController)
        case let viewController as UITabBarController:
            return .tab(viewController)
        case let viewController as UISplitViewController:
            return .split(viewController)
        default:
            if let navigationController = keyViewController?.navigationController {
                return .navigation(navigationController)
            } else {
                if let viewController = keyViewController {
                    return .regular(viewController)
                } else {
                    preconditionFailure("""

                        🔥>> Coordinator \(self) does not have a key controller
                        🔥>> Make sure that you overrode `start()` method and called `present(controller:style:)`
                        🔥>> from it with a relevant view contoller

                    """)
                }
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

    // swiftlint:disable:next identifier_name
    @Once public var _onDeinit: (() -> Void)?

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

    public init() {

    }

    deinit {
        // Add a Breakpoint whose action is Debugger Command is:
        //      po NSString(format: "--- deinit: @\"<%@>\"", String(reflecting: self))
    }

    open func start(style: PresentationStyle) {
        fatalError("""

            🔥>> Please override this method
            🔥>> and call `present(controller:style)` with a relevant view controller

            """)
    }

    public func present(controller: KeyController, style: PresentationStyle, completion: @escaping () -> Void = {}) {
        assert(keyViewController == nil, """

            🔥>> This method should be called only once from `start(style:)` method of a coordinator
            🔥>> To present another view controller, please use `presentationController.(modal|push)`

            """)
        keyViewController = controller

        switch style {
        case let .app(window):
            window.rootViewController = keyViewController
            window.makeKeyAndVisible()
        case let .modal(parameters):
            let presentationController = parent!.presentationController
            presentModal(parent: presentationController.viewController, parameters: parameters, completion: completion)
        case .push:
            let presentationController = parent!.presentationController
            if let navigationController = presentationController.navigationController {
                navigationController.pushViewController(controller, animated: true)
            } else {
                fatalError("Trying to present \(controller) into \(presentationController) without navigation controller")
            }
        case let .pushOrModal(parameters: parameters):
            let presentationController = parent!.presentationController
            if let navigationController = presentationController.navigationController {
                navigationController.pushViewController(controller, animated: true)
            } else {
                presentModal(parent: presentationController.viewController, parameters: parameters, completion: completion)
            }
        case .tab(let tabBarController):
            var viewControllers: [UIViewController] = tabBarController.viewControllers ?? []
            viewControllers.append(controller)
            tabBarController.viewControllers = viewControllers
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
            self.parent?._remove(coordinator: self)
            completion?()
        }

        guard let keyViewController = keyViewController else {
            done()
            return
        }

        keyViewController.presentedViewController?.dismiss(animated: animated)

        if let navigationController = keyViewController.navigationController {
            if navigationController.viewControllers.first == keyViewController {
                navigationController.dismiss(animated: animated, completion: done)
            } else {
                if let index = navigationController.viewControllers.firstIndex(of: keyViewController) {
                    let previous = navigationController.viewControllers[index - 1]
                    navigationController.popToViewController(previous, animated: animated, done)
                } else {
                    assertionFailure("Inconsistent state: Basically impossible")
                }
            }
        } else {
            keyViewController.dismiss(animated: animated, completion: done)
        }
    }

    public func popChildCoordinator(animated: Bool, _ completion: @escaping () -> Void = {}) {
        children.last?.dismiss(animated: animated, completion)
    }

    private func presentModal(parent: UIViewController, parameters: PresentationStyle.ModalParameters, completion: @escaping () -> Void = {}) {
        guard let keyViewController = keyViewController else {
            preconditionFailure("""

                🔥>> Coordinator \(self) does not have a key controller
                🔥>> Check your `start(style:)` method calls `present(controller:style)` with a relevant view conroller

                """)
        }
        parameters.apply(to: keyViewController)
        if parameters.navigated {
            let navigationController = UINavigationController(rootViewController: keyViewController)
            parameters.apply(to: navigationController)
            navigationController.transitioningDelegate = parameters.transitioningDelegate
            parent.present(navigationController, animated: parameters.animated, completion: completion)
        } else {
            keyViewController.transitioningDelegate = parameters.transitioningDelegate
            parent.present(keyViewController, animated: parameters.animated, completion: completion)
        }
    }

    public func present(coordinator: Coordinator, style: PresentationStyle) {
        guard !children.contains(where: { $0 === coordinator }) else { return }
        guard coordinator._onDeinit == nil else {
            fatalError("onDeinit shouldn't be set manually")
        }
        coordinator._onDeinit = { [weak self, unowned coordinator] in
            self?._remove(coordinator: coordinator)
        }
        children.append(coordinator)

        coordinator.parent = self
        coordinator.start(style: style)
    }

    // swiftlint:disable:next identifier_name
    public func _remove(coordinator: Coordinator) {
        guard let index = children.firstIndex(where: { $0 === coordinator }) else { return }
        children.remove(at: index)
        (coordinator as? BaseCoordinator)?.notifyDismissEvents()
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

    public var activeCoordinator: Coordinator? {
        guard keyViewController?.selectedIndex != NSNotFound else { return nil }
        guard let index = keyViewController?.selectedIndex else { return nil }
        let activeChild = tabCoordinators[safeIndex: index]
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
    public func setupTabs(controller: UITabBarController, coordinators: [Coordinator]) {
        coordinators.forEach { coordinator in
            presentTab(coordinator: coordinator, controller: controller)
        }
    }

    /// Method used to present child coordinator on TabCoordinator as tabs
    /// - Parameters:
    ///   - coordinators: Array of child coordinators
    ///   - style: Presentation style
    func presentTab(coordinator: Coordinator, controller: UITabBarController) {
        guard tabCoordinators.first(where: { $0 === coordinator}) == nil else { return }
        coordinator._onDeinit = { [weak self, unowned coordinator] in
            self?._remove(coordinator: coordinator)
        }
        tabCoordinators.append(coordinator)

        coordinator.parent = self
        coordinator.start(style: .tab(controller))
    }
}
