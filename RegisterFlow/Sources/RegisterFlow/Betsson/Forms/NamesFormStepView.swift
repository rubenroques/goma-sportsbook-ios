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

    let firstName: CurrentValueSubject<String?, Never>
    let lastName: CurrentValueSubject<String?, Never>

    private var userRegisterEnvelopUpdater: UserRegisterEnvelopUpdater

    var isFormCompleted: AnyPublisher<Bool, Never> {
        return Publishers.CombineLatest(self.firstName, self.lastName)
            .map { (firstName, lastName) in
                if let firstName, let lastName {
                    return firstName.count > 1 && lastName.count > 1
                }
                return false
            }
            .eraseToAnyPublisher()
    }

    init(title: String,
         firstName: String? = nil,
         lastName: String? = nil,
         userRegisterEnvelopUpdater: UserRegisterEnvelopUpdater) {

        self.title = title
        self.firstName = .init(firstName)
        self.lastName = .init(lastName)

        self.userRegisterEnvelopUpdater = userRegisterEnvelopUpdater
    }

    func setFirstName(_ firstName: String) {
        self.firstName.send(firstName)
        self.userRegisterEnvelopUpdater.setName(firstName)
    }

    func setLastName(_ lastName: String) {
        self.lastName.send(lastName)
        self.userRegisterEnvelopUpdater.setSurname(lastName)
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

    override var isFormCompleted: AnyPublisher<Bool, Never> {
        return self.viewModel.isFormCompleted
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
        self.firstNameHeaderTextFieldView.setPlaceholderText("First Name")
        self.firstNameHeaderTextFieldView.didTapReturn = { [weak self] in
            self?.lastNameHeaderTextFieldView.becomeFirstResponder()
        }
        
        self.lastNameHeaderTextFieldView.setReturnKeyType(.continue)
        self.lastNameHeaderTextFieldView.setPlaceholderText("Last Name")
        self.lastNameHeaderTextFieldView.didTapReturn = { [weak self] in
            self?.lastNameHeaderTextFieldView.resignFirstResponder()
        }
        
        self.firstNameHeaderTextFieldView.setText(self.viewModel.firstName.value ?? "")
        self.lastNameHeaderTextFieldView.setText(self.viewModel.lastName.value ?? "")

        self.firstNameHeaderTextFieldView.textPublisher
            .sink { [weak self] text in
                self?.viewModel.setFirstName(text)
            }
            .store(in: &self.cancellables)


        self.lastNameHeaderTextFieldView.textPublisher
            .sink { [weak self] text in
                self?.viewModel.setLastName(text)
            }
            .store(in: &self.cancellables)

    }

    public override func layoutSubviews() {
        super.layoutSubviews()
    }

    override func setupWithTheme() {
        super.setupWithTheme()

        self.firstNameHeaderTextFieldView.setViewColor(AppColor.inputBackground)
        self.firstNameHeaderTextFieldView.setHeaderLabelColor(AppColor.inputTextTitle)
        self.firstNameHeaderTextFieldView.setTextFieldColor(AppColor.inputText)

        self.lastNameHeaderTextFieldView.setViewColor(AppColor.inputBackground)
        self.lastNameHeaderTextFieldView.setHeaderLabelColor(AppColor.inputTextTitle)
        self.lastNameHeaderTextFieldView.setTextFieldColor(AppColor.inputText)
    }

    override func canPresentError(forFormStep formStep: FormStep) -> Bool {
        switch formStep {
        case .names: return true
        default: return false
        }
    }

    override func presentError(_ error: RegisterError, forFormStep formStep: FormStep) {
        if !self.canPresentError(forFormStep: formStep) { return }
        switch (error.field, error.error) {
        case ("firstName", "INVALID_LENGTH"):
            self.firstNameHeaderTextFieldView.showErrorOnField(text: "This name has an invalid length", color: AppColor.alertError)
        case ("lastName", "INVALID_LENGTH"):
            self.lastNameHeaderTextFieldView.showErrorOnField(text: "This last name has an invalid length", color: AppColor.alertError)
        case ("firstName", _):
            self.firstNameHeaderTextFieldView.showErrorOnField(text: "Please enter a valid name", color: AppColor.alertError)
        case ("lastName", _):
            self.lastNameHeaderTextFieldView.showErrorOnField(text: "Please enter a valid last name", color: AppColor.alertError)
        default:
            ()
        }
    }

}

extension NamesFormStepView {

    fileprivate static func createFirstNameHeaderTextFieldView() -> HeaderTextFieldView {
        let headerTextFieldView = HeaderTextFieldView()
        headerTextFieldView.setTextFieldFont(AppFont.with(type: .semibold, size: 16))
        headerTextFieldView.setHeaderLabelFont(AppFont.with(type: .semibold, size: 16))
        headerTextFieldView.translatesAutoresizingMaskIntoConstraints = false
        return headerTextFieldView
    }

    fileprivate static func createLastNameHeaderTextFieldView() -> HeaderTextFieldView {
        let headerTextFieldView = HeaderTextFieldView()
        headerTextFieldView.setTextFieldFont(AppFont.with(type: .semibold, size: 16))
        headerTextFieldView.setHeaderLabelFont(AppFont.with(type: .semibold, size: 16))
        headerTextFieldView.translatesAutoresizingMaskIntoConstraints = false
        return headerTextFieldView
    }

}
