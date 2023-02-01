//
//  File.swift
//  
//
//  Created by Ruben Roques on 23/01/2023.
//

import Foundation
import UIKit
import ServicesProvider
import Theming
import Extensions
import Combine
import SharedModels
import CountrySelectionFeature

class ContactsFormStepViewModel {

    enum EmailState {
        case empty
        case needsValidation
        case validating
        case serverError
        case alreadyInUse
        case invalidSyntax
        case valid
    }

    enum CountriesState {
        case idle
        case loading
        case loaded(countries: [SharedModels.Country])
    }

    let title: String

    let defaultCountryIso3Code: String

    let email: CurrentValueSubject<String?, Never>
    let phoneNumber: CurrentValueSubject<String?, Never>

    //
    var emailState: CurrentValueSubject<EmailState, Never> = .init(.empty)
    private var checkEmailRegisteredCancellables: AnyCancellable?

    //
    var selectedCountry: CurrentValueSubject<SharedModels.Country?, Never>
    var selectedPrefixText: AnyPublisher<String?, Never> {
        self.selectedCountry
            .map({ country -> String? in
                if let selectedCountry = country {
                    let countryString = self.formatIndicativeCountry(selectedCountry)
                    return countryString
                } else {
                    return nil
                }
            })
            .eraseToAnyPublisher()
    }

    //
    private var defaultCountrySubject: CurrentValueSubject<SharedModels.Country?, Never> = .init(nil)
    var defaultCountryText: AnyPublisher<String?, Never> {
        self.defaultCountrySubject
            .map { country in
                if let country {
                    return self.formatIndicativeCountry(country)
                }
                else {
                    return nil
                }
            }
            .eraseToAnyPublisher()
    }

    //
    var countriesState: CurrentValueSubject<CountriesState, Never> = .init(.idle)
    var countries: [SharedModels.Country]? {
        switch self.countriesState.value {
        case .loaded(let countries): return countries
        default: return nil
        }
    }

    var isFormCompleted: AnyPublisher<Bool, Never> {
        return Publishers.CombineLatest3(self.emailState, self.phoneNumber, self.selectedCountry)
            .map { emailState, phoneNumber, prefixCountry -> Bool in
                let isEmailValid = emailState == .valid
                let isPhoneNumberValid = self.isValidPhoneNumber(phoneNumber ?? "")
                let hasPrefix = prefixCountry != nil
                return isEmailValid && isPhoneNumberValid && hasPrefix
            }
            .eraseToAnyPublisher()
    }

    private var serviceProvider: ServicesProviderClient
    private var userRegisterEnvelopUpdater: UserRegisterEnvelopUpdater

    private var cancellables = Set<AnyCancellable>()

    init(title: String,
         email: String? = nil,
         phoneNumber: String? = nil,
         prefixCountry: Country?,
         defaultCountryIso3Code: String,
         serviceProvider: ServicesProviderClient,
         userRegisterEnvelopUpdater: UserRegisterEnvelopUpdater) {

        self.title = title

        self.selectedCountry = .init(prefixCountry)
        self.phoneNumber = .init(phoneNumber)
        self.email = .init(email)

        self.defaultCountryIso3Code = defaultCountryIso3Code

        self.serviceProvider = serviceProvider
        self.userRegisterEnvelopUpdater = userRegisterEnvelopUpdater

        self.email
            .removeDuplicates()
            .sink { [weak self] newEmail in

                self?.userRegisterEnvelopUpdater.setEmail(nil)
                self?.checkEmailRegisteredCancellables?.cancel()

                guard
                    let newEmail
                else {
                    self?.emailState.send(.empty)
                    return
                }

                if newEmail.isEmpty {
                    self?.emailState.send(.empty)
                }
                else if self?.isValidEmailAddress(newEmail) ?? false {
                    self?.emailState.send(.needsValidation)
                }
                else {
                    self?.emailState.send(EmailState.invalidSyntax)
                }
            }
            .store(in: &self.cancellables)

        //
        let clearedEmailState = self.emailState.removeDuplicates()
        let clearedEmail = self.email.removeDuplicates()

        Publishers.CombineLatest(clearedEmailState, clearedEmail)
            .print("DEBUG-EMAIL: ")
            .debounce(for: .seconds(0.6), scheduler: DispatchQueue.main)
            .filter { emailState, email in
                return emailState == .needsValidation
            }
            .map { _, email -> String? in
                return email
            }
            .compactMap({ $0 })
            .sink { [weak self] email in
                self?.requestValidEmailCheck(email: email)
            }
            .store(in: &self.cancellables)

        Publishers.CombineLatest(self.emailState, self.email)
            .filter { emailState, email in
                return emailState == .valid
            }
            .map { _, email -> String? in
                return email
            }
            .compactMap({ $0 })
            .sink { validEmail in
                self.userRegisterEnvelopUpdater.setEmail(validEmail)
            }
            .store(in: &self.cancellables)

        self.loadCountries()
    }

