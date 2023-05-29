//
//  AddressFormStepView.swift
//  
//
//  Created by Ruben Roques on 16/01/2023.
//

import UIKit
import Theming
import Extensions
import Combine
import SharedModels
import AdresseFrancaise
import HeaderTextField

public struct AddressSearchResult {
    public var title: String
    public var city: String?
    public var street: String?
    public var postcode: String?
}

class AddressFormStepViewModel {

    let title: String

    var countryCodeForSuggestions: String
    var place: CurrentValueSubject<String?, Never>
    var postcode: CurrentValueSubject<String?, Never>
    var street: CurrentValueSubject<String?, Never>
    var streetNumber: CurrentValueSubject<String?, Never>
//
//    var isPlaceValid: AnyPublisher<Bool, Never> {
//        return self.place.map { place in
//            if let place = place {
//                return place.allSatisfy { $0.isLetter }
//            }
//            else {
//                return false
//            }
//        }
//        .eraseToAnyPublisher()
//    }

    var isPostcodeValid: AnyPublisher<Bool, Never> {
        return self.postcode.map { postcode in
            if let postcode = postcode {
                return postcode.range(of: "^[0-9]*$", options: .regularExpression) != nil && postcode.count == 5
            }
            else {
                return false
            }
        }
        .eraseToAnyPublisher()
    }

    var isStreetNumberValid: AnyPublisher<Bool, Never> {
        return self.streetNumber.map { streetNumber in
            if let streetNumber = streetNumber {
                return streetNumber.range(of: "^[0-9a-zA-Z]*$", options: .regularExpression) != nil && streetNumber.count > 0 && streetNumber.count < 4
            }
            else {
                return false
            }
        }
        .eraseToAnyPublisher()
    }

//    var shouldShowPlaceFormatErrorMessage: AnyPublisher<Bool, Never> {
//        return Publishers.CombineLatest(self.place, self.isPlaceValid)
//            .map { place, isPlaceValid in
//                if let place = place {
//                    if place.isEmpty {
//                        return false // if its nil/empty the message shouldn't appear
//                    }
//                    return !isPlaceValid  // is it is not valid we show the message
//                }
//                else {
//                    return false // if its nil/empty the message shouldn't appear
//                }
//            }
//            .eraseToAnyPublisher()
//    }

    var shouldShowPostcodeFormatErrorMessage: AnyPublisher<Bool, Never> {
        return Publishers.CombineLatest(self.postcode, self.isPostcodeValid)
            .map { postcode, isPostcodeValid in
                if let postcode = postcode {
                    if postcode.isEmpty {
                        return false // if its nil/empty the message shouldn't appear
                    }
                    return !isPostcodeValid  // is it is not valid we show the message
                }
                else {
                    return false // if its nil/empty the message shouldn't appear
                }
            }
            .eraseToAnyPublisher()
    }

    var shouldShowStreetNumberFormatErrorMessage: AnyPublisher<Bool, Never> {
        return Publishers.CombineLatest(self.streetNumber, self.isStreetNumberValid)
            .map { streetNumber, isStreetNumberValid in
                if let streetNumber = streetNumber {
                    if streetNumber.isEmpty {
                        return false // if its nil/empty the message shouldn't appear
                    }
                    return !isStreetNumberValid // is it is not valid we show the message
                }
                else {
                    return false // if its nil/empty the message shouldn't appear
                }
            }
            .eraseToAnyPublisher()
    }

    var shouldSuggestAddresses: Bool = true

    private var userRegisterEnvelopUpdater: UserRegisterEnvelopUpdater
    private var adresseFrancaiseClient: AdresseFrancaiseClient

    private var cancellables = Set<AnyCancellable>()


