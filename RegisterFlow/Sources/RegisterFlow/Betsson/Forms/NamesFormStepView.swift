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

    private let viewModel: NamesFormStepViewModel

    private var cancellables = Set<AnyCancellable>()

    init(viewModel: NamesFormStepViewModel) {
        self.viewModel = viewModel

        super.init()

        self.configureSubviews()
    }

    private var isFormCompletedCurrentValue: CurrentValueSubject<Bool, Never> = .init(false)
    override var isFormCompleted: AnyPublisher<Bool, Never> {
        return isFormCompletedCurrentValue.eraseToAnyPublisher()
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

        Publishers.CombineLatest(self.firstNameHeaderTextFieldView.textPublisher, self.lastNameHeaderTextFieldView.textPublisher)
            .map { (firstName, lastName) in
                firstName.count > 1 && lastName.count > 1
            }
            .sink { [weak self] completed in
                self?.isFormCompletedCurrentValue.send(completed)
            }
            .store(in: &self.cancellables)

    }

    public override func layoutSubviews() {
        super.layoutSubviews()
    }

    override func setupWithTheme() {
        super.setupWithTheme()

        self.firstNameHeaderTextFieldView.backgroundColor = AppColor.backgroundPrimary
        self.firstNameHeaderTextFieldView.setHeaderLabelColor(AppColor.inputTextTitle)
        self.firstNameHeaderTextFieldView.setTextFieldColor(AppColor.inputText)

        self.lastNameHeaderTextFieldView.backgroundColor = AppColor.backgroundPrimary
        self.lastNameHeaderTextFieldView.setHeaderLabelColor(AppColor.inputTextTitle)
        self.lastNameHeaderTextFieldView.setTextFieldColor(AppColor.inputText)
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
