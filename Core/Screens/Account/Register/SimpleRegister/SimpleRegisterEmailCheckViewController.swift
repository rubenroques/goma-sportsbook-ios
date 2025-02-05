//
//  SmallRegisterViewController.swift
//  Sportsbook
//
//  Created by André Lascas on 15/09/2021.
//

import UIKit
import Combine

class SimpleRegisterEmailCheckViewController: UIViewController {

    // MARK: Private Properties
    @IBOutlet private var scrollView: UIScrollView!
    @IBOutlet private var containerView: UIView!
    @IBOutlet private var skipView: UIView!
    @IBOutlet private var backButton: UIButton!
    @IBOutlet private var skipButton: UIButton!
    @IBOutlet private var logoImageView: UIImageView!
    @IBOutlet private var registerTitleLabel: UILabel!
    @IBOutlet private var emailHeadertextFieldView: HeaderTextFieldView!
    @IBOutlet private var registerButton: UIButton!
    @IBOutlet private var policyLinkView: PolicyLinkView!

    @IBOutlet private var loadingEmailValidityView: UIActivityIndicatorView!
    @IBOutlet private var loadingBaseView: UIView!
    @IBOutlet private var acitivityIndicatorView: UIActivityIndicatorView!

    private var viewModel: SimpleRegisterEmailCheckViewModel
    private var cancellables = Set<AnyCancellable>()

    // MARK: Public Properties
    var isLoading: Bool = false {
        didSet {
            if isLoading {
                self.loadingBaseView.isHidden = false
            }
            else {
                self.loadingBaseView.isHidden = true
            }
        }
    }

    // MARK: Lifetime and Cycle
    init() {
        self.viewModel = SimpleRegisterEmailCheckViewModel()
        super.init(nibName: "SimpleRegisterEmailCheckViewController", bundle: nil)
    }

    @available(iOS, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.viewModel.sendAnalyticsEvent(event: .signupScreen)
        commonInit()
        setupWithTheme()

        self.bind(toViewModel: self.viewModel)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }

    func commonInit() {
        skipButton.setTitle(localized("skip"), for: .normal)
        skipButton.titleLabel?.font = AppFont.with(type: .semibold, size: 17)

        logoImageView.image = UIImage(named: "brand_icon_variation_new")
        logoImageView.sizeToFit()

        registerTitleLabel.font = AppFont.with(type: AppFont.AppFontType.semibold, size: 26)
        registerTitleLabel.text = localized("signup")

        emailHeadertextFieldView.setPlaceholderText("Email Address")

        registerButton.setTitle(localized("get_started"), for: .normal)
        registerButton.titleLabel?.font = AppFont.with(type: AppFont.AppFontType.bold, size: 18)

        let tapGestureRecognizer = UITapGestureRecognizer.init(target: self, action: #selector(didTapBackground))
        self.view.addGestureRecognizer(tapGestureRecognizer)

        emailHeadertextFieldView.textPublisher
            .removeDuplicates()
            .sink { _ in
                self.hideEmailError()
            }
            .store(in: &cancellables)

        emailHeadertextFieldView.textPublisher
            .compactMap { $0 }
            .filter(self.viewModel.isValidEmail)
            .removeDuplicates()
            .debounce(for: 0.5, scheduler: DispatchQueue.main)
            .handleEvents(receiveOutput: { [weak self] _ in
                self?.loadingEmailValidityView.startAnimating()
            })
            .sink(receiveValue: self.viewModel.requestValidEmailCheck)
            .store(in: &cancellables)

        checkPolicyLinks()

        if self.isModal {
            self.skipButton.isHidden = true
        }
        else {
            self.skipButton.isHidden = false
        }

        self.registerButton.isEnabled = false

        self.isLoading = false
    }

    // MARK: Layout and Theme
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)

