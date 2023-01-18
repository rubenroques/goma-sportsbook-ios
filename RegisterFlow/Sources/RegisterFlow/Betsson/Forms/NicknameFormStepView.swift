//
//  AddressFormStepView.swift
//  
//
//  Created by Ruben Roques on 16/01/2023.
//

import UIKit
import Extensions

struct NicknameFormStepViewModel {

    let title: String
    let nickname: String?
    let nicknamePlaceholder: String

}

class NicknameFormStepView: FormStepView {

    private lazy var nicknameHeaderTextFieldView: HeaderTextFieldView = Self.createNicknameHeaderTextFieldView()
    private lazy var suggestedNicknamesStackview: UIStackView = Self.createSuggestedNicknamesStackview()

    let viewModel: NicknameFormStepViewModel

    init(viewModel: NicknameFormStepViewModel) {
        self.viewModel = viewModel

        super.init()

        self.configureSubviews()
    }

    func configureSubviews() {
        self.stackView.addArrangedSubview(self.nicknameHeaderTextFieldView)

        self.titleLabel.text = self.viewModel.title
        self.nicknameHeaderTextFieldView.setPlaceholderText(self.viewModel.nicknamePlaceholder)
    }

    public override func layoutSubviews() {
        super.layoutSubviews()
    }

    override func setupWithTheme() {
        super.setupWithTheme()

    }

}

extension NicknameFormStepView {

    fileprivate static func createNicknameHeaderTextFieldView() -> HeaderTextFieldView {
        let headerTextFieldView = HeaderTextFieldView()
        headerTextFieldView.translatesAutoresizingMaskIntoConstraints = false
        return headerTextFieldView
    }

    fileprivate static func createSuggestedNicknamesStackview() -> UIStackView {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.distribution = .fill
        stackView.spacing = 8
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }

}
