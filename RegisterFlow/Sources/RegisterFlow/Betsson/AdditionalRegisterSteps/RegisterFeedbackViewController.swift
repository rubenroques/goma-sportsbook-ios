//
//  File.swift
//  
//
//  Created by Ruben Roques on 27/01/2023.
//

import Foundation
import UIKit
import Theming

public struct RegisterFeedbackViewModel {
    public var registerSuccess: Bool

    public init(registerSuccess: Bool) {
        self.registerSuccess = registerSuccess
    }
}

public class RegisterFeedbackViewController: UIViewController {

    public var didTapContinueButtonAction: () -> Void = { }

    private lazy var contentBaseView: UIView = Self.createContentBaseView()
    private lazy var feedbackImageView: UIImageView = Self.createFeedbackImageView()
    private lazy var titleLabel: UILabel = Self.createTitleLabel()
    private lazy var subtitleLabel: UILabel = Self.createSubtitleLabel()

    private lazy var footerBaseView: UIView = Self.createFooterBaseView()
    private lazy var continueButton: UIButton = Self.createContinueButton()

    let viewModel: RegisterFeedbackViewModel

    public init(viewModel: RegisterFeedbackViewModel) {

        self.viewModel = viewModel

        super.init(nibName: nil, bundle: nil)
    }

    @available(iOS, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override public func viewDidLoad() {
        super.viewDidLoad()

        self.setupSubviews()
        self.setupWithTheme()

        if self.viewModel.registerSuccess {
            self.feedbackImageView.image = UIImage(named: "registerSuccess", in: Bundle.module, compatibleWith: nil)
            self.titleLabel.text = "Congratulations!"
            self.subtitleLabel.text = "Your account is registered. Now you only need to verify your identity."
            self.continueButton.setTitle("Continue", for: .normal)
        }
        else {
            self.feedbackImageView.image = UIImage(named: "registerError", in: Bundle.module, compatibleWith: nil)
            self.titleLabel.text = "Oh no!"
            self.subtitleLabel.text = "Sorry there was a problem while creating your account, contact us for help."
            self.continueButton.setTitle("Contact Us", for: .normal)
        }

        self.continueButton.addTarget(self, action: #selector(didTapContinueButton), for: .primaryActionTriggered)
    }

    override public func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)

        self.setupWithTheme()
    }

    private func setupWithTheme() {
        self.view.backgroundColor = AppColor.backgroundPrimary
        self.contentBaseView.backgroundColor = AppColor.backgroundPrimary

        self.titleLabel.textColor = AppColor.textPrimary
        self.subtitleLabel.textColor = AppColor.textPrimary

        // Continue button styling
        self.continueButton.setTitleColor(AppColor.buttonTextPrimary, for: .normal)
        self.continueButton.setTitleColor(AppColor.buttonTextPrimary.withAlphaComponent(0.7), for: .highlighted)
        self.continueButton.setTitleColor(AppColor.buttonTextDisablePrimary.withAlphaComponent(0.39), for: .disabled)

        self.continueButton.setBackgroundColor(AppColor.buttonBackgroundPrimary, for: .normal)
        self.continueButton.setBackgroundColor(AppColor.buttonBackgroundSecondary, for: .highlighted)

        self.continueButton.layer.cornerRadius = 8
        self.continueButton.layer.masksToBounds = true
        self.continueButton.backgroundColor = .clear
    }

    @objc func didTapContinueButton() {
        self.didTapContinueButtonAction()
    }
}

public extension RegisterFeedbackViewController {

    private static func createContentBaseView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }

    private static func createFeedbackImageView() -> UIImageView {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }

    private static func createTitleLabel() -> UILabel {
        let label = UILabel()
        label.font = AppFont.with(type: .bold, size: 30)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }

    private static func createSubtitleLabel() -> UILabel {
        let label = UILabel()
        label.font = AppFont.with(type: .bold, size: 16)
        label.textAlignment = .left
        label.numberOfLines = 2
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }

    private static func createFooterBaseView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }

    private static func createContinueButton() -> UIButton {
        let button = UIButton()
        button.setTitle("Continue", for: .normal)
        button.titleLabel?.font = AppFont.with(type: .bold, size: 18)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.layer.cornerRadius = 8
        return button
    }

    private func setupSubviews() {

        self.view.addSubview(self.contentBaseView)
        self.contentBaseView.addSubview(self.feedbackImageView)
        self.contentBaseView.addSubview(self.titleLabel)
        self.contentBaseView.addSubview(self.subtitleLabel)

        self.view.addSubview(self.footerBaseView)
        self.footerBaseView.addSubview(self.continueButton)

        self.initConstraints()
    }

    private func initConstraints() {

        NSLayoutConstraint.activate([

            self.feedbackImageView.topAnchor.constraint(equalTo: self.contentBaseView.topAnchor, constant: 8),
            self.feedbackImageView.widthAnchor.constraint(equalTo: self.feedbackImageView.heightAnchor),
            self.feedbackImageView.widthAnchor.constraint(equalToConstant: 200),
            self.feedbackImageView.centerXAnchor.constraint(equalTo: self.contentBaseView.centerXAnchor),

            self.titleLabel.topAnchor.constraint(equalTo: self.feedbackImageView.bottomAnchor, constant: 28),
            self.titleLabel.leadingAnchor.constraint(equalTo: self.contentBaseView.leadingAnchor),
            self.titleLabel.trailingAnchor.constraint(equalTo: self.contentBaseView.trailingAnchor),

            self.subtitleLabel.topAnchor.constraint(equalTo: self.titleLabel.bottomAnchor, constant: 28),
            self.subtitleLabel.leadingAnchor.constraint(equalTo: self.contentBaseView.leadingAnchor),
            self.subtitleLabel.trailingAnchor.constraint(equalTo: self.contentBaseView.trailingAnchor),

            self.subtitleLabel.bottomAnchor.constraint(equalTo: self.contentBaseView.bottomAnchor, constant: -8),

            self.contentBaseView.leadingAnchor.constraint(equalTo: self.continueButton.leadingAnchor),
            self.contentBaseView.trailingAnchor.constraint(equalTo: self.continueButton.trailingAnchor),

            self.contentBaseView.bottomAnchor.constraint(equalTo: self.view.centerYAnchor, constant: -10),

            self.footerBaseView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            self.footerBaseView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            self.footerBaseView.heightAnchor.constraint(equalToConstant: 70),
            self.footerBaseView.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor),

            self.continueButton.centerXAnchor.constraint(equalTo: self.footerBaseView.centerXAnchor),
            self.continueButton.centerYAnchor.constraint(equalTo: self.footerBaseView.centerYAnchor),
            self.continueButton.leadingAnchor.constraint(equalTo: self.footerBaseView.leadingAnchor, constant: 34),
            self.continueButton.heightAnchor.constraint(equalToConstant: 50),

        ])
    }

}