    init(title: String,
         countryCodeForSuggestions: String,
         place: String? = nil,
         street: String? = nil,
         postcode: String? = nil,
         streetNumber: String? = nil,
         userRegisterEnvelopUpdater: UserRegisterEnvelopUpdater,
         adresseFrancaiseClient: AdresseFrancaiseClient = AdresseFrancaiseClient()) {

        self.title = title
        self.countryCodeForSuggestions = countryCodeForSuggestions
        self.place = .init(place)
        self.postcode = .init(postcode)
        self.street = .init(street)
        self.streetNumber = .init(streetNumber)

        self.userRegisterEnvelopUpdater = userRegisterEnvelopUpdater
        self.adresseFrancaiseClient = AdresseFrancaiseClient()


    }

    var isFormCompleted: AnyPublisher<Bool, Never> {
        return Publishers.CombineLatest4(self.place, self.street, self.isPostcodeValid, self.isStreetNumberValid)
            .map { place, street, isPostcodeValid, isStreetNumberValid in
                return (place ?? "").count > 0 && (street ?? "").count > 0 && isPostcodeValid && isStreetNumberValid
            }
            .eraseToAnyPublisher()
    }

    func setPlace(_ place: String) {
        self.place.send(place)
        self.userRegisterEnvelopUpdater.setPlaceAddress(place)
    }

    func setPostcode(_ postcode: String) {
        self.postcode.send(postcode)
        self.userRegisterEnvelopUpdater.setPostcode(postcode)
    }

    func setStreet(_ street: String) {
        self.street.send(street)
        self.userRegisterEnvelopUpdater.setStreetAddress(street)
    }

    func setStreetNumber(_ streetNumber: String) {
        self.streetNumber.send(streetNumber)
        self.userRegisterEnvelopUpdater.setStreetNumber(streetNumber)
    }

    func requestStreetAutoCompletion(forQuery query: String, fromPostcode postcode: String?) -> AnyPublisher<[AddressSearchResult], Never> {
        return self.adresseFrancaiseClient
            .searchStreet(query: query, fromPostcode: postcode)
            .map { results in
                let addressResults  = results.map({ AddressSearchResult(title: $0.street ?? $0.label, city: $0.city, street: $0.street, postcode: $0.postcode) })
                return Array(addressResults.prefix(4))
            }
            .replaceError(with: [AddressSearchResult]() )
            .eraseToAnyPublisher()
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

}

class AddressFormStepView: FormStepView {

    private lazy var placeHeaderTextFieldView: HeaderTextFieldView = Self.createPlaceHeaderTextFieldView()
    private lazy var placeSearchCompletionView: SearchCompletionView = Self.createSearchCompletionView()

    private lazy var postCodeHeaderTextFieldView: HeaderTextFieldView = Self.createStreetHeaderTextFieldView()
    private lazy var postCodeSearchCompletionView: SearchCompletionView = Self.createSearchCompletionView()

    private lazy var streetNameHeaderTextFieldView: HeaderTextFieldView = Self.createAdditionalStreetHeaderTextFieldView()
    private lazy var streetNameSearchCompletionView: SearchCompletionView = Self.createSearchCompletionView()

    private lazy var numberHeaderTextFieldView: HeaderTextFieldView = Self.createStreetHeaderTextFieldView()

    private let viewModel: AddressFormStepViewModel
    private var cancellables = Set<AnyCancellable>()

    override var isFormCompleted: AnyPublisher<Bool, Never> {
        return self.viewModel.isFormCompleted
    }

    init(viewModel: AddressFormStepViewModel) {
        self.viewModel = viewModel

        super.init()

        self.configureSubviews()
    }

