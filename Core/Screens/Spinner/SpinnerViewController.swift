//
//  SpinnerViewController.swift
//  ShowcaseProd
//
//  Created by André Lascas on 27/10/2021.
//

import UIKit

class SpinnerViewController: UIViewController {

    var spinnerActivityIndicatorView = UIActivityIndicatorView(style: .large)

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .black.withAlphaComponent(0.4)

        spinnerActivityIndicatorView.translatesAutoresizingMaskIntoConstraints = false
        spinnerActivityIndicatorView.startAnimating()
        view.addSubview(spinnerActivityIndicatorView)

        spinnerActivityIndicatorView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        spinnerActivityIndicatorView.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
    }

}
