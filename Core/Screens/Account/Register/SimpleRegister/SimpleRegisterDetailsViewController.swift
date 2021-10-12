//
//  SimpleRegisterDetailsViewController.swift
//  Sportsbook
//
//  Created by André Lascas on 15/09/2021.
//

import UIKit
import Combine

class SimpleRegisterDetailsViewController: UIViewController {

    @IBOutlet private var scrollView: UIScrollView!
    @IBOutlet private var containerView: UIView!
    @IBOutlet private var backView: UIView!
    @IBOutlet private var backButton: UIButton!
    @IBOutlet private var registerTitleLabel: UILabel!
    @IBOutlet private var topSignUpView: UIView!
    @IBOutlet private var usernameHeaderTextView: HeaderTextFieldView!
    @IBOutlet private var dateHeaderTextView: HeaderTextFieldView!
    @IBOutlet private var phoneView: UIView!
    @IBOutlet private var indicativeHeaderTextView: HeaderTextFieldView!
    @IBOutlet private var phoneHeaderTextView: HeaderTextFieldView!
    @IBOutlet private var lineView: UIView!
    @IBOutlet private var emailHeaderTextView: HeaderTextFieldView!
    @IBOutlet private var passwordHeaderTextView: HeaderTextFieldView!
    @IBOutlet private var confirmPasswordHeaderTextView: HeaderTextFieldView!
    @IBOutlet private var termsLabel: UILabel!
    @IBOutlet private var signUpButton: UIButton!

    @IBOutlet private var loadingUsernameValidityView: UIActivityIndicatorView!

    var cancellables = Set<AnyCancellable>()
    
    // Variables
    var emailAddress: String

    private var mobilePrefixTextual = ""

    init(emailAddress: String) {
        self.emailAddress = emailAddress

        super.init(nibName: "SimpleRegisterDetailsViewController", bundle: nil)
    }

