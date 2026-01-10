//
//  RecoverPasswordViewController.swift
//  Sportsbook
//
//  Created by André Lascas on 31/10/2022.
//

import UIKit
import Combine
import ServicesProvider
import HeaderTextField
import Extensions

class RecoverPasswordViewController: UIViewController {

    // MARK: Private properties
    private lazy var topSafeAreaView: UIView = Self.createTopSafeAreaView()
    private lazy var bottomSafeAreaView: UIView = Self.createBottomSafeAreaView()
    private lazy var navigationView: UIView = Self.createNavigationView()
    private lazy var backButton: UIButton = Self.createBackButton()
    private lazy var containerView: UIView = Self.createContainerView()
    private lazy var titleLabel: UILabel = Self.createTitleLabel()
    private lazy var subtitleLabel: UILabel = Self.createSubtitleLabel()
    private lazy var emailTextField: HeaderTextField.HeaderTextFieldView = Self.createEmailHeaderTextFieldView()
    private lazy var proceedButton: UIButton = Self.createProceedButton()
    private lazy var loadingBaseView: UIView = Self.createLoadingBaseView()
    private lazy var loadingActivityIndicatorView: UIActivityIndicatorView = Self.createLoadingActivityIndicatorView()

    private var cancellables = Set<AnyCancellable>()

    private var viewModel: RecoverPasswordViewModel

    // MARK: Public Properties
    var isLoading: Bool = false {
        didSet {
            if isLoading {
                self.loadingBaseView.isHidden = false
                self.loadingActivityIndicatorView.startAnimating()
            }
            else {
                self.loadingBaseView.isHidden = true
                self.loadingActivityIndicatorView.stopAnimating()
            }
        }
    }

    // MARK: - Lifetime and Cycle
    init(viewModel: RecoverPasswordViewModel) {

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

        self.backButton.addTarget(self, action: #selector(didTapBackButton), for: .primaryActionTriggered)

        self.proceedButton.addTarget(self, action: #selector(didTapProceedButton), for: .primaryActionTriggered)

        let tapGestureRecognizer = UITapGestureRecognizer.init(target: self, action: #selector(didTapBackground))
        self.view.addGestureRecognizer(tapGestureRecognizer)

        self.isLoading = false

        self.setupPublishers()

        self.bind(toViewModel: self.viewModel)

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

        self.backButton.backgroundColor = .clear

        self.containerView.backgroundColor = .clear

        self.titleLabel.textColor = UIColor.App.textPrimary

        self.subtitleLabel.textColor = UIColor.App.textPrimary

        self.emailTextField.setHeaderLabelColor(UIColor.App.inputTextTitle)
        self.emailTextField.setTextFieldColor(UIColor.App.textPrimary)

        StyleHelper.styleButton(button: self.proceedButton)

        self.loadingBaseView.backgroundColor = UIColor.App.backgroundPrimary.withAlphaComponent(0.7)

        self.loadingActivityIndicatorView.color = UIColor.lightGray
    }

    // MARK: - Bindings
    private func bind(toViewModel viewModel: RecoverPasswordViewModel) {

    }

    // MARK: Functions
    private func setupPublishers() {

        self.emailTextField.textPublisher
            .debounce(for: .seconds(0.5), scheduler: DispatchQueue.main)
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] emailText in
                guard let self = self else { return }
                if emailText != "" {

                    if emailText.isValidEmailAddress() {
                        self.emailTextField.hideTipAndError()
                        self.proceedButton.isEnabled = true
                    }
                    else {
                        self.emailTextField.showError(withMessage: localized("invalid_email"))
                        self.proceedButton.isEnabled = false
                    }
                }
                else {
                    self.emailTextField.hideTipAndError()
                }
            })
            .store(in: &cancellables)

    }

    private func showMessageAlert(title: String, message: String) {
        let alert = UIAlertController(title: title,
                                      message: message,
                                      preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: localized("ok"), style: .default, handler: { [weak self] _ in
            self?.closeScreen()
        }))
        self.present(alert, animated: true, completion: nil)
    }

    private func closeScreen() {
        self.navigationController?.popViewController(animated: true)
    }

//    private func isValidEmailAddress(_ email: String) -> Bool {
//        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
//        let emailPred = NSPredicate(format: "SELF MATCHES %@", emailRegEx)
//        return emailPred.evaluate(with: email)
//    }

    // MARK: Actions
    @objc func didTapBackButton() {
        self.navigationController?.popViewController(animated: true)
    }

    @objc func didTapProceedButton() {
        self.isLoading = true

        let email = self.emailTextField.text

        self.viewModel.submitRecoverPassword(email: email)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { [weak self] completion in
                switch completion {

                case .finished:
                    ()
                case .failure(let error):
                    print("FORGOT PASSWORD ERROR: \(error)")

                }
                self?.isLoading = false
            }, receiveValue: { [weak self] success in
                if success {
                    self?.showMessageAlert(title: localized("recover_password_sent"), message: localized("recover_password_sent_message"))
                }
            })
            .store(in: &cancellables)

    }

    @objc func didTapBackground() {
        self.resignFirstResponder()

        self.emailTextField.resignFirstResponder()

    }
}

