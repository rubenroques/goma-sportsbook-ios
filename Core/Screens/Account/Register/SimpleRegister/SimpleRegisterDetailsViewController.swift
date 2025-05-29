//
//  SimpleRegisterDetailsViewController.swift
//  Sportsbook
//
//  Created by André Lascas on 15/09/2021.
//

import UIKit
import Combine
import ServicesProvider
import SharedModels

class SimpleRegisterDetailsViewController: UIViewController {

    @IBOutlet private var scrollView: UIScrollView!
    @IBOutlet private var containerView: UIView!
    @IBOutlet private var backView: UIView!
    @IBOutlet private var backButton: UIButton!
    @IBOutlet private var registerTitleLabel: UILabel!
    @IBOutlet private var topSignUpView: UIView!
    @IBOutlet private var usernameHeaderTextView: HeaderTextFieldView!
    @IBOutlet private var dateHeaderTextView: HeaderDropDownSelectionView!
    @IBOutlet private var phoneView: UIView!
    @IBOutlet private var indicativeHeaderTextView: HeaderTextFieldView!
    @IBOutlet private var phoneHeaderTextView: HeaderTextFieldView!
    @IBOutlet private var lineView: UIView!
    @IBOutlet private var emailHeaderTextView: HeaderTextFieldView!
    @IBOutlet private var passwordHeaderTextView: HeaderTextFieldView!
    @IBOutlet private var confirmPasswordHeaderTextView: HeaderTextFieldView!
    @IBOutlet private var signUpButton: UIButton!
    @IBOutlet private var policyLinkView: PolicyLinkView!

    @IBOutlet private var quitButton: UIButton!

    @IBOutlet private var loadingUsernameValidityView: UIActivityIndicatorView!
    var spinnerViewController = LoadingSpinnerViewController()

    var cancellables = Set<AnyCancellable>()
    
    // Variables
    var emailAddress: String
    
    private var selectedCountry: Country?

    private var currentCountry: Country?
    private var countriesArray: [Country] = []
    
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

        self.setupWithTheme()
        self.commonInit()

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