    @available(iOS, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        setupWithTheme()
        commonInit()

        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow),
                                               name: UIResponder.keyboardWillShowNotification,
                                               object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide),
                                               name: UIResponder.keyboardWillHideNotification,
                                               object: nil)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.setupPublishers()
    }

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }

    func commonInit() {

        registerTitleLabel.font = AppFont.with(type: AppFont.AppFontType.semibold, size: 26)
        registerTitleLabel.text = localized("string_signup")

        usernameHeaderTextView.setPlaceholderText(localized("string_username"))

        emailHeaderTextView.setPlaceholderText(localized("string_email"))
        emailHeaderTextView.setSecureField(false)
        emailHeaderTextView.setTextFieldDefaultValue(self.emailAddress)
        emailHeaderTextView.isDisabled = true

        //dateHeaderTextView.shouldBeginEditing = { return false }
        dateHeaderTextView.setPlaceholderText(localized("string_birth_date"))
        dateHeaderTextView.setImageTextField(UIImage(named: "calendar_regular_icon")!)
        dateHeaderTextView.setDatePickerMode()


        indicativeHeaderTextView.setPlaceholderText(localized("string_phone_prefix"))
        indicativeHeaderTextView.setText("----")
        indicativeHeaderTextView.setImageTextField(UIImage(named: "arrow_dropdown_icon")!, size: 10)
        indicativeHeaderTextView.setTextFieldFont(AppFont.with(type: .regular, size: 16))
        indicativeHeaderTextView.isUserInteractionEnabled = false

        phoneHeaderTextView.setPlaceholderText(localized("string_phone_number"))
        phoneHeaderTextView.setKeyboardType(.numberPad)

        passwordHeaderTextView.setPlaceholderText(localized("string_password"))
        confirmPasswordHeaderTextView.setPlaceholderText(localized("string_confirm_password"))

        signUpButton.setTitle(localized("string_signup"), for: .normal)
        signUpButton.titleLabel?.font = AppFont.with(type: AppFont.AppFontType.bold, size: 18)

        let tapGestureRecognizer = UITapGestureRecognizer.init(target: self, action: #selector(didTapBackground))
        self.view.addGestureRecognizer(tapGestureRecognizer)

        let calendar = Calendar(identifier: .gregorian)
        var components = DateComponents()
        components.calendar = calendar
        components.year = -18
        let maxDate = calendar.date(byAdding: components, to: Date())!
        dateHeaderTextView.datePicker.maximumDate = maxDate

    }

    func setupWithTheme() {

        self.view.backgroundColor = UIColor.App.mainBackground

        containerView.backgroundColor = UIColor.App.mainBackground
        backView.backgroundColor = UIColor.App.mainBackground
        registerTitleLabel.textColor = UIColor.App.headingMain
        topSignUpView.backgroundColor = UIColor.App.mainBackground

        usernameHeaderTextView.backgroundColor = UIColor.App.mainBackground
        usernameHeaderTextView.setHeaderLabelColor(UIColor.App.headerTextField)
        usernameHeaderTextView.setTextFieldColor(UIColor.App.headingMain)
        usernameHeaderTextView.setSecureField(false)

        dateHeaderTextView.backgroundColor = UIColor.App.mainBackground
        dateHeaderTextView.setHeaderLabelColor(UIColor.App.headerTextField)
        dateHeaderTextView.setTextFieldColor(UIColor.App.headingMain)

        phoneView.backgroundColor = UIColor.App.mainBackground

        indicativeHeaderTextView.backgroundColor = UIColor.App.mainBackground
        indicativeHeaderTextView.setTextFieldColor(UIColor.App.headingMain)
        indicativeHeaderTextView.setViewColor(UIColor.App.mainBackground)
        indicativeHeaderTextView.setViewBorderColor(UIColor.App.headerTextField)
        indicativeHeaderTextView.setSecureField(false)

        phoneHeaderTextView.backgroundColor = UIColor.App.mainBackground
        phoneHeaderTextView.setHeaderLabelColor(UIColor.App.headerTextField)
        phoneHeaderTextView.setTextFieldColor(UIColor.App.headingMain)
        phoneHeaderTextView.setSecureField(false)

        lineView.backgroundColor = UIColor.App.headerTextField.withAlphaComponent(0.2)

        emailHeaderTextView.backgroundColor = UIColor.App.mainBackground
        emailHeaderTextView.setHeaderLabelColor(UIColor.App.headerTextField)
        emailHeaderTextView.setTextFieldColor(UIColor.App.headingMain)

        passwordHeaderTextView.backgroundColor = UIColor.App.mainBackground
        passwordHeaderTextView.setHeaderLabelColor(UIColor.App.headerTextField)
        passwordHeaderTextView.setTextFieldColor(UIColor.App.headingMain)
        passwordHeaderTextView.setSecureField(true)

        confirmPasswordHeaderTextView.backgroundColor = UIColor.App.mainBackground
        confirmPasswordHeaderTextView.setHeaderLabelColor(UIColor.App.headerTextField)
        confirmPasswordHeaderTextView.setTextFieldColor(UIColor.App.headingMain)
        confirmPasswordHeaderTextView.setSecureField(true)

        underlineTextLabel()

        signUpButton.setTitleColor(UIColor.App.headingMain, for: .normal)
        signUpButton.setTitleColor(UIColor.white.withAlphaComponent(0.7), for: .highlighted)
        signUpButton.setTitleColor(UIColor.white.withAlphaComponent(0.4), for: .disabled)

        signUpButton.backgroundColor = .clear
        signUpButton.setBackgroundColor(UIColor.App.primaryButtonNormal, for: .normal)
        signUpButton.setBackgroundColor(UIColor.App.primaryButtonPressed, for: .highlighted)
        signUpButton.layer.cornerRadius = CornerRadius.button
        signUpButton.layer.masksToBounds = true
    }

    private func setupPublishers() {

        Env.everyMatrixAPIClient.getCountries()
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
            .sink { _ in
                self.indicativeHeaderTextView.isUserInteractionEnabled = true
            } receiveValue: { countries in
                self.setupWithCountryCodes(countries)
            }
            .store(in: &cancellables)

        self.usernameHeaderTextView.textPublisher
            .removeDuplicates()
            .sink { _ in
                self.hideUsernameError()
            }
            .store(in: &cancellables)

        self.usernameHeaderTextView.textPublisher
            .removeDuplicates()
            .compactMap { $0 }
            .filter { $0.count > 3 }
            .debounce(for: 0.5, scheduler: DispatchQueue.main)
            .handleEvents(receiveOutput: { [weak self] _ in
                self?.loadingUsernameValidityView.startAnimating()
            })
            .eraseToAnyPublisher()
            .sink(receiveValue: {
                self.requestValidUsernameCheck($0)
            })
            .store(in: &cancellables)

        Publishers.CombineLatest4(self.usernameHeaderTextView.textPublisher,
                                 self.passwordHeaderTextView.textPublisher,
                                 self.confirmPasswordHeaderTextView.textPublisher,
                                 self.phoneHeaderTextView.textPublisher)
            .map { username, password, passwordConf, phone in

                if password != passwordConf {
                    return false
                }

                return (username?.isNotEmpty ?? false) &&
                        (password?.isNotEmpty ?? false) &&
                        (phone?.isNotEmpty ?? false)

            }
            .assign(to: \.isEnabled, on: signUpButton)
            .store(in: &cancellables)

    }

    @IBAction private func didTapBackButton() {
        self.navigationController?.popViewController(animated: true)
    }

    func underlineTextLabel() {
        let termsText = localized("string_agree_terms_conditions")

        termsLabel.text = termsText
        termsLabel.numberOfLines = 0
        termsLabel.font = AppFont.with(type: .regular, size: 14.0)

        self.termsLabel.textColor = UIColor.App.headingMain

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
        underlineAttriString.addAttribute(.foregroundColor, value: UIColor.App.mainTint, range: range1)
        underlineAttriString.addAttribute(.foregroundColor, value: UIColor.App.mainTint, range: range2)
        underlineAttriString.addAttribute(.foregroundColor, value: UIColor.App.mainTint, range: range3)
        underlineAttriString.addAttribute(.underlineStyle, value: NSUnderlineStyle.single.rawValue, range: range1)
        underlineAttriString.addAttribute(.underlineStyle, value: NSUnderlineStyle.single.rawValue, range: range2)
        underlineAttriString.addAttribute(.underlineStyle, value: NSUnderlineStyle.single.rawValue, range: range3)
        underlineAttriString.addAttribute(.paragraphStyle, value: paragraphStyle, range: NSMakeRange(0, underlineAttriString.length))

        termsLabel.attributedText = underlineAttriString
        termsLabel.isUserInteractionEnabled = true
        termsLabel.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(tapUnderlineLabel(gesture:))))
    }

    @objc private func tapUnderlineLabel(gesture: UITapGestureRecognizer) {
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

    @IBAction private func signUpAction() {

        var validFields = true

        let username = usernameHeaderTextView.text
        let birthDate = dateHeaderTextView.text // Must be yyyy-MM-dd
        let mobile = phoneHeaderTextView.text
        let email = emailHeaderTextView.text
        let password = passwordHeaderTextView.text
        let confirmPassword = confirmPasswordHeaderTextView.text
        let emailVerificationURL = EveryMatrixInfo.emailVerificationURL(withUserEmail: email)

        if password != confirmPassword {
            passwordHeaderTextView.showErrorOnField(text: localized("string_password_not_match"), color: UIColor.App.alertError)
            validFields = false
        }
        else if password.count < 8 {
            passwordHeaderTextView.showTip(text: localized("string_weak_password"))
            validFields = false
        }

        if dateHeaderTextView.text.isEmpty {
            dateHeaderTextView.showErrorOnField(text: localized("string_invalid_birthDate"), color: UIColor.App.alertError)
            validFields = false
        }

        guard validFields else {
            return
        }

        let form = EveryMatrix.SimpleRegisterForm(email: email,
                                                  username: username,
                                                  password: password,
                                                  birthDate: birthDate,
                                                  mobilePrefix: mobilePrefixTextual,
                                                  mobileNumber: mobile,
                                                  emailVerificationURL: emailVerificationURL)
        self.registerUser(form: form)

    }

    func pushRegisterNextViewController(email: String) {
        let simpleRegisterEmailSentViewController = SimpleRegisterEmailSentViewController()
        simpleRegisterEmailSentViewController.emailUser = email
        self.navigationController?.pushViewController(simpleRegisterEmailSentViewController, animated: true)
    }

    @objc func didTapBackground() {
        self.resignFirstResponder()

        self.usernameHeaderTextView.resignFirstResponder()
        self.dateHeaderTextView.resignFirstResponder()
        self.indicativeHeaderTextView.resignFirstResponder()
        self.phoneHeaderTextView.resignFirstResponder()
        self.passwordHeaderTextView.resignFirstResponder()
        self.confirmPasswordHeaderTextView.resignFirstResponder()
    }

}