extension RecoverPasswordViewController {

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

    private static func createBackButton() -> UIButton {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("", for: .normal)
        button.setImage(UIImage(named: "arrow_back_icon"), for: .normal)
        return button
    }

    private static func createContainerView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }

    private static func createTitleLabel() -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = localized("forgot_password")
        label.font = AppFont.with(type: .bold, size: 26)
        label.textAlignment = .center
        return label
    }

    private static func createSubtitleLabel() -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = localized("enter_associated_email")
        label.font = AppFont.with(type: .bold, size: 15)
        label.textAlignment = .center
        label.numberOfLines = 0
        return label
    }

    private static func createEmailHeaderTextFieldView() -> HeaderTextField.HeaderTextFieldView {
        let textField = HeaderTextField.HeaderTextFieldView()
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.setSecureField(false)
        textField.setKeyboardType(.emailAddress)
        textField.setPlaceholderText(localized("email"))
        textField.setHeaderLabelFont(AppFont.with(type: .semibold, size: 16)) 
        return textField
    }

    private static func createProceedButton() -> UIButton {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle(localized("proceed"), for: .normal)
        button.titleLabel?.font = AppFont.with(type: .bold, size: 18)
        return button
    }

    private static func createLoadingBaseView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }

    private static func createLoadingActivityIndicatorView() -> UIActivityIndicatorView {
        let activityIndicatorView = UIActivityIndicatorView.init(style: .large)
        activityIndicatorView.translatesAutoresizingMaskIntoConstraints = false
        activityIndicatorView.hidesWhenStopped = true
        activityIndicatorView.stopAnimating()
        return activityIndicatorView
    }

    private func setupSubviews() {

        self.view.addSubview(self.topSafeAreaView)

        self.view.addSubview(self.bottomSafeAreaView)

        self.view.addSubview(self.navigationView)

        self.navigationView.addSubview(self.backButton)

        self.view.addSubview(self.containerView)

        self.containerView.addSubview(self.titleLabel)

        self.containerView.addSubview(self.subtitleLabel)

        self.containerView.addSubview(self.emailTextField)

        self.containerView.addSubview(self.proceedButton)

        self.containerView.addSubview(self.loadingBaseView)

        self.loadingBaseView.addSubview(self.loadingActivityIndicatorView)

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

            self.backButton.leadingAnchor.constraint(equalTo: self.navigationView.leadingAnchor),
            self.backButton.widthAnchor.constraint(equalToConstant: 40),
            self.backButton.heightAnchor.constraint(equalToConstant: 44)
        ])

        // Container view
        NSLayoutConstraint.activate([
            self.containerView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            self.containerView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            self.containerView.topAnchor.constraint(equalTo: self.navigationView.bottomAnchor),
            self.containerView.bottomAnchor.constraint(equalTo: self.bottomSafeAreaView.topAnchor),

            self.titleLabel.leadingAnchor.constraint(equalTo: self.containerView.leadingAnchor, constant: 20),
            self.titleLabel.trailingAnchor.constraint(equalTo: self.containerView.trailingAnchor, constant: -20),
            self.titleLabel.topAnchor.constraint(equalTo: self.containerView.topAnchor, constant: 30),

            self.subtitleLabel.leadingAnchor.constraint(equalTo: self.containerView.leadingAnchor, constant: 20),
            self.subtitleLabel.trailingAnchor.constraint(equalTo: self.containerView.trailingAnchor, constant: -20),
            self.subtitleLabel.topAnchor.constraint(equalTo: self.titleLabel.bottomAnchor, constant: 20),

            self.emailTextField.leadingAnchor.constraint(equalTo: self.containerView.leadingAnchor, constant: 20),
            self.emailTextField.trailingAnchor.constraint(equalTo: self.containerView.trailingAnchor, constant: -20),
            self.emailTextField.topAnchor.constraint(equalTo: self.subtitleLabel.bottomAnchor, constant: 20),
            self.emailTextField.heightAnchor.constraint(equalToConstant: 80),

            self.proceedButton.leadingAnchor.constraint(equalTo: self.containerView.leadingAnchor, constant: 20),
            self.proceedButton.trailingAnchor.constraint(equalTo: self.containerView.trailingAnchor, constant: -20),
            self.proceedButton.heightAnchor.constraint(equalToConstant: 50),
            self.proceedButton.bottomAnchor.constraint(equalTo: self.containerView.bottomAnchor, constant: -20)
        ])

        // Loading view
        NSLayoutConstraint.activate([

            self.loadingBaseView.leadingAnchor.constraint(equalTo: self.containerView.leadingAnchor),
            self.loadingBaseView.trailingAnchor.constraint(equalTo: self.containerView.trailingAnchor),
            self.loadingBaseView.topAnchor.constraint(equalTo: self.containerView.topAnchor),
            self.loadingBaseView.bottomAnchor.constraint(equalTo: self.containerView.bottomAnchor),

            self.loadingActivityIndicatorView.centerYAnchor.constraint(equalTo: self.loadingBaseView.centerYAnchor),
            self.loadingActivityIndicatorView.centerXAnchor.constraint(equalTo: self.loadingBaseView.centerXAnchor)
        ])

    }
}
