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
import AdresseFrancaise

class AgeCountryFormStepViewModel {

    let title: String


    var birthDate: CurrentValueSubject<Date?, Never>
    var placeBirth: CurrentValueSubject<String?, Never>

    var departmentOfBirth: CurrentValueSubject<String?, Never>

    let defaultCountryIso3Code: String

    var shouldSuggestAddresses: Bool {
        return (self.selectedCountry.value?.iso3Code ?? "") == defaultCountryIso3Code
    }

    var shouldShowDepartmentOfBirth: AnyPublisher<Bool, Never> {
        return self.selectedCountry.map { (optionalCountry: Country?) -> Bool in
            if let optionalCountry {
                return optionalCountry.iso3Code == "FRA"
            }
            else {
                return false
            }
        }.eraseToAnyPublisher()
    }

    var isDepartmentOfBirthValid: AnyPublisher<Bool, Never> {
        return Publishers.CombineLatest(self.selectedCountry, self.departmentOfBirth)
            .map { (selectedCountry, departmentOfBirth) -> Bool in
                if let selectedCountry = selectedCountry, let departmentOfBirth = departmentOfBirth {
                    if selectedCountry.iso3Code != "FRA" && departmentOfBirth == "99" {
                        return true
                    }
                    else if selectedCountry.iso3Code == "FRA" && self.isValidFrenchDepartmentCode(departmentOfBirth) {
                        return true
                    }
                }
                return false
            }
            .eraseToAnyPublisher()

//        self.selectedCountry.map { (optionalCountry: Country?) -> Bool in
//            if let optionalCountry {
//                return optionalCountry.iso3Code == "FRA"
//            }
//            else {
//                return false
//            }
//        }.eraseToAnyPublisher()
    }

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

