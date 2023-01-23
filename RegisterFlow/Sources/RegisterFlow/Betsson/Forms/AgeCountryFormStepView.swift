//
//  NamesFormStepView.swift
//  
//
//  Created by Ruben Roques on 16/01/2023.
//

import UIKit
import Theming
import Extensions
import Combine
import ServicesProvider
import SharedModels
import CountrySelectionFeature

class AgeCountryFormStepViewModel {

    let title: String

    var birthDate: Date?

    private var selectedCountry: Country? {
        didSet {
            if let selectedCountry = self.selectedCountry {
                let countryString = self.formatIndicativeCountry(selectedCountry)
                self.selectedCountryText.send(countryString)
            } else {
                self.selectedCountryText.send(nil)
            }
        }
    }

    var selectedCountryText: CurrentValueSubject<String?, Never> = .init(nil)

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

    init(title: String, countryState: CountryState = .idle, birthDate: Date? = nil, serviceProvider: ServicesProviderClient) {
        self.title = title

        self.countryState = .init(countryState)
        self.birthDate = birthDate

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

    func setSelectedCountry(_ country: Country) {
        self.selectedCountry = country
    }


    private func formatIndicativeCountry(_ country: Country) -> String {
        var stringCountry = "\(country.iso2Code) - \(country.name)"
        if let flag = CountryFlagHelper.flag(forCode: country.iso2Code) {
            stringCountry = "\(flag) \(country.name)"
        }
        return stringCountry
    }

}

class AgeCountryFormStepView: FormStepView {

    private lazy var dateHeaderTextFieldView: HeaderTextFieldView = Self.createHeaderTextFieldView()
    private lazy var countryHeaderTextFieldView: HeaderTextFieldView = Self.createHeaderTextFieldView()
    private lazy var placeHeaderTextFieldView: HeaderTextFieldView = Self.createHeaderTextFieldView()

    private let viewModel: AgeCountryFormStepViewModel

    private var cancellables = Set<AnyCancellable>()

    init(viewModel: AgeCountryFormStepViewModel) {
        self.viewModel = viewModel

        super.init()

        self.configureSubviews()
    }

    private var isFormCompletedCurrentValue: CurrentValueSubject<Bool, Never> = .init(false)
    override var isFormCompleted: AnyPublisher<Bool, Never> {
        return isFormCompletedCurrentValue.eraseToAnyPublisher()
    }

    func configureSubviews() {

        self.dateHeaderTextFieldView.setDatePickerMode()
        
        self.stackView.addArrangedSubview(self.dateHeaderTextFieldView)
        self.stackView.addArrangedSubview(self.countryHeaderTextFieldView)
        self.stackView.addArrangedSubview(self.placeHeaderTextFieldView)
        
        NSLayoutConstraint.activate([
            self.dateHeaderTextFieldView.heightAnchor.constraint(equalToConstant: 80),
            self.countryHeaderTextFieldView.heightAnchor.constraint(equalToConstant: 80),
            self.placeHeaderTextFieldView.heightAnchor.constraint(equalToConstant: 80),
        ])
        
        self.titleLabel.text = self.viewModel.title
        
        self.dateHeaderTextFieldView.setReturnKeyType(.next)
        self.dateHeaderTextFieldView.setPlaceholderText("Date of Birth")
        self.dateHeaderTextFieldView.didTapReturn = { [weak self] in
            self?.countryHeaderTextFieldView.becomeFirstResponder()
        }

        let maxDate = self.dateForMaxLegalAge(legalAge: 18)
        self.dateHeaderTextFieldView.datePicker.maximumDate = maxDate

        self.countryHeaderTextFieldView.setReturnKeyType(.continue)
        self.countryHeaderTextFieldView.setPlaceholderText("Country")
        self.countryHeaderTextFieldView.didTapReturn = { [weak self] in
            self?.placeHeaderTextFieldView.becomeFirstResponder()
        }
        self.countryHeaderTextFieldView.shouldBeginEditing = { [weak self] in
            self?.showCountrySelector()
            return false
        }

        self.placeHeaderTextFieldView.setReturnKeyType(.continue)
        self.placeHeaderTextFieldView.setPlaceholderText("Place of Birth")
        self.placeHeaderTextFieldView.didTapReturn = { [weak self] in
            self?.placeHeaderTextFieldView.resignFirstResponder()
        }
        
        self.viewModel.selectedCountryText
            .sink { [weak self] countryText in
                self?.countryHeaderTextFieldView.setText(countryText ?? "")
            }
            .store(in: &self.cancellables)

    }

    public override func layoutSubviews() {
        super.layoutSubviews()
    }

    override func setupWithTheme() {
        super.setupWithTheme()

        self.dateHeaderTextFieldView.backgroundColor = AppColor.backgroundPrimary
        self.dateHeaderTextFieldView.setHeaderLabelColor(AppColor.inputTextTitle)
        self.dateHeaderTextFieldView.setTextFieldColor(AppColor.inputText)

        self.countryHeaderTextFieldView.backgroundColor = AppColor.backgroundPrimary
        self.countryHeaderTextFieldView.setHeaderLabelColor(AppColor.inputTextTitle)
        self.countryHeaderTextFieldView.setTextFieldColor(AppColor.inputText)

        self.placeHeaderTextFieldView.backgroundColor = AppColor.backgroundPrimary
        self.placeHeaderTextFieldView.setHeaderLabelColor(AppColor.inputTextTitle)
        self.placeHeaderTextFieldView.setTextFieldColor(AppColor.inputText)
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
                self?.viewModel.setSelectedCountry(selectedCountry)
                countrySelectorViewController?.animateDismissView()
            }
            self.viewController?.present(countrySelectorViewController, animated: true)
        }
    }


}

extension AgeCountryFormStepView {

    fileprivate static func createHeaderTextFieldView() -> HeaderTextFieldView {
        let headerTextFieldView = HeaderTextFieldView()
        headerTextFieldView.translatesAutoresizingMaskIntoConstraints = false
        return headerTextFieldView
    }

}

extension AgeCountryFormStepView {

    private func dateForMaxLegalAge(legalAge: Int) -> Date {
        let calendar = Calendar(identifier: .gregorian)
        var components = DateComponents()
        components.calendar = calendar
        components.year = -legalAge
        let maxDate = calendar.date(byAdding: components, to: Date())!
        return maxDate
    }

}
