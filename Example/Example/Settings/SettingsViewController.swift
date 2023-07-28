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
    var extraCallback: () -> Void = {}

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

        let extra = UIButton().then {
            $0.setTitle("Push Extra", for: .normal)
            $0.setTitleColor(.black, for: .normal)
        }
        extra.addAction(.init(handler: { [unowned self] _ in
            self.extraCallback()
        }), for: .touchUpInside)
        view.addSubview(extra)
        extra.snp.makeConstraints { make in
            make.top.equalTo(b.snp.bottom).offset(20.0)
            make.centerX.equalToSuperview()
        }
    }

    @objc private func closeAction(_ sender: UIBarButtonItem) {
        smartDismiss(animated: true)
    }

}
