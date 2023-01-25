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

class AddressFormStepViewModel {

    let title: String

    var place: CurrentValueSubject<String?, Never>
    var street: CurrentValueSubject<String?, Never>
    var additionalStreet: CurrentValueSubject<String?, Never>

    private var userRegisterEnvelopUpdater: UserRegisterEnvelopUpdater

    init(title: String,
         place: String? = nil,
         street: String? = nil,
         additionalStreet: String? = nil,
         userRegisterEnvelopUpdater: UserRegisterEnvelopUpdater) {

        self.title = title
        self.place = .init(place)
        self.street = .init(street)
        self.additionalStreet = .init(additionalStreet)
        self.userRegisterEnvelopUpdater = userRegisterEnvelopUpdater
    }

    var isFormCompleted: AnyPublisher<Bool, Never> {
        return Publishers.CombineLatest3(self.place, self.street, self.additionalStreet)
            .map { place, street, additionalStreet in
                return (place ?? "").count > 0 &&
                (street ?? "").count > 0 &&
                (additionalStreet ?? "").count > 0
            }
            .eraseToAnyPublisher()
    }

    func setPlace(_ place: String) {
        self.place.send(place)
        self.userRegisterEnvelopUpdater.setPlaceBirth(place)
    }

    func setStreet(_ street: String) {
        self.street.send(street)
        self.userRegisterEnvelopUpdater.setStreetAddress(street)
    }

    func setAdditionalStreet(_ additionalStreet: String) {
        self.additionalStreet.send(additionalStreet)
        self.userRegisterEnvelopUpdater.setAdditionalStreetAddress(additionalStreet)
    }

}

class AddressFormStepView: FormStepView {

    private lazy var placeHeaderTextFieldView: HeaderTextFieldView = Self.createPlaceHeaderTextFieldView()
    private lazy var streetHeaderTextFieldView: HeaderTextFieldView = Self.createStreetHeaderTextFieldView()
    private lazy var additionalStreetHeaderTextFieldView: HeaderTextFieldView = Self.createAdditionalStreetHeaderTextFieldView()

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

        self.stackView.addArrangedSubview(self.placeHeaderTextFieldView)
        self.stackView.addArrangedSubview(self.streetHeaderTextFieldView)
        self.stackView.addArrangedSubview(self.additionalStreetHeaderTextFieldView)


        NSLayoutConstraint.activate([
            self.placeHeaderTextFieldView.heightAnchor.constraint(equalToConstant: 80),
            self.streetHeaderTextFieldView.heightAnchor.constraint(equalToConstant: 80),
            self.additionalStreetHeaderTextFieldView.heightAnchor.constraint(equalToConstant: 80),
        ])

        self.titleLabel.text = self.viewModel.title

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
    }

    public override func layoutSubviews() {
        super.layoutSubviews()
    }

    override func setupWithTheme() {
        super.setupWithTheme()

        self.placeHeaderTextFieldView.backgroundColor = AppColor.backgroundPrimary
        self.placeHeaderTextFieldView.setHeaderLabelColor(AppColor.inputTextTitle)
        self.placeHeaderTextFieldView.setTextFieldColor(AppColor.inputText)

        self.streetHeaderTextFieldView.backgroundColor = AppColor.backgroundPrimary
        self.streetHeaderTextFieldView.setHeaderLabelColor(AppColor.inputTextTitle)
        self.streetHeaderTextFieldView.setTextFieldColor(AppColor.inputText)

        self.additionalStreetHeaderTextFieldView.backgroundColor = AppColor.backgroundPrimary
        self.additionalStreetHeaderTextFieldView.setHeaderLabelColor(AppColor.inputTextTitle)
        self.additionalStreetHeaderTextFieldView.setTextFieldColor(AppColor.inputText)
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

}
