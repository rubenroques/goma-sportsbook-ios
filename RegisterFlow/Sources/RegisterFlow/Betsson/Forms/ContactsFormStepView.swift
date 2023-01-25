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

    let title: String

    let email: CurrentValueSubject<String?, Never>
    let phoneNumber: CurrentValueSubject<String?, Never>

    let defaultCountryIso3Code: String

    private var selectedPrefixCountrySubject: CurrentValueSubject<SharedModels.Country?, Never> = .init(nil)

    var selectedPrefixText: AnyPublisher<String?, Never> {
        self.selectedPrefixCountrySubject
            .map({ country -> String? in
                if let selectedPrefixCountry = country {
                    let countryString = self.formatIndicativeCountry(selectedPrefixCountry)
                    return countryString
                } else {
                    return nil
                }
            })
            .eraseToAnyPublisher()
    }

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

    var countryState: CurrentValueSubject<CountryState, Never> = .init(.idle)
    var countries: [SharedModels.Country]? {
        switch self.countryState.value {
        case .loaded(let countries): return countries
        default: return nil
        }
    }

    var isFormCompleted: AnyPublisher<Bool, Never> {
        return Publishers.CombineLatest3(self.email, self.phoneNumber, self.selectedPrefixCountrySubject)
            .map { email, phoneNumber, prefixCountry -> Bool in
                let isEmailValid = self.isValidEmailAddress(email ?? "")
                let isPhoneNumberValid = self.isValidPhoneNumber(phoneNumber ?? "")
                let hasPrefix = prefixCountry != nil
                return isEmailValid && isPhoneNumberValid && hasPrefix
            }
            .eraseToAnyPublisher()
    }

    private var serviceProvider: ServicesProviderClient
    private var userRegisterEnvelopUpdater: UserRegisterEnvelopUpdater

    private var cancellables = Set<AnyCancellable>()

    enum CountryState {
        case idle
        case loading
        case loaded(countries: [SharedModels.Country])
    }


    init(title: String, email: String? = nil, phoneNumber: String? = nil, defaultCountryIso3Code: String, serviceProvider: ServicesProviderClient, userRegisterEnvelopUpdater: UserRegisterEnvelopUpdater) {
        self.title = title

        self.phoneNumber = .init(phoneNumber)
        self.email = .init(email)

        self.defaultCountryIso3Code = defaultCountryIso3Code

        self.serviceProvider = serviceProvider
        self.userRegisterEnvelopUpdater = userRegisterEnvelopUpdater

        self.loadCountries()
    }

    func loadCountries() {

        self.countryState.send(.loading)

        self.serviceProvider.getCountries()
            .sink { completion in

            } receiveValue: { [weak self] countries in
                self?.defaultCountrySubject.send(countries.first(where: { $0.iso3Code == self?.defaultCountryIso3Code}))
                self?.countryState.send(.loaded(countries: countries))
            }
            .store(in: &self.cancellables)
    }

    func setSelectedPrefixCountry(_ country: Country) {
        self.selectedPrefixCountrySubject.send(country)
        self.userRegisterEnvelopUpdater.setPhonePrefixCountry(country)
    }

    func setEmail(_ email: String) {
        self.email.send(email)
        self.userRegisterEnvelopUpdater.setEmail(email)
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
        let emailValidationRegex = "^[\\p{L}0-9!#$%&'*+\\/=?^_`{|}~-][\\p{L}0-9.!#$%&'*+\\/=?^_`{|}~-]{0,63}@[\\p{L}0-9-]+(?:\\.[\\p{L}0-9-]{2,7})*$"
        let emailValidationPredicate = NSPredicate(format: "SELF MATCHES %@", emailValidationRegex)
        return emailValidationPredicate.evaluate(with: email)
    }

    private func isValidPhoneNumber(_ phoneNumber: String) -> Bool {
//        let phoneNumberValidationRegex = #"^(?:0|\+33 ?|0?0?33 ?|)([1-9] ?(?:[0-9] ?){8})$"#
//        let phoneNumberValidationPredicate = NSPredicate(format: "SELF MATCHES %@", phoneNumberValidationRegex)
//        return phoneNumberValidationPredicate.evaluate(with: phoneNumber)
        return phoneNumber.count > 2
    }

}

class ContactsFormStepView: FormStepView {

    private lazy var emailHeaderTextFieldView: HeaderTextFieldView = Self.createEmailHeaderTextFieldView()

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

        self.stackView.addArrangedSubview(self.emailHeaderTextFieldView)
        self.stackView.addArrangedSubview(self.phoneStackView)

        NSLayoutConstraint.activate([

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
        self.phoneHeaderTextFieldView.setKeyboardType(.namePhonePad)

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

        self.emailHeaderTextFieldView.setText(self.viewModel.email.value ?? "")
        self.phoneHeaderTextFieldView.setText(self.viewModel.phoneNumber.value ?? "")

        self.viewModel.countryState
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
            .sink { [weak self] text in
                self?.viewModel.setPhoneNumber(text)
            }
            .store(in: &self.cancellables)

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
                                                                                                      showIndicatives: false)
            countrySelectorViewController.modalPresentationStyle = .overCurrentContext
            countrySelectorViewController.didSelectCountry = { [weak self, weak countrySelectorViewController] (selectedCountry: SharedModels.Country) in
                self?.viewModel.setSelectedPrefixCountry(selectedCountry)
                countrySelectorViewController?.animateDismissView()
            }
            self.viewController?.present(countrySelectorViewController, animated: true)
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
