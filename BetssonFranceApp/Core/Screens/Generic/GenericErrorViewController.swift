//
//  GenericErrorViewController.swift
//  Sportsbook
//
//  Created by André Lascas on 22/06/2023.
//

import UIKit

class GenericErrorViewController: UIViewController {

    private lazy var containerView: UIView = Self.createContainerView()
    private lazy var topGradientView: GradientView = Self.createTopGradientView()
    private lazy var shapeView: UIView = Self.createShapeView()
    private lazy var closeButton: UIButton = Self.createCloseButton()
    private lazy var logoImageView: UIImageView = Self.createLogoImageView()
    private lazy var titleLabel: UILabel = Self.createTitleLabel()
    private lazy var subtitleLabel: UILabel = Self.createSubtitleLabel()
    private lazy var continueButton: UIButton = Self.createContinueButton()

    override func viewDidLoad() {
        super.viewDidLoad()

        self.setupSubviews()
        self.setupWithTheme()

        self.closeButton.addTarget(self, action: #selector(didTapCloseButton), for: .primaryActionTriggered)

        self.continueButton.addTarget(self, action: #selector(didTapContinueButton), for: .primaryActionTriggered)
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        self.topGradientView.startPoint = CGPoint(x: 0.0, y: 0.5)
        self.topGradientView.endPoint = CGPoint(x: 1.0, y: 0.5)

        let path = UIBezierPath()
        path.move(to: CGPoint(x: 0.0, y: self.shapeView.frame.size.height))
        path.addCurve(to: CGPoint(x: self.shapeView.frame.size.width, y: self.shapeView.frame.size.height),
                      controlPoint1: CGPoint(x: self.shapeView.frame.size.width*0.40, y: 0),
                      controlPoint2: CGPoint(x: self.shapeView.frame.size.width*0.60, y: 20))
        path.addLine(to: CGPoint(x: self.shapeView.frame.size.width, y: self.shapeView.frame.size.height))
        path.addLine(to: CGPoint(x: 0.0, y: self.shapeView.frame.size.height))
        path.close()

        let shapeLayer = CAShapeLayer()
        shapeLayer.path = path.cgPath
        shapeLayer.fillColor = UIColor.App.backgroundPrimary.cgColor

        self.shapeView.layer.mask = shapeLayer
        self.shapeView.layer.masksToBounds = true

    }

    private func setupWithTheme() {

        self.containerView.backgroundColor = UIColor.App.backgroundPrimary

        self.topGradientView.colors = [(UIColor.App.topBarGradient1, NSNumber(0.0)),
                                       (UIColor.App.topBarGradient2, NSNumber(0.5)),
                                       (UIColor.App.topBarGradient3, NSNumber(1.0))]

        self.closeButton.setTitleColor(UIColor.App.highlightPrimary, for: .normal)

        self.logoImageView.backgroundColor = .clear

        self.titleLabel.textColor = UIColor.App.buttonTextPrimary

        self.subtitleLabel.textColor = UIColor.App.textPrimary

        self.shapeView.backgroundColor = UIColor.App.backgroundPrimary

        StyleHelper.styleButton(button: self.continueButton)

    }

    func setTextInfo(title: String, subtitle: String) {

        self.titleLabel.text = title

        self.subtitleLabel.text = subtitle
    }

    @objc private func didTapCloseButton() {

        self.dismiss(animated: true)

    }

    @objc private func didTapContinueButton() {

        self.dismiss(animated: true)

    }
}

extension GenericErrorViewController {

    private static func createContainerView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }

    private static func createTopGradientView() -> GradientView {
        let view = GradientView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }

    private static func createShapeView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }

    private static func createCloseButton() -> UIButton {
        let button = UIButton()
        button.setTitle(localized("close"), for: .normal)
        button.titleLabel?.font = AppFont.with(type: .bold, size: 16)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }

    private static func createLogoImageView() -> UIImageView {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.image = UIImage(named: "error_alert_icon")
        imageView.contentMode = .scaleAspectFit

        return imageView
    }

