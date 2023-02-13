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

class AddressFormStepViewModel {

    let title: String

    var countryCodeForSuggestions: String
    var place: CurrentValueSubject<String?, Never>
    var street: CurrentValueSubject<String?, Never>
    var additionalStreet: CurrentValueSubject<String?, Never>

    var shouldSuggestAddresses: Bool = true

    private var userRegisterEnvelopUpdater: UserRegisterEnvelopUpdater
    private var adresseFrancaiseClient: AdresseFrancaiseClient

    private var cancellables = Set<AnyCancellable>()


    init(title: String,
         countryCodeForSuggestions: String,
         place: String? = nil,
         street: String? = nil,
         additionalStreet: String? = nil,
         userRegisterEnvelopUpdater: UserRegisterEnvelopUpdater,
         adresseFrancaiseClient: AdresseFrancaiseClient = AdresseFrancaiseClient()) {

        self.title = title
        self.countryCodeForSuggestions = countryCodeForSuggestions
        self.place = .init(place)
        self.street = .init(street)
        self.additionalStreet = .init(additionalStreet)
        self.userRegisterEnvelopUpdater = userRegisterEnvelopUpdater
        self.adresseFrancaiseClient = AdresseFrancaiseClient()

         self.userRegisterEnvelopUpdater.selectedCountry
            .map { [weak self] country -> Bool in
            if let countryValue = country {
                return countryValue.iso3Code == (self?.countryCodeForSuggestions ?? "")
            }
            else {
                return false
            }
        }
        .sink(receiveValue: { [weak self] shouldSuggest in
            self?.shouldSuggestAddresses = shouldSuggest
        })
        .store(in: &self.cancellables)

    }

    var isFormCompleted: AnyPublisher<Bool, Never> {
        return Publishers.CombineLatest(self.place, self.street)
            .map { place, street in
                return (place ?? "").count > 0 &&
                (street ?? "").count > 0
            }
            .eraseToAnyPublisher()
    }

    func setPlace(_ place: String) {
        self.place.send(place)
        self.userRegisterEnvelopUpdater.setPlaceAddress(place)
    }

    func setStreet(_ street: String) {
        self.street.send(street)
        self.userRegisterEnvelopUpdater.setStreetAddress(street)
    }

    func setAdditionalStreet(_ additionalStreet: String) {
        self.additionalStreet.send(additionalStreet)
        self.userRegisterEnvelopUpdater.setAdditionalStreetAddress(additionalStreet)
    }

    func requestStreetAutoCompletion(forQuery query: String) -> AnyPublisher<[String], Never> {
        return self.adresseFrancaiseClient
            .searchStreet(query: query)
            .map { results in
                let labels = results.map(\.label)
                let uniqueLabels = NSOrderedSet(array: labels).prefix(4)
                return Array(uniqueLabels) as! [String]
            }
            .replaceError(with: [String]() )
            .eraseToAnyPublisher()
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

}

class AddressFormStepView: FormStepView {

    private lazy var placeHeaderTextFieldView: HeaderTextFieldView = Self.createPlaceHeaderTextFieldView()
    private lazy var placeSearchCompletionView: SearchCompletionView = Self.createSearchCompletionView()

    private lazy var streetHeaderTextFieldView: HeaderTextFieldView = Self.createStreetHeaderTextFieldView()
    private lazy var streetSearchCompletionView: SearchCompletionView = Self.createSearchCompletionView()

    private lazy var additionalStreetHeaderTextFieldView: HeaderTextFieldView = Self.createAdditionalStreetHeaderTextFieldView()
    private lazy var additionalStreetSearchCompletionView: SearchCompletionView = Self.createSearchCompletionView()

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
        streetContainerView.addSubview(self.streetHeaderTextFieldView)
        streetContainerView.addSubview(self.streetSearchCompletionView)

        let additionalStreetContainerView = UIView()
        additionalStreetContainerView.translatesAutoresizingMaskIntoConstraints = false
        additionalStreetContainerView.backgroundColor = .clear
        additionalStreetContainerView.addSubview(self.additionalStreetHeaderTextFieldView)
        additionalStreetContainerView.addSubview(self.additionalStreetSearchCompletionView)

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
            self.streetHeaderTextFieldView.heightAnchor.constraint(equalToConstant: 80),
            self.streetHeaderTextFieldView.topAnchor.constraint(equalTo: streetContainerView.topAnchor),
            self.streetHeaderTextFieldView.leadingAnchor.constraint(equalTo: streetContainerView.leadingAnchor),
            self.streetHeaderTextFieldView.trailingAnchor.constraint(equalTo: streetContainerView.trailingAnchor),

