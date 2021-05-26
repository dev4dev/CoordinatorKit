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

        func apply(to vc: UIViewController) {
            vc.modalPresentationStyle = presentation
            vc.modalTransitionStyle = transition
        }

        public init(navigated: Bool = false, animated: Bool = true, presentation: UIModalPresentationStyle = .fullScreen, transition: UIModalTransitionStyle = .coverVertical, delegate: UIViewControllerTransitioningDelegate? = nil) {
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
        case .navigation(let vc): return vc
        case .regular(let vc): return vc
        case .split(let vc): return vc
        case .tab(let vc): return vc
        }
    }

    public var navigationController: UINavigationController? {
        switch self {
        case .navigation(let vc): return vc
        case .regular(let vc): return vc.navigationController
        case .split(let vc): return vc.navigationController
        case .tab(let vc): return vc.navigationController
        }
    }

    public var tabBarController: UITabBarController? {
        switch self {
        case .navigation, .regular, .split: return nil
        case .tab(let vc): return vc
        }
    }

    public func modal(_ vc: UIViewController, animated: Bool, completion: (() -> Void)? = nil) {
        viewController.present(vc, animated: animated, completion: completion)
    }

    public func push(_ vc: UIViewController, animated: Bool, completion: (() -> Void)? = nil) {
        guard let nc = navigationController else {
            fatalError("There is no navigationController in stack")
        }

        nc.pushViewController(vc, animated: animated, completion)
    }
}

public extension PresentationController {
    init(auto vc: UIViewController) {
        if let nav = vc.navigationController {
            self = .navigation(nav)
        } else if let nav = vc as? UINavigationController {
            self = .navigation(nav)
        } else if let tab = vc.tabBarController {
            self = .tab(tab)
        } else if let split = vc.splitViewController {
            self = .split(split)
        } else {
            self = .regular(vc)
        }
    }
}

public protocol Coordinator: AnyObject {

    /// Presentation controller to be used as a parameter in child coordinators presentation methods
    var presentationController: PresentationController { get }

    /// Parent coordinator
    var parent: Coordinator? { get set }

    /// Children Coordinators
    var childred: [Coordinator] { get }

    /// Service callback, shouldn't be used from a client code
    var _onDeinit: (() -> Void)? { get set }

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

    /// Remove coordinator. Shouldn't be called directly
    /// - Parameter coordinator: Coordinator to remove
    func _remove(coordinator: Coordinator)

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
    fileprivate(set) public var childred: [Coordinator] = []
    public unowned var keyViewController: KeyController! {
        didSet {
            keyViewController?.setDeinitNotification { [weak self] in
                self?._onDeinit?()
            }
        }
    }
    public var presentationController: PresentationController {
        switch keyViewController {
        case let vc as UINavigationController:
            return .navigation(vc)
        case let vc as UITabBarController:
            return .tab(vc)
        case let vc as UISplitViewController:
            return .split(vc)
        default:
            if let nc = keyViewController?.navigationController {
                return .navigation(nc)
            } else {
                if let vc = keyViewController {
                    return .regular(vc)
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
        var result = childred.last

        while let c = result?.presented {
            result = c
        }

        return result
    }

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

    open func start(style: PresentationStyle) {
        fatalError("""

            🔥>> Please override this method
            🔥>> and call `present(controller:style)` with a relevant view controller

            """)
    }

    public func present(controller: KeyController, style: PresentationStyle, completion:  @escaping () -> Void = {}) {
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
            let pc = parent!.presentationController
            presentModal(parent: pc.viewController, parameters: parameters, completion: completion)
        case .push:
            let pc = parent!.presentationController
            if let nc = pc.navigationController {
                nc.pushViewController(controller, animated: true)
            } else {
                fatalError("Trying to present \(controller) into \(pc) without navigation controller")
            }
        case let .pushOrModal(parameters: parameters):
            let pc = parent!.presentationController
            if let nc = pc.navigationController {
                nc.pushViewController(controller, animated: true)
            } else {
                presentModal(parent: pc.viewController, parameters: parameters, completion: completion)
            }
        case .tab(let tabBarController):
            var vcs: [UIViewController] = tabBarController.viewControllers ?? []
            vcs.append(controller)
            tabBarController.viewControllers = vcs
        }

    }

    public func complete(data: ResponseData, animated: Bool = true) {
        dismiss(animated: animated) {
            self.completionCallback?(data)
            self.completionSubject.send(data)
            self.completionSubject.send(completion: .finished)
        }
    }

    public func dismiss(animated: Bool, _ completion: (() -> Void)?) {
        let done = {
            self.parent?._remove(coordinator: self)
            completion?()
        }

        guard keyViewController != nil else {
            done()
            return
        }

        if let nc = keyViewController?.navigationController {
            if nc.viewControllers.first == keyViewController {
                nc.dismiss(animated: true, completion: done)
            } else {
                nc.popViewController(animated: animated, done)
            }
        } else {
            keyViewController?.dismiss(animated: animated, completion: done)
        }
    }

    public func popChildCoordinator(animated: Bool, _ completion: @escaping () -> Void = {}) {
        childred.last?.dismiss(animated: animated, completion)
    }

    private func presentModal(parent: UIViewController, parameters: PresentationStyle.ModalParameters, completion:  @escaping () -> Void = {}) {
        guard let keyViewController = keyViewController else {
            preconditionFailure("""

                🔥>> Coordinator \(self) does not have a key controller
                🔥>> Check your `start(style:)` method calls `present(controller:style)` with a relevant view conroller

                """)
        }
        parameters.apply(to: keyViewController)
        if parameters.navigated {
            let nc = UINavigationController(rootViewController: keyViewController)
            parameters.apply(to: nc)
            nc.transitioningDelegate = parameters.transitioningDelegate
            parent.present(nc, animated: parameters.animated, completion: completion)
        } else {
            keyViewController.transitioningDelegate = parameters.transitioningDelegate
            parent.present(keyViewController, animated: parameters.animated, completion: completion)
        }
    }

    public func present(coordinator: Coordinator, style: PresentationStyle) {
        guard !childred.contains(where: { $0 === coordinator }) else { return }
        guard coordinator._onDeinit == nil else {
            fatalError("onDeinit shouldn't be set manually")
        }
        coordinator._onDeinit = { [weak self, unowned coordinator] in
            self?._remove(coordinator: coordinator)
        }
        childred.append(coordinator)

        coordinator.parent = self
        coordinator.start(style: style)
    }

    public func _remove(coordinator: Coordinator) {
        guard let index = childred.firstIndex(where: { $0 === coordinator }) else { return }
        childred.remove(at: index)
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
    func complete(animated: Bool = true) {
        complete(data: Void(), animated: animated)
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
        if let cc = childred.last {
            return cc
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
        print("present: ", coordinator)
    }
}
