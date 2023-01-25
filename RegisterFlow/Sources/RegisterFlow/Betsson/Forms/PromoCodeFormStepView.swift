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

struct PromoCodeFormStepViewModel {

    let title: String

}

class PromoCodeFormStepView: FormStepView {

    private lazy var promoCodeHeaderTextFieldView: HeaderTextFieldView = Self.createPromoCodeHeaderTextFieldView()
    private lazy var godfatherHeaderTextFieldView: HeaderTextFieldView = Self.createGodfatherHeaderTextFieldView()

    let viewModel: PromoCodeFormStepViewModel

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

    }

    public override func layoutSubviews() {
        super.layoutSubviews()
    }

    override func setupWithTheme() {
        super.setupWithTheme()

        self.promoCodeHeaderTextFieldView.backgroundColor = AppColor.backgroundPrimary
        self.promoCodeHeaderTextFieldView.setHeaderLabelColor(AppColor.inputTextTitle)
        self.promoCodeHeaderTextFieldView.setTextFieldColor(AppColor.inputText)

        self.godfatherHeaderTextFieldView.backgroundColor = AppColor.backgroundPrimary
        self.godfatherHeaderTextFieldView.setHeaderLabelColor(AppColor.inputTextTitle)
        self.godfatherHeaderTextFieldView.setTextFieldColor(AppColor.inputText)

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
