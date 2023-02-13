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

class PromoCodeFormStepViewModel {

    let title: String
    let promoCode: CurrentValueSubject<String?, Never>
    var godfatherCode: CurrentValueSubject<String?, Never>

    private var userRegisterEnvelopUpdater: UserRegisterEnvelopUpdater

    init(title: String,
         promoCode: String?,
         godfatherCode: String?,
         userRegisterEnvelopUpdater: UserRegisterEnvelopUpdater) {

        self.title = title
        self.promoCode = .init(promoCode)
        self.godfatherCode = .init(godfatherCode)
        self.userRegisterEnvelopUpdater = userRegisterEnvelopUpdater
    }

    func setPromoCode(_ promoCode: String) {
        self.promoCode.send(promoCode)
        self.userRegisterEnvelopUpdater.setPromoCode(promoCode)
    }

    func setGodfatherCode(_ godfatherCode: String) {
        self.godfatherCode.send(godfatherCode)
        self.userRegisterEnvelopUpdater.setGodfatherCode(godfatherCode)
    }

}

class PromoCodeFormStepView: FormStepView {

    private lazy var promoCodeHeaderTextFieldView: HeaderTextFieldView = Self.createPromoCodeHeaderTextFieldView()
    private lazy var godfatherHeaderTextFieldView: HeaderTextFieldView = Self.createGodfatherHeaderTextFieldView()

    let viewModel: PromoCodeFormStepViewModel

    private var cancellables = Set<AnyCancellable>()

    init(viewModel: PromoCodeFormStepViewModel) {
        self.viewModel = viewModel

        super.init()

        self.configureSubviews()
    }

    func configureSubviews() {

        self.stackView.addArrangedSubview(self.promoCodeHeaderTextFieldView)
        self.stackView.addArrangedSubview(self.godfatherHeaderTextFieldView)

        NSLayoutConstraint.activate([
            self.promoCodeHeaderTextFieldView.heightAnchor.constraint(equalToConstant: 80),
            self.godfatherHeaderTextFieldView.heightAnchor.constraint(equalToConstant: 80),

        ])

        self.titleLabel.text = self.viewModel.title

        self.promoCodeHeaderTextFieldView.setPlaceholderText("Promo Code")
        self.godfatherHeaderTextFieldView.setPlaceholderText("Godfather")


        self.promoCodeHeaderTextFieldView.setReturnKeyType(.next)
        self.promoCodeHeaderTextFieldView.didTapReturn = { [weak self] in
            self?.godfatherHeaderTextFieldView.becomeFirstResponder()
        }

        self.godfatherHeaderTextFieldView.setReturnKeyType(.continue)
        self.godfatherHeaderTextFieldView.didTapReturn = { [weak self] in
            self?.godfatherHeaderTextFieldView.resignFirstResponder()
        }

        self.promoCodeHeaderTextFieldView.setText(self.viewModel.promoCode.value ?? "")
        self.godfatherHeaderTextFieldView.setText(self.viewModel.godfatherCode.value ?? "")

        self.promoCodeHeaderTextFieldView.textPublisher
            .sink { [weak self] text in
                self?.viewModel.setPromoCode(text)
            }
            .store(in: &self.cancellables)

        self.godfatherHeaderTextFieldView.textPublisher
            .sink { [weak self] text in
                self?.viewModel.setGodfatherCode(text)
            }
            .store(in: &self.cancellables)

    }

    public override func layoutSubviews() {
        super.layoutSubviews()
    }

    override func setupWithTheme() {
        super.setupWithTheme()

        self.promoCodeHeaderTextFieldView.setViewColor(AppColor.inputBackground)
        self.promoCodeHeaderTextFieldView.setHeaderLabelColor(AppColor.inputTextTitle)
        self.promoCodeHeaderTextFieldView.setTextFieldColor(AppColor.inputText)

        self.godfatherHeaderTextFieldView.setViewColor(AppColor.inputBackground)
        self.godfatherHeaderTextFieldView.setHeaderLabelColor(AppColor.inputTextTitle)
        self.godfatherHeaderTextFieldView.setTextFieldColor(AppColor.inputText)

    }

    override func canPresentError(forFormStep formStep: FormStep) -> Bool {
        switch formStep {
        case .promoCodes: return true
        default: return false
        }
    }

    override func presentError(_ error: RegisterError, forFormStep formStep: FormStep) {
        if !self.canPresentError(forFormStep: formStep) { return }

        switch (error.field, error.error) {
        case ("bonusCode", "INVALID_LENGTH"):
            self.promoCodeHeaderTextFieldView.showErrorOnField(text: "Promo Code is too long", color: AppColor.alertError)
        case ("bonusCode", _):
            self.promoCodeHeaderTextFieldView.showErrorOnField(text: "Please enter a valid Promo Code", color: AppColor.alertError)
        default:
            ()
        }
    }

}

extension PromoCodeFormStepView {

    fileprivate static func createPromoCodeHeaderTextFieldView() -> HeaderTextFieldView {
        let headerTextFieldView = HeaderTextFieldView()
        headerTextFieldView.setTextFieldFont(AppFont.with(type: .semibold, size: 16))
        headerTextFieldView.setHeaderLabelFont(AppFont.with(type: .semibold, size: 16))
        headerTextFieldView.translatesAutoresizingMaskIntoConstraints = false
        return headerTextFieldView
    }

    fileprivate static func createGodfatherHeaderTextFieldView() -> HeaderTextFieldView {
        let headerTextFieldView = HeaderTextFieldView()
        headerTextFieldView.setTextFieldFont(AppFont.with(type: .semibold, size: 16))
        headerTextFieldView.setHeaderLabelFont(AppFont.with(type: .semibold, size: 16))
        headerTextFieldView.translatesAutoresizingMaskIntoConstraints = false
        return headerTextFieldView
    }

}
