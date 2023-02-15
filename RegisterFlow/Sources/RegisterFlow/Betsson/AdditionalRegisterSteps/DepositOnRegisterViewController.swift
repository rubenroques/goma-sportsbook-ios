//
//  DepositOnRegisterViewController.swift
//  
//
//  Created by Ruben Roques on 27/01/2023.
//

import Foundation
import UIKit
import Theming

public class DepositOnRegisterViewController: UIViewController {

    public var didTapDepositButtonAction: (String) -> Void = { amount in }

    public var didTapBackButtonAction: () -> Void = { }
    public var didTapCancelButtonAction: () -> Void = { }

    private lazy var headerBaseView: UIView = Self.createHeaderBaseView()
    private lazy var backButton: UIButton = Self.createBackButton()
    private lazy var cancelButton: UIButton = Self.createCancelButton()

    private lazy var promoImageView: UIImageView = Self.createPromoImageView()

    private lazy var contentBaseView: UIView = Self.createContentBaseView()
    private lazy var titleLabel: UILabel = Self.createTitleLabel()
    private lazy var subtitleLabel: UILabel = Self.createSubtitleLabel()

    private lazy var depositHeaderTextFieldView: HeaderTextFieldView = Self.createHeaderTextFieldView()
    private lazy var depositSubtitleLabel: UILabel = Self.createDepositSubtitleLabel()

    private lazy var amountButtonsStackView: UIStackView = Self.createAmountButtonsStackView()
    private lazy var amountButton1: UIButton = Self.createAmountButton()
    private lazy var amountButton2: UIButton = Self.createAmountButton()
    private lazy var amountButton3: UIButton = Self.createAmountButton()
    private lazy var amountButton4: UIButton = Self.createAmountButton()

    private lazy var footerBaseView: UIView = Self.createFooterBaseView()
    private lazy var depositButton: UIButton = Self.createDepositButton()

    private lazy var loadingBaseView: UIView = Self.createLoadingBaseView()
    private lazy var activityIndicatorView: UIActivityIndicatorView = Self.createActivityIndicatorView()

    public var isLoading: Bool = false {
        didSet {
            self.loadingBaseView.isHidden = !isLoading
        }
    }

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

        self.titleLabel.text = "Deposit"
        self.subtitleLabel.text = "Make your first deposit and win 5€ of freebet."

        self.depositButton.setTitle("Deposit", for: .normal)

