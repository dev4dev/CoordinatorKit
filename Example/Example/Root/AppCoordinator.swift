//
//  AppCoordinator.swift
//  Example
//
//  Created by Alex Antonyuk on 05.10.2020.
//

import UIKit
import CoordinatorKit

final class AppCoordinator: BaseCoordinator<UIViewController, Void> {
    override func start(style: PresentationStyle) {
        // make decision what coordinator to show
        present(coordinator: RootCoordinator(), style: style)
    }
}
