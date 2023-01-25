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


    var birthDate: CurrentValueSubject<Date?, Never>
    var placeBirth: CurrentValueSubject<String?, Never>

    let defaultCountryIso3Code: String

    var selectedCountry: CurrentValueSubject<Country?, Never> = .init(nil)


    var selectedCountryText: AnyPublisher<String?, Never> {
        return self.selectedCountry.map { country in
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

    var defaultCountry: Country? {
        self.countries?.first(where: { $0.iso3Code == self.defaultCountryIso3Code })
    }

    private var serviceProvider: ServicesProviderClient
    private var userRegisterEnvelopUpdater: UserRegisterEnvelopUpdater

    private var cancellables = Set<AnyCancellable>()

    enum CountryState {
        case idle
        case loading
        case loaded(countries: [SharedModels.Country])
    }

    var isFormCompleted: AnyPublisher<Bool, Never> {
        return Publishers.CombineLatest3(self.birthDate, self.selectedCountry, self.placeBirth)
            .map { date, country, place -> Bool in
                return date != nil && country != nil && place != nil && !(place?.isEmpty ?? true)
            }.eraseToAnyPublisher()
    }

    init(title: String,
         defaultCountryIso3Code: String,
         countryState: CountryState = .idle,
         birthDate: Date?,
         selectedCountry: Country?,
         placeBirth: String?,

         serviceProvider: ServicesProviderClient,
         userRegisterEnvelopUpdater: UserRegisterEnvelopUpdater) {

        self.title = title

        self.defaultCountryIso3Code = defaultCountryIso3Code
        self.countryState = .init(countryState)

        self.selectedCountry = .init(selectedCountry)
        self.birthDate = .init(birthDate)
        self.placeBirth = .init(placeBirth)

        self.serviceProvider = serviceProvider
        self.userRegisterEnvelopUpdater = userRegisterEnvelopUpdater

        self.loadCountries()
    }

    func loadCountries() {

        self.countryState.send(.loading)

        self.serviceProvider.getCountries()
            .sink { completion in

            } receiveValue: { [weak self] countries in
                self?.countryState.send(.loaded(countries: countries))
            }
            .store(in: &self.cancellables)
    }

    func setSelectedDate(_ date: Date) {
        self.birthDate.send(date)
        self.userRegisterEnvelopUpdater.setDateOfBirth(date)
    }

    func setSelectedCountry(_ country: Country) {
        self.selectedCountry.send(country)
        self.userRegisterEnvelopUpdater.setCountryBirth(country)
    }

    func setPlaceOfBirth(_ place: String) {
        self.placeBirth.send(place)
        self.userRegisterEnvelopUpdater.setPlaceBirth(place)
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

    override var isFormCompleted: AnyPublisher<Bool, Never> {
        return self.viewModel.isFormCompleted
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


        self.placeHeaderTextFieldView.textPublisher
            .sink { [weak self] text in
                self?.viewModel.setPlaceOfBirth(text)
            }
            .store(in: &self.cancellables)

        self.viewModel.selectedCountryText
            .receive(on: DispatchQueue.main)
            .sink { [weak self] countryText in
                self?.countryHeaderTextFieldView.setText(countryText ?? "")
            }
            .store(in: &self.cancellables)

        self.dateHeaderTextFieldView.textPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] dateString in
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "dd-MM-yyyy"
                if let date = dateFormatter.date(from: dateString) {
                    self?.viewModel.setSelectedDate(date)
                }
            }
            .store(in: &self.cancellables)

        if let placeOfBirth = self.viewModel.placeBirth.value {
            self.placeHeaderTextFieldView.setText(placeOfBirth)
        }

        if let birthDate = self.viewModel.birthDate.value {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "dd-MM-yyyy"
            self.dateHeaderTextFieldView.setText(dateFormatter.string(from: birthDate))
        }


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
            let countrySelectorViewController = CountrySelectionFeature.CountrySelectorViewController(countries: countries,
                                                                                                      originCountry: self.viewModel.defaultCountry,
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
        headerTextFieldView.setTextFieldFont(AppFont.with(type: .semibold, size: 16))
        headerTextFieldView.setHeaderLabelFont(AppFont.with(type: .semibold, size: 16))
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