    func configureSubviews() {

        let placeContainerView = UIView()
        placeContainerView.translatesAutoresizingMaskIntoConstraints = false
        placeContainerView.backgroundColor = .clear
        placeContainerView.addSubview(self.placeHeaderTextFieldView)
        placeContainerView.addSubview(self.placeSearchCompletionView)

        let streetContainerView = UIView()
        streetContainerView.translatesAutoresizingMaskIntoConstraints = false
        streetContainerView.backgroundColor = .clear
        streetContainerView.addSubview(self.postCodeHeaderTextFieldView)
        streetContainerView.addSubview(self.postCodeSearchCompletionView)

        let additionalStreetContainerView = UIView()
        additionalStreetContainerView.translatesAutoresizingMaskIntoConstraints = false
        additionalStreetContainerView.backgroundColor = .clear
        additionalStreetContainerView.addSubview(self.streetNameHeaderTextFieldView)
        additionalStreetContainerView.addSubview(self.streetNameSearchCompletionView)

        self.stackView.addArrangedSubview(placeContainerView)
        self.stackView.addArrangedSubview(streetContainerView)
        self.stackView.addArrangedSubview(self.numberHeaderTextFieldView)
        self.stackView.addArrangedSubview(additionalStreetContainerView)

        NSLayoutConstraint.activate([
            placeContainerView.heightAnchor.constraint(greaterThanOrEqualToConstant: 80),
            self.placeHeaderTextFieldView.heightAnchor.constraint(equalToConstant: 80),
            self.placeHeaderTextFieldView.topAnchor.constraint(equalTo: placeContainerView.topAnchor),
            self.placeHeaderTextFieldView.leadingAnchor.constraint(equalTo: placeContainerView.leadingAnchor),
            self.placeHeaderTextFieldView.trailingAnchor.constraint(equalTo: placeContainerView.trailingAnchor),

            self.placeSearchCompletionView.topAnchor.constraint(equalTo: self.placeHeaderTextFieldView.bottomAnchor, constant: -16),
            self.placeSearchCompletionView.leadingAnchor.constraint(equalTo: self.placeHeaderTextFieldView.leadingAnchor),
            self.placeSearchCompletionView.trailingAnchor.constraint(equalTo: self.placeHeaderTextFieldView.trailingAnchor),
            placeContainerView.bottomAnchor.constraint(greaterThanOrEqualTo: self.placeSearchCompletionView.bottomAnchor),

            streetContainerView.heightAnchor.constraint(greaterThanOrEqualToConstant: 80),
            self.postCodeHeaderTextFieldView.heightAnchor.constraint(equalToConstant: 80),
            self.postCodeHeaderTextFieldView.topAnchor.constraint(equalTo: streetContainerView.topAnchor),
            self.postCodeHeaderTextFieldView.leadingAnchor.constraint(equalTo: streetContainerView.leadingAnchor),
            self.postCodeHeaderTextFieldView.trailingAnchor.constraint(equalTo: streetContainerView.trailingAnchor),

            self.postCodeSearchCompletionView.topAnchor.constraint(equalTo: self.postCodeHeaderTextFieldView.bottomAnchor, constant: -16),
            self.postCodeSearchCompletionView.leadingAnchor.constraint(equalTo: self.postCodeHeaderTextFieldView.leadingAnchor),
            self.postCodeSearchCompletionView.trailingAnchor.constraint(equalTo: self.postCodeHeaderTextFieldView.trailingAnchor),
            streetContainerView.bottomAnchor.constraint(greaterThanOrEqualTo: self.postCodeSearchCompletionView.bottomAnchor),

            additionalStreetContainerView.heightAnchor.constraint(greaterThanOrEqualToConstant: 80),
            self.streetNameHeaderTextFieldView.heightAnchor.constraint(equalToConstant: 80),
            self.streetNameHeaderTextFieldView.topAnchor.constraint(equalTo: additionalStreetContainerView.topAnchor),
            self.streetNameHeaderTextFieldView.leadingAnchor.constraint(equalTo: additionalStreetContainerView.leadingAnchor),
            self.streetNameHeaderTextFieldView.trailingAnchor.constraint(equalTo: additionalStreetContainerView.trailingAnchor),

            self.streetNameSearchCompletionView.topAnchor.constraint(equalTo: self.streetNameHeaderTextFieldView.bottomAnchor, constant: -16),
            self.streetNameSearchCompletionView.leadingAnchor.constraint(equalTo: self.streetNameHeaderTextFieldView.leadingAnchor),
            self.streetNameSearchCompletionView.trailingAnchor.constraint(equalTo: self.streetNameHeaderTextFieldView.trailingAnchor),
            additionalStreetContainerView.bottomAnchor.constraint(greaterThanOrEqualTo: self.streetNameSearchCompletionView.bottomAnchor),
        ])

        NSLayoutConstraint.activate([
            self.postCodeHeaderTextFieldView.heightAnchor.constraint(equalToConstant: 80),
            self.streetNameHeaderTextFieldView.heightAnchor.constraint(equalToConstant: 80),
            self.numberHeaderTextFieldView.heightAnchor.constraint(equalToConstant: 80),
        ])

        self.titleLabel.text = self.viewModel.title

        self.placeSearchCompletionView.didSelectSearchCompletion = { [weak self] searchCompletion in
            self?.placeHeaderTextFieldView.setText(searchCompletion.title)
            self?.postCodeHeaderTextFieldView.setText(searchCompletion.postcode ?? "")
            self?.placeHeaderTextFieldView.resignFirstResponder()
            self?.placeSearchCompletionView.clearResults()
        }

        //        self.postCodeSarchCompletionView.didSelectSearchCompletion = { [weak self] searchCompletion in
        //            self?.postCodeHeaderTextFieldView.setText(searchCompletion)
        //            self?.postCodeHeaderTextFieldView.resignFirstResponder()
        //            self?.postCodeSearchCompletionView.clearResults()
        //        }

        self.streetNameSearchCompletionView.didSelectSearchCompletion = { [weak self] searchCompletion in
            self?.streetNameHeaderTextFieldView.setText(searchCompletion.title)
            self?.streetNameHeaderTextFieldView.resignFirstResponder()
            self?.streetNameSearchCompletionView.clearResults()
        }

        self.placeHeaderTextFieldView.setPlaceholderText(Localization.localized("place_commune"))
        self.postCodeHeaderTextFieldView.setPlaceholderText(Localization.localized("postal_code"))
        self.streetNameHeaderTextFieldView.setPlaceholderText(Localization.localized("street_name"))
        self.numberHeaderTextFieldView.setPlaceholderText(Localization.localized("street_number"))

        self.placeHeaderTextFieldView.setReturnKeyType(.next)
        self.placeHeaderTextFieldView.didTapReturn = { [weak self] in
            self?.postCodeHeaderTextFieldView.becomeFirstResponder()
        }

        self.postCodeHeaderTextFieldView.setReturnKeyType(.continue)
        self.postCodeHeaderTextFieldView.didTapReturn = { [weak self] in
            self?.streetNameHeaderTextFieldView.becomeFirstResponder()
        }


        self.streetNameHeaderTextFieldView.setReturnKeyType(.continue)
        self.streetNameHeaderTextFieldView.didTapReturn = { [weak self] in
            self?.numberHeaderTextFieldView.becomeFirstResponder()
        }

        self.numberHeaderTextFieldView.setReturnKeyType(.done)
        self.numberHeaderTextFieldView.didTapReturn = { [weak self] in
            self?.numberHeaderTextFieldView.resignFirstResponder()
        }

        self.placeHeaderTextFieldView.setText(self.viewModel.place.value ?? "")
        self.postCodeHeaderTextFieldView.setText(self.viewModel.postcode.value ?? "")
        self.streetNameHeaderTextFieldView.setText(self.viewModel.street.value ?? "")
        self.numberHeaderTextFieldView.setText(self.viewModel.streetNumber.value ?? "")

        self.postCodeHeaderTextFieldView.setKeyboardType(.numberPad)
        self.numberHeaderTextFieldView.setKeyboardType(.numbersAndPunctuation)

        self.placeHeaderTextFieldView.textPublisher
            .sink { [weak self] place in
                self?.viewModel.setPlace(place)
            }
            .store(in: &self.cancellables)

        self.postCodeHeaderTextFieldView.textPublisher
            .sink { [weak self] postcode in
                self?.viewModel.setPostcode(postcode)
            }
            .store(in: &self.cancellables)

        self.streetNameHeaderTextFieldView.textPublisher
            .sink { [weak self] street in
                self?.viewModel.setStreet(street)
            }
            .store(in: &self.cancellables)

        self.numberHeaderTextFieldView.textPublisher
            .sink { [weak self] streetNumber in
                self?.viewModel.setStreetNumber(streetNumber)
            }
            .store(in: &self.cancellables)


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

        self.placeHeaderTextFieldView.didEndEditing = { [weak self] in
            self?.placeSearchCompletionView.clearResults()
        }

        //        self.postCodeHeaderTextFieldView.textPublisher
        //            .compactMap({ $0 })
        //            .debounce(for: .seconds(0.6), scheduler: DispatchQueue.main)
        //            .filter({ [weak self] _ in
        //                guard let self else { return false }
        //                return self.viewModel.shouldSuggestAddresses && self.postCodeHeaderTextFieldView.isFirstResponder
        //            })
        //            .flatMap { [weak self] query in
        //                guard
        //                    let self = self
        //                else {
        //                    return Just([String]()).eraseToAnyPublisher()
        //                }
        //                let cityName = self.placeHeaderTextFieldView.text
        //                return self.viewModel.requestStreetAutoCompletion(forQuery: query, fromCity: cityName)
        //            }
        //            .receive(on: DispatchQueue.main)
        //            .sink { [weak self] suggestions in
        //                UIView.animate(withDuration: 0.1) {
        //                    self?.postCodeSearchCompletionView.presentResults(suggestions)
        //                }
        //            }
        //            .store(in: &self.cancellables)
        //
        //        self.postCodeHeaderTextFieldView.didEndEditing = { [weak self] in
        //            self?.postCodeSearchCompletionView.clearResults()
        //        }

        self.streetNameHeaderTextFieldView.textPublisher
            .compactMap({ $0 })
            .debounce(for: .seconds(0.6), scheduler: DispatchQueue.main)
            .filter({ [weak self] _ in
                guard let self else { return false }
                return self.viewModel.shouldSuggestAddresses && self.streetNameHeaderTextFieldView.isFirstResponder
            })
            .flatMap { [weak self] query in
                guard
                    let self = self
                else {
                    return Just([AddressSearchResult]()).eraseToAnyPublisher()
                }
                let postCodeu = self.postCodeHeaderTextFieldView.text
                return self.viewModel.requestStreetAutoCompletion(forQuery: query, fromPostcode: postCodeu)
            }
            .receive(on: DispatchQueue.main)
            .sink { [weak self] (suggestions: [AddressSearchResult]) in
                UIView.animate(withDuration: 0.1) {
                    self?.streetNameSearchCompletionView.presentResults(suggestions)
                }
            }
            .store(in: &self.cancellables)

        self.streetNameHeaderTextFieldView.didEndEditing = { [weak self] in
            self?.streetNameSearchCompletionView.clearResults()
        }


//        self.viewModel.shouldShowPlaceFormatErrorMessage
//            .receive(on: DispatchQueue.main)
//            .sink { shouldShowPostcodeFormatErrorMessage in
//                if shouldShowPostcodeFormatErrorMessage {
//                    self.placeHeaderTextFieldView.showErrorOnField(text: Localization.localized("place_commune_invalid"),
//                                                                   color: AppColor.alertError)
//                }
//                else {
//                    self.placeHeaderTextFieldView.hideTipAndError()
//                }
//            }
//            .store(in: &self.cancellables)

        self.viewModel.shouldShowPostcodeFormatErrorMessage
            .receive(on: DispatchQueue.main)
            .sink { shouldShowPostcodeFormatErrorMessage in
                if shouldShowPostcodeFormatErrorMessage {
                    self.postCodeHeaderTextFieldView.showError(withMessage: Localization.localized("invalid_postcode"))
                }
                else {
                    self.postCodeHeaderTextFieldView.hideTipAndError()
                }
            }
            .store(in: &self.cancellables)

        self.viewModel.shouldShowStreetNumberFormatErrorMessage
            .receive(on: DispatchQueue.main)
            .sink { shouldShowStreetNumberFormatErrorMessage in
                if shouldShowStreetNumberFormatErrorMessage {
                    self.numberHeaderTextFieldView.showError(withMessage: Localization.localized("invalid_number"))
                }
                else {
                    self.numberHeaderTextFieldView.hideTipAndError()
                }
            }
            .store(in: &self.cancellables)
    }