    func loadCountries() {

        self.countriesState.send(.loading)

        self.serviceProvider.getCountries()
            .sink { completion in

            } receiveValue: { [weak self] countries in
                self?.defaultCountrySubject.send(countries.first(where: { $0.iso3Code == self?.defaultCountryIso3Code}))
                self?.countriesState.send(.loaded(countries: countries))
            }
            .store(in: &self.cancellables)

        self.defaultCountrySubject
            .compactMap({ $0 })
            .sink { [weak self] defaultCountry in
                if self?.selectedCountry.value == nil {
                    self?.setSelectedPrefixCountry(defaultCountry)
                }
            }
            .store(in: &self.cancellables)
    }

    func requestValidEmailCheck(email: String) {

        self.checkEmailRegisteredCancellables?.cancel()

        self.emailState.send(.validating)

        self.checkEmailRegisteredCancellables = self.serviceProvider.checkEmailRegistered(email)
                    .receive(on: DispatchQueue.main)
                    .sink { [weak self] completion in
                        switch completion {
                        case .failure(_):
                            self?.emailState.send(.serverError)
                        case .finished:
                            ()
                        }
                    }
                    receiveValue: { [weak self] isEmailInUse in
                        if isEmailInUse {
                            self?.emailState.send(.alreadyInUse)
                        }
                        else {
                            self?.emailState.send(.valid)
                        }
                    }

    }

    func setSelectedPrefixCountry(_ country: Country) {
        self.selectedCountry.send(country)
        self.userRegisterEnvelopUpdater.setPhonePrefixCountry(country)
    }

    func setEmail(_ email: String) {
        self.email.send(email)
    }

    func setPhoneNumber(_ phoneNumber: String) {
        self.phoneNumber.send(phoneNumber)
        self.userRegisterEnvelopUpdater.setPhoneNumber(phoneNumber)
    }

    private func formatIndicativeCountry(_ country: Country) -> String {
        var stringCountry = "\(country.iso2Code) - \(country.phonePrefix)"
        if let flag = CountryFlagHelper.flag(forCode: country.iso2Code) {
            stringCountry = "\(flag)  \(country.phonePrefix)"
        }
        return stringCountry
    }

    private func isValidEmailAddress(_ email: String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPred = NSPredicate(format: "SELF MATCHES %@", emailRegEx)
        return emailPred.evaluate(with: email)
    }

    private func isValidPhoneNumber(_ phoneNumber: String) -> Bool {
//        let phoneNumberValidationRegex = #"^(?:0|\+33 ?|0?0?33 ?|)([1-9] ?(?:[0-9] ?){8})$"#
//        let phoneNumberValidationPredicate = NSPredicate(format: "SELF MATCHES %@", phoneNumberValidationRegex)
//        return phoneNumberValidationPredicate.evaluate(with: phoneNumber)

        let numbersCharacterSet: NSCharacterSet = NSCharacterSet(charactersIn: "0123456789")
        if phoneNumber.rangeOfCharacter(from: numbersCharacterSet.inverted) != nil {
            return false
        }
        return phoneNumber.count > 2
    }

}

class ContactsFormStepView: FormStepView {

    private lazy var emailHeaderTextFieldView: HeaderTextFieldView = Self.createEmailHeaderTextFieldView()
    private lazy var loadingView: UIActivityIndicatorView = Self.createLoadingView()

