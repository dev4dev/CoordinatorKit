//
//  PresentationStyle.swift
//  CoordinatorKit
//
//  Created by Alex Antonyuk on 29.03.2025.
//

import UIKit

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
