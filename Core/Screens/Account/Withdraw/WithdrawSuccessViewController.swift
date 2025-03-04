//
//  WithdrawSuccessViewController.swift
//  Sportsbook
//
//  Created by André Lascas on 16/03/2023.
//

import UIKit

class WithdrawSuccessViewController: UIViewController {

    private lazy var containerView: UIView = Self.createContainerView()
    private lazy var logoImageView: UIImageView = Self.createLogoImageView()
    private lazy var titleLabel: UILabel = Self.createTitleLabel()
    private lazy var messageLabel: UILabel = Self.createMessageLabel()
    private lazy var continueButton: UIButton = Self.createContinueButton()

    // MARK: - Lifetime and Cycle
    init() {

        super.init(nibName: nil, bundle: nil)

    }

    @available(iOS, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        self.setupSubviews()

        self.setupWithTheme()

        self.continueButton.addTarget(self, action: #selector(didTapContinueButton), for: .primaryActionTriggered)

    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)

        self.setupWithTheme()
    }

    private func setupWithTheme() {
        self.view.backgroundColor = UIColor.App.backgroundPrimary

        self.containerView.backgroundColor = UIColor.App.backgroundPrimary

        self.logoImageView.backgroundColor = .clear

        self.titleLabel.textColor = UIColor.App.textPrimary

        self.messageLabel.textColor = UIColor.App.textPrimary

        self.continueButton.setBackgroundColor(UIColor.App.highlightPrimary, for: .normal)
        self.continueButton.setBackgroundColor(UIColor.App.buttonDisablePrimary, for: .disabled)
        self.continueButton.setTitleColor(UIColor.App.buttonTextPrimary, for: .normal)
        self.continueButton.setTitleColor(UIColor.App.textDisablePrimary, for: .disabled)
        self.continueButton.layer.cornerRadius = CornerRadius.button
        self.continueButton.layer.masksToBounds = true
    }

    // MARK: Functions
    func configureInfo(title: String, message: String) {
        self.titleLabel.text = title

        self.messageLabel.text = message
    }

    // MARK: Actions
    @objc func didTapContinueButton() {
        self.dismiss(animated: true)
    }
}

extension WithdrawSuccessViewController {

    private static func createContainerView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }

    private static func createLogoImageView() -> UIImageView {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.image = UIImage(named: "like_success_icon")
        imageView.contentMode = .scaleAspectFit
        return imageView
    }

    private static func createTitleLabel() -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = UIColor.App.textPrimary
        label.font = AppFont.with(type: .bold, size: 14)
        label.textAlignment = .center
        label.text = localized("withdrawal_request_sent_title")
        label.numberOfLines = 0
        return label
    }

    private static func createMessageLabel() -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = UIColor.App.textPrimary
        label.font = AppFont.with(type: .semibold, size: 14)
        label.textAlignment = .center
        label.text = localized("withdrawal_request_sent_text")
        label.numberOfLines = 0
        return label
    }

    private static func createContinueButton() -> UIButton {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle(localized("continue_"), for: .normal)
        button.titleLabel?.font = AppFont.with(type: .bold, size: 17)
        StyleHelper.styleButton(button: button)
        return button
    }

    private func setupSubviews() {

        self.view.addSubview(self.containerView)

        self.containerView.addSubview(self.logoImageView)
        self.containerView.addSubview(self.titleLabel)
        self.containerView.addSubview(self.messageLabel)
        self.containerView.addSubview(self.continueButton)

        self.initConstraints()
    }

    private func initConstraints() {

        // Container view
        NSLayoutConstraint.activate([
            self.containerView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            self.containerView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            self.containerView.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor),
            self.containerView.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor),

            self.logoImageView.widthAnchor.constraint(equalToConstant: 64),
            self.logoImageView.heightAnchor.constraint(equalToConstant: 48),
            self.logoImageView.topAnchor.constraint(equalTo: self.containerView.centerYAnchor, constant: -100),
            self.logoImageView.centerXAnchor.constraint(equalTo: self.containerView.centerXAnchor),

            self.titleLabel.leadingAnchor.constraint(equalTo: self.containerView.leadingAnchor, constant: 60),
            self.titleLabel.trailingAnchor.constraint(equalTo: self.containerView.trailingAnchor, constant: -60),
            self.titleLabel.topAnchor.constraint(equalTo: self.logoImageView.bottomAnchor, constant: 10),

            self.messageLabel.leadingAnchor.constraint(equalTo: self.containerView.leadingAnchor, constant: 60),
            self.messageLabel.trailingAnchor.constraint(equalTo: self.containerView.trailingAnchor, constant: -60),
            self.messageLabel.topAnchor.constraint(equalTo: self.titleLabel.bottomAnchor, constant: 20),

            self.continueButton.leadingAnchor.constraint(equalTo: self.containerView.leadingAnchor, constant: 25),
            self.continueButton.trailingAnchor.constraint(equalTo: self.containerView.trailingAnchor, constant: -25),
            self.continueButton.heightAnchor.constraint(equalToConstant: 50),
            self.continueButton.bottomAnchor.constraint(equalTo: self.containerView.bottomAnchor, constant: -34)
        ])
    }
}
