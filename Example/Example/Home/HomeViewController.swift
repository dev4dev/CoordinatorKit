//
//  HomeViewController.swift
//  Example
//
//  Created by Alex Antonyuk on 05.10.2020.
//

import UIKit
import CommonLib
import SnapKit

final class HomeViewController: UIViewController {

    let modalNavButton = UIButton().then {
        $0.setTitle("Modal Nav", for: .normal)
        $0.setTitleColor(.black, for: .normal)
    }
    let modalRawButton = UIButton().then {
        $0.setTitle("Modal Raw", for: .normal)
        $0.setTitleColor(.black, for: .normal)
    }
    let pushButton = UIButton().then {
        $0.setTitle("Modal Push", for: .normal)
        $0.setTitleColor(.black, for: .normal)
    }
    let multiButton = UIButton().then {
        $0.setTitle("Multi", for: .normal)
        $0.setTitleColor(.black, for: .normal)
    }
    let mixedButton = UIButton().then {
        $0.setTitle("Mixed", for: .normal)
        $0.setTitleColor(.black, for: .normal)
    }

    var action: (SettingsStyle) -> Void = { _ in }

    init() {
        super.init(nibName: nil, bundle: nil)

        self.tabBarItem = .init(tabBarSystemItem: .search, tag: 0)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .white
        navigationItem.title = "Home"

        let stack = UIStackView(arrangedSubviews: [modalNavButton, modalRawButton, pushButton, multiButton, mixedButton])
        stack.axis = .vertical
        stack.spacing = 10.0

        modalNavButton.addAction(.init(handler: { [unowned self] _ in
            self.action(.modalNav)
        }), for: .touchUpInside)
        modalRawButton.addAction(.init(handler: { [unowned self] _ in
            self.action(.modalRaw)
        }), for: .touchUpInside)
        pushButton.addAction(.init(handler: { [unowned self] _ in
            self.action(.push)
        }), for: .touchUpInside)
        multiButton.addAction(.init(handler: { [unowned self] _ in
            self.action(.multi)
        }), for: .touchUpInside)
        mixedButton.addAction(.init(handler: { [unowned self] _ in
            self.action(.mixed)
        }), for: .touchUpInside)

        view.addSubview(stack)
        stack.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
    }

    private func showAlert() {
        let alert = UIAlertController(title: "Test", message: "kek", preferredStyle: .alert)
        alert.addAction(.init(title: "OK", style: .default, handler: nil))
        present(alert, animated: true)
    }
}
