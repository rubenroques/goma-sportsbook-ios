//
//  AddressFormStepView.swift
//  
//
//  Created by Ruben Roques on 16/01/2023.
//

import UIKit
import Extensions

struct GenderFormStepViewModel {

    let title: String
    let selectedGender: Int?

}

class GenderFormStepView: FormStepView {

    private lazy var maleButton: UIButton = Self.createMaleButton()
    private lazy var femaleButton: UIButton = Self.createFemaleButton()

    private lazy var stackContainerView: UIView = Self.createStackContainerView()
    private lazy var buttonStackView: UIStackView = Self.createStackView()

    let viewModel: GenderFormStepViewModel

    init(viewModel: GenderFormStepViewModel) {
        self.viewModel = viewModel

        super.init()

        self.configureSubviews()
    }

    func configureSubviews() {

        self.titleLabel.text = self.viewModel.title

        self.maleButton.addTarget(self, action: #selector(self.didTapMaleButton), for: .primaryActionTriggered)
        self.femaleButton.addTarget(self, action: #selector(self.didTapFemaleButton), for: .primaryActionTriggered)

        self.stackView.addArrangedSubview(self.stackContainerView)
        self.stackContainerView.addSubview(self.buttonStackView)

        self.buttonStackView.addArrangedSubview(self.maleButton)
        self.buttonStackView.addArrangedSubview(self.femaleButton)

        NSLayoutConstraint.activate([
            self.maleButton.heightAnchor.constraint(equalToConstant: 40),
            self.femaleButton.heightAnchor.constraint(equalToConstant: 40),
            self.maleButton.widthAnchor.constraint(greaterThanOrEqualToConstant: 80),
            self.femaleButton.widthAnchor.constraint(greaterThanOrEqualToConstant: 80),

            self.buttonStackView.leadingAnchor.constraint(equalTo: self.stackContainerView.leadingAnchor),
            self.buttonStackView.topAnchor.constraint(equalTo: self.stackContainerView.topAnchor),
            self.buttonStackView.bottomAnchor.constraint(equalTo: self.stackContainerView.bottomAnchor),
        ])
    }

    override func setupWithTheme() {
        super.setupWithTheme()

        self.maleButton.setTitleColor(.white, for: .normal)
        self.femaleButton.setTitleColor(.white, for: .normal)
        self.maleButton.setBackgroundColor(.darkGray, for: .normal)
        self.femaleButton.setBackgroundColor(.darkGray, for: .normal)

        self.maleButton.setTitleColor(.darkGray, for: .selected)
        self.femaleButton.setTitleColor(.darkGray, for: .selected)
        self.maleButton.setBackgroundColor(.lightGray, for: .selected)
        self.femaleButton.setBackgroundColor(.lightGray, for: .selected)
    }

    @objc func didTapMaleButton() {
        self.maleButton.isSelected = true
        self.femaleButton.isSelected = false
    }

    @objc func didTapFemaleButton() {
        self.maleButton.isSelected = false
        self.femaleButton.isSelected = true
    }

}

extension GenderFormStepView {

    fileprivate static func createMaleButton() -> UIButton {
        let button = UIButton()
        button.setTitle("Male", for: .normal)
        button.layer.cornerRadius = 20
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }

    fileprivate static func createFemaleButton() -> UIButton {
        let button = UIButton()
        button.setTitle("Female", for: .normal)
        button.layer.cornerRadius = 20
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }

    fileprivate static func createStackContainerView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }

    fileprivate static func createStackView() -> UIStackView {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.spacing = 16
        stackView.distribution = .fill
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }

}