    private static func createTitleLabel() -> UILabel {
        let label = UILabel()
        label.font = AppFont.with(type: .bold, size: 30)
        label.text = "\(localized("oh_no"))!"
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }

    private static func createSubtitleLabel() -> UILabel {
        let label = UILabel()
        label.font = AppFont.with(type: .bold, size: 16)
        label.text = localized("error")
        label.textAlignment = .center
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }

    private static func createContinueButton() -> UIButton {
        let button = UIButton()
        button.setTitle(localized("go_back"), for: .normal)
        button.titleLabel?.font = AppFont.with(type: .bold, size: 16)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }

    private func setupSubviews() {

        self.view.addSubview(self.containerView)

        self.containerView.addSubview(self.topGradientView)

        self.topGradientView.addSubview(self.closeButton)

        self.topGradientView.addSubview(self.logoImageView)
        self.topGradientView.addSubview(self.titleLabel)

        self.topGradientView.addSubview(self.shapeView)

        self.containerView.addSubview(self.subtitleLabel)
        self.containerView.addSubview(self.continueButton)

        self.initConstraints()

    }

    private func initConstraints() {

        NSLayoutConstraint.activate([

            self.containerView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            self.containerView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            self.containerView.topAnchor.constraint(equalTo: self.view.topAnchor),
            self.containerView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor),

            self.topGradientView.leadingAnchor.constraint(equalTo: self.containerView.leadingAnchor),
            self.topGradientView.trailingAnchor.constraint(equalTo: self.containerView.trailingAnchor),
            self.topGradientView.topAnchor.constraint(equalTo: self.containerView.topAnchor),
            self.topGradientView.bottomAnchor.constraint(equalTo: self.containerView.centerYAnchor),

            self.shapeView.leadingAnchor.constraint(equalTo: self.topGradientView.leadingAnchor),
            self.shapeView.trailingAnchor.constraint(equalTo: self.topGradientView.trailingAnchor),
            self.shapeView.bottomAnchor.constraint(equalTo: self.topGradientView.bottomAnchor),
            self.shapeView.heightAnchor.constraint(equalToConstant: 40),

            self.closeButton.trailingAnchor.constraint(equalTo: self.containerView.trailingAnchor, constant: -34),
            self.closeButton.topAnchor.constraint(equalTo: self.containerView.topAnchor, constant: 20),
            self.closeButton.heightAnchor.constraint(equalToConstant: 40),

            self.logoImageView.topAnchor.constraint(equalTo: self.closeButton.bottomAnchor, constant: 60),
            self.logoImageView.widthAnchor.constraint(equalToConstant: 190),
            self.logoImageView.heightAnchor.constraint(equalToConstant: 150),
            self.logoImageView.centerXAnchor.constraint(equalTo: self.topGradientView.centerXAnchor),

            self.titleLabel.leadingAnchor.constraint(equalTo: self.topGradientView.leadingAnchor, constant: 30),
            self.titleLabel.trailingAnchor.constraint(equalTo: self.topGradientView.trailingAnchor, constant: -30),
            self.titleLabel.topAnchor.constraint(equalTo: self.logoImageView.bottomAnchor, constant: 40),

            self.subtitleLabel.leadingAnchor.constraint(equalTo: self.containerView.leadingAnchor, constant: 30),
            self.subtitleLabel.trailingAnchor.constraint(equalTo: self.containerView.trailingAnchor, constant: -30),
            self.subtitleLabel.topAnchor.constraint(equalTo: self.topGradientView.bottomAnchor, constant: 20),

            self.continueButton.leadingAnchor.constraint(equalTo: self.containerView.leadingAnchor, constant: 30),
            self.continueButton.trailingAnchor.constraint(equalTo: self.containerView.trailingAnchor, constant: -30),
            self.continueButton.bottomAnchor.constraint(equalTo: self.containerView.bottomAnchor, constant: -50),
            self.continueButton.heightAnchor.constraint(equalToConstant: 50)
        ])

    }
}
