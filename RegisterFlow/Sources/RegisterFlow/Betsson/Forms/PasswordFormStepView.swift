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

    let title: String

    var password: CurrentValueSubject<String?, Never>

    private var userRegisterEnvelopUpdater: UserRegisterEnvelopUpdater
    private var cancellables = Set<AnyCancellable>()

    var passwordState: AnyPublisher<[PasswordState], Never> {
        return self.password
            .map { password in

                var passwordStates: [PasswordState] = []

                guard let password else { return [PasswordState.empty] }

                if password.isEmpty { passwordStates.append(PasswordState.empty) }
                if password.count < 8 { passwordStates.append(PasswordState.short) }
                if password.count > 16 { passwordStates.append(PasswordState.long) }

                let numbersCharacterSet: NSCharacterSet = NSCharacterSet(charactersIn: "0123456789")
                if password.rangeOfCharacter(from: numbersCharacterSet.inverted) == nil {
                    passwordStates.append(PasswordState.onlyNumbers)
                }

                let validCharacterSet: NSCharacterSet = NSCharacterSet(charactersIn: "-!@$^&*abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789")
                if password.rangeOfCharacter(from: validCharacterSet.inverted) != nil {
                    passwordStates.append(PasswordState.invalidChars)
                }

                let specialCharacterSet: NSCharacterSet = NSCharacterSet(charactersIn: "-!@$^&*")
                let lowerCharacterSet: NSCharacterSet = NSCharacterSet(charactersIn: "abcdefghijklmnopqrstuvwxyz")
                let upperCharacterSet: NSCharacterSet = NSCharacterSet(charactersIn: "ABCDEFGHIJKLMNOPQRSTUVWXYZ")

                if password.rangeOfCharacter(from: lowerCharacterSet as CharacterSet) == nil {
                    passwordStates.append(PasswordState.needLowercase)
                }
                if password.rangeOfCharacter(from: upperCharacterSet as CharacterSet) == nil {
                    passwordStates.append(PasswordState.needUppercase)
                }
                if password.rangeOfCharacter(from: numbersCharacterSet as CharacterSet) == nil {
                    passwordStates.append(PasswordState.needNumber)
                }
                if password.rangeOfCharacter(from: specialCharacterSet as CharacterSet) == nil {
                    passwordStates.append(PasswordState.needSpecial)
                }

                if !passwordStates.isEmpty {
                    return passwordStates
                }

                return [PasswordState.valid]
            }
            .eraseToAnyPublisher()
    }

    var isFormCompleted: AnyPublisher<Bool, Never> {
        return self.passwordState
            .map({ passwordStates in
                return passwordStates.contains(PasswordState.valid)
            })
            .eraseToAnyPublisher()
    }

    init(title: String,
         password: String? = nil,
         userRegisterEnvelopUpdater: UserRegisterEnvelopUpdater) {

        self.title = title
        self.password = .init(password)

        self.userRegisterEnvelopUpdater = userRegisterEnvelopUpdater

        Publishers.CombineLatest(self.passwordState, self.password)
            .sink { passwordState, password in
                if passwordState.contains(.valid) {
                    self.userRegisterEnvelopUpdater.setPassword(password)
                }
                else {
                    self.userRegisterEnvelopUpdater.setPassword(nil)
                }
            }
            .store(in: &self.cancellables)
    }

    func setPassword(_ password: String) {
        self.password.send(password)
    }

}

class PasswordFormStepView: FormStepView {

    private lazy var passwordHeaderTextFieldView: HeaderTextFieldView = Self.createPasswordHeaderTextFieldView()
    private lazy var tipsContainerView: UIView = Self.createTipsContainerView()

    private lazy var tipsContainerStackView: UIStackView = Self.createTipsContainerStackView()

    private lazy var tipTitleLabel: UILabel = Self.createTipTitleLabel()
    private lazy var lengthTipLabel: UILabel = Self.createLengthTipLabel()
    private lazy var numbersTipLabel: UILabel = Self.createNumbersTipLabel()
    private lazy var uppercaseTipLabel: UILabel = Self.createUppercaseTipLabel()
    private lazy var lowercaseTipLabel: UILabel = Self.createLowercaseTipLabel()
    private lazy var symbolsTipLabel: UILabel = Self.createSymbolsTipLabel()


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

        self.tipsContainerView.addSubview(self.tipsContainerStackView)

        self.tipsContainerStackView.addArrangedSubview(self.tipTitleLabel)
        self.tipsContainerStackView.addArrangedSubview(self.lengthTipLabel)
        self.tipsContainerStackView.addArrangedSubview(self.uppercaseTipLabel)
        self.tipsContainerStackView.addArrangedSubview(self.lowercaseTipLabel)
        self.tipsContainerStackView.addArrangedSubview(self.numbersTipLabel)
        self.tipsContainerStackView.addArrangedSubview(self.symbolsTipLabel)


