//
//  ConfirmationCodeFormStepView.swift
//  
//
//  Created by Ruben Roques on 25/01/2023.
//

import Foundation
import UIKit
import Theming
import Extensions
import Combine

class ConfirmationCodeFormStepViewModel {

    let title: String

    var code: CurrentValueSubject<String?, Never>

    private var userRegisterEnvelopUpdater: UserRegisterEnvelopUpdater

    init(title: String,
         userRegisterEnvelopUpdater: UserRegisterEnvelopUpdater) {

        self.title = title
        self.code = .init(nil)

        self.userRegisterEnvelopUpdater = userRegisterEnvelopUpdater
    }

    var isFormCompleted: AnyPublisher<Bool, Never> {
        return self.code
            .map { code in
                return (code ?? "").count > 0
            }
            .eraseToAnyPublisher()
    }

}

class ConfirmationCodeFormStepView: FormStepView {

    public var didUpdateConfirmationCode: (String) -> Void = { _ in }

    private lazy var codeHeaderTextFieldView: HeaderTextFieldView = Self.createCodeHeaderTextFieldView()

    private let viewModel: ConfirmationCodeFormStepViewModel
    private var cancellables = Set<AnyCancellable>()

    override var isFormCompleted: AnyPublisher<Bool, Never> {
        return self.viewModel.isFormCompleted
    }

    init(viewModel: ConfirmationCodeFormStepViewModel) {
        self.viewModel = viewModel

        super.init()

        self.configureSubviews()
    }

    func configureSubviews() {


        self.stackView.addArrangedSubview(self.codeHeaderTextFieldView)

        NSLayoutConstraint.activate([
            self.codeHeaderTextFieldView.heightAnchor.constraint(equalToConstant: 80),
        ])

        self.titleLabel.text = self.viewModel.title

        self.codeHeaderTextFieldView.setPlaceholderText("Confirmation Code")

        self.codeHeaderTextFieldView.setReturnKeyType(.next)
        self.codeHeaderTextFieldView.didTapReturn = { [weak self] in
            self?.codeHeaderTextFieldView.resignFirstResponder()
        }

        self.codeHeaderTextFieldView.setText(self.viewModel.code.value ?? "")

        self.codeHeaderTextFieldView.textPublisher
            .sink { [weak self] text in
                self?.didUpdateConfirmationCode(text)
                self?.viewModel.code.send(text)
            }
            .store(in: &self.cancellables)
    }

    public override func layoutSubviews() {
        super.layoutSubviews()
    }

    override func setupWithTheme() {
        super.setupWithTheme()

        self.codeHeaderTextFieldView.backgroundColor = AppColor.backgroundPrimary
        self.codeHeaderTextFieldView.setHeaderLabelColor(AppColor.inputTextTitle)
        self.codeHeaderTextFieldView.setTextFieldColor(AppColor.inputText)
    }

}

extension ConfirmationCodeFormStepView {

    fileprivate static func createCodeHeaderTextFieldView() -> HeaderTextFieldView {
        let headerTextFieldView = HeaderTextFieldView()
        headerTextFieldView.setTextFieldFont(AppFont.with(type: .semibold, size: 16))
        headerTextFieldView.setHeaderLabelFont(AppFont.with(type: .semibold, size: 16))
        headerTextFieldView.translatesAutoresizingMaskIntoConstraints = false
        return headerTextFieldView
    }

}
