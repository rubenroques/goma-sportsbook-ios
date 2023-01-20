//
//  AddressFormStepView.swift
//  
//
//  Created by Ruben Roques on 16/01/2023.
//

import UIKit
import Extensions
import Combine

struct AvatarFormStepViewModel {

    let title: String
    let avatarIconNames: [String]

}

class AvatarFormStepView: FormStepView {

    let viewModel: AvatarFormStepViewModel

    init(viewModel: AvatarFormStepViewModel) {
        self.viewModel = viewModel

        super.init()

        self.configureSubviews()
    }

    override var isFormCompleted: AnyPublisher<Bool, Never> {
        return Just(true).eraseToAnyPublisher()
    }
    
    func configureSubviews() {

        self.titleLabel.text = self.viewModel.title

    }

    public override func layoutSubviews() {
        super.layoutSubviews()
    }

    override func setupWithTheme() {
        super.setupWithTheme()

    }

}

extension AvatarFormStepView {

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