        self.depositButton.addTarget(self, action: #selector(didTapDepositButton), for: .primaryActionTriggered)

        self.cancelButton.addTarget(self, action: #selector(didTapCancelButton), for: .primaryActionTriggered)
        self.backButton.addTarget(self, action: #selector(didTapBackButton), for: .primaryActionTriggered)

        self.backButton.isHidden = true

        self.amountButton1.titleLabel?.font = AppFont.with(type: .bold, size: 16)
        self.amountButton2.titleLabel?.font = AppFont.with(type: .bold, size: 16)
        self.amountButton3.titleLabel?.font = AppFont.with(type: .bold, size: 16)
        self.amountButton4.titleLabel?.font = AppFont.with(type: .bold, size: 16)

        self.depositHeaderTextFieldView.setCurrencyMode(true, currencySymbol: "€")

        self.amountButton1.setTitle("€10", for: .normal)
        self.amountButton2.setTitle("€20", for: .normal)
        self.amountButton3.setTitle("€50", for: .normal)
        self.amountButton4.setTitle("€100", for: .normal)

        self.amountButton1.addTarget(self, action: #selector(didTapAmountButton1), for: .primaryActionTriggered)
        self.amountButton2.addTarget(self, action: #selector(didTapAmountButton2), for: .primaryActionTriggered)
        self.amountButton3.addTarget(self, action: #selector(didTapAmountButton3), for: .primaryActionTriggered)
        self.amountButton4.addTarget(self, action: #selector(didTapAmountButton4), for: .primaryActionTriggered)


        self.depositHeaderTextFieldView.setPlaceholderText("Deposit Value")
        self.depositHeaderTextFieldView.setKeyboardType(.decimalPad)
        self.depositSubtitleLabel.text = "Minimum Value: 10€"

        self.isLoading = false

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


        self.depositHeaderTextFieldView.setViewColor(AppColor.inputBackground)
        self.depositHeaderTextFieldView.setHeaderLabelColor(AppColor.inputTextTitle)
        self.depositHeaderTextFieldView.setTextFieldColor(AppColor.inputText)

        self.depositSubtitleLabel.textColor = AppColor.textSecondary

        self.configureStyleOnButton(self.depositButton)
        self.configureStyleOnButton(self.amountButton1)
        self.configureStyleOnButton(self.amountButton2)
        self.configureStyleOnButton(self.amountButton3)
        self.configureStyleOnButton(self.amountButton4)

        self.loadingBaseView.backgroundColor = AppColor.backgroundPrimary.withAlphaComponent(0.7)

    }

    @objc func didTapBackButton() {
        self.didTapBackButtonAction()
    }

    @objc func didTapCancelButton() {
        self.didTapCancelButtonAction()
    }

    @objc func didTapDepositButton() {
        let amount = self.depositHeaderTextFieldView.text
        self.didTapDepositButtonAction(amount)
    }

    @objc func didTapAmountButton1() {
        self.depositHeaderTextFieldView.setText("10")
    }

    @objc func didTapAmountButton2() {
        self.depositHeaderTextFieldView.setText("20")
    }

    @objc func didTapAmountButton3() {
        self.depositHeaderTextFieldView.setText("50")
    }

    @objc func didTapAmountButton4() {
        self.depositHeaderTextFieldView.setText("100")
    }

    private func configureStyleOnButton(_ button: UIButton) {

        button.setTitleColor(AppColor.buttonTextPrimary, for: .normal)
        button.setTitleColor(AppColor.buttonTextPrimary.withAlphaComponent(0.7), for: .highlighted)
        button.setTitleColor(AppColor.buttonTextDisablePrimary, for: .disabled)

        button.setBackgroundColor(AppColor.buttonBackgroundPrimary, for: .normal)
        button.setBackgroundColor(AppColor.buttonBackgroundSecondary, for: .highlighted)

        button.layer.cornerRadius = 8
        button.layer.masksToBounds = true
        button.backgroundColor = .clear

    }

    public func showErrorAlert(errorMessage: String) {

        let errorTitle = "Deposit Error"
        let errorMessage = errorMessage

        let alert = UIAlertController(title: errorTitle,
                                      message: errorMessage,
                                      preferredStyle: .alert)

        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }

}

public extension DepositOnRegisterViewController {

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

    private static func createPromoImageView() -> UIImageView {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 8
        imageView.backgroundColor = .lightGray
        imageView.image = UIImage(named: "depositPromo", in: Bundle.module, compatibleWith: nil)
        return imageView
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

    private static func createFooterBaseView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }

    private static func createHeaderTextFieldView() -> HeaderTextFieldView {
        let headerTextFieldView = HeaderTextFieldView()
        headerTextFieldView.setTextFieldFont(AppFont.with(type: .semibold, size: 16))
        headerTextFieldView.setHeaderLabelFont(AppFont.with(type: .semibold, size: 16))
        headerTextFieldView.translatesAutoresizingMaskIntoConstraints = false
        return headerTextFieldView
    }

    private static func createDepositSubtitleLabel() -> UILabel {
        let label = UILabel()
        label.font = AppFont.with(type: .semibold, size: 12)
        label.textAlignment = .left
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }

    private static func createAmountButton() -> UIButton {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }

    private static func createAmountButtonsStackView() -> UIStackView {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.spacing = 8
        stackView.distribution = .fillEqually
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }

    private static func createDepositButton() -> UIButton {
        let button = UIButton()
        button.setTitle("Continue", for: .normal)
        button.titleLabel?.font = AppFont.with(type: .bold, size: 18)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.layer.cornerRadius = 8
        return button
    }

    private static func createLoadingBaseView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }

    private static func createActivityIndicatorView() -> UIActivityIndicatorView {
        let activityIndicatorView = UIActivityIndicatorView.init(style: .large)
        activityIndicatorView.translatesAutoresizingMaskIntoConstraints = false
        activityIndicatorView.hidesWhenStopped = true
        activityIndicatorView.startAnimating()
        return activityIndicatorView
    }

    private func setupSubviews() {

        self.view.addSubview(self.headerBaseView)
        self.headerBaseView.addSubview(self.backButton)
        self.headerBaseView.addSubview(self.cancelButton)

        self.view.addSubview(self.promoImageView)

        self.view.addSubview(self.titleLabel)
        self.view.addSubview(self.subtitleLabel)

        self.view.addSubview(self.depositHeaderTextFieldView)
        self.view.addSubview(self.depositSubtitleLabel)

        self.amountButtonsStackView.addArrangedSubview(self.amountButton1)
        self.amountButtonsStackView.addArrangedSubview(self.amountButton2)
        self.amountButtonsStackView.addArrangedSubview(self.amountButton3)
        self.amountButtonsStackView.addArrangedSubview(self.amountButton4)
        self.view.addSubview(self.amountButtonsStackView)

        self.view.addSubview(self.footerBaseView)
        self.footerBaseView.addSubview(self.depositButton)

        self.view.addSubview(self.loadingBaseView)

        self.loadingBaseView.addSubview(self.activityIndicatorView)

        self.initConstraints()
    }

    private func initConstraints() {

        NSLayoutConstraint.activate([
            self.headerBaseView.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor),
            self.headerBaseView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            self.headerBaseView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            self.headerBaseView.heightAnchor.constraint(equalToConstant: 60),

            self.backButton.leadingAnchor.constraint(equalTo: self.headerBaseView.leadingAnchor, constant: 18),
            self.backButton.centerYAnchor.constraint(equalTo: self.headerBaseView.centerYAnchor),
            self.backButton.widthAnchor.constraint(equalTo: self.backButton.heightAnchor),
            self.backButton.widthAnchor.constraint(equalToConstant: 40),

            self.cancelButton.centerYAnchor.constraint(equalTo: self.headerBaseView.centerYAnchor),
            self.cancelButton.trailingAnchor.constraint(equalTo: self.headerBaseView.trailingAnchor, constant: -34),

            self.promoImageView.topAnchor.constraint(equalTo: self.headerBaseView.bottomAnchor, constant: 8),
            self.promoImageView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 34),
            self.promoImageView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -34),
            self.promoImageView.heightAnchor.constraint(equalTo: self.promoImageView.widthAnchor, multiplier: 0.32),

            self.titleLabel.topAnchor.constraint(equalTo: self.promoImageView.bottomAnchor, constant: 32),
            self.titleLabel.leadingAnchor.constraint(equalTo: self.promoImageView.leadingAnchor),
            self.titleLabel.trailingAnchor.constraint(equalTo: self.promoImageView.trailingAnchor),

            self.subtitleLabel.topAnchor.constraint(equalTo: self.titleLabel.bottomAnchor, constant: 16),
            self.subtitleLabel.leadingAnchor.constraint(equalTo: self.promoImageView.leadingAnchor),
            self.subtitleLabel.trailingAnchor.constraint(equalTo: self.promoImageView.trailingAnchor),

            self.depositHeaderTextFieldView.topAnchor.constraint(equalTo: self.subtitleLabel.bottomAnchor, constant: 32),
            self.depositHeaderTextFieldView.leadingAnchor.constraint(equalTo: self.promoImageView.leadingAnchor),
            self.depositHeaderTextFieldView.trailingAnchor.constraint(equalTo: self.promoImageView.trailingAnchor),
            self.depositHeaderTextFieldView.heightAnchor.constraint(equalToConstant: 80),

            self.depositSubtitleLabel.leadingAnchor.constraint(equalTo: self.promoImageView.leadingAnchor),
            self.depositSubtitleLabel.trailingAnchor.constraint(equalTo: self.promoImageView.trailingAnchor),
            self.depositSubtitleLabel.topAnchor.constraint(equalTo: self.depositHeaderTextFieldView.bottomAnchor, constant: -13),
            self.depositSubtitleLabel.heightAnchor.constraint(equalToConstant: 14),

            self.amountButtonsStackView.topAnchor.constraint(equalTo: self.depositHeaderTextFieldView.bottomAnchor, constant: 26),
            self.amountButtonsStackView.leadingAnchor.constraint(equalTo: self.promoImageView.leadingAnchor),
            self.amountButtonsStackView.trailingAnchor.constraint(equalTo: self.promoImageView.trailingAnchor),
            self.amountButtonsStackView.heightAnchor.constraint(equalToConstant: 46),

            self.footerBaseView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            self.footerBaseView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            self.footerBaseView.heightAnchor.constraint(equalToConstant: 70),
            self.footerBaseView.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor),

            self.depositButton.centerXAnchor.constraint(equalTo: self.footerBaseView.centerXAnchor),
            self.depositButton.centerYAnchor.constraint(equalTo: self.footerBaseView.centerYAnchor),
            self.depositButton.leadingAnchor.constraint(equalTo: self.footerBaseView.leadingAnchor, constant: 34),
            self.depositButton.heightAnchor.constraint(equalToConstant: 50),

        ])

        // Loading Screen
        NSLayoutConstraint.activate([
            self.loadingBaseView.topAnchor.constraint(equalTo: self.view.topAnchor),
            self.loadingBaseView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            self.loadingBaseView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            self.loadingBaseView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor),

            self.activityIndicatorView.centerXAnchor.constraint(equalTo: self.loadingBaseView.centerXAnchor),
            self.activityIndicatorView.centerYAnchor.constraint(equalTo: self.loadingBaseView.centerYAnchor)
        ])
    }

}