    var defaultCountry: CurrentValueSubject<SharedModels.Country?, Never> = .init(nil)
    var defaultCountryText: AnyPublisher<String?, Never> {
        self.defaultCountry
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

    private var serviceProvider: ServicesProviderClient
    private var userRegisterEnvelopUpdater: UserRegisterEnvelopUpdater
    private var adresseFrancaiseClient: AdresseFrancaiseClient

    private var cancellables = Set<AnyCancellable>()

    enum CountryState {
        case idle
        case loading
        case loaded(countries: [SharedModels.Country])
    }

    var isFormCompleted: AnyPublisher<Bool, Never> {
        return Publishers.CombineLatest4(self.birthDate, self.selectedCountry, self.placeBirth, self.departmentOfBirth)
            .map { date, country, place, departmentOfBirth -> Bool in
                var isDepartmentOfBirthValid = self.isValidFrenchDepartmentCode(departmentOfBirth ?? "")
                if let iso3Code = country?.iso3Code, iso3Code != "FRA" {
                    isDepartmentOfBirthValid = (departmentOfBirth ?? "99") == "99"
                }
                return date != nil && country != nil && place != nil && !(place?.isEmpty ?? true) && isDepartmentOfBirthValid
            }.eraseToAnyPublisher()
    }

    init(title: String,
         defaultCountryIso3Code: String,
         countryState: CountryState = .idle,
         birthDate: Date?,
         selectedCountry: Country?,
         departmentOfBirth: String?,
         placeBirth: String?,

         serviceProvider: ServicesProviderClient,
         userRegisterEnvelopUpdater: UserRegisterEnvelopUpdater,
         adresseFrancaiseClient: AdresseFrancaiseClient = AdresseFrancaiseClient()) {

        self.title = title

        self.defaultCountryIso3Code = defaultCountryIso3Code
        self.countryState = .init(countryState)

        self.selectedCountry = .init(selectedCountry)
        self.birthDate = .init(birthDate)
        self.placeBirth = .init(placeBirth)

        self.departmentOfBirth = .init(departmentOfBirth)

        self.serviceProvider = serviceProvider
        self.userRegisterEnvelopUpdater = userRegisterEnvelopUpdater

        self.adresseFrancaiseClient = AdresseFrancaiseClient()

        self.loadCountries()

        self.selectedCountry
            .sink { [weak self] country in
                if let country = country {
                    if country.iso3Code != "FRA" {
                        self?.setDeparmentOfBirth("99") // deparment Of Birth not required for this country
                    }
                    else if self?.departmentOfBirth.value == "99" {
                        self?.setDeparmentOfBirth(nil)
                    }
                }
                else {
                    self?.setDeparmentOfBirth(nil) // no country found
                }
            }
            .store(in: &self.cancellables)

    }

    func loadCountries() {

        self.countryState.send(.loading)

        self.serviceProvider.getCountries()
            .sink { completion in

            } receiveValue: { [weak self] countries in
                self?.countryState.send(.loaded(countries: countries))

                self?.defaultCountry.send(countries.first(where: { $0.iso3Code == self?.defaultCountryIso3Code}))

            }
            .store(in: &self.cancellables)

        self.defaultCountry
            .compactMap({ $0 })
            .sink { [weak self] defaultCountry in
                if self?.selectedCountry.value == nil {
                    self?.setSelectedCountry(defaultCountry)
                }
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

    func setDeparmentOfBirth(_ departmentOfBirth: String?) {
        self.departmentOfBirth.send(departmentOfBirth)
        self.userRegisterEnvelopUpdater.setDepartmentOfBirth(departmentOfBirth)
    }

    func setPlaceOfBirth(_ place: String) {
        self.placeBirth.send(place)
        self.userRegisterEnvelopUpdater.setPlaceBirth(place)
    }

    func requestCommuneAutoCompletion(forQuery query: String) -> AnyPublisher<[AddressSearchResult], Never> {
        return self.adresseFrancaiseClient
            .searchCommune(query: query)
            .map { results in
                let addressResults  = results.map({ AddressSearchResult(title: $0.label, city: $0.city, street: $0.street, postcode: $0.postcode) })
                return Array(addressResults.prefix(4))
            }
            .replaceError(with: [AddressSearchResult]() )
            .eraseToAnyPublisher()
    }

    private func formatIndicativeCountry(_ country: Country) -> String {
        var stringCountry = "\(country.iso2Code) - \(country.name)"
        if let flag = CountryFlagHelper.flag(forCode: country.iso2Code) {
            stringCountry = "\(flag) \(country.name)"
        }
        return stringCountry
    }

    private func isValidFrenchDepartmentCode(_ input: String) -> Bool {
        let departmentCodePattern = "^(0[1-9]|[1-8]\\d|9[0-5]|2[ABab]|97[1-6])$"
        let departmentCodeRegex = try! NSRegularExpression(pattern: departmentCodePattern)
        let range = NSRange(location: 0, length: input.utf16.count)

        return departmentCodeRegex.firstMatch(in: input, options: [], range: range) != nil
    }

}

class AgeCountryFormStepView: FormStepView {

    private lazy var dateHeaderTextFieldView: HeaderTextFieldView = Self.createHeaderTextFieldView()
    private lazy var countryHeaderTextFieldView: HeaderTextFieldView = Self.createHeaderTextFieldView()

    private lazy var departmentBirthHeaderTextFieldView: HeaderTextFieldView = Self.createHeaderTextFieldView()

    private lazy var placeHeaderTextFieldView: HeaderTextFieldView = Self.createHeaderTextFieldView()
    private lazy var placeSearchCompletionView: SearchCompletionView = Self.createPlaceSearchCompletionView()

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

        let placeContainerView = UIView()
        placeContainerView.translatesAutoresizingMaskIntoConstraints = false
        placeContainerView.backgroundColor = .clear
        placeContainerView.addSubview(self.placeHeaderTextFieldView)
        placeContainerView.addSubview(self.placeSearchCompletionView)

        self.stackView.addArrangedSubview(self.dateHeaderTextFieldView)
        self.stackView.addArrangedSubview(self.countryHeaderTextFieldView)
        self.stackView.addArrangedSubview(self.departmentBirthHeaderTextFieldView)
        self.stackView.addArrangedSubview(placeContainerView)

        NSLayoutConstraint.activate([
            self.dateHeaderTextFieldView.heightAnchor.constraint(equalToConstant: 80),
            self.countryHeaderTextFieldView.heightAnchor.constraint(equalToConstant: 80),
            self.departmentBirthHeaderTextFieldView.heightAnchor.constraint(equalToConstant: 80),

            placeContainerView.heightAnchor.constraint(greaterThanOrEqualToConstant: 80),
            self.placeHeaderTextFieldView.heightAnchor.constraint(equalToConstant: 80),
            self.placeHeaderTextFieldView.topAnchor.constraint(equalTo: placeContainerView.topAnchor),
            self.placeHeaderTextFieldView.leadingAnchor.constraint(equalTo: placeContainerView.leadingAnchor),
            self.placeHeaderTextFieldView.trailingAnchor.constraint(equalTo: placeContainerView.trailingAnchor),

            self.placeSearchCompletionView.topAnchor.constraint(equalTo: self.placeHeaderTextFieldView.bottomAnchor, constant: -16),
            self.placeSearchCompletionView.leadingAnchor.constraint(equalTo: self.placeHeaderTextFieldView.leadingAnchor),
            self.placeSearchCompletionView.trailingAnchor.constraint(equalTo: self.placeHeaderTextFieldView.trailingAnchor),
            placeContainerView.bottomAnchor.constraint(greaterThanOrEqualTo: self.placeSearchCompletionView.bottomAnchor),
        ])

        self.titleLabel.text = self.viewModel.title
        
        self.dateHeaderTextFieldView.setReturnKeyType(.next)
        self.dateHeaderTextFieldView.setPlaceholderText(Localization.localized("date_of_birth"))
        self.dateHeaderTextFieldView.didTapReturn = { [weak self] in
            self?.countryHeaderTextFieldView.becomeFirstResponder()
        }

        let maxDate = self.dateForMaxLegalAge(legalAge: 18)
        self.dateHeaderTextFieldView.datePicker.maximumDate = maxDate

        self.countryHeaderTextFieldView.setReturnKeyType(.continue)
        self.countryHeaderTextFieldView.setPlaceholderText(Localization.localized("country_of_birth"))
        self.countryHeaderTextFieldView.shouldBeginEditing = { [weak self] in
            self?.showCountrySelector()
            return false
        }

        self.departmentBirthHeaderTextFieldView.setReturnKeyType(.continue)
        self.departmentBirthHeaderTextFieldView.setPlaceholderText(Localization.localized("department_of_birth"))
        self.departmentBirthHeaderTextFieldView.didTapReturn = { [weak self] in
            self?.placeHeaderTextFieldView.becomeFirstResponder()
        }

        self.placeHeaderTextFieldView.setReturnKeyType(.continue)
        self.placeHeaderTextFieldView.setPlaceholderText(Localization.localized("birth_place"))
        self.placeHeaderTextFieldView.didTapReturn = { [weak self] in
            self?.placeHeaderTextFieldView.resignFirstResponder()
        }


        self.placeSearchCompletionView.didSelectSearchCompletion = { [weak self] searchCompletion in
            self?.placeHeaderTextFieldView.setText(searchCompletion.title)
            self?.placeHeaderTextFieldView.resignFirstResponder()
            self?.placeSearchCompletionView.clearResults()
        }

        self.placeHeaderTextFieldView.didEndEditing = { [weak self] in
            self?.placeSearchCompletionView.clearResults()
        }

        self.placeHeaderTextFieldView.textPublisher
            .compactMap({ $0 })
            .debounce(for: .seconds(0.6), scheduler: DispatchQueue.main)
            .filter({ [weak self] _ in
                guard let self else { return false }
                return self.viewModel.shouldSuggestAddresses && self.placeHeaderTextFieldView.isFirstResponder
            })
            .flatMap { [weak self] query in
                guard
                    let self = self
                else {
                    return Just([AddressSearchResult]()).eraseToAnyPublisher()
                }
                return self.viewModel.requestCommuneAutoCompletion(forQuery: query)
            }
            .receive(on: DispatchQueue.main)
            .sink { [weak self] (suggestions: [AddressSearchResult]) in
                UIView.animate(withDuration: 0.1) {
                    self?.placeSearchCompletionView.presentResults(suggestions)
                }
            }
            .store(in: &self.cancellables)

        self.placeHeaderTextFieldView.textPublisher
            .sink { [weak self] text in
                self?.viewModel.setPlaceOfBirth(text)
            }
            .store(in: &self.cancellables)

        self.departmentBirthHeaderTextFieldView.textPublisher
            .sink { [weak self] text in
                self?.viewModel.setDeparmentOfBirth(text)
            }
            .store(in: &self.cancellables)

        self.viewModel.selectedCountryText
            .receive(on: DispatchQueue.main)
            .sink { [weak self] countryText in
                self?.countryHeaderTextFieldView.setText(countryText ?? "")
            }
            .store(in: &self.cancellables)

        self.viewModel.shouldShowDepartmentOfBirth
            .receive(on: DispatchQueue.main)
            .sink { [weak self] shouldShowDepartmentOfBirth in
                self?.departmentBirthHeaderTextFieldView.isHidden = !shouldShowDepartmentOfBirth
            }
            .store(in: &self.cancellables)

        self.viewModel.isDepartmentOfBirthValid
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isDepartmentOfBirthValid in
                if (self?.departmentBirthHeaderTextFieldView.text.isEmpty ?? true) {
                    self?.departmentBirthHeaderTextFieldView.hideTipAndError()
                }
                else {
                    if isDepartmentOfBirthValid {
                        self?.departmentBirthHeaderTextFieldView.hideTipAndError()
                    }
                    else {
                        self?.departmentBirthHeaderTextFieldView.showErrorOnField(text: "This departement of birth is invalid", color: AppColor.alertError)
                    }
                }
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

        self.viewModel.departmentOfBirth
            .sink { departmentOfBirth in
                self.departmentBirthHeaderTextFieldView.setText(departmentOfBirth ?? "", shouldPublish: false)
            }
            .store(in: &self.cancellables)

//        if let departmentOfBirth = self.viewModel.departmentOfBirth.value {
//            self.departmentBirthHeaderTextFieldView.setText(departmentOfBirth)
//        }

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

        self.dateHeaderTextFieldView.setViewColor(AppColor.inputBackground)
        self.dateHeaderTextFieldView.setHeaderLabelColor(AppColor.inputTextTitle)
        self.dateHeaderTextFieldView.setTextFieldColor(AppColor.inputText)

        self.countryHeaderTextFieldView.setViewColor(AppColor.inputBackground)
        self.countryHeaderTextFieldView.setHeaderLabelColor(AppColor.inputTextTitle)
        self.countryHeaderTextFieldView.setTextFieldColor(AppColor.inputText)

        self.departmentBirthHeaderTextFieldView.setViewColor(AppColor.inputBackground)
        self.departmentBirthHeaderTextFieldView.setHeaderLabelColor(AppColor.inputTextTitle)
        self.departmentBirthHeaderTextFieldView.setTextFieldColor(AppColor.inputText)

        self.placeHeaderTextFieldView.setViewColor(AppColor.inputBackground)
        self.placeHeaderTextFieldView.setHeaderLabelColor(AppColor.inputTextTitle)
        self.placeHeaderTextFieldView.setTextFieldColor(AppColor.inputText)
    }

    func showCountrySelector() {
        if let countries = self.viewModel.countries {
            let countrySelectorViewController = CountrySelectionFeature.CountrySelectorViewController(countries: countries,
                                                                                                      originCountry: self.viewModel.defaultCountry.value,
                                                                                                      showIndicatives: false)
            countrySelectorViewController.modalPresentationStyle = .overCurrentContext
            countrySelectorViewController.didSelectCountry = { [weak self, weak countrySelectorViewController] (selectedCountry: SharedModels.Country) in
                self?.viewModel.setSelectedCountry(selectedCountry)
                countrySelectorViewController?.animateDismissView()
            }
            self.viewController?.present(countrySelectorViewController, animated: true)
        }
    }

    override func canPresentError(forFormStep formStep: FormStep) -> Bool {
        switch formStep {
        case .ageCountry: return true
        default: return false
        }
    }

    override func presentError(_ error: RegisterError, forFormStep formStep: FormStep) {
        if !self.canPresentError(forFormStep: formStep) { return }
        switch (error.field, error.error) {
        case ("birthDate", "BELOW_MINIMUM_AGE"):
            self.dateHeaderTextFieldView.showErrorOnField(text: "Player is not old enough to be registered", color: AppColor.alertError)
        case ("country", "INVALID_LENGTH"):
            self.countryHeaderTextFieldView.showErrorOnField(text: "Country name is too long", color: AppColor.alertError)
        case ("birthDate", _):
            self.dateHeaderTextFieldView.showErrorOnField(text: "Please enter a valid birth date", color: AppColor.alertError)
        case ("country", _):
            self.countryHeaderTextFieldView.showErrorOnField(text: "Please enter a valid Country", color: AppColor.alertError)
        default:
            ()
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

    fileprivate static func createPlaceSearchCompletionView() -> SearchCompletionView {
        let searchCompletionView = SearchCompletionView()
        searchCompletionView.translatesAutoresizingMaskIntoConstraints = false
        return searchCompletionView
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