        setupWithTheme()
    }

    func setupWithTheme() {
        self.view.backgroundColor = UIColor.App.backgroundPrimary

        containerView.backgroundColor = UIColor.App.backgroundPrimary

        skipView.backgroundColor = UIColor.App.backgroundPrimary

        skipButton.setTitleColor(UIColor.App.highlightPrimary, for: .normal)

        registerTitleLabel.textColor = UIColor.App.textHeadlinePrimary

        emailHeadertextFieldView.backgroundColor = UIColor.App.backgroundPrimary
        emailHeadertextFieldView.setHeaderLabelColor(UIColor.App.inputTextTitle)
        emailHeadertextFieldView.setTextFieldColor(UIColor.App.inputText)
        emailHeadertextFieldView.setSecureField(false)

        registerButton.setTitleColor(UIColor.App.buttonTextPrimary, for: .normal)
        registerButton.setTitleColor(UIColor.App.buttonTextPrimary.withAlphaComponent(0.7), for: .highlighted)
        registerButton.setTitleColor(UIColor.App.buttonTextPrimary.withAlphaComponent(0.4), for: .disabled)

        registerButton.backgroundColor = .clear
        registerButton.setBackgroundColor(UIColor.App.buttonBackgroundPrimary, for: .normal)
        registerButton.setBackgroundColor(UIColor.App.buttonBackgroundPrimary, for: .highlighted)
        registerButton.layer.cornerRadius = CornerRadius.button
        registerButton.layer.masksToBounds = true

        self.loadingBaseView.backgroundColor = UIColor.App.backgroundPrimary.withAlphaComponent(0.7)

    }

    // MARK: Binding
    private func bind(toViewModel viewModel: SimpleRegisterEmailCheckViewModel) {

        viewModel.isLoadingPublisher
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] isLoading in
                self?.isLoading = isLoading
            })
            .store(in: &cancellables)

        viewModel.registerErrorTypePublisher
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] registerErrorType in
                switch registerErrorType {
                case .server:
                    self?.showServerErrorAlert()
                case .wrongEmail:
                    self?.showWrongEmailFormatError()
                case .usedEmail:
                    self?.showEmailUsedError()
                case .hideEmail:
                    self?.hideEmailError()
                default:
                    ()
                }
            })
            .store(in: &cancellables)

        viewModel.shouldShowNextViewController
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] shouldShowNextViewController in
                if shouldShowNextViewController {
                    self?.pushRegisterNextViewController()
                }
            })
            .store(in: &cancellables)

        viewModel.isRegisterEnabled
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] isEnabled in
                self?.registerButton.isEnabled = isEnabled
            })
            .store(in: &cancellables)

        viewModel.shouldAnimateEmailValidityView
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] shouldAnimate in
                if shouldAnimate {
                    self?.loadingEmailValidityView.startAnimating()
                }
                else {
                    self?.loadingEmailValidityView.stopAnimating()
                }
            })
            .store(in: &cancellables)
    }

    // MARK: Functions
    private func checkPolicyLinks() {
            policyLinkView.didTapTerms = {
                // TO-DO: Call VC to register
            }

            policyLinkView.didTapPrivacy = {
                // TO-DO: Call VC to register
            }

            policyLinkView.didTapEula = {
                // TO-DO: Call VC to register
            }
        }

    private func pushRegisterNextViewController() {
        let smallRegisterStep2ViewController = SimpleRegisterDetailsViewController(emailAddress: self.emailHeadertextFieldView.text)
        self.navigationController?.pushViewController(smallRegisterStep2ViewController, animated: true)
    }

    // MARK: Actions
    @objc func didTapBackground() {
        self.resignFirstResponder()

        self.emailHeadertextFieldView.resignFirstResponder()
    }

    @IBAction private func didTapBackButton() {
        self.navigationController?.popViewController(animated: true)
    }

    @IBAction private func didTapRegisterButton() {
        let email = emailHeadertextFieldView.text
        self.viewModel.registerEmail(email: email)
    }

    @IBAction private func skipAction() {
        let rootViewController = Router.mainScreenViewController()
        self.navigationController?.pushViewController(rootViewController, animated: true)
    }

}

extension SimpleRegisterEmailCheckViewController {

    // MARK: Error Alerts
    func showServerErrorAlert() {
        UIAlertController.showServerErrorMessage(on: self)
    }

    func showWrongEmailFormatError() {
        self.emailHeadertextFieldView.showErrorOnField(text: localized("invalid_email"), color: UIColor.App.alertError)
    }

    func showEmailUsedError() {
        self.emailHeadertextFieldView.showErrorOnField(text: localized("email_already_registered"), color: UIColor.App.alertError)
    }

    func hideEmailError() {
        self.emailHeadertextFieldView.hideTipAndError()
    }

}
