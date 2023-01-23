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

    private var selectedPrefixCountry: SharedModels.Country? {
        didSet {
            if let selectedPrefixCountry = self.selectedPrefixCountry {
                let countryString = self.formatIndicativeCountry(selectedPrefixCountry)
                self.selectedPrefixText.send(countryString)
            } else {
                self.selectedPrefixText.send(nil)
            }
        }
    }

    var selectedPrefixText: CurrentValueSubject<String?, Never> = .init(nil)

    var countryState: CurrentValueSubject<CountryState, Never> = .init(.idle)
    var countries: [SharedModels.Country]? {
        switch self.countryState.value {
        case .loaded(let countries): return countries
        default: return nil
        }
    }

    private var serviceProvider: ServicesProviderClient
    private var cancellables = Set<AnyCancellable>()

    enum CountryState {
        case idle
        case loading
        case loaded(countries: [SharedModels.Country])
    }


    init(title: String, serviceProvider: ServicesProviderClient) {
        self.title = title
        self.serviceProvider = serviceProvider

        self.loadCountries()
    }

    func loadCountries() {

        self.countryState.send(.loading)

        serviceProvider.getCountries()
            .sink { completion in

            } receiveValue: { [weak self] countries in
                self?.countryState.send(.loaded(countries: countries))
            }
            .store(in: &self.cancellables)
    }

    func setSelectedPrefixCountry(_ country: Country) {
        self.selectedPrefixCountry = country
    }

    private func formatIndicativeCountry(_ country: Country) -> String {
        var stringCountry = "\(country.iso2Code) - \(country.phonePrefix)"
        if let flag = CountryFlagHelper.flag(forCode: country.iso2Code) {
            stringCountry = "\(flag)  \(country.phonePrefix)"
        }
        return stringCountry
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
            self.prefixDownIconImageView.widthAnchor.constraint(equalToConstant: 8),
            self.prefixDownIconImageView.centerYAnchor.constraint(equalTo: self.prefixContainerView.centerYAnchor),
            self.prefixDownIconImageView.trailingAnchor.constraint(equalTo: self.prefixContainerView.trailingAnchor, constant: -9),

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

        self.viewModel.selectedPrefixText
            .receive(on: DispatchQueue.main)
            .sink { [weak self] prefixString in
                if let prefixString {
                    self?.prefixLabel.textColor = AppColor.textPrimary
                    self?.prefixLabel.text = prefixString
                }
                else {
                    self?.prefixLabel.textColor = UIColor(hex: 0x3E4A59)
                    self?.prefixLabel.text = "Prefix"
                }
            }
            .store(in: &self.cancellables)

        self.prefixContainerView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.didTapPrefixView)))

    }

    public override func layoutSubviews() {
        super.layoutSubviews()
    }

    override func setupWithTheme() {
        super.setupWithTheme()

        self.prefixContainerView.layer.borderColor = AppColor.textPrimary.cgColor

        self.prefixLabel.textColor = UIColor(hex: 0x3E4A59)

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
        headerTextFieldView.translatesAutoresizingMaskIntoConstraints = false
        return headerTextFieldView
    }

    private static func createPhoneHeaderTextFieldView() -> HeaderTextFieldView {
        let headerTextFieldView = HeaderTextFieldView()
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
        let imageView = UIImageView(image: UIImage(systemName: "arrow.down"))
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        return imageView
    }


}
