//
//  EmailVerificationCodeViewController.swift
//  Sportsbook
//
//  Created by André Lascas on 27/10/2022.
//

import UIKit
import Combine

class EmailVerificationCodeViewModel {

    init() {

    }

    func submitVerificationCode(email: String, code: String) {
        // TO-DO: Process submit code
        print("SUBMIT: \(email) - \(code)")
    }
}

class EmailVerificationCodeViewController: UIViewController {

    // MARK: Private properties
    private lazy var topSafeAreaView: UIView = Self.createTopSafeAreaView()
    private lazy var bottomSafeAreaView: UIView = Self.createBottomSafeAreaView()
    private lazy var navigationView: UIView = Self.createNavigationView()
    private lazy var closeButton: UIButton = Self.createCloseButton()
    private lazy var navigationTitleLabel: UILabel = Self.createNavigationTitleLabel()
    private lazy var containerView: UIView = Self.createContainerView()
    private lazy var logoImageView: UIImageView = Self.createLogoImageView()
    private lazy var titleLabel: UILabel = Self.createTitleLabel()
    private lazy var subtitleLabel: UILabel = Self.createSubtitleLabel()
    private lazy var emailTextField: HeaderTextFieldView = Self.createEmailHeaderTextFieldView()
    private lazy var codeTextField: HeaderTextFieldView = Self.createCodeHeaderTextFieldView()
    private lazy var resendButton: UIButton = Self.createResendButton()
    private lazy var doneButton: UIButton = Self.createDoneButton()

    private var cancellables = Set<AnyCancellable>()

    private var viewModel: EmailVerificationCodeViewModel

    init(viewModel: EmailVerificationCodeViewModel) {

        self.viewModel = viewModel

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

        self.setupPublishers()

        self.closeButton.addTarget(self, action: #selector(didTapCloseButton), for: .primaryActionTriggered)

        self.resendButton.addTarget(self, action: #selector(didTapResendButton), for: .primaryActionTriggered)

        self.doneButton.addTarget(self, action: #selector(didTapDoneButton), for: .primaryActionTriggered)

        let tapGestureRecognizer = UITapGestureRecognizer.init(target: self, action: #selector(didTapBackground))
        self.view.addGestureRecognizer(tapGestureRecognizer)
    }

    // MARK: - Layout and Theme
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)

        self.setupWithTheme()
    }

    private func setupWithTheme() {
        self.view.backgroundColor = UIColor.App.backgroundPrimary

        self.navigationView.backgroundColor = .clear

        self.closeButton.backgroundColor = .clear
        self.closeButton.setTitleColor(UIColor.App.highlightPrimary, for: .normal)

        self.navigationTitleLabel.textColor = UIColor.App.textPrimary

        self.containerView.backgroundColor = .clear

        self.logoImageView.backgroundColor = .clear

        self.titleLabel.textColor = UIColor.App.textPrimary

        self.subtitleLabel.textColor = UIColor.App.textPrimary

        self.emailTextField.setHeaderLabelColor(UIColor.App.inputTextTitle)
        self.emailTextField.setTextFieldColor(UIColor.App.textPrimary)

        self.codeTextField.setHeaderLabelColor(UIColor.App.inputTextTitle)
        self.codeTextField.setTextFieldColor(UIColor.App.textPrimary)

        self.resendButton.backgroundColor = .clear
        self.resendButton.setTitleColor(UIColor.App.highlightPrimary, for: .normal)

        StyleHelper.styleButton(button: self.doneButton)
    }

    // MARK: Functions
    private func setupPublishers() {

        Publishers.CombineLatest(self.emailTextField.textPublisher, self.codeTextField.textPublisher)
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] emailText, codeText in

                if emailText != "" && codeText != "" {
                    self?.doneButton.isEnabled = true
                }
                else {
                    self?.doneButton.isEnabled = false
                }
            })
            .store(in: &cancellables)

