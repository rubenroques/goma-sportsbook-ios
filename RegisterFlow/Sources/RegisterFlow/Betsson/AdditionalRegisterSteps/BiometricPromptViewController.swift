//
//  BiometricPromptViewController.swift
//  
//
//  Created by Ruben Roques on 27/01/2023.
//

import Foundation
import Foundation
import UIKit
import Theming

public class BiometricPromptViewController: UIViewController {

    public var didTapActivateButtonAction: () -> Void = { }
    public var didTapLaterButtonAction: () -> Void = { }

    public var didTapBackButtonAction: () -> Void = { }
    public var didTapCancelButtonAction: () -> Void = { }

    public var didActivatedBiometricsAction: () -> Void = { }

    private lazy var headerBaseView: UIView = Self.createHeaderBaseView()
    private lazy var backButton: UIButton = Self.createBackButton()
    private lazy var cancelButton: UIButton = Self.createCancelButton()

    private lazy var contentBaseView: UIView = Self.createContentBaseView()
    private lazy var titleLabel: UILabel = Self.createTitleLabel()
    private lazy var subtitleLabel: UILabel = Self.createSubtitleLabel()
    private lazy var detailsLabel: UILabel = Self.createDetailsLabel()

    private lazy var footerBaseView: UIView = Self.createFooterBaseView()
    private lazy var continueButton: UIButton = Self.createContinueButton()
    private lazy var laterButton: UIButton = Self.createContinueButton()

