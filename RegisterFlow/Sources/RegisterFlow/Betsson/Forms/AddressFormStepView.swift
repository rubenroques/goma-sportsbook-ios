//
//  AddressFormStepView.swift
//  
//
//  Created by Ruben Roques on 16/01/2023.
//

import UIKit
import Theming
import Extensions

struct AddressFormStepViewModel {

    let title: String

    let place: String?
    let street: String?
    let additionalStreet: String?

    let placePlaceholder: String
    let streetPlaceholder: String
    let additionalStreetPlaceholder: String

}

class AddressFormStepView: FormStepView {

    private lazy var placeHeaderTextFieldView: HeaderTextFieldView = Self.createPlaceHeaderTextFieldView()
    private lazy var streetHeaderTextFieldView: HeaderTextFieldView = Self.createStreetHeaderTextFieldView()
    private lazy var additionalStreetHeaderTextFieldView: HeaderTextFieldView = Self.createAdditionalStreetHeaderTextFieldView()

    let viewModel: AddressFormStepViewModel

    init(viewModel: AddressFormStepViewModel) {
        self.viewModel = viewModel

        super.init()

        self.configureSubviews()
    }

    func configureSubviews() {



        self.stackView.addArrangedSubview(self.placeHeaderTextFieldView)
        self.stackView.addArrangedSubview(self.streetHeaderTextFieldView)
        self.stackView.addArrangedSubview(self.additionalStreetHeaderTextFieldView)

        self.titleLabel.text = self.viewModel.title

        self.placeHeaderTextFieldView.setPlaceholderText(self.viewModel.placePlaceholder)
        self.streetHeaderTextFieldView.setPlaceholderText(self.viewModel.streetPlaceholder)
        self.additionalStreetHeaderTextFieldView.setPlaceholderText(self.viewModel.additionalStreetPlaceholder)

    }

    public override func layoutSubviews() {
        super.layoutSubviews()
    }

    override func setupWithTheme() {
        super.setupWithTheme()

    }

}

extension AddressFormStepView {

    fileprivate static func createPlaceHeaderTextFieldView() -> HeaderTextFieldView {
        let headerTextFieldView = HeaderTextFieldView()
        headerTextFieldView.translatesAutoresizingMaskIntoConstraints = false
        return headerTextFieldView
    }

    fileprivate static func createStreetHeaderTextFieldView() -> HeaderTextFieldView {
        let headerTextFieldView = HeaderTextFieldView()
        headerTextFieldView.translatesAutoresizingMaskIntoConstraints = false
        return headerTextFieldView
    }

    fileprivate static func createAdditionalStreetHeaderTextFieldView() -> HeaderTextFieldView {
        let headerTextFieldView = HeaderTextFieldView()
        headerTextFieldView.translatesAutoresizingMaskIntoConstraints = false
        return headerTextFieldView
    }


}