        self.emailTextField.textPublisher
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] emailText in
                if let emailText = emailText {
                    self?.subtitleLabel.text = "\(localized("check_email_text1")) \(emailText)"
                }
            })
            .store(in: &cancellables)
    }

    // MARK: Actions
    @objc func didTapCloseButton() {
        self.dismiss(animated: true)
    }

    @objc func didTapDoneButton() {
        print("SUBMIT CODE!")

        let email = self.emailTextField.text
        let code = self.codeTextField.text

        self.viewModel.submitVerificationCode(email: email, code: code)
    }

    @objc func didTapResendButton() {
        print("RESEND EMAIL")
    }

    @objc func didTapBackground() {
        self.resignFirstResponder()

        self.emailTextField.resignFirstResponder()

        self.codeTextField.resignFirstResponder()
    }

}

extension EmailVerificationCodeViewController {

    private static func createTopSafeAreaView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }

    private static func createBottomSafeAreaView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }

    private static func createNavigationView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }

    private static func createCloseButton() -> UIButton {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle(localized("close"), for: .normal)
        button.titleLabel?.font = AppFont.with(type: .semibold, size: 14)
        return button
    }

    private static func createNavigationTitleLabel() -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = localized("email_verification")
        label.font = AppFont.with(type: .bold, size: 18)
        label.textAlignment = .center
        return label
    }

    private static func createContainerView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }

    private static func createLogoImageView() -> UIImageView {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.image = UIImage(named: "check_email_box_icon")
        imageView.contentMode = .center
        return imageView
    }

    private static func createTitleLabel() -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = localized("check_email")
        label.font = AppFont.with(type: .bold, size: 26)
        label.textAlignment = .center
        return label
    }

    private static func createSubtitleLabel() -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = localized("check_email_text1")
        label.font = AppFont.with(type: .bold, size: 15)
        label.textAlignment = .center
        label.numberOfLines = 0
        return label
    }

    private static func createEmailHeaderTextFieldView() -> HeaderTextFieldView {
        let textField = HeaderTextFieldView()
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.setSecureField(false)
        textField.setKeyboardType(.emailAddress)
        textField.setPlaceholderText(localized("email"))
        textField.headerLabel.font = AppFont.with(type: .semibold, size: 16)
        return textField
    }

    private static func createCodeHeaderTextFieldView() -> HeaderTextFieldView {
        let textField = HeaderTextFieldView()
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.setSecureField(false)
        textField.setKeyboardType(.default)
        textField.setPlaceholderText(localized("code"))
        textField.headerLabel.font = AppFont.with(type: .semibold, size: 16)
        return textField
    }

    private static func createResendButton() -> UIButton {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle(localized("resend_email"), for: .normal)
        button.titleLabel?.font = AppFont.with(type: .semibold, size: 14)
        return button
    }

    private static func createDoneButton() -> UIButton {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle(localized("done"), for: .normal)
        button.titleLabel?.font = AppFont.with(type: .bold, size: 18)
        return button
    }

    private func setupSubviews() {

        self.view.addSubview(self.topSafeAreaView)

        self.view.addSubview(self.bottomSafeAreaView)

        self.view.addSubview(self.navigationView)

        self.navigationView.addSubview(self.closeButton)

        self.navigationView.addSubview(self.navigationTitleLabel)

        self.view.addSubview(self.containerView)

        self.containerView.addSubview(self.logoImageView)

        self.containerView.addSubview(self.titleLabel)

        self.containerView.addSubview(self.subtitleLabel)

        self.containerView.addSubview(self.emailTextField)

        self.containerView.addSubview(self.codeTextField)

        self.containerView.addSubview(self.resendButton)

        self.containerView.addSubview(self.doneButton)

        self.initConstraints()
    }

    private func initConstraints() {

        // Top and Bottom Safe Area View
        NSLayoutConstraint.activate([
            self.topSafeAreaView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            self.topSafeAreaView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            self.topSafeAreaView.topAnchor.constraint(equalTo: self.view.topAnchor),
            self.topSafeAreaView.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor),

            self.bottomSafeAreaView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            self.bottomSafeAreaView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            self.bottomSafeAreaView.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor),
            self.bottomSafeAreaView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor)
        ])

        // Navigation view
        NSLayoutConstraint.activate([
            self.navigationView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            self.navigationView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            self.navigationView.topAnchor.constraint(equalTo: self.topSafeAreaView.bottomAnchor),
            self.navigationView.heightAnchor.constraint(equalToConstant: 44),

            self.closeButton.trailingAnchor.constraint(equalTo: self.navigationView.trailingAnchor, constant: -20),
            self.closeButton.heightAnchor.constraint(equalToConstant: 44),

            self.navigationTitleLabel.leadingAnchor.constraint(equalTo: self.navigationView.leadingAnchor, constant: 50),
            self.navigationTitleLabel.trailingAnchor.constraint(equalTo: self.navigationView.trailingAnchor, constant: -50),
            self.navigationTitleLabel.centerYAnchor.constraint(equalTo: self.navigationView.centerYAnchor)

        ])

        // Container view
        NSLayoutConstraint.activate([
            self.containerView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            self.containerView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            self.containerView.topAnchor.constraint(equalTo: self.navigationView.bottomAnchor),
            self.containerView.bottomAnchor.constraint(equalTo: self.bottomSafeAreaView.topAnchor),

            self.logoImageView.widthAnchor.constraint(equalToConstant: 100),
            self.logoImageView.heightAnchor.constraint(equalTo: self.logoImageView.widthAnchor),
            self.logoImageView.topAnchor.constraint(equalTo: self.containerView.topAnchor, constant: 50),
            self.logoImageView.centerXAnchor.constraint(equalTo: self.containerView.centerXAnchor),

            self.titleLabel.leadingAnchor.constraint(equalTo: self.containerView.leadingAnchor, constant: 50),
            self.titleLabel.trailingAnchor.constraint(equalTo: self.containerView.trailingAnchor, constant: -50),
            self.titleLabel.topAnchor.constraint(equalTo: self.logoImageView.bottomAnchor, constant: 30),

            self.subtitleLabel.leadingAnchor.constraint(equalTo: self.containerView.leadingAnchor, constant: 50),
            self.subtitleLabel.trailingAnchor.constraint(equalTo: self.containerView.trailingAnchor, constant: -50),
            self.subtitleLabel.topAnchor.constraint(equalTo: self.titleLabel.bottomAnchor, constant: 10),

            self.emailTextField.leadingAnchor.constraint(equalTo: self.containerView.leadingAnchor, constant: 50),
            self.emailTextField.trailingAnchor.constraint(equalTo: self.containerView.trailingAnchor, constant: -50),
            self.emailTextField.topAnchor.constraint(equalTo: self.subtitleLabel.bottomAnchor, constant: 40),
            self.emailTextField.heightAnchor.constraint(equalToConstant: 80),

            self.codeTextField.leadingAnchor.constraint(equalTo: self.containerView.leadingAnchor, constant: 50),
            self.codeTextField.trailingAnchor.constraint(equalTo: self.containerView.trailingAnchor, constant: -50),
            self.codeTextField.topAnchor.constraint(equalTo: self.emailTextField.bottomAnchor, constant: 10),
            self.codeTextField.heightAnchor.constraint(equalToConstant: 80),

            self.resendButton.trailingAnchor.constraint(equalTo: self.containerView.trailingAnchor, constant: -50),
            self.resendButton.topAnchor.constraint(equalTo: self.codeTextField.bottomAnchor, constant: -20),
            self.resendButton.heightAnchor.constraint(equalToConstant: 40),

            self.doneButton.leadingAnchor.constraint(equalTo: self.containerView.leadingAnchor, constant: 50),
            self.doneButton.trailingAnchor.constraint(equalTo: self.containerView.trailingAnchor, constant: -50),
            self.doneButton.heightAnchor.constraint(equalToConstant: 50),
            self.doneButton.bottomAnchor.constraint(equalTo: self.containerView.bottomAnchor, constant: -20)
        ])

    }
}
