//
//  AddressFormStepView.swift
//
//
//  Created by Ruben Roques on 16/01/2023.
//

import UIKit
import Extensions
import Combine
import Theming

class GenderFormStepViewModel {

    let title: String

    var selectedGender: CurrentValueSubject<Gender?, Never> = .init(nil)

    private var userRegisterEnvelopUpdater: UserRegisterEnvelopUpdater

    enum Gender {
        case male
        case female
    }

    private var shouldShowGenderErrorMessageSubject: CurrentValueSubject<Bool, Never> = .init(false)
    var shouldShowGenderErrorMessage: AnyPublisher<Bool, Never> {
        return self.shouldShowGenderErrorMessageSubject.eraseToAnyPublisher()
    }

    var isFormCompleted: AnyPublisher<Bool, Never> {
        return self.selectedGender.map { genderString -> Bool in
            if genderString != nil {
                return true
            }
            return false
        }.eraseToAnyPublisher()
    }

    init(title: String,
         selectedGender: Gender?,
         userRegisterEnvelopUpdater: UserRegisterEnvelopUpdater) {

        self.title = title
        self.userRegisterEnvelopUpdater = userRegisterEnvelopUpdater

        switch selectedGender {
        case .none:
            self.selectedGender = .init(nil)
        case .some(let wrapped):
            switch wrapped {
            case .male:
                self.selectedGender = .init(.male)
            case .female:
                self.selectedGender = .init(.female)
            }
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 5.0) { [weak self] in
            self?.checkGenderSelected()
        }

    }

    func setGender(_ gender: Gender) {
        self.selectedGender.send(gender)

        switch gender {
        case .male:
            self.userRegisterEnvelopUpdater.setGender(UserRegisterEnvelop.Gender.male)
            self.shouldShowGenderErrorMessageSubject.send(false)
        case .female:
            self.userRegisterEnvelopUpdater.setGender(UserRegisterEnvelop.Gender.female)
            self.shouldShowGenderErrorMessageSubject.send(false)
        }

    }

    private func checkGenderSelected() {
        if self.selectedGender.value == nil {
            self.shouldShowGenderErrorMessageSubject.send(true)
        }
    }

}

class GenderFormStepView: FormStepView {

    private lazy var internalStackView: UIStackView = Self.createInternalStackView()

    private lazy var maleButton: UIButton = Self.createMaleButton()
    private lazy var femaleButton: UIButton = Self.createFemaleButton()

    private lazy var genderErrorLabel: UILabel = Self.createGenderErrorLabel()

    private lazy var buttonsContainerView: UIView = Self.createButtonsContainerView()
    private lazy var buttonStackView: UIStackView = Self.createStackView()

    override var isFormCompleted: AnyPublisher<Bool, Never> {
        return self.viewModel.isFormCompleted
    }

    let viewModel: GenderFormStepViewModel

    private var cancellables = Set<AnyCancellable>()

    init(viewModel: GenderFormStepViewModel) {
        self.viewModel = viewModel

        super.init()

        self.configureSubviews()
    }