        self.stackView.addArrangedSubview(self.tipsContainerView)
        self.stackView.addArrangedSubview(self.passwordHeaderTextFieldView)

        NSLayoutConstraint.activate([
            self.tipsContainerView.leadingAnchor.constraint(equalTo: self.tipsContainerStackView.leadingAnchor),
            self.tipsContainerView.trailingAnchor.constraint(equalTo: self.tipsContainerStackView.trailingAnchor),
            self.tipsContainerView.topAnchor.constraint(equalTo: self.tipsContainerStackView.topAnchor),
            self.tipsContainerView.bottomAnchor.constraint(equalTo: self.tipsContainerStackView.bottomAnchor,constant: 16),

            self.tipTitleLabel.heightAnchor.constraint(greaterThanOrEqualToConstant: 20),
            self.numbersTipLabel.heightAnchor.constraint(greaterThanOrEqualToConstant: 20),
            self.uppercaseTipLabel.heightAnchor.constraint(greaterThanOrEqualToConstant: 20),
            self.lowercaseTipLabel.heightAnchor.constraint(greaterThanOrEqualToConstant: 20),
            self.symbolsTipLabel.heightAnchor.constraint(greaterThanOrEqualToConstant: 20),
            self.lengthTipLabel.heightAnchor.constraint(greaterThanOrEqualToConstant: 20),

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
            // .debounce(for: .seconds(1.5), scheduler: DispatchQueue.main)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] passwordStates in

                guard let self = self else { return }

                let allLabels = [self.lengthTipLabel,
                                 self.uppercaseTipLabel,
                                 self.lowercaseTipLabel,
                                 self.numbersTipLabel,
                                 self.symbolsTipLabel]

                if passwordStates.contains(.empty) {
                    for label in allLabels {
                        self.resetTipLabel(label: label)
                    }
                    return
                }

                var errorLabels: Set<UILabel> = []

                if passwordStates.contains(.short) || passwordStates.contains(.long) {
                    errorLabels.insert(self.lengthTipLabel)
                }

                if passwordStates.contains(.invalidChars) {
                    errorLabels.insert(self.symbolsTipLabel)
                }

                if passwordStates.contains(.onlyNumbers) {
                    errorLabels.insert(self.lowercaseTipLabel)
                    errorLabels.insert(self.uppercaseTipLabel)
                    errorLabels.insert(self.symbolsTipLabel)
                }

                if passwordStates.contains(.needLowercase) {
                    errorLabels.insert(self.lowercaseTipLabel)
                }
                if passwordStates.contains(.needUppercase) {
                    errorLabels.insert(self.uppercaseTipLabel)
                }
                if passwordStates.contains(.needNumber) {
                    errorLabels.insert(self.numbersTipLabel)
                }
                if passwordStates.contains(.needSpecial) {
                    errorLabels.insert(self.symbolsTipLabel)
                }

                for label in allLabels where !errorLabels.contains(label) {
                    self.markTipLabelCompleted(label: label)
                }

                for label in errorLabels {
                    self.markTipLabelError(label: label)
                }

//                for passwordState in passwordStates {
//                    switch passwordState {
//                    case .empty:
//                        self.passwordHeaderTextFieldView.hideTipAndError()
//                    case .short:
//                        self.passwordHeaderTextFieldView.showErrorOnField(text: "The password is too short", color: AppColor.inputError)
//                    case .long:
//                        self.passwordHeaderTextFieldView.showErrorOnField(text: "The password is too long", color: AppColor.inputError)
//                    case .invalidChars:
//                        self.passwordHeaderTextFieldView.showErrorOnField(text: "The password contains invalids characters", color: AppColor.inputError)
//                    case .onlyNumbers:
//                        self.passwordHeaderTextFieldView.showErrorOnField(text: "The password can not be all numbers", color: AppColor.inputError)
//                    case .needUppercase:
//                        self.passwordHeaderTextFieldView.showErrorOnField(text: "The password must contain an uppercase letter", color: AppColor.inputError)
//                    case .needLowercase:
//                        self.passwordHeaderTextFieldView.showErrorOnField(text: "The password must contain a lowercase letter", color: AppColor.inputError)
//                    case .needNumber:
//                        self.passwordHeaderTextFieldView.showErrorOnField(text: "The password must contain a number", color: AppColor.inputError)
//                    case .needSpecial:
//                        self.passwordHeaderTextFieldView.showErrorOnField(text: "The password must contain a special character (-!@$^&*)", color: AppColor.inputError)
//                    case .valid:
//                        self.passwordHeaderTextFieldView.hideTipAndError()
//                    }
//                }

            }
            .store(in: &self.cancellables)
    }

    public override func layoutSubviews() {
        super.layoutSubviews()
    }

