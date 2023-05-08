//
//  LoadingSpinnerViewController.swift
//  ShowcaseProd
//
//  Created by André Lascas on 27/10/2021.
//

import UIKit
import Lottie

class LoadingSpinnerViewController: UIViewController {

    let animationView = LottieAnimationView()

    var spinnerActivityIndicatorView = UIActivityIndicatorView(style: .large)

    override func viewDidLoad() {
        super.viewDidLoad()

        self.view.backgroundColor = .black.withAlphaComponent(0.2)

        self.animationView.translatesAutoresizingMaskIntoConstraints = false
        self.animationView.contentMode = .scaleAspectFit

        self.view.addSubview(self.animationView)

        // Some time later
        let starAnimation = LottieAnimation.named("sports-loading")
        self.animationView.animation = starAnimation
        self.animationView.loopMode = .loop

        NSLayoutConstraint.activate([
            self.animationView.widthAnchor.constraint(equalTo: self.animationView.heightAnchor),
            self.animationView.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
            self.animationView.centerYAnchor.constraint(equalTo: self.view.centerYAnchor),
            self.animationView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 16)
        ])
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        self.animationView.play()
    }

    public func startAnimating() {
        self.animationView.play { (finished) in
        /// Animation stopped
        }
    }

    public func stopAnimating() {
        self.animationView.stop()
    }

}