    func configureSubviews() {

        self.titleLabel.text = self.viewModel.title

        self.maleButton.addTarget(self, action: #selector(self.didTapMaleButton), for: .primaryActionTriggered)
        self.femaleButton.addTarget(self, action: #selector(self.didTapFemaleButton), for: .primaryActionTriggered)

        self.buttonStackView.addArrangedSubview(self.maleButton)
        self.buttonStackView.addArrangedSubview(self.femaleButton)

        self.buttonsContainerView.addSubview(self.buttonStackView)

        self.internalStackView.addArrangedSubview(self.buttonsContainerView)
        self.internalStackView.addArrangedSubview(self.genderErrorLabel)

        self.stackView.addArrangedSubview(self.internalStackView)

        self.genderErrorLabel.isHidden = true

        NSLayoutConstraint.activate([
            self.maleButton.heightAnchor.constraint(equalToConstant: 40),
            self.femaleButton.heightAnchor.constraint(equalToConstant: 40),
            self.maleButton.widthAnchor.constraint(greaterThanOrEqualToConstant: 80),
            self.femaleButton.widthAnchor.constraint(greaterThanOrEqualToConstant: 80),

            self.genderErrorLabel.heightAnchor.constraint(equalToConstant: 27),

            self.buttonStackView.leadingAnchor.constraint(equalTo: self.buttonsContainerView.leadingAnchor),
            self.buttonStackView.topAnchor.constraint(equalTo: self.buttonsContainerView.topAnchor),
            self.buttonStackView.bottomAnchor.constraint(equalTo: self.buttonsContainerView.bottomAnchor),
        ])

        if let gender = self.viewModel.selectedGender.value {
            switch gender {
            case .male:
                self.didTapMaleButton()
            case .female:
                self.didTapFemaleButton()
            }
        }

        self.viewModel
            .shouldShowGenderErrorMessage
            .sink(receiveValue: { shouldShowGenderErrorMessage in
                self.genderErrorLabel.isHidden = !shouldShowGenderErrorMessage
            })
            .store(in: &self.cancellables)
    }

    override func setupWithTheme() {
        super.setupWithTheme()

        self.maleButton.imageView?.tintColor = AppColor.textSecondary
        self.femaleButton.imageView?.tintColor = AppColor.textSecondary

        self.maleButton.setTitleColor(AppColor.textSecondary, for: .normal)
        self.femaleButton.setTitleColor(AppColor.textSecondary, for: .normal)
        self.maleButton.setBackgroundColor(AppColor.backgroundSecondary, for: .normal)
        self.femaleButton.setBackgroundColor(AppColor.backgroundSecondary, for: .normal)

        self.maleButton.imageView?.tintColor = AppColor.textSecondary
        self.femaleButton.imageView?.tintColor = AppColor.textSecondary

        self.maleButton.layer.borderColor = AppColor.highlightPrimary.cgColor
        self.femaleButton.layer.borderColor = AppColor.highlightPrimary.cgColor

        self.maleButton.setTitleColor(AppColor.textPrimary, for: .selected)
        self.femaleButton.setTitleColor(AppColor.textPrimary, for: .selected)

        self.maleButton.setBackgroundColor(AppColor.backgroundTertiary, for: .selected)
        self.femaleButton.setBackgroundColor(AppColor.backgroundTertiary, for: .selected)
    }

    @objc func didTapMaleButton() {
        self.maleButton.isSelected = true
        self.femaleButton.isSelected = false

        self.viewModel.setGender(.male)

        self.maleButton.imageView?.tintColor = AppColor.textPrimary
        self.femaleButton.imageView?.tintColor = AppColor.textSecondary

        self.maleButton.layer.borderWidth = 2
        self.femaleButton.layer.borderWidth = 0
    }

    @objc func didTapFemaleButton() {
        self.maleButton.isSelected = false
        self.femaleButton.isSelected = true

        self.viewModel.setGender(.female)

        self.maleButton.imageView?.tintColor = AppColor.textSecondary
        self.femaleButton.imageView?.tintColor = AppColor.textPrimary

        self.maleButton.layer.borderWidth = 0
        self.femaleButton.layer.borderWidth = 2
    }

    override func canPresentError(forFormStep formStep: FormStep) -> Bool {
        switch formStep {
        case .gender: return true
        default: return false
        }
    }

    override func presentError(_ error: RegisterError, forFormStep formStep: FormStep) {
        if !self.canPresentError(forFormStep: formStep) { return }
    }

}

extension GenderFormStepView {

    fileprivate static func createMaleButton() -> UIButton {
        let button = UIButton()

        let image = UIImage(named: "GenderMale", in: Bundle.module, with: nil)?.withRenderingMode(.alwaysTemplate)
        button.setImage(image, for: .normal)

        button.setTitle(Localization.localized("male"), for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16)
        button.layer.cornerRadius = 20
        button.clipsToBounds = true
        button.translatesAutoresizingMaskIntoConstraints = false

        button.setInsets(forContentPadding: UIEdgeInsets(top: 2, left: 12, bottom: 2, right: 12),
                         imageTitlePadding: 6)
        return button
    }

    fileprivate static func createFemaleButton() -> UIButton {
        let button = UIButton()

        let image = UIImage(named: "GenderFemale", in: Bundle.module, with: nil)?.withRenderingMode(.alwaysTemplate)
        button.setImage(image, for: .normal)

        button.setInsets(forContentPadding: UIEdgeInsets(top: 2, left: 10, bottom: 2, right: 12),
                         imageTitlePadding: 6)

        button.setTitle(Localization.localized("female"), for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16)
        button.layer.cornerRadius = 20
        button.clipsToBounds = true
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }

    fileprivate static func createGenderErrorLabel() -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 2
        label.font = AppFont.with(type: .semibold, size: 12)
        label.text = "  " + Localization.localized("invalid_gender")
        label.textColor = AppColor.alertError
        return label
    }

    fileprivate static func createButtonsContainerView() -> UIView {
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


    fileprivate static func createInternalStackView() -> UIStackView {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 8
        stackView.distribution = .fill
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }


}


