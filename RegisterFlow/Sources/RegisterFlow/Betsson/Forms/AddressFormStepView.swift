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