// Sign Up status updates
extension SimpleRegisterDetailsViewController {

    func enableSignUpButton() {
        self.signUpButton.isEnabled = true
    }

    func disableSignUpButton() {
        self.signUpButton.isEnabled = false
    }

}

// Screen status updates
extension SimpleRegisterDetailsViewController {

    func showUsernameTakenErrorStatus() {
        self.usernameHeaderTextView
            .showErrorOnField(text: localized("string_username_already_registered"), color: UIColor.App.alertError)
        self.disableSignUpButton()
    }

    func showEmailTakenErrorStatus() {
        self.usernameHeaderTextView
            .showErrorOnField(text: localized("string_email_already_registered"), color: UIColor.App.alertError)
        self.disableSignUpButton()
    }

    func showPasswordTooWeakErrorStatus() {
        self.disableSignUpButton()
        self.passwordHeaderTextView.showErrorOnField(text: localized("string_password_too_weak"), color: UIColor.App.alertError)
    }

    func showServerErrorStatus() {
        UIAlertController.showServerErrorMessage(on: self)
    }

    func hideUsernameError() {
        self.usernameHeaderTextView.hideTipAndError()
        self.enableSignUpButton()
    }
    
}

// Network Requests
extension SimpleRegisterDetailsViewController {

    private func registerUser(form: EveryMatrix.SimpleRegisterForm) {
        Logger.log("Sent user register \(form.email)")
        Env.userSessionStore.registerUser(form: form)
            .breakpointOnError()
            .receive(on: DispatchQueue.main)
            .sink { completion in
                switch completion {
                case .failure(let error):
                    switch error {
                    case let .requestError(message) where message.lowercased().contains("username is already taken"):
                        self.showUsernameTakenErrorStatus()
                    case let .requestError(message) where message.lowercased().contains("email already exists"):
                        self.showEmailTakenErrorStatus()
                    case let .requestError(message) where message.lowercased().contains("Your password is too simple and does not match"):
                        self.showPasswordTooWeakErrorStatus()
                    default:
                        self.showServerErrorStatus()
                    }
                case .finished:
                    ()
                }
            } receiveValue: { _ in
                Logger.log("User registered \(form.email)")
                self.pushRegisterNextViewController(email: form.email)
            }
            .store(in: &cancellables)
    }

