//
//  NamesFormStepView.swift
//  
//
//  Created by Ruben Roques on 16/01/2023.
//

import UIKit
import Extensions

struct NamesFormStepViewModel {

    let title: String

    let firstName: String?
    let lastName: String?

    let firstNamePlaceholder: String
    let lastNamePlaceholder: String

    init(title: String, firstName: String? = nil, lastName: String? = nil, firstNamePlaceholder: String, lastNamePlaceholder: String) {
        self.title = title
        self.firstName = firstName
        self.lastName = lastName
        self.firstNamePlaceholder = firstNamePlaceholder
        self.lastNamePlaceholder = lastNamePlaceholder
    }

}

class NamesFormStepView: FormStepView {

    private lazy var firstNameHeaderTextFieldView: HeaderTextFieldView = Self.createFirstNameHeaderTextFieldView()
    private lazy var lastNameHeaderTextFieldView: HeaderTextFieldView = Self.createLastNameHeaderTextFieldView()

    let viewModel: NamesFormStepViewModel

    init(viewModel: NamesFormStepViewModel) {
        self.viewModel = viewModel

        super.init()

        self.configureSubviews()
    }

    func configureSubviews() {

        self.stackView.addArrangedSubview(self.firstNameHeaderTextFieldView)
        self.stackView.addArrangedSubview(self.lastNameHeaderTextFieldView)

        NSLayoutConstraint.activate([
            self.firstNameHeaderTextFieldView.heightAnchor.constraint(equalToConstant: 80),
            self.lastNameHeaderTextFieldView.heightAnchor.constraint(equalToConstant: 80),
        ])

        self.titleLabel.text = self.viewModel.title

        self.firstNameHeaderTextFieldView.setReturnKeyType(.next)
        self.firstNameHeaderTextFieldView.setPlaceholderText(self.viewModel.firstNamePlaceholder)
        self.firstNameHeaderTextFieldView.didTapReturn = { [weak self] in
            self?.lastNameHeaderTextFieldView.becomeFirstResponder()
        }

        self.lastNameHeaderTextFieldView.setReturnKeyType(.continue)
        self.lastNameHeaderTextFieldView.setPlaceholderText(self.viewModel.lastNamePlaceholder)
        self.lastNameHeaderTextFieldView.didTapReturn = { [weak self] in
            self?.lastNameHeaderTextFieldView.resignFirstResponder()
        }
    }

    public override func layoutSubviews() {
        super.layoutSubviews()
    }

    override func setupWithTheme() {
        super.setupWithTheme()
    }

}

extension NamesFormStepView {

    fileprivate static func createFirstNameHeaderTextFieldView() -> HeaderTextFieldView {
        let headerTextFieldView = HeaderTextFieldView()
        headerTextFieldView.translatesAutoresizingMaskIntoConstraints = false
        return headerTextFieldView
    }

    fileprivate static func createLastNameHeaderTextFieldView() -> HeaderTextFieldView {
        let headerTextFieldView = HeaderTextFieldView()
        headerTextFieldView.translatesAutoresizingMaskIntoConstraints = false
        return headerTextFieldView
    }

}
