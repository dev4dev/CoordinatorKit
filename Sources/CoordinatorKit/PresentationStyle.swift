//
//  PresentationStyle.swift
//  CoordinatorKit
//
//  Created by Alex Antonyuk on 29.03.2025.
//

import UIKit
import ObjectiveC.runtime

@MainActor
public enum PresentationStyle {
    @MainActor
    public struct ModalParameters {
        let presentation: UIModalPresentationStyle
        let transition: UIModalTransitionStyle
        let navigated: Bool
        let animated: Bool
        // swiftlint:disable:next weak_delegate
        let transitioningDelegate: UIViewControllerTransitioningDelegate?

        @MainActor
        private enum AssociatedKeys {
            static var transitionDelegate = "CoordinatorKit.ModalParameters.transitionDelegate"
        }

        func apply(to viewController: UIViewController) {
            viewController.modalPresentationStyle = presentation
            viewController.modalTransitionStyle = transition
            viewController.transitioningDelegate = transitioningDelegate
            withUnsafePointer(to: AssociatedKeys.transitionDelegate) {
                if let transitioningDelegate {
                    objc_setAssociatedObject(
                        viewController,
                        $0,
                        transitioningDelegate,
                        .OBJC_ASSOCIATION_RETAIN_NONATOMIC
                    )
                }
            }
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
