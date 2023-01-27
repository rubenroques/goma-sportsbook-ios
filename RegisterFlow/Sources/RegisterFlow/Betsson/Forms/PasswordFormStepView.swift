//
//  File.swift
//  
//
//  Created by Ruben Roques on 24/01/2023.
//

import Foundation
import UIKit
import Theming
import Extensions
import Combine

class PasswordFormStepViewModel {

    let title: String

    var password: CurrentValueSubject<String?, Never>

    private var userRegisterEnvelopUpdater: UserRegisterEnvelopUpdater

    enum PasswordState {
        case empty
        case short
        case long
        case invalidChars
        case onlyNumbers
        case needUppercase
        case needLowercase
        case needNumber
        case needSpecial
        case valid
    }
    var passwordState: AnyPublisher<PasswordState, Never> {
        return self.password
            .map { password in
                guard let password else { return PasswordState.empty }
                if password.isEmpty { return PasswordState.empty }
                if password.count < 8 { return PasswordState.short }
                if password.count > 16 { return PasswordState.long }

                let numbersCharacterSet: NSCharacterSet = NSCharacterSet(charactersIn: "0123456789")
                if password.rangeOfCharacter(from: numbersCharacterSet.inverted) == nil {
                    return PasswordState.onlyNumbers
                }

                let validCharacterSet: NSCharacterSet = NSCharacterSet(charactersIn: "-!@$^&*abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789")
                if password.rangeOfCharacter(from: validCharacterSet.inverted) != nil {
                    return PasswordState.invalidChars
                }

                let specialCharacterSet: NSCharacterSet = NSCharacterSet(charactersIn: "-!@$^&*")
                let lowerCharacterSet: NSCharacterSet = NSCharacterSet(charactersIn: "abcdefghijklmnopqrstuvwxyz")
                let upperCharacterSet: NSCharacterSet = NSCharacterSet(charactersIn: "ABCDEFGHIJKLMNOPQRSTUVWXYZ")

                if password.rangeOfCharacter(from: lowerCharacterSet as CharacterSet) == nil {
                    return PasswordState.needLowercase
                }
                if password.rangeOfCharacter(from: upperCharacterSet as CharacterSet) == nil {
                    return PasswordState.needUppercase
                }
                if password.rangeOfCharacter(from: numbersCharacterSet as CharacterSet) == nil {
                    return PasswordState.needNumber
                }
                if password.rangeOfCharacter(from: specialCharacterSet as CharacterSet) == nil {
                    return PasswordState.needSpecial
                }

                return PasswordState.valid
            }
            .eraseToAnyPublisher()
    }

    var isFormCompleted: AnyPublisher<Bool, Never> {
        return self.passwordState
            .map({ passwordState in
                switch passwordState {
                case .valid: return true
                default: return false
                }
            })
            .eraseToAnyPublisher()
    }

    init(title: String,
         password: String? = nil,
         userRegisterEnvelopUpdater: UserRegisterEnvelopUpdater) {

        self.title = title
        self.password = .init(password)

        self.userRegisterEnvelopUpdater = userRegisterEnvelopUpdater
    }

    func setPassword(_ password: String) {
        self.password.send(password)
        self.userRegisterEnvelopUpdater.setPassword(password)
    }

}

class PasswordFormStepView: FormStepView {

    private lazy var passwordHeaderTextFieldView: HeaderTextFieldView = Self.createPasswordHeaderTextFieldView()

    private let viewModel: PasswordFormStepViewModel
    private var cancellables = Set<AnyCancellable>()

    override var isFormCompleted: AnyPublisher<Bool, Never> {
        return self.viewModel.isFormCompleted
    }

    init(viewModel: PasswordFormStepViewModel) {
        self.viewModel = viewModel

        super.init()

        self.configureSubviews()
    }

    func configureSubviews() {

        self.passwordHeaderTextFieldView.setSecureField(true)

        self.stackView.addArrangedSubview(self.passwordHeaderTextFieldView)

        NSLayoutConstraint.activate([
            self.passwordHeaderTextFieldView.heightAnchor.constraint(equalToConstant: 80),
        ])

        self.titleLabel.text = self.viewModel.title

        self.passwordHeaderTextFieldView.setPlaceholderText("Password")

        self.passwordHeaderTextFieldView.setReturnKeyType(.next)
        self.passwordHeaderTextFieldView.didTapReturn = { [weak self] in
            self?.passwordHeaderTextFieldView.resignFirstResponder()
        }

        self.passwordHeaderTextFieldView.setText(self.viewModel.password.value ?? "")

        self.passwordHeaderTextFieldView.textPublisher
            .sink { [weak self] text in
                self?.passwordHeaderTextFieldView.hideTipAndError()
                self?.viewModel.setPassword(text)
            }
            .store(in: &self.cancellables)

        self.viewModel.passwordState
            .debounce(for: .seconds(1.5), scheduler: DispatchQueue.main)
            .receive(on: DispatchQueue.main)
            .sink { passwordState in
                switch passwordState {
                case .empty:
                    self.passwordHeaderTextFieldView.hideTipAndError()
                case .short:
                    self.passwordHeaderTextFieldView.showErrorOnField(text: "The password is too short", color: AppColor.inputError)
                case .long:
                    self.passwordHeaderTextFieldView.showErrorOnField(text: "The password is too long", color: AppColor.inputError)
                case  .invalidChars:
                    self.passwordHeaderTextFieldView.showErrorOnField(text: "The password contains invalids characters", color: AppColor.inputError)
                case .onlyNumbers:
                    self.passwordHeaderTextFieldView.showErrorOnField(text: "The password can not be all numbers", color: AppColor.inputError)
                case .needUppercase:
                    self.passwordHeaderTextFieldView.showErrorOnField(text: "The password must contain an uppercase letter", color: AppColor.inputError)
                case .needLowercase:
                    self.passwordHeaderTextFieldView.showErrorOnField(text: "The password must contain a lowercase letter", color: AppColor.inputError)
                case .needNumber:
                    self.passwordHeaderTextFieldView.showErrorOnField(text: "The password must contain a number", color: AppColor.inputError)
                case .needSpecial:
                    self.passwordHeaderTextFieldView.showErrorOnField(text: "The password must contain a special character (-!@$^&*)", color: AppColor.inputError)
                case .valid:
                    self.passwordHeaderTextFieldView.hideTipAndError()
                }
            }
            .store(in: &self.cancellables)
    }

    public override func layoutSubviews() {
        super.layoutSubviews()
    }

    override func setupWithTheme() {
        super.setupWithTheme()

        self.passwordHeaderTextFieldView.backgroundColor = AppColor.backgroundPrimary
        self.passwordHeaderTextFieldView.setHeaderLabelColor(AppColor.inputTextTitle)
        self.passwordHeaderTextFieldView.setTextFieldColor(AppColor.inputText)
    }

}

extension PasswordFormStepView {

    fileprivate static func createPasswordHeaderTextFieldView() -> HeaderTextFieldView {
        let headerTextFieldView = HeaderTextFieldView()
        headerTextFieldView.setTextFieldFont(AppFont.with(type: .semibold, size: 16))
        headerTextFieldView.setHeaderLabelFont(AppFont.with(type: .semibold, size: 16))
        headerTextFieldView.translatesAutoresizingMaskIntoConstraints = false
        return headerTextFieldView
    }

}