    public override func layoutSubviews() {
        super.layoutSubviews()
    }

    override func setupWithTheme() {
        super.setupWithTheme()

        self.placeHeaderTextFieldView.setViewColor(AppColor.inputBackground)
        self.placeHeaderTextFieldView.setHeaderLabelColor(AppColor.inputTextTitle)
        self.placeHeaderTextFieldView.setTextFieldColor(AppColor.inputText)

        self.postCodeHeaderTextFieldView.setViewColor(AppColor.inputBackground)
        self.postCodeHeaderTextFieldView.setHeaderLabelColor(AppColor.inputTextTitle)
        self.postCodeHeaderTextFieldView.setTextFieldColor(AppColor.inputText)

        self.streetNameHeaderTextFieldView.setViewColor(AppColor.inputBackground)
        self.streetNameHeaderTextFieldView.setHeaderLabelColor(AppColor.inputTextTitle)
        self.streetNameHeaderTextFieldView.setTextFieldColor(AppColor.inputText)

        self.numberHeaderTextFieldView.setViewColor(AppColor.inputBackground)
        self.numberHeaderTextFieldView.setHeaderLabelColor(AppColor.inputTextTitle)
        self.numberHeaderTextFieldView.setTextFieldColor(AppColor.inputText)
    }

    override func canPresentError(forFormStep formStep: FormStep) -> Bool {
        switch formStep {
        case .address: return true
        default: return false
        }
    }

