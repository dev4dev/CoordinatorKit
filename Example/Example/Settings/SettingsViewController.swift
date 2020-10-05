//
//  SettingsViewController.swift
//  Example
//
//  Created by Alex Antonyuk on 05.10.2020.
//

import UIKit

final class SettingsViewController: UIViewController {
    deinit {
        print("☠️ dead \(self)")
    }

    var completionCallback: () -> Void = {}

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .white

        navigationItem.title = "Settings"
        navigationItem.rightBarButtonItem = .init(title: "Close", style: .plain, target: self, action: #selector(closeAction(_:)))

        let b = UIButton().then {
            $0.setTitle("Close", for: .normal)
            $0.setTitleColor(.black, for: .normal)
        }
        b.addAction(.init(handler: { [unowned self] _ in
            self.completionCallback()
        }), for: .touchUpInside)
        view.addSubview(b)
        b.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
    }

    @objc private func closeAction(_ sender: UIBarButtonItem) {
        smartDismiss()
    }

}
