//
//  SmallRegisterViewController.swift
//  Sportsbook
//
//  Created by André Lascas on 15/09/2021.
//

import UIKit
import Combine

class SimpleRegisterEmailCheckViewController: UIViewController {

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

    var cancellables = Set<AnyCancellable>()

    init() {
        super.init(nibName: "SimpleRegisterEmailCheckViewController", bundle: nil)
    }

    @available(iOS, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        AnalyticsClient.sendEvent(event: .signupScreen)
        commonInit()
        setupWithTheme()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }

    

    func commonInit() {
        skipButton.setTitle(localized("skip"), for: .normal)
        skipButton.titleLabel?.font = AppFont.with(type: .semibold, size: 18)

        logoImageView.image = UIImage(named: "logo_horizontal_large")
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
            .filter(isValidEmail)
            .removeDuplicates()
            .debounce(for: 0.5, scheduler: DispatchQueue.main)
            .handleEvents(receiveOutput: { [weak self] _ in
                self?.loadingEmailValidityView.startAnimating()
            })
            .sink(receiveValue: requestValidEmailCheck)
            .store(in: &cancellables)

        checkPolicyLinks()

        if self.isModal {
            self.skipButton.isHidden = true
        }
        else {
            self.skipButton.isHidden = false
        }
    }

    func setupWithTheme() {
        self.view.backgroundColor = UIColor.App.mainBackground

        containerView.backgroundColor = UIColor.App.mainBackground

        skipView.backgroundColor = UIColor.App.mainBackground

        skipButton.setTitleColor(UIColor.white, for: .normal)
        skipButton.layer.borderColor = .none
        skipButton.layer.backgroundColor = UIColor.white.withAlphaComponent(0).cgColor

        registerTitleLabel.textColor = .white

        emailHeadertextFieldView.backgroundColor = UIColor.App.mainBackground
        emailHeadertextFieldView.setHeaderLabelColor(UIColor.App.headerTextField)
        emailHeadertextFieldView.setTextFieldColor(.white)
        emailHeadertextFieldView.setSecureField(false)

        registerButton.setTitleColor(UIColor.App.headingMain, for: .normal)
        registerButton.setTitleColor(UIColor.white.withAlphaComponent(0.7), for: .highlighted)
        registerButton.setTitleColor(UIColor.white.withAlphaComponent(0.4), for: .disabled)

        registerButton.backgroundColor = .clear
        registerButton.setBackgroundColor(UIColor.App.primaryButtonNormal, for: .normal)
        registerButton.setBackgroundColor(UIColor.App.primaryButtonPressed, for: .highlighted)
        registerButton.layer.cornerRadius = CornerRadius.button
        registerButton.layer.masksToBounds = true

    }

    func checkPolicyLinks() {
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

    @objc func didTapBackground() {
        self.resignFirstResponder()

        self.emailHeadertextFieldView.resignFirstResponder()
    }

    @IBAction private func didTapBackButton() {
        self.navigationController?.popViewController(animated: true)
    }

    @IBAction private func didTapRegisterButton() {

        let email = emailHeadertextFieldView.text

        if !isValidEmail(email) {
            self.showWrongEmailFormatError()
            return
        }

        Env.everyMatrixClient.validateEmail(email)
            .receive(on: DispatchQueue.main)
            .handleEvents(receiveOutput: { [weak self] _ in
                self?.loadingEmailValidityView.startAnimating()
            })
            .sink { completed in
                if case .failure = completed {
                    self.showServerErrorAlert()
                }
                self.loadingEmailValidityView.stopAnimating()
            }
            receiveValue: { value in
                if !value.isAvailable {
                    self.showEmailUsedError()
                    AnalyticsClient.sendEvent(event: .userSignUpFail)
                }
                else {
                    self.pushRegisterNextViewController()
                    AnalyticsClient.sendEvent(event: .userSignUpSuccess)
                }
                self.loadingEmailValidityView.stopAnimating()
            }
            .store(in: &cancellables)
    }

    private func pushRegisterNextViewController() {
        let smallRegisterStep2ViewController = SimpleRegisterDetailsViewController(emailAddress: self.emailHeadertextFieldView.text)
        self.navigationController?.pushViewController(smallRegisterStep2ViewController, animated: true)
    }

    @IBAction private func skipAction() {
        let rootViewController = Router.mainScreenViewController()
        self.navigationController?.pushViewController(rootViewController, animated: true)
    }

    func isValidEmail(_ email: String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"

        let emailPred = NSPredicate(format: "SELF MATCHES %@", emailRegEx)
        return emailPred.evaluate(with: email)
    }

}

extension SimpleRegisterEmailCheckViewController {

    func requestValidEmailCheck(email: String) {
        Env.everyMatrixClient.validateEmail(email)
            .receive(on: DispatchQueue.main)
            .sink { _ in
                self.loadingEmailValidityView.stopAnimating()
            }
            receiveValue: { value in
                if !value.isAvailable {
                    self.showEmailUsedError()
                }
                self.loadingEmailValidityView.stopAnimating()
            }
            .store(in: &cancellables)
    }

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
