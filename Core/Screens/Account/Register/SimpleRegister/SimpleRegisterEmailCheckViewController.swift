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
    @IBOutlet private var termsLabel: UILabel!

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

        commonInit()
        setupWithTheme()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }

    func commonInit() {
        skipButton.setTitle(localized("string_skip"), for: .normal)
        skipButton.titleLabel?.font = AppFont.with(type: .semibold, size: 18)

        logoImageView.image = UIImage(named: "logo_horizontal_large")
        logoImageView.sizeToFit()

        registerTitleLabel.font = AppFont.with(type: AppFont.AppFontType.semibold, size: 26)
        registerTitleLabel.text = localized("string_signup")

        emailHeadertextFieldView.setPlaceholderText("Email Address")

        registerButton.setTitle(localized("string_get_started"), for: .normal)
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


        if self.isModal {
            self.skipButton.isHidden = true
        }
        else {
            self.skipButton.isHidden = false
        }
    }

    func setupWithTheme() {
        self.view.backgroundColor = UIColor.App.mainBackgroundColor

        containerView.backgroundColor = UIColor.App.mainBackgroundColor

        skipView.backgroundColor = UIColor.App.mainBackgroundColor

        skipButton.setTitleColor(UIColor.white, for: .normal)
        skipButton.layer.borderColor = .none
        skipButton.layer.backgroundColor = UIColor.white.withAlphaComponent(0).cgColor

        registerTitleLabel.textColor = .white

        emailHeadertextFieldView.backgroundColor = UIColor.App.mainBackgroundColor
        emailHeadertextFieldView.setHeaderLabelColor(UIColor.App.headerTextFieldGray)
        emailHeadertextFieldView.setTextFieldColor(.white)
        emailHeadertextFieldView.setSecureField(false)

        registerButton.setTitleColor(UIColor.App.headingMain, for: .normal)
        registerButton.setTitleColor(UIColor.white.withAlphaComponent(0.7), for: .highlighted)
        registerButton.setTitleColor(UIColor.white.withAlphaComponent(0.4), for: .disabled)

        registerButton.backgroundColor = .clear
        registerButton.setBackgroundColor(UIColor.App.primaryButtonNormalColor, for: .normal)
        registerButton.setBackgroundColor(UIColor.App.primaryButtonPressedColor, for: .highlighted)
        registerButton.layer.cornerRadius = CornerRadius.button
        registerButton.layer.masksToBounds = true

        underlineTextLabel()
    }

    func underlineTextLabel() {
        let termsText = localized("string_agree_terms_conditions")

        termsLabel.text = termsText
        termsLabel.numberOfLines = 0
        termsLabel.font = AppFont.with(type: .regular, size: 14.0)
        self.termsLabel.textColor =  UIColor.App.headingMain

        let underlineAttriString = NSMutableAttributedString(string: termsText)

        let range1 = (termsText as NSString).range(of: localized("string_terms"))
        let range2 = (termsText as NSString).range(of: localized("string_privacy_policy"))
        let range3 = (termsText as NSString).range(of: localized("string_eula"))

        let paragraphStyle = NSMutableParagraphStyle()

        paragraphStyle.lineHeightMultiple = TextSpacing.subtitle
        paragraphStyle.alignment = .center

        underlineAttriString.addAttribute(.font, value: AppFont.with(type: .regular, size: 14), range: range1)
        underlineAttriString.addAttribute(.font, value: AppFont.with(type: .regular, size: 14), range: range2)
        underlineAttriString.addAttribute(.font, value: AppFont.with(type: .regular, size: 14), range: range3)
        underlineAttriString.addAttribute(.foregroundColor, value: UIColor.App.buttonMain, range: range1)
        underlineAttriString.addAttribute(.foregroundColor, value: UIColor.App.buttonMain, range: range2)
        underlineAttriString.addAttribute(.foregroundColor, value: UIColor.App.buttonMain, range: range3)
        underlineAttriString.addAttribute(.underlineStyle, value: NSUnderlineStyle.single.rawValue, range: range1)
        underlineAttriString.addAttribute(.underlineStyle, value: NSUnderlineStyle.single.rawValue, range: range2)
        underlineAttriString.addAttribute(.underlineStyle, value: NSUnderlineStyle.single.rawValue, range: range3)
        underlineAttriString.addAttribute(.paragraphStyle, value: paragraphStyle, range: NSMakeRange(0, underlineAttriString.length))

        termsLabel.attributedText = underlineAttriString
        termsLabel.isUserInteractionEnabled = true
        termsLabel.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(tapUnderlineLabel(gesture:))))
    }

    @IBAction private func tapUnderlineLabel(gesture: UITapGestureRecognizer) {
        let text = localized("string_agree_terms_conditions")

        let termsRange = (text as NSString).range(of: localized("string_terms"))
        let privacyRange = (text as NSString).range(of: localized("string_privacy_policy"))
        let eulaRange = (text as NSString).range(of: localized("string_eula"))

        if gesture.didTapAttributedTextInLabel(label: termsLabel, inRange: termsRange) {
            print("Tapped Terms")
            UIApplication.shared.open(NSURL(string: "https://gomadevelopment.pt/")! as URL, options: [:], completionHandler: nil)
        }
        else if gesture.didTapAttributedTextInLabel(label: termsLabel, inRange: privacyRange) {
            print("Tapped Privacy")
            UIApplication.shared.open(NSURL(string: "https://gomadevelopment.pt/")! as URL, options: [:], completionHandler: nil)
        }
        else if gesture.didTapAttributedTextInLabel(label: termsLabel, inRange: eulaRange) {
            print("Tapped EULA")
            UIApplication.shared.open(NSURL(string: "https://gomadevelopment.pt/")! as URL, options: [:], completionHandler: nil)
        }
        else {
            print("Tapped none")
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

        Env.everyMatrixAPIClient.validateEmail(email)
            .receive(on: RunLoop.main)
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
                }
                else {
                    self.pushRegisterNextViewController()
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
        Env.everyMatrixAPIClient.validateEmail(email)
            .receive(on: RunLoop.main)
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
        self.emailHeadertextFieldView.showErrorOnField(text: localized("string_invalid_email"), color: UIColor.App.alertError)
    }

    func showEmailUsedError() {
        self.emailHeadertextFieldView.showErrorOnField(text: localized("string_email_already_registered"), color: UIColor.App.alertError)
    }

    func hideEmailError() {
        self.emailHeadertextFieldView.hideTipAndError()
    }

}