    public init() {
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

        self.titleLabel.text = "Login with Biometric"
        self.subtitleLabel.text = "Do you want to login with Fingerprint/Face Recognization?"
        self.detailsLabel.text = "At any moment, you can disable it in the app settings."

        self.continueButton.setTitle("Activate", for: .normal)
        self.laterButton.setTitle("Later", for: .normal)

        self.continueButton.addTarget(self, action: #selector(didTapActivateButton), for: .primaryActionTriggered)
        self.laterButton.addTarget(self, action: #selector(didTapLaterButton), for: .primaryActionTriggered)

        self.cancelButton.addTarget(self, action: #selector(didTapCancelButton), for: .primaryActionTriggered)
        self.backButton.addTarget(self, action: #selector(didTapBackButton), for: .primaryActionTriggered)
    }

    override public func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)

        self.setupWithTheme()
    }

    private func setupWithTheme() {
        self.view.backgroundColor = AppColor.backgroundPrimary
        self.contentBaseView.backgroundColor = AppColor.backgroundPrimary

        self.cancelButton.setTitleColor(AppColor.highlightPrimary, for: .normal)

        self.titleLabel.textColor = AppColor.textPrimary
        self.subtitleLabel.textColor = AppColor.textPrimary
        self.detailsLabel.textColor = AppColor.textSecondary

        // Continue button styling
        self.continueButton.setTitleColor(AppColor.buttonTextPrimary, for: .normal)
        self.continueButton.setTitleColor(AppColor.buttonTextPrimary.withAlphaComponent(0.7), for: .highlighted)
        self.continueButton.setTitleColor(AppColor.buttonTextDisablePrimary.withAlphaComponent(0.39), for: .disabled)

        self.continueButton.setBackgroundColor(AppColor.buttonBackgroundPrimary, for: .normal)
        self.continueButton.setBackgroundColor(AppColor.buttonBackgroundSecondary, for: .highlighted)

        self.continueButton.layer.cornerRadius = 8
        self.continueButton.layer.masksToBounds = true
        self.continueButton.backgroundColor = .clear

        // Continue button styling
        self.laterButton.setTitleColor(AppColor.textPrimary, for: .normal)
        self.laterButton.setTitleColor(AppColor.textPrimary.withAlphaComponent(0.7), for: .highlighted)
        self.laterButton.setTitleColor(AppColor.textPrimary.withAlphaComponent(0.39), for: .disabled)

        self.laterButton.setBackgroundColor(UIColor.clear, for: .normal)
        self.laterButton.setBackgroundColor(UIColor.clear, for: .highlighted)

    }

    @objc func didTapBackButton() {
        self.didTapBackButtonAction()
    }

    @objc func didTapCancelButton() {
        self.didTapCancelButtonAction()
    }

    @objc func didTapActivateButton() {
        self.didTapActivateButtonAction()
    }

    @objc func didTapLaterButton() {
        self.didTapLaterButtonAction()
    }

}

public extension BiometricPromptViewController {

    private static func createHeaderBaseView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }

    private static func createBackButton() -> UIButton {
        let button = UIButton()
        let image = UIImage(named: "back_icon", in: Bundle.module, with: nil)
        button.setImage(image, for: .normal)
        button.setTitle(nil, for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }

    private static func createCancelButton() -> UIButton {
        let button = UIButton()
        button.setTitle("Close", for: .normal)
        button.titleLabel?.font = AppFont.with(type: .bold, size: 16)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }
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
        label.textAlignment = .left
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


    private static func createDetailsLabel() -> UILabel {
        let label = UILabel()
        label.font = AppFont.with(type: .semibold, size: 14)
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


        self.view.addSubview(self.headerBaseView)
        self.headerBaseView.addSubview(self.backButton)
        self.headerBaseView.addSubview(self.cancelButton)

        self.view.addSubview(self.contentBaseView)
        self.contentBaseView.addSubview(self.titleLabel)
        self.contentBaseView.addSubview(self.subtitleLabel)
        self.contentBaseView.addSubview(self.detailsLabel)

        self.view.addSubview(self.footerBaseView)
        self.footerBaseView.addSubview(self.continueButton)
        self.footerBaseView.addSubview(self.laterButton)

        self.initConstraints()
    }

    private func initConstraints() {

        NSLayoutConstraint.activate([
            self.headerBaseView.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor),
            self.headerBaseView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            self.headerBaseView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            self.headerBaseView.heightAnchor.constraint(equalToConstant: 68),

            self.backButton.leadingAnchor.constraint(equalTo: self.headerBaseView.leadingAnchor, constant: 18),
            self.backButton.centerYAnchor.constraint(equalTo: self.headerBaseView.centerYAnchor),
            self.backButton.widthAnchor.constraint(equalTo: self.backButton.heightAnchor),
            self.backButton.widthAnchor.constraint(equalToConstant: 40),

            self.cancelButton.centerYAnchor.constraint(equalTo: self.headerBaseView.centerYAnchor),
            self.cancelButton.trailingAnchor.constraint(equalTo: self.headerBaseView.trailingAnchor, constant: -34),

            self.titleLabel.topAnchor.constraint(equalTo: self.contentBaseView.topAnchor, constant: 8),
            self.titleLabel.leadingAnchor.constraint(equalTo: self.contentBaseView.leadingAnchor),
            self.titleLabel.trailingAnchor.constraint(equalTo: self.contentBaseView.trailingAnchor),

            self.subtitleLabel.topAnchor.constraint(equalTo: self.titleLabel.bottomAnchor, constant: 28),
            self.subtitleLabel.leadingAnchor.constraint(equalTo: self.contentBaseView.leadingAnchor),
            self.subtitleLabel.trailingAnchor.constraint(equalTo: self.contentBaseView.trailingAnchor),

            self.detailsLabel.topAnchor.constraint(equalTo: self.subtitleLabel.bottomAnchor, constant: 16),
            self.detailsLabel.leadingAnchor.constraint(equalTo: self.contentBaseView.leadingAnchor),
            self.detailsLabel.trailingAnchor.constraint(equalTo: self.contentBaseView.trailingAnchor),

            self.detailsLabel.bottomAnchor.constraint(equalTo: self.contentBaseView.bottomAnchor, constant: -8),

            self.contentBaseView.leadingAnchor.constraint(equalTo: self.continueButton.leadingAnchor),
            self.contentBaseView.trailingAnchor.constraint(equalTo: self.continueButton.trailingAnchor),

            self.contentBaseView.bottomAnchor.constraint(equalTo: self.view.centerYAnchor, constant: -10),

            self.footerBaseView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            self.footerBaseView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            self.footerBaseView.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor),

            self.continueButton.topAnchor.constraint(equalTo: self.footerBaseView.topAnchor, constant: 8),
            self.continueButton.centerXAnchor.constraint(equalTo: self.footerBaseView.centerXAnchor),
            self.continueButton.leadingAnchor.constraint(equalTo: self.footerBaseView.leadingAnchor, constant: 34),
            self.continueButton.heightAnchor.constraint(equalToConstant: 50),

            self.continueButton.bottomAnchor.constraint(equalTo: self.laterButton.topAnchor, constant: -8),

            self.laterButton.centerXAnchor.constraint(equalTo: self.footerBaseView.centerXAnchor),
            self.laterButton.leadingAnchor.constraint(equalTo: self.footerBaseView.leadingAnchor, constant: 34),
            self.laterButton.heightAnchor.constraint(equalToConstant: 50),
            self.laterButton.bottomAnchor.constraint(equalTo: self.footerBaseView.bottomAnchor, constant: -8),

        ])
    }

}
