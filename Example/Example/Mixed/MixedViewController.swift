//
//  MultiViewController.swift
//  Example
//
//  Created by Alex Antonyuk on 08.07.2021.
//

import UIKit

final class MixedViewController: UIViewController {
    var close: (() -> Void)?

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .white

        let button = UIButton(primaryAction: .init(handler: { [unowned self] _ in
            let vc = MixedViewController()
            vc.close = self.close
            self.navigationController?.pushViewController(vc, animated: true)
        })).then {
            $0.setTitle("Push", for: .normal)
            $0.setTitleColor(.black, for: .normal)
        }

        let button2 = UIButton(primaryAction: .init(handler: { [unowned self] _ in
            let vc = MixedViewController()
            vc.modalPresentationStyle = .fullScreen
            vc.close = self.close
            self.navigationController?.present(vc, animated: true)
        })).then {
            $0.setTitle("Modal", for: .normal)
            $0.setTitleColor(.black, for: .normal)
        }

        let button3 = UIButton(primaryAction: .init(handler: { [unowned self] _ in
            self.close?()
        })).then {
            $0.setTitle("Close", for: .normal)
            $0.setTitleColor(.black, for: .normal)
        }

        let s = [button, button2, button3].stackify { sv in
            sv.verticalFlowSetup()
        }

        view.addSubview(s) { make in
            make.center.equalToSuperview()
        }
    }
}
