//
//  SuccessSignUpFormStepView.swift
//  
//
//  Created by Ruben Roques on 25/01/2023.
//

import Foundation
import UIKit
import Theming
import Extensions
import Combine

class SuccessSignUpFormStepViewModel {

    let title: String

    private var userRegisterEnvelopUpdater: UserRegisterEnvelopUpdater

    init(title: String, userRegisterEnvelopUpdater: UserRegisterEnvelopUpdater) {
        self.title = title
        self.userRegisterEnvelopUpdater = userRegisterEnvelopUpdater
    }

}

class SuccessSignUpFormStepView: FormStepView {

    private let viewModel: SuccessSignUpFormStepViewModel
    private var cancellables = Set<AnyCancellable>()

    init(viewModel: SuccessSignUpFormStepViewModel) {
        self.viewModel = viewModel

        super.init()

        self.configureSubviews()
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

extension SuccessSignUpFormStepView {

    fileprivate static func createCodeHeaderTextFieldView() -> HeaderTextFieldView {
        let headerTextFieldView = HeaderTextFieldView()
        return headerTextFieldView
    }

}