            self.streetSearchCompletionView.topAnchor.constraint(equalTo: self.streetHeaderTextFieldView.bottomAnchor, constant: -16),
            self.streetSearchCompletionView.leadingAnchor.constraint(equalTo: self.streetHeaderTextFieldView.leadingAnchor),
            self.streetSearchCompletionView.trailingAnchor.constraint(equalTo: self.streetHeaderTextFieldView.trailingAnchor),
            streetContainerView.bottomAnchor.constraint(greaterThanOrEqualTo: self.streetSearchCompletionView.bottomAnchor),

            additionalStreetContainerView.heightAnchor.constraint(greaterThanOrEqualToConstant: 80),
            self.additionalStreetHeaderTextFieldView.heightAnchor.constraint(equalToConstant: 80),
            self.additionalStreetHeaderTextFieldView.topAnchor.constraint(equalTo: additionalStreetContainerView.topAnchor),
            self.additionalStreetHeaderTextFieldView.leadingAnchor.constraint(equalTo: additionalStreetContainerView.leadingAnchor),
            self.additionalStreetHeaderTextFieldView.trailingAnchor.constraint(equalTo: additionalStreetContainerView.trailingAnchor),

            self.additionalStreetSearchCompletionView.topAnchor.constraint(equalTo: self.additionalStreetHeaderTextFieldView.bottomAnchor, constant: -16),
            self.additionalStreetSearchCompletionView.leadingAnchor.constraint(equalTo: self.additionalStreetHeaderTextFieldView.leadingAnchor),
            self.additionalStreetSearchCompletionView.trailingAnchor.constraint(equalTo: self.additionalStreetHeaderTextFieldView.trailingAnchor),
            additionalStreetContainerView.bottomAnchor.constraint(greaterThanOrEqualTo: self.additionalStreetSearchCompletionView.bottomAnchor),
        ])

        self.stackView.addArrangedSubview(placeContainerView)
        self.stackView.addArrangedSubview(streetContainerView)
        self.stackView.addArrangedSubview(additionalStreetContainerView)


        NSLayoutConstraint.activate([

            self.streetHeaderTextFieldView.heightAnchor.constraint(equalToConstant: 80),
            self.additionalStreetHeaderTextFieldView.heightAnchor.constraint(equalToConstant: 80),
        ])

        self.titleLabel.text = self.viewModel.title

        self.placeSearchCompletionView.didSelectSearchCompletion = { [weak self] searchCompletion in
            self?.placeHeaderTextFieldView.setText(searchCompletion)
            self?.placeHeaderTextFieldView.resignFirstResponder()
            self?.placeSearchCompletionView.clearResults()
        }

        self.streetSearchCompletionView.didSelectSearchCompletion = { [weak self] searchCompletion in
            self?.streetHeaderTextFieldView.setText(searchCompletion)
            self?.streetHeaderTextFieldView.resignFirstResponder()
            self?.streetSearchCompletionView.clearResults()
        }

        self.additionalStreetSearchCompletionView.didSelectSearchCompletion = { [weak self] searchCompletion in
            self?.additionalStreetHeaderTextFieldView.setText(searchCompletion)
            self?.additionalStreetHeaderTextFieldView.resignFirstResponder()
            self?.additionalStreetSearchCompletionView.clearResults()
        }

        self.placeHeaderTextFieldView.setPlaceholderText("Place/Commune")
        self.streetHeaderTextFieldView.setPlaceholderText("Street line 1")
        self.additionalStreetHeaderTextFieldView.setPlaceholderText("Street line 2")

        self.placeHeaderTextFieldView.setReturnKeyType(.next)
        self.placeHeaderTextFieldView.didTapReturn = { [weak self] in
            self?.streetHeaderTextFieldView.becomeFirstResponder()
        }

        self.streetHeaderTextFieldView.setReturnKeyType(.continue)
        self.streetHeaderTextFieldView.didTapReturn = { [weak self] in
            self?.additionalStreetHeaderTextFieldView.becomeFirstResponder()
        }


        self.additionalStreetHeaderTextFieldView.setReturnKeyType(.continue)
        self.additionalStreetHeaderTextFieldView.didTapReturn = { [weak self] in
            self?.additionalStreetHeaderTextFieldView.resignFirstResponder()
        }

        self.placeHeaderTextFieldView.setText(self.viewModel.place.value ?? "")
        self.streetHeaderTextFieldView.setText(self.viewModel.street.value ?? "")
        self.additionalStreetHeaderTextFieldView.setText(self.viewModel.additionalStreet.value ?? "")

        self.placeHeaderTextFieldView.textPublisher
            .sink { [weak self] place in
                self?.viewModel.setPlace(place)
            }
            .store(in: &self.cancellables)

        self.streetHeaderTextFieldView.textPublisher
            .sink { [weak self] street in
                self?.viewModel.setStreet(street)
            }
            .store(in: &self.cancellables)

        self.additionalStreetHeaderTextFieldView.textPublisher
            .sink { [weak self] additionalStreet in
                self?.viewModel.setAdditionalStreet(additionalStreet)
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

        self.placeHeaderTextFieldView.didEndEditing = { [weak self] in
            self?.placeSearchCompletionView.clearResults()
        }

        self.streetHeaderTextFieldView.textPublisher
            .compactMap({ $0 })
            .debounce(for: .seconds(0.6), scheduler: DispatchQueue.main)
            .filter({ [weak self] _ in
                guard let self else { return false }
                return self.viewModel.shouldSuggestAddresses && self.streetHeaderTextFieldView.isFirstResponder
            })
            .flatMap { [weak self] query in
                guard
                    let self = self
                else {
                    return Just([String]()).eraseToAnyPublisher()
                }
                return self.viewModel.requestStreetAutoCompletion(forQuery: query)
            }
            .receive(on: DispatchQueue.main)
            .sink { [weak self] suggestions in
                UIView.animate(withDuration: 0.1) {
                    self?.streetSearchCompletionView.presentResults(suggestions)
                }
            }
            .store(in: &self.cancellables)

        self.streetHeaderTextFieldView.didEndEditing = { [weak self] in
            self?.streetSearchCompletionView.clearResults()
        }

        self.additionalStreetHeaderTextFieldView.textPublisher
            .compactMap({ $0 })
            .debounce(for: .seconds(0.6), scheduler: DispatchQueue.main)
            .filter({ [weak self] _ in
                guard let self else { return false }
                return self.viewModel.shouldSuggestAddresses && self.additionalStreetHeaderTextFieldView.isFirstResponder
            })
            .flatMap { [weak self] query in
                guard
                    let self = self
                else {
                    return Just([String]()).eraseToAnyPublisher()
                }
                return self.viewModel.requestStreetAutoCompletion(forQuery: query)
            }
            .receive(on: DispatchQueue.main)
            .sink { [weak self] suggestions in
                UIView.animate(withDuration: 0.1) {
                    self?.additionalStreetSearchCompletionView.presentResults(suggestions)
                }
            }
            .store(in: &self.cancellables)

        self.additionalStreetHeaderTextFieldView.didEndEditing = { [weak self] in
            self?.additionalStreetSearchCompletionView.clearResults()
        }
    }

    public override func layoutSubviews() {
        super.layoutSubviews()
    }

    override func setupWithTheme() {
        super.setupWithTheme()

        self.placeHeaderTextFieldView.setViewColor(AppColor.inputBackground)
        self.placeHeaderTextFieldView.setHeaderLabelColor(AppColor.inputTextTitle)
        self.placeHeaderTextFieldView.setTextFieldColor(AppColor.inputText)

        self.streetHeaderTextFieldView.setViewColor(AppColor.inputBackground)
        self.streetHeaderTextFieldView.setHeaderLabelColor(AppColor.inputTextTitle)
        self.streetHeaderTextFieldView.setTextFieldColor(AppColor.inputText)

        self.additionalStreetHeaderTextFieldView.setViewColor(AppColor.inputBackground)
        self.additionalStreetHeaderTextFieldView.setHeaderLabelColor(AppColor.inputTextTitle)
        self.additionalStreetHeaderTextFieldView.setTextFieldColor(AppColor.inputText)
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
            self.placeHeaderTextFieldView.showErrorOnField(text: "Place/Commune is too long", color: AppColor.alertError)
        case ("address", "INVALID_LENGTH"):
            self.streetHeaderTextFieldView.showErrorOnField(text: "Street name is too long", color: AppColor.alertError)
        case ("city", _):
            self.placeHeaderTextFieldView.showErrorOnField(text: "Please enter a valid Place/Commune", color: AppColor.alertError)
        case ("address", _):
            self.streetHeaderTextFieldView.showErrorOnField(text: "Please enter a valid Street", color: AppColor.alertError)
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