    override func setupWithTheme() {
        super.setupWithTheme()

        self.tipTitleLabel.textColor = AppColor.textPrimary
        self.lengthTipLabel.textColor = AppColor.textPrimary
        self.uppercaseTipLabel.textColor = AppColor.textPrimary
        self.lowercaseTipLabel.textColor = AppColor.textPrimary
        self.numbersTipLabel.textColor = AppColor.textPrimary
        self.symbolsTipLabel.textColor = AppColor.textPrimary

        self.passwordHeaderTextFieldView.setViewColor(AppColor.inputBackground)
        self.passwordHeaderTextFieldView.setHeaderLabelColor(AppColor.inputTextTitle)
        self.passwordHeaderTextFieldView.setTextFieldColor(AppColor.inputText)
    }


    override func canPresentError(forFormStep formStep: FormStep) -> Bool {
        switch formStep {
        case .password: return true
        default: return false
        }
    }

    override func presentError(_ error: RegisterError, forFormStep formStep: FormStep) {
        if !self.canPresentError(forFormStep: formStep) { return }

        switch (error.field, error.error) {
        case ("password", "INVALID_LENGTH"):
            self.passwordHeaderTextFieldView.showErrorOnField(text: "This password has an invalid length", color: AppColor.alertError)
        case ("password", "INVALID_VALUE"):
            self.passwordHeaderTextFieldView.showErrorOnField(text: "Please enter a valid Password", color: AppColor.alertError)
        case ("password", _):
            self.passwordHeaderTextFieldView.showErrorOnField(text: "Please enter a valid Password", color: AppColor.alertError)
        default:
            ()
        }

    }

    private func resetTipLabel(label: UILabel) {
        label.alpha = 1.0
//        label.textColor = AppColor.textPrimary
//        let attributeString: NSMutableAttributedString = NSMutableAttributedString(string: label.text ?? "")
//        label.attributedText = attributeString
    }

    private func markTipLabelCompleted(label: UILabel) {
        UIView.animate(withDuration: 0.2) {
            label.alpha = 0.37
        }

//        label.textColor = AppColor.textPrimary
//        let attributeString: NSMutableAttributedString = NSMutableAttributedString(string: label.text ?? "")
//        attributeString.addAttribute(NSAttributedString.Key.strikethroughStyle, value: 2, range: NSRange(location: 0, length: attributeString.length))
//        label.attributedText = attributeString
    }

    private func markTipLabelError(label: UILabel) {
//        label.textColor = AppColor.alertError
//        let attributeString: NSMutableAttributedString = NSMutableAttributedString(string: label.text ?? "")
//        label.attributedText = attributeString

        UIView.animate(withDuration: 0.2) {
            label.alpha = 1.0
        }
    }

}

extension PasswordFormStepView {

    private static func createTipsContainerView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }

    private static func createTipsContainerStackView() -> UIStackView {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.distribution = .fillProportionally
        stackView.spacing = 2
        return stackView
    }

    private static func createTipTitleLabel() -> UILabel {
        let label = UILabel()
        label.font = AppFont.with(type: .semibold, size: 12)
        label.numberOfLines = 2
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "In order to protect your account your password must:"
        return label
    }

    private static func createNumbersTipLabel() -> UILabel {
        let label = UILabel()
        label.font = AppFont.with(type: .semibold, size: 12)
        label.numberOfLines = 2
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "• Contain at least one number"
        return label
    }

    private static func createUppercaseTipLabel() -> UILabel {
        let label = UILabel()
        label.font = AppFont.with(type: .semibold, size: 12)
        label.numberOfLines = 2
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "• Contain an uppercase character"
        return label
    }

    private static func createLowercaseTipLabel() -> UILabel {
        let label = UILabel()
        label.font = AppFont.with(type: .semibold, size: 12)
        label.numberOfLines = 2
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "• Contain a lowercase character"
        return label
    }

    private static func createSymbolsTipLabel() -> UILabel {
        let label = UILabel()
        label.font = AppFont.with(type: .semibold, size: 12)
        label.numberOfLines = 2
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "• Be alphanumeric with at least 1 symbol from -!@^$&*"
        return label
    }

    private static func createLengthTipLabel() -> UILabel {
        let label = UILabel()
        label.font = AppFont.with(type: .semibold, size: 12)
        label.numberOfLines = 2
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "• Have length between 8 and 16 characters"
        return label
    }

    private static func createPasswordHeaderTextFieldView() -> HeaderTextFieldView {
        let headerTextFieldView = HeaderTextFieldView()
        headerTextFieldView.setTextFieldFont(AppFont.with(type: .semibold, size: 16))
        headerTextFieldView.setHeaderLabelFont(AppFont.with(type: .semibold, size: 16))
        headerTextFieldView.translatesAutoresizingMaskIntoConstraints = false
        return headerTextFieldView
    }

}