    private func requestValidUsernameCheck(_ username: String) {
        Env.everyMatrixAPIClient
            .validateUsername(username)
            .receive(on: DispatchQueue.main)
            .sink { completed in
                self.loadingUsernameValidityView.stopAnimating()
            } receiveValue: { usernameAvailability in
                if !usernameAvailability.isAvailable {
                    self.showUsernameTakenErrorStatus()
                }
                self.loadingUsernameValidityView.stopAnimating()
            }
            .store(in: &cancellables)
    }
}

// Flags business logic
extension SimpleRegisterDetailsViewController {

    private func setupWithCountryCodes(_ listings: EveryMatrix.CountryListing) {

        for country in listings.countries where country.isoCode == listings.currentIpCountry {
            self.mobilePrefixTextual = country.phonePrefix
            self.indicativeHeaderTextView.setText( self.formatIndicativeCountry(country), slideUp: true)
        }

        self.indicativeHeaderTextView.isUserInteractionEnabled = true
        self.indicativeHeaderTextView.shouldBeginEditing = { [weak self] in
            self?.showPhonePrefixSelector(listing: listings)
            return false
        }
    }

    private func showPhonePrefixSelector(listing: EveryMatrix.CountryListing) {
        let phonePrefixSelectorViewController = PhonePrefixSelectorViewController(countriesArray: listing)
        phonePrefixSelectorViewController.modalPresentationStyle = .overCurrentContext
        phonePrefixSelectorViewController.didSelectCountry = { [weak self] country in
            self?.setupWithSelectedCountry(country)
            phonePrefixSelectorViewController.animateDismissView()
        }
        self.present(phonePrefixSelectorViewController, animated: false, completion: nil)
    }

    private func setupWithSelectedCountry(_ country: EveryMatrix.Country) {
        self.mobilePrefixTextual = country.phonePrefix
        self.indicativeHeaderTextView.setText(formatIndicativeCountry(country), slideUp: true)
    }

    private func formatIndicativeCountry(_ country: EveryMatrix.Country) -> String {
        var stringCountry = "\(country.phonePrefix)"
        if let isoCode = country.isoCode {
            stringCountry = "\(isoCode) - \(country.phonePrefix)"
            if let flag = CountryFlagHelper.flag(forCode: isoCode) {
                stringCountry = "\(flag) \(country.phonePrefix)"
            }
        }
        return stringCountry
    }

}

// Keyboard
extension SimpleRegisterDetailsViewController {

    @objc func keyboardWillShow(notification: NSNotification) {

        guard let userInfo = notification.userInfo else { return }

        // swiftlint:disable:next force_cast
        var keyboardFrame: CGRect = (userInfo[UIResponder.keyboardFrameBeginUserInfoKey] as! NSValue).cgRectValue
        keyboardFrame = self.view.convert(keyboardFrame, from: nil)

        var contentInset = self.scrollView.contentInset
        contentInset.bottom = keyboardFrame.size.height + 20
        scrollView.contentInset = contentInset
    }

    @objc func keyboardWillHide(notification: NSNotification) {
        let contentInset: UIEdgeInsets = .zero
        scrollView.contentInset = contentInset
    }

}
