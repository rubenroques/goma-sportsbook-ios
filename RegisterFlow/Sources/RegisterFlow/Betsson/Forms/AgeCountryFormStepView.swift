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

    let defaultCountryIso3Code: String

    var shouldSuggestAddresses: Bool {
        return (self.selectedCountry.value?.iso3Code ?? "") == defaultCountryIso3Code
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
         userRegisterEnvelopUpdater: UserRegisterEnvelopUpdater,
         adresseFrancaiseClient: AdresseFrancaiseClient = AdresseFrancaiseClient()) {

        self.title = title

        self.defaultCountryIso3Code = defaultCountryIso3Code
        self.countryState = .init(countryState)

        self.selectedCountry = .init(selectedCountry)
        self.birthDate = .init(birthDate)
        self.placeBirth = .init(placeBirth)

        self.serviceProvider = serviceProvider
        self.userRegisterEnvelopUpdater = userRegisterEnvelopUpdater

        self.adresseFrancaiseClient = AdresseFrancaiseClient()

        self.loadCountries()
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

    func setPlaceOfBirth(_ place: String) {
        self.placeBirth.send(place)
        self.userRegisterEnvelopUpdater.setPlaceBirth(place)
    }

    func requestCommuneAutoCompletion(forQuery query: String) -> AnyPublisher<[String], Never> {
        return self.adresseFrancaiseClient
            .searchCommune(query: query)
            .map { results in
                let labels = results.map(\.label)
                let uniqueLabels = NSOrderedSet(array: labels).prefix(4)
                return Array(uniqueLabels) as! [String]
            }
            .replaceError(with: [String]() )
            .eraseToAnyPublisher()
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

        NSLayoutConstraint.activate([
            self.dateHeaderTextFieldView.heightAnchor.constraint(equalToConstant: 80),
            self.countryHeaderTextFieldView.heightAnchor.constraint(equalToConstant: 80),

            self.placeHeaderTextFieldView.heightAnchor.constraint(equalToConstant: 80),
            placeContainerView.heightAnchor.constraint(greaterThanOrEqualToConstant: 80),
            self.placeHeaderTextFieldView.topAnchor.constraint(equalTo: placeContainerView.topAnchor),
            self.placeHeaderTextFieldView.leadingAnchor.constraint(equalTo: placeContainerView.leadingAnchor),
            self.placeHeaderTextFieldView.trailingAnchor.constraint(equalTo: placeContainerView.trailingAnchor),

            self.placeSearchCompletionView.topAnchor.constraint(equalTo: self.placeHeaderTextFieldView.bottomAnchor, constant: -16),
            self.placeSearchCompletionView.leadingAnchor.constraint(equalTo: self.placeHeaderTextFieldView.leadingAnchor),
            self.placeSearchCompletionView.trailingAnchor.constraint(equalTo: self.placeHeaderTextFieldView.trailingAnchor),
            self.placeSearchCompletionView.bottomAnchor.constraint(greaterThanOrEqualTo: placeContainerView.bottomAnchor),
        ])

        self.stackView.addArrangedSubview(self.dateHeaderTextFieldView)
        self.stackView.addArrangedSubview(self.countryHeaderTextFieldView)
        self.stackView.addArrangedSubview(placeContainerView)

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


        self.placeSearchCompletionView.didSelectSearchCompletion = { [weak self] searchCompletion in
            self?.placeHeaderTextFieldView.setText(searchCompletion)
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
                    return Just([String]()).eraseToAnyPublisher()
                }
                return self.viewModel.requestCommuneAutoCompletion(forQuery: query)
            }
            .receive(on: DispatchQueue.main)
            .sink { [weak self] suggestions in
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

        self.dateHeaderTextFieldView.setViewColor(AppColor.inputBackground)
        self.dateHeaderTextFieldView.setHeaderLabelColor(AppColor.inputTextTitle)
        self.dateHeaderTextFieldView.setTextFieldColor(AppColor.inputText)

        self.countryHeaderTextFieldView.setViewColor(AppColor.inputBackground)
        self.countryHeaderTextFieldView.setHeaderLabelColor(AppColor.inputTextTitle)
        self.countryHeaderTextFieldView.setTextFieldColor(AppColor.inputText)

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
