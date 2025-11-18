import Testing
import UIKit
@testable import CoordinatorKit

@Suite
@MainActor
final class PresentationStyleTests {

    @Test("Modal parameters retain custom transition delegates via association")
    func modalParametersRetainTransitionDelegate() {
        let viewController = UIViewController()
        weak var weakDelegate: TestTransitionDelegate?

        do {
            let delegate = TestTransitionDelegate()
            weakDelegate = delegate

            let parameters = PresentationStyle.ModalParameters(delegate: delegate)
            parameters.apply(to: viewController)
        }

        #expect(weakDelegate != nil, "Delegate should be retained by the associated object")
        #expect(
            viewController.transitioningDelegate === weakDelegate,
            "Transitioning delegate should be the same instance that was passed in"
        )
    }
}

private final class TestTransitionDelegate: NSObject, UIViewControllerTransitioningDelegate {}