    private lazy var phoneStackView: UIStackView = Self.createPhoneStackView()

    private lazy var phoneHeaderTextFieldView: HeaderTextFieldView = Self.createPhoneHeaderTextFieldView()
    private lazy var prefixContainerView: UIView = Self.createPrefixContainerView()
    private lazy var prefixDownIconImageView: UIImageView = Self.createPrefixDownIconImageView()
    private lazy var prefixLabel: UILabel = Self.createPrefixLabel()

    private let viewModel: ContactsFormStepViewModel

    private var cancellables = Set<AnyCancellable>()

    override var isFormCompleted: AnyPublisher<Bool, Never> {
        return self.viewModel.isFormCompleted
    }

    init(viewModel: ContactsFormStepViewModel) {
        self.viewModel = viewModel

        super.init()

        self.configureSubviews()
    }

    func configureSubviews() {

        self.prefixContainerView.addSubview(self.prefixLabel)
        self.prefixContainerView.addSubview(self.prefixDownIconImageView)

        let prefixPlaceholderView = UIView()
        prefixPlaceholderView.backgroundColor = .clear
        prefixPlaceholderView.translatesAutoresizingMaskIntoConstraints = false
        prefixPlaceholderView.addSubview(self.prefixContainerView)

        self.phoneStackView.addArrangedSubview(prefixPlaceholderView)
        self.phoneStackView.addArrangedSubview(self.phoneHeaderTextFieldView)

        self.emailHeaderTextFieldView.addSubview(self.loadingView)

        self.stackView.addArrangedSubview(self.emailHeaderTextFieldView)
        self.stackView.addArrangedSubview(self.phoneStackView)

        NSLayoutConstraint.activate([

            self.loadingView.centerYAnchor.constraint(equalTo: self.emailHeaderTextFieldView.contentCenterYConstraint),
            self.loadingView.trailingAnchor.constraint(equalTo: self.emailHeaderTextFieldView.trailingAnchor, constant: -10),

            self.prefixContainerView.heightAnchor.constraint(equalToConstant: 57),
            self.prefixContainerView.widthAnchor.constraint(equalToConstant: 114),

            self.prefixContainerView.leadingAnchor.constraint(equalTo: prefixPlaceholderView.leadingAnchor),
            self.prefixContainerView.topAnchor.constraint(equalTo: prefixPlaceholderView.topAnchor),
            self.prefixContainerView.trailingAnchor.constraint(equalTo: prefixPlaceholderView.trailingAnchor),

            self.prefixDownIconImageView.widthAnchor.constraint(equalTo: self.prefixDownIconImageView.heightAnchor),
            self.prefixDownIconImageView.widthAnchor.constraint(equalToConstant: 13),
            self.prefixDownIconImageView.centerYAnchor.constraint(equalTo: self.prefixContainerView.centerYAnchor),
            self.prefixDownIconImageView.trailingAnchor.constraint(equalTo: self.prefixContainerView.trailingAnchor, constant: -11),

            self.prefixLabel.leadingAnchor.constraint(equalTo: self.prefixContainerView.leadingAnchor, constant: 15),
            self.prefixLabel.centerYAnchor.constraint(equalTo: self.prefixContainerView.centerYAnchor),
            self.prefixLabel.trailingAnchor.constraint(equalTo: self.prefixDownIconImageView.leadingAnchor, constant: -2),

            self.emailHeaderTextFieldView.heightAnchor.constraint(equalToConstant: 80),
            self.phoneHeaderTextFieldView.heightAnchor.constraint(equalToConstant: 80),
        ])

        self.titleLabel.text = self.viewModel.title

        self.emailHeaderTextFieldView.setKeyboardType(.emailAddress)
        self.phoneHeaderTextFieldView.setKeyboardType(.phonePad)

        self.emailHeaderTextFieldView.setPlaceholderText("Email")
        self.phoneHeaderTextFieldView.setPlaceholderText("Phone number")

        self.emailHeaderTextFieldView.setReturnKeyType(.next)
        self.emailHeaderTextFieldView.didTapReturn = { [weak self] in
            self?.phoneHeaderTextFieldView.becomeFirstResponder()
        }

        self.phoneHeaderTextFieldView.setReturnKeyType(.continue)
        self.phoneHeaderTextFieldView.didTapReturn = { [weak self] in
            self?.phoneHeaderTextFieldView.resignFirstResponder()
        }

        self.viewModel.countriesState
            .receive(on: DispatchQueue.main)
            .sink { [weak self] state in
                switch state {
                case .loaded(_):
                    self?.prefixContainerView.isUserInteractionEnabled = true
                default:
                    self?.prefixContainerView.isUserInteractionEnabled = false
                }
            }
            .store(in: &self.cancellables)

        Publishers.CombineLatest(self.viewModel.selectedPrefixText, self.viewModel.defaultCountryText)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] prefixString, defaultCountry in
                if let prefixString {
                    self?.prefixLabel.textColor = AppColor.textPrimary
                    self?.prefixLabel.text = prefixString
                }
                else if let defaultCountry {
                    self?.prefixLabel.textColor = AppColor.textPrimary
                    self?.prefixLabel.text = defaultCountry
                }
                else {
                    self?.prefixLabel.textColor = AppColor.inputTextTitle
                    self?.prefixLabel.text = "Prefix"
                }
            }
            .store(in: &self.cancellables)

        self.emailHeaderTextFieldView.textPublisher
            .sink { [weak self] text in
                self?.viewModel.setEmail(text)
            }
            .store(in: &self.cancellables)

        self.phoneHeaderTextFieldView.textPublisher
            .sink { [weak self] email in
                self?.viewModel.setPhoneNumber(email)
            }
            .store(in: &self.cancellables)

        self.viewModel.emailState
            .receive(on: DispatchQueue.main)
            .debounce(for: .seconds(2.0), scheduler: DispatchQueue.main)
            .filter({ state in
                return state == .invalidSyntax
            })
            .sink { [weak self] _ in
                self?.emailHeaderTextFieldView.showErrorOnField(text: "Please insert a valid email format", color: AppColor.inputError)
            }
            .store(in: &self.cancellables)

        self.viewModel.emailState
            .receive(on: DispatchQueue.main)
            .sink { [weak self] emailState in
                if emailState == .validating {
                    self?.loadingView.startAnimating()
                }
                else {
                    self?.loadingView.stopAnimating()
                }

                switch emailState {
                case .empty:
                    self?.emailHeaderTextFieldView.hideTipAndError()
                case .needsValidation:
                    self?.emailHeaderTextFieldView.hideTipAndError()
                case .validating:
                    self?.emailHeaderTextFieldView.hideTipAndError()
                case .serverError:
                    self?.emailHeaderTextFieldView.showErrorOnField(text: "Sorry we cannot verify this email", color: AppColor.inputError)
                case .alreadyInUse:
                    self?.emailHeaderTextFieldView.showErrorOnField(text: "This email is already in use", color: AppColor.inputError)
                case .invalidSyntax:
                    self?.emailHeaderTextFieldView.hideTipAndError()
                case .valid:
                    self?.emailHeaderTextFieldView.hideTipAndError()
                }

            }
            .store(in: &self.cancellables)

        self.emailHeaderTextFieldView.setText(self.viewModel.email.value ?? "")
        self.phoneHeaderTextFieldView.setText(self.viewModel.phoneNumber.value ?? "")

        self.prefixContainerView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.didTapPrefixView)))
    }

    public override func layoutSubviews() {
        super.layoutSubviews()
    }

    override func setupWithTheme() {
        super.setupWithTheme()

        self.prefixContainerView.layer.borderColor = AppColor.backgroundBorder.cgColor

        self.prefixLabel.textColor = AppColor.inputTextTitle

        self.prefixDownIconImageView.tintColor = AppColor.textPrimary

        self.emailHeaderTextFieldView.backgroundColor = AppColor.backgroundPrimary
        self.emailHeaderTextFieldView.setHeaderLabelColor(AppColor.inputTextTitle)
        self.emailHeaderTextFieldView.setTextFieldColor(AppColor.inputText)

        self.phoneHeaderTextFieldView.backgroundColor = AppColor.backgroundPrimary
        self.phoneHeaderTextFieldView.setHeaderLabelColor(AppColor.inputTextTitle)
        self.phoneHeaderTextFieldView.setTextFieldColor(AppColor.inputText)
    }

    @objc func didTapPrefixView() {
        self.showCountrySelector()
    }

    func showCountrySelector() {
        if let countries = self.viewModel.countries {

            let defaultCountry = countries.filter { country in
                country.iso3Code == "FRA"
            }

            let countrySelectorViewController = CountrySelectionFeature.CountrySelectorViewController(countries: countries,
                                                                                                      originCountry: defaultCountry.first,
                                                                                                      showIndicatives: true)
            countrySelectorViewController.modalPresentationStyle = .overCurrentContext
            countrySelectorViewController.didSelectCountry = { [weak self, weak countrySelectorViewController] (selectedCountry: SharedModels.Country) in
                self?.viewModel.setSelectedPrefixCountry(selectedCountry)
                countrySelectorViewController?.animateDismissView()
            }
            self.viewController?.present(countrySelectorViewController, animated: true)
        }
    }

    override func canPresentError(forFormStep formStep: FormStep) -> Bool {
        switch formStep {
        case .contacts: return true
        default: return false
        }
    }

    override func presentError(_ error: RegisterError, forFormStep formStep: FormStep) {
        if !self.canPresentError(forFormStep: formStep) { return }

        switch (error.field, error.error) {
        case ("email", "INVALID_LENGTH"):
            self.emailHeaderTextFieldView.showErrorOnField(text: "Place/Commune is too long", color: AppColor.alertError)
        case ("mobile", "INVALID_LENGTH"):
            self.phoneHeaderTextFieldView.showErrorOnField(text: "Street name is too long", color: AppColor.alertError)
        case ("email", "DUPLICATE"):
            self.emailHeaderTextFieldView.showErrorOnField(text: "This email is already in use", color: AppColor.alertError)
        case ("mobile", "DUPLICATE"):
            self.phoneHeaderTextFieldView.showErrorOnField(text: "This mobile number is already in use", color: AppColor.alertError)
        case ("email", _):
            self.emailHeaderTextFieldView.showErrorOnField(text: "Please enter a valid Email", color: AppColor.alertError)
        case ("mobile", _):
            self.phoneHeaderTextFieldView.showErrorOnField(text: "Please enter a valid Phone Number", color: AppColor.alertError)
        default:
            ()
        }
    }

}

