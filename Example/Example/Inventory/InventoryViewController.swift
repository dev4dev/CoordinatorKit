//
//  InventoryViewController.swift
//  Example
//
//  Created by Alex Antonyuk on 05.10.2020.
//

import UIKit
import Then

final class InventoryViewController: UIViewController {

    init() {
        super.init(nibName: nil, bundle: nil)

        self.tabBarItem = .init(tabBarSystemItem: .featured, tag: 1)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .white
    }

}
