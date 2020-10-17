//
//  SettingsExtraViewController.swift
//  Example
//
//  Created by Alex Antonyuk on 17.10.2020.
//

import UIKit

final class SettingsExtraViewController: UIViewController {

    init() {
        super.init(nibName: nil, bundle: nil)


    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()
    }

    private func setupUI() {
        view.backgroundColor = .purple

        let b = UIButton().then {
            $0.setTitle("Close", for: .normal)
            $0.setTitleColor(.white, for: .normal)
        }
        b.addAction(.init(handler: { [unowned self] _ in
            self.navigationController?.popViewController(animated: true)
        }), for: .touchUpInside)
        view.addSubview(b)
        b.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
    }

}
