//
//  File.swift
//  
//
//  Created by Alex Antonyuk on 28.07.2023.
//

import UIKit

extension UIViewController {
    func dismissAllPresentedControllers(animated: Bool, completion: (() -> Void)? = nil) {
        if let pvc = presentedViewController {
            pvc.dismissAllPresentedControllers(animated: animated) {
                pvc.dismiss(animated: animated, completion: completion)
            }
        } else {
            completion?()
        }
    }
}
