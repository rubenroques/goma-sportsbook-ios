//
//  LimitsOnRegisterViewController.swift
//  
//
//  Created by Ruben Roques on 27/01/2023.
//

import Foundation
import Foundation
import UIKit
import Theming

public class LimitsOnRegisterViewController: UIViewController {

    public var didTapContinueButtonAction: () -> Void = { }

    public var didTapBackButtonAction: () -> Void = { }
    public var didTapCancelButtonAction: () -> Void = { }

    private lazy var headerBaseView: UIView = Self.createHeaderBaseView()
    private lazy var backButton: UIButton = Self.createBackButton()
    private lazy var cancelButton: UIButton = Self.createCancelButton()

    private lazy var contentBaseView: UIView = Self.createContentBaseView()
    private lazy var titleLabel: UILabel = Self.createTitleLabel()
    private lazy var subtitleLabel: UILabel = Self.createSubtitleLabel()

    private lazy var stackView: UIStackView = Self.createStackView()

    private lazy var depositLimitHeaderTextFieldView: HeaderTextFieldView = Self.createHeaderTextFieldView()
    private lazy var bettingLimitHeaderTextFieldView: HeaderTextFieldView = Self.createHeaderTextFieldView()
    private lazy var autoPayoutHeaderTextFieldView: HeaderTextFieldView = Self.createHeaderTextFieldView()

    private lazy var footerBaseView: UIView = Self.createFooterBaseView()
    private lazy var continueButton: UIButton = Self.createContinueButton()

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

        self.titleLabel.text = "Limits Management"
        self.subtitleLabel.text = "What type of playerare you?"

        self.continueButton.setTitle("Continue", for: .normal)

        self.continueButton.addTarget(self, action: #selector(didTapContinueButton), for: .primaryActionTriggered)

        self.cancelButton.addTarget(self, action: #selector(didTapCancelButton), for: .primaryActionTriggered)
        self.backButton.addTarget(self, action: #selector(didTapBackButton), for: .primaryActionTriggered)

        self.depositLimitHeaderTextFieldView.setPlaceholderText("Deposit Limit")
        self.bettingLimitHeaderTextFieldView.setPlaceholderText("Betting Limit")
        self.autoPayoutHeaderTextFieldView.setPlaceholderText("Auto Payout")

        self.depositLimitHeaderTextFieldView.setKeyboardType(.numbersAndPunctuation)
        self.bettingLimitHeaderTextFieldView.setKeyboardType(.numbersAndPunctuation)
        self.autoPayoutHeaderTextFieldView.setKeyboardType(.numbersAndPunctuation)

        self.depositLimitHeaderTextFieldView.setReturnKeyType(.next)
        self.depositLimitHeaderTextFieldView.didTapReturn = { [weak self] in
            self?.bettingLimitHeaderTextFieldView.becomeFirstResponder()
        }

        self.bettingLimitHeaderTextFieldView.setReturnKeyType(.next)
        self.bettingLimitHeaderTextFieldView.didTapReturn = { [weak self] in
            self?.autoPayoutHeaderTextFieldView.becomeFirstResponder()
        }

        self.autoPayoutHeaderTextFieldView.setReturnKeyType(.done)
        self.autoPayoutHeaderTextFieldView.didTapReturn = { [weak self] in
            self?.autoPayoutHeaderTextFieldView.resignFirstResponder()
        }

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

        self.depositLimitHeaderTextFieldView.backgroundColor = AppColor.backgroundPrimary
        self.depositLimitHeaderTextFieldView.setHeaderLabelColor(AppColor.inputTextTitle)
        self.depositLimitHeaderTextFieldView.setTextFieldColor(AppColor.inputText)

        self.bettingLimitHeaderTextFieldView.backgroundColor = AppColor.backgroundPrimary
        self.bettingLimitHeaderTextFieldView.setHeaderLabelColor(AppColor.inputTextTitle)
        self.bettingLimitHeaderTextFieldView.setTextFieldColor(AppColor.inputText)

        self.autoPayoutHeaderTextFieldView.backgroundColor = AppColor.backgroundPrimary
        self.autoPayoutHeaderTextFieldView.setHeaderLabelColor(AppColor.inputTextTitle)
        self.autoPayoutHeaderTextFieldView.setTextFieldColor(AppColor.inputText)

    }

    @objc func didTapBackButton() {
        self.didTapBackButtonAction()
    }

    @objc func didTapCancelButton() {
        self.didTapCancelButtonAction()
    }

    @objc func didTapContinueButton() {
        self.didTapContinueButtonAction()
    }

}

public extension LimitsOnRegisterViewController {

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

    private static func createStackView() -> UIStackView {
        let stackview = UIStackView()
        stackview.distribution = .fill
        stackview.axis = .vertical
        stackview.spacing = 22
        stackview.translatesAutoresizingMaskIntoConstraints = false
        return stackview
    }

    private static func createHeaderTextFieldView() -> HeaderTextFieldView {
        let headerTextFieldView = HeaderTextFieldView()
        headerTextFieldView.setTextFieldFont(AppFont.with(type: .semibold, size: 16))
        headerTextFieldView.setHeaderLabelFont(AppFont.with(type: .semibold, size: 16))
        headerTextFieldView.translatesAutoresizingMaskIntoConstraints = false
        return headerTextFieldView
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

        let topPlaceholderView = UIView()
        topPlaceholderView.translatesAutoresizingMaskIntoConstraints = false
        topPlaceholderView.backgroundColor = .clear
        NSLayoutConstraint.activate([
            topPlaceholderView.heightAnchor.constraint(equalToConstant: 40)
        ])
        self.stackView.addArrangedSubview(topPlaceholderView)
        self.stackView.addArrangedSubview(self.depositLimitHeaderTextFieldView)
        self.stackView.addArrangedSubview(self.bettingLimitHeaderTextFieldView)
        self.stackView.addArrangedSubview(self.autoPayoutHeaderTextFieldView)

        self.contentBaseView.addSubview(self.stackView)

        self.view.addSubview(self.footerBaseView)
        self.footerBaseView.addSubview(self.continueButton)

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

            self.depositLimitHeaderTextFieldView.heightAnchor.constraint(equalToConstant: 80),
            self.bettingLimitHeaderTextFieldView.heightAnchor.constraint(equalToConstant: 80),
            self.autoPayoutHeaderTextFieldView.heightAnchor.constraint(equalToConstant: 80),

            self.stackView.topAnchor.constraint(equalTo: self.subtitleLabel.bottomAnchor, constant: -12),
            self.stackView.leadingAnchor.constraint(equalTo: self.contentBaseView.leadingAnchor),
            self.stackView.trailingAnchor.constraint(equalTo: self.contentBaseView.trailingAnchor),
            self.stackView.bottomAnchor.constraint(equalTo: self.contentBaseView.bottomAnchor, constant: -8),

            self.contentBaseView.leadingAnchor.constraint(equalTo: self.continueButton.leadingAnchor),
            self.contentBaseView.trailingAnchor.constraint(equalTo: self.continueButton.trailingAnchor),
            self.contentBaseView.centerYAnchor.constraint(equalTo: self.view.centerYAnchor, constant: -10),

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