    override func presentError(_ error: RegisterError, forFormStep formStep: FormStep) {
        if !self.canPresentError(forFormStep: formStep) { return }
        switch (error.field, error.error) {
        case ("city", "INVALID_LENGTH"):
            self.placeHeaderTextFieldView.showError(withMessage: Localization.localized("place_too_long"))
        case ("address", "INVALID_LENGTH"):
            self.postCodeHeaderTextFieldView.showError(withMessage: Localization.localized("street_name_too_long"))
        case ("city", _):
            self.placeHeaderTextFieldView.showError(withMessage: Localization.localized("invalid_place"))
        case ("address", _):
            self.postCodeHeaderTextFieldView.showError(withMessage: Localization.localized("invalid_street"))
        default:
            ()
        }
    }
    
}

extension AddressFormStepView {

    fileprivate static func createPlaceHeaderTextFieldView() -> HeaderTextFieldView {
        let headerTextFieldView = HeaderTextFieldView()
        headerTextFieldView.setTextFieldFont(AppFont.with(type: .semibold, size: 16))
        headerTextFieldView.setHeaderLabelFont(AppFont.with(type: .semibold, size: 16))
        headerTextFieldView.translatesAutoresizingMaskIntoConstraints = false
        return headerTextFieldView
    }

    fileprivate static func createStreetHeaderTextFieldView() -> HeaderTextFieldView {
        let headerTextFieldView = HeaderTextFieldView()
        headerTextFieldView.setTextFieldFont(AppFont.with(type: .semibold, size: 16))
        headerTextFieldView.setHeaderLabelFont(AppFont.with(type: .semibold, size: 16))
        headerTextFieldView.translatesAutoresizingMaskIntoConstraints = false
        return headerTextFieldView
    }

    fileprivate static func createAdditionalStreetHeaderTextFieldView() -> HeaderTextFieldView {
        let headerTextFieldView = HeaderTextFieldView()
        headerTextFieldView.setTextFieldFont(AppFont.with(type: .semibold, size: 16))
        headerTextFieldView.setHeaderLabelFont(AppFont.with(type: .semibold, size: 16))
        headerTextFieldView.translatesAutoresizingMaskIntoConstraints = false
        return headerTextFieldView
    }

    fileprivate static func createSearchCompletionView() -> SearchCompletionView {
        let searchCompletionView = SearchCompletionView()
        searchCompletionView.translatesAutoresizingMaskIntoConstraints = false
        return searchCompletionView
    }

}
