//
//  UIViewController+Additions.swift
//  Example
//
//  Created by Alex Antonyuk on 11.11.2020.
//

import UIKit

extension UIViewController {
    @objc func navigated(fullscreen: Bool = true) -> UINavigationController {
        let nc = UINavigationController(rootViewController: self)
        if fullscreen {
            nc.modalPresentationStyle = .fullScreen
        }
        return nc
    }

    @IBAction func smartDismiss() {
        if let nc = navigationController {
            if nc.viewControllers.count == 1 {
                // if the only vc in navcontroller, then dismiss navcontroller
                nc.dismiss(animated: true)
            } else if nc.topViewController == self {
                // otherwise pop controller
                nc.popViewController(animated: true)
            }
        } else {
            // dismiss controller
            dismiss(animated: true)
        }
    }
}
