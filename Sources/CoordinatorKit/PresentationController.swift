//
//  PresentationController.swift
//  CoordinatorKit
//
//  Created by Alex Antonyuk on 29.03.2025.
//

import UIKit

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
            assertionFailure("There is no navigationController in view hierarchy")
            return
        }

        navigationController.pushViewController(viewController, animated: animated, completion)
    }
}

public extension PresentationController {
    init(viewController: UIViewController) {
        switch viewController {
        case let viewController as UINavigationController:
            self = .navigation(viewController)
        case let viewController as UISplitViewController:
            self = .split(viewController)
        case let viewController as UITabBarController:
            self = .tab(viewController)
        default:
            if let navigationController = viewController.navigationController {
                self = .navigation(navigationController)
            } else {
                self = .regular(viewController)
            }
        }
    }

    //    init(auto viewController: UIViewController) {
    //        if let navigationController = viewController.navigationController {
    //            self = .navigation(navigationController)
    //        } else if let navigationController = viewController as? UINavigationController {
    //            self = .navigation(navigationController)
    //        } else if let tabBarController = viewController.tabBarController {
    //            self = .tab(tabBarController)
    //        } else if let splitViewController = viewController.splitViewController {
    //            self = .split(splitViewController)
    //        } else {
    //            self = .regular(viewController)
    //        }
    //    }
}