    func commonInit() {

        registerTitleLabel.font = AppFont.with(type: AppFont.AppFontType.semibold, size: 26)
        registerTitleLabel.text = localized("signup")

        usernameHeaderTextView.setPlaceholderText(localized("username"))

        emailHeaderTextView.setPlaceholderText(localized("email"))
        emailHeaderTextView.setSecureField(false)
        emailHeaderTextView.setTextFieldDefaultValue(self.emailAddress)
        emailHeaderTextView.isDisabled = true

        // dateHeaderTextView.shouldBeginEditing = { return false }
        dateHeaderTextView.setPlaceholderText(localized("birth_date"))
        dateHeaderTextView.setImageTextField(UIImage(named: "calendar_regular_icon")!)
        dateHeaderTextView.setDatePickerMode()

        indicativeHeaderTextView.setPlaceholderText(localized("phone_prefix"))
        indicativeHeaderTextView.setText("----")
        indicativeHeaderTextView.setImageTextField(UIImage(named: "arrow_dropdown_icon")!, size: 10)
        indicativeHeaderTextView.setTextFieldFont(AppFont.with(type: .regular, size: 16))
        indicativeHeaderTextView.isUserInteractionEnabled = false

        phoneHeaderTextView.setPlaceholderText(localized("phone_number"))
        phoneHeaderTextView.setKeyboardType(.numberPad)

        passwordHeaderTextView.setPlaceholderText(localized("password"))
        confirmPasswordHeaderTextView.setPlaceholderText(localized("confirm_password"))

        signUpButton.setTitle(localized("signup"), for: .normal)
        signUpButton.titleLabel?.font = AppFont.with(type: AppFont.AppFontType.bold, size: 18)

        let tapGestureRecognizer = UITapGestureRecognizer.init(target: self, action: #selector(didTapBackground))
        self.view.addGestureRecognizer(tapGestureRecognizer)

        let maxDate = self.dateForMaxLegalAge(legalAge: 18)
        dateHeaderTextView.datePicker.maximumDate = maxDate

        self.quitButton.titleLabel?.font = AppFont.with(type: AppFont.AppFontType.semibold, size: 17)
        self.quitButton.setTitle(localized("quit"), for: .normal)
    }

    func setupWithTheme() {

        self.view.backgroundColor = UIColor.App.backgroundPrimary

        containerView.backgroundColor = UIColor.App.backgroundPrimary
        backView.backgroundColor = UIColor.App.backgroundPrimary
        registerTitleLabel.textColor = UIColor.App.textPrimary
        topSignUpView.backgroundColor = UIColor.App.backgroundPrimary

        usernameHeaderTextView.backgroundColor = UIColor.App.backgroundPrimary
        usernameHeaderTextView.setHeaderLabelColor(UIColor.App.inputTextTitle)
        usernameHeaderTextView.setTextFieldColor(UIColor.App.inputText)
        usernameHeaderTextView.setSecureField(false)

        dateHeaderTextView.backgroundColor = UIColor.App.backgroundPrimary
        dateHeaderTextView.setTextFieldColor(UIColor.App.inputText)
        dateHeaderTextView.setViewColor(UIColor.App.backgroundPrimary)
        dateHeaderTextView.setViewBorderColor(UIColor.App.inputTextTitle)
        dateHeaderTextView.setHeaderLabelColor(UIColor.App.inputTextTitle)
        dateHeaderTextView.setTextFieldFont(AppFont.with(type: .regular, size: 16))
        dateHeaderTextView.setHeaderLabelFont(AppFont.with(type: .regular, size: 15))
        dateHeaderTextView.setPlaceholderTextColor(UIColor.App.inputTextTitle)

        phoneView.backgroundColor = UIColor.App.backgroundPrimary

        indicativeHeaderTextView.backgroundColor = UIColor.App.backgroundPrimary
        indicativeHeaderTextView.setTextFieldColor(UIColor.App.inputText)
        indicativeHeaderTextView.setViewColor(UIColor.App.backgroundPrimary)
        indicativeHeaderTextView.setSecureField(false)

        phoneHeaderTextView.backgroundColor = UIColor.App.backgroundPrimary
        phoneHeaderTextView.setHeaderLabelColor(UIColor.App.inputTextTitle)
        phoneHeaderTextView.setTextFieldColor(UIColor.App.inputText)
        phoneHeaderTextView.setSecureField(false)

        lineView.backgroundColor = UIColor.App.inputTextTitle.withAlphaComponent(0.2)

        emailHeaderTextView.backgroundColor = UIColor.App.backgroundPrimary
        emailHeaderTextView.setHeaderLabelColor(UIColor.App.inputTextTitle)
        emailHeaderTextView.setTextFieldColor(UIColor.App.inputText)
        
        passwordHeaderTextView.backgroundColor = UIColor.App.backgroundPrimary
        passwordHeaderTextView.setHeaderLabelColor(UIColor.App.inputTextTitle)
        passwordHeaderTextView.setTextFieldColor(UIColor.App.inputText)
        passwordHeaderTextView.setSecureField(true)

        checkPolicyLinks()

        confirmPasswordHeaderTextView.backgroundColor = UIColor.App.backgroundPrimary
        confirmPasswordHeaderTextView.setHeaderLabelColor(UIColor.App.inputTextTitle)
        confirmPasswordHeaderTextView.setTextFieldColor(UIColor.App.inputText)
        confirmPasswordHeaderTextView.setSecureField(true)

        signUpButton.setTitleColor(UIColor.App.buttonTextPrimary, for: .normal)
        signUpButton.setTitleColor(UIColor.App.buttonTextPrimary.withAlphaComponent(0.7), for: .highlighted)
        signUpButton.setTitleColor(UIColor.App.buttonTextPrimary.withAlphaComponent(0.4), for: .disabled)

        signUpButton.backgroundColor = .clear
        signUpButton.setBackgroundColor(UIColor.App.buttonBackgroundPrimary, for: .normal)
        signUpButton.setBackgroundColor(UIColor.App.buttonBackgroundPrimary, for: .highlighted)
        signUpButton.layer.cornerRadius = CornerRadius.button
        signUpButton.layer.masksToBounds = true

        quitButton.setTitleColor(UIColor.App.highlightPrimary, for: .normal)
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

    private func setupPublishers() {
        
        Env.servicesProvider.getCurrentCountry()
            .compactMap({ $0 })
            .map({ (serviceProviderCountry: SharedModels.Country) -> Country in
                return Country(name: serviceProviderCountry.name,
                               capital: serviceProviderCountry.capital,
                               region: serviceProviderCountry.region,
                               iso2Code: serviceProviderCountry.iso2Code,
                               iso3Code: serviceProviderCountry.iso3Code,
                               numericCode: serviceProviderCountry.numericCode,
                               phonePrefix: serviceProviderCountry.phonePrefix)
            })
            .receive(on: DispatchQueue.main)
            .sink { _ in
                self.indicativeHeaderTextView.isUserInteractionEnabled = true
            } receiveValue: { [weak self] currentCountry in
                self?.currentCountry = currentCountry
                self?.selectedCountry = currentCountry
                
                self?.setupWithSelectedCountry(currentCountry)
            }
            .store(in: &cancellables)
        
        Env.servicesProvider.getCountries()
            .map { (serviceProviderCountries: [SharedModels.Country]) -> [Country] in
                serviceProviderCountries.map({ (serviceProviderCountry: SharedModels.Country) -> Country in
                    return Country(name: serviceProviderCountry.name,
                                   capital: serviceProviderCountry.capital,
                                   region: serviceProviderCountry.region,
                                   iso2Code: serviceProviderCountry.iso2Code,
                                   iso3Code: serviceProviderCountry.iso3Code,
                                   numericCode: serviceProviderCountry.numericCode,
                                   phonePrefix: serviceProviderCountry.phonePrefix)
                    
                })
            }
            .receive(on: DispatchQueue.main)
            .sink { _ in
                self.indicativeHeaderTextView.isUserInteractionEnabled = true
            } receiveValue: {  [weak self] countriesArray in
                self?.countriesArray = countriesArray
                
                self?.setupWithCountryCodes(countriesArray)
            }
            .store(in: &cancellables)

        self.usernameHeaderTextView.textPublisher
            .removeDuplicates()
            .receive(on: DispatchQueue.main)
            .sink {  [weak self] _ in
                self?.hideUsernameError()
            }
            .store(in: &cancellables)

        self.usernameHeaderTextView.textPublisher
            .receive(on: DispatchQueue.main)
            .removeDuplicates()
            .compactMap { $0 }
            .filter { $0.count > 3 }
            .debounce(for: 0.5, scheduler: DispatchQueue.main)
            .handleEvents(receiveOutput: { [weak self] _ in
                self?.loadingUsernameValidityView.startAnimating()
            })
            .eraseToAnyPublisher()
            .sink(receiveValue: { [weak self] username in
                self?.requestValidUsernameCheck(username)
            })
            .store(in: &cancellables)

        Publishers.CombineLatest4(self.usernameHeaderTextView.textPublisher,
                                 self.passwordHeaderTextView.textPublisher,
                                 self.confirmPasswordHeaderTextView.textPublisher,
                                 self.phoneHeaderTextView.textPublisher)
            .receive(on: DispatchQueue.main)
            .map { username, password, passwordConf, phone in

                if password != passwordConf {
                    return false
                }

                return (username?.isNotEmpty ?? false) &&
                        (password?.isNotEmpty ?? false) &&
                        (phone?.isNotEmpty ?? false)

            }
            .sink(receiveValue: { [weak self] valid in
                self?.signUpButton.isEnabled = valid
            })
            .store(in: &cancellables)

    }

    @IBAction private func didTapBackButton() {
        self.navigationController?.popViewController(animated: true)
    }

    @IBAction private func didTapQuitButton() {
        let submitCashoutAlert = UIAlertController(title: localized("quit_register"),
                                                   message: localized("quit_register_message"),
                                                   preferredStyle: UIAlertController.Style.alert)
        submitCashoutAlert.addAction(UIAlertAction(title: localized("quit"), style: .default, handler: { [weak self] _ in
            guard let self = self else { return }
            if self.isModal {
                self.dismiss(animated: true, completion: nil)
            }
            else {
                self.navigationController?.popToRootViewController(animated: true)
            }
        }))
        submitCashoutAlert.addAction(UIAlertAction(title: localized("cancel"), style: .cancel))

        self.present(submitCashoutAlert, animated: true, completion: nil)
    }

    @IBAction private func signUpAction() {

        let username = usernameHeaderTextView.text
        
        let birthDateString = dateHeaderTextView.text // Must be yyyy-MM-dd
        let birthDate = self.getDateFromTextFieldString(string: birthDateString)
        
        let mobile = phoneHeaderTextView.text
        let email = emailHeaderTextView.text
        let password = passwordHeaderTextView.text
        let confirmPassword = confirmPasswordHeaderTextView.text
        let emailVerificationURL = ""

        if password != confirmPassword {
            passwordHeaderTextView.showErrorOnField(text: localized("password_not_match"), color: UIColor.App.alertError)
            return
        }
        else if password.count < 9 {
            passwordHeaderTextView.showTip(text: localized("password_too_weak"))
            return
        }
        
        guard
            let selectedCountryISO = self.selectedCountry?.iso2Code,
            let mobilePrefixTextual = self.selectedCountry?.phonePrefix
        else {
            return
        }
        
        let currency = Env.businessSettingsSocket.clientSettings.locale?.currency ?? "EUR"
        
        if !checkDateBirth() {
            return
        }
//
//        let form = SimpleRegisterForm(email: email,
//                                                  username: username,
//                                                  password: password,
//                                                  birthDate: birthDate,
//                                                  mobilePrefix: mobilePrefixTextual,
//                                                  mobileNumber: mobile,
//                                                  emailVerificationURL: emailVerificationURL,
//                                                  countryCode: selectedCountryISO,
//                                                  currencyCode: currency)

//        let form = ServicesProvider.SimpleSignUpForm.init(email: email,
//                                                         username: username,
//                                                         password: password,
//                                                         birthDate: birthDate,
//                                                         mobilePrefix: mobilePrefixTextual,
//                                                         mobileNumber: mobile,
//                                                         countryIsoCode: selectedCountryISO,
//                                                         currencyCode: currency)
//
//        self.showLoadingSpinner()

        self.hideLoadingSpinner()

//        Env.userSessionStore.registerUser(form: form)
//            .receive(on: DispatchQueue.main)
//            .sink { [weak self] completion in
//                self?.hideLoadingSpinner()
//                switch completion {
//                case .failure(let error):
//                    switch error {
//                    case .usernameInvalid:
//                        self?.showUsernameInvalidErrorStatus()
//                    case .emailInvalid:
//                        self?.showEmailInavalidErrorStatus()
//                    case .passwordInvalid:
//                        self?.showServerErrorStatus()
//                    case .usernameAlreadyUsed:
//                        self?.showUsernameTakenErrorStatus()
//                    case .emailAlreadyUsed:
//                        self?.showEmailTakenErrorStatus()
//                    case .passwordWeak:
//                        self?.showPasswordTooWeakErrorStatus()
//                    case .serverError:
//                        self?.showServerErrorStatus()
//                    }
//                    AnalyticsClient.sendEvent(event: .userSignUpFail)
//                case .finished:
//                    ()
//                }
//            } receiveValue: { [weak self] userCreated in
//                if userCreated {
//                    Logger.log("User registered \(form.email)")
//                    AnalyticsClient.sendEvent(event: .userSignUpSuccess)
//                    self?.pushRegisterNextViewController(email: form.email)
//                }
//            }
//            .store(in: &cancellables)

    }

    private func checkDateBirth() -> Bool {

        if dateHeaderTextView.text.isEmpty {
            // dateHeaderTextView.showErrorOnField(text: localized("invalid_birthDate"), color: UIColor.App.alertError)
            return false
        }
        else {

            let textDate = getDateFromTextFieldString(string: dateHeaderTextView.text)
            if textDate > dateHeaderTextView.datePicker.date {
                // dateHeaderTextView.showErrorOnField(text: localized("invalid_birthDate"), color: UIColor.App.alertError)
                return false
            }
        }
        return true
    }

    func getDateFromTextFieldString(string: String) -> Date {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy/MM/dd"
        if let textDate = dateFormatter.date(from: string) {
            return textDate
        }
        return Date()
    }

    func pushRegisterNextViewController(email: String) {
        let codeVerificationViewController = CodeVerificationViewController(viewModel: CodeVerificationViewModel(email: email))
        self.navigationController?.pushViewController(codeVerificationViewController, animated: true)
    }

    @objc func didTapBackground() {
        self.resignFirstResponder()

        self.usernameHeaderTextView.resignFirstResponder()
        // self.dateHeaderTextView.resignFirstResponder()
        self.indicativeHeaderTextView.resignFirstResponder()
        self.phoneHeaderTextView.resignFirstResponder()
        self.passwordHeaderTextView.resignFirstResponder()
        self.confirmPasswordHeaderTextView.resignFirstResponder()
    }

    func showLoadingSpinner() {

        view.addSubview(spinnerViewController.view)
        spinnerViewController.view.translatesAutoresizingMaskIntoConstraints = false
        spinnerViewController.view.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        spinnerViewController.view.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        spinnerViewController.view.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        spinnerViewController.view.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        spinnerViewController.didMove(toParent: self)

    }

    func hideLoadingSpinner() {
        spinnerViewController.willMove(toParent: nil)
        spinnerViewController.removeFromParent()
        spinnerViewController.view.removeFromSuperview()
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
        self.usernameHeaderTextView.showErrorOnField(text: localized("username_already_registered"),
                                                     color: UIColor.App.alertError)
        self.disableSignUpButton()
    }

    func showUsernameInvalidErrorStatus() {
        self.usernameHeaderTextView.showErrorOnField(text: localized("username_invalid"),
                                                     color: UIColor.App.alertError)
        self.disableSignUpButton()
    }
    
    func showEmailTakenErrorStatus() {
        self.usernameHeaderTextView.showErrorOnField(text: localized("email_already_registered"), color: UIColor.App.alertError)
        self.disableSignUpButton()
    }
    
    func showEmailInavalidErrorStatus() {
        self.usernameHeaderTextView
            .showErrorOnField(text: localized("invalid_email"),
                              color: UIColor.App.alertError)
        self.disableSignUpButton()
    }

    func showPasswordTooWeakErrorStatus() {
        self.disableSignUpButton()
        self.passwordHeaderTextView.showErrorOnField(text: localized("password_too_weak"),
                                                     color: UIColor.App.alertError)
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

    private func requestValidUsernameCheck(_ username: String) {
//        Env. em .validateUsername(username)
//            .receive(on: DispatchQueue.main)
//            .sink { [weak self] _ in
//                self?.loadingUsernameValidityView.stopAnimating()
//            } receiveValue: { [weak self] usernameAvailability in
//                if !usernameAvailability.isAvailable {
//                    self?.showUsernameTakenErrorStatus()
//                }
//                self?.loadingUsernameValidityView.stopAnimating()
//            }
//            .store(in: &cancellables)
    }
}

// Flags business logic
extension SimpleRegisterDetailsViewController {

    private func setupWithCountryCodes(_ countries: [Country]) {
        self.indicativeHeaderTextView.isUserInteractionEnabled = true
        self.indicativeHeaderTextView.shouldBeginEditing = { [weak self] in
            self?.showPhonePrefixSelector(countries)
            return false
        }
    }

    private func showPhonePrefixSelector(_ countries: [Country]) {
        let phonePrefixSelectorViewController = PhonePrefixSelectorViewController(countries: countries, originCountry: self.currentCountry)
        phonePrefixSelectorViewController.modalPresentationStyle = .overCurrentContext
        phonePrefixSelectorViewController.didSelectCountry = { [weak self] country in
            self?.setupWithSelectedCountry(country)
            
            phonePrefixSelectorViewController.animateDismissView()
            
            // TODO: Legal Age
            let legalAge = 18
            self?.updateBirthAgeLimit(ageLimit: legalAge)
        }
        self.present(phonePrefixSelectorViewController, animated: false, completion: nil)
    }

    private func setupWithSelectedCountry(_ country: Country) {
        self.selectedCountry = country
        self.indicativeHeaderTextView.setText(self.formatIndicativeCountry(country), slideUp: true)

        // TODO: Legal Age
        let legalAge = 18
        
        let maxDate = self.dateForMaxLegalAge(legalAge: legalAge)
        self.dateHeaderTextView.datePicker.maximumDate = maxDate
    }

    private func formatIndicativeCountry(_ country: Country) -> String {
        var stringCountry = "\(country.phonePrefix)"
        let isoCode = country.iso2Code
        
        stringCountry = "\(isoCode) - \(country.phonePrefix)"
        if let flag = CountryFlagHelper.flag(forCode: isoCode) {
            stringCountry = "\(flag) \(country.phonePrefix)"
        }
        
        return stringCountry
    }

    private func updateBirthAgeLimit(ageLimit: Int) {
        let maxDate = self.dateForMaxLegalAge(legalAge: ageLimit)
        let fieldDate = getDateFromTextFieldString(string: dateHeaderTextView.text)
        if fieldDate > maxDate {
            dateHeaderTextView.datePicker.maximumDate = maxDate
        }
    }

    private func dateForMaxLegalAge(legalAge: Int) -> Date {
        let calendar = Calendar(identifier: .gregorian)
        var components = DateComponents()
        components.calendar = calendar
        components.year = -legalAge
        let maxDate = calendar.date(byAdding: components, to: Date())!
        return maxDate
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