extension ContactsFormStepView {

    private static func createEmailHeaderTextFieldView() -> HeaderTextFieldView {
        let headerTextFieldView = HeaderTextFieldView()
        headerTextFieldView.setTextFieldFont(AppFont.with(type: .semibold, size: 16))
        headerTextFieldView.setHeaderLabelFont(AppFont.with(type: .semibold, size: 16))
        headerTextFieldView.translatesAutoresizingMaskIntoConstraints = false
        return headerTextFieldView
    }


    private static func createLoadingView() -> UIActivityIndicatorView {
        let loadingView = UIActivityIndicatorView(style: .medium)
        loadingView.hidesWhenStopped = true
        loadingView.translatesAutoresizingMaskIntoConstraints = false
        return loadingView
    }

    private static func createPhoneHeaderTextFieldView() -> HeaderTextFieldView {
        let headerTextFieldView = HeaderTextFieldView()
        headerTextFieldView.setTextFieldFont(AppFont.with(type: .semibold, size: 16))
        headerTextFieldView.setHeaderLabelFont(AppFont.with(type: .semibold, size: 16))
        headerTextFieldView.translatesAutoresizingMaskIntoConstraints = false
        return headerTextFieldView
    }

    private static func createPhoneStackView() -> UIStackView {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .horizontal
        stackView.distribution = .fillProportionally
        stackView.spacing = 20
        return stackView
    }

    private static func createPrefixContainerView() -> UIView {
        let view = UIView()
        view.layer.cornerRadius = 10
        view.layer.borderWidth = 1
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }

    private static func createPrefixLabel() -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Label"
        return label
    }

    private static func createPrefixDownIconImageView() -> UIImageView {
        let imageView = UIImageView(image: UIImage(systemName: "arrowtriangle.down.fill"))
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        return imageView
    }


}
