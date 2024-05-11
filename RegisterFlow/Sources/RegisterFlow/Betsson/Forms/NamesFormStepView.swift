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
import HeaderTextField

struct NamesFormStepViewModel {

    let title: String

    let firstName: CurrentValueSubject<String?, Never>
    let lastName: CurrentValueSubject<String?, Never>
    let middleName: CurrentValueSubject<String?, Never>

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
         middleName: String? = nil,
         lastName: String? = nil,
         userRegisterEnvelopUpdater: UserRegisterEnvelopUpdater) {

        self.title = title
        self.firstName = .init(firstName)
        self.lastName = .init(lastName)
        self.middleName = .init(middleName)
        
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
    
    func setMiddleName(_ middleName: String) {
        self.middleName.send(middleName)
        self.userRegisterEnvelopUpdater.setMiddleName(middleName)
    }

}

class NamesFormStepView: FormStepView {

    private lazy var descriptionLabel: UILabel = Self.createDescriptionLabel()
    private lazy var firstNameHeaderTextFieldView: HeaderTextFieldView = Self.createFirstNameHeaderTextFieldView()
    private lazy var lastNameHeaderTextFieldView: HeaderTextFieldView = Self.createLastNameHeaderTextFieldView()
    private lazy var middleNameHeaderTextFieldView: HeaderTextFieldView = Self.createMiddleNameHeaderTextFieldView()
    private lazy var middleNameView: UIView = Self.createMiddleNameView()
    private lazy var middleNameTipView: UIView = Self.createMiddleNameTipView()
    private lazy var middleNameTipIconImageView: UIImageView = Self.createMiddleNameTipIconImageView()
    private lazy var middleNameTipLabel: UILabel = Self.createMiddleNameTipLabel()

    private let viewModel: NamesFormStepViewModel

    private var cancellables = Set<AnyCancellable>()
    
    private var showMiddleNameTip: Bool = true {
        didSet {
            self.middleNameTipView.isHidden = !showMiddleNameTip
        }
    }

    init(viewModel: NamesFormStepViewModel) {
        self.viewModel = viewModel

        super.init()

        self.configureSubviews()
        
        self.showMiddleNameTip = true
        
    }

    override var isFormCompleted: AnyPublisher<Bool, Never> {
        return self.viewModel.isFormCompleted
    }

    func configureSubviews() {
        
        self.stackView.addArrangedSubview(self.descriptionLabel)
        
        self.stackView.addArrangedSubview(self.firstNameHeaderTextFieldView)
        
        self.stackView.addArrangedSubview(self.middleNameView)
        
        self.middleNameView.addSubview(self.middleNameHeaderTextFieldView)
        self.middleNameView.addSubview(self.middleNameTipView)
        
        self.middleNameTipView.addSubview(self.middleNameTipIconImageView)
        self.middleNameTipView.addSubview(self.middleNameTipLabel)
        
        self.stackView.addArrangedSubview(self.lastNameHeaderTextFieldView)
        
        NSLayoutConstraint.activate([
            self.descriptionLabel.heightAnchor.constraint(greaterThanOrEqualToConstant: 30),
            self.descriptionLabel.topAnchor.constraint(equalTo: self.stackView.topAnchor, constant: -20),
            
            self.firstNameHeaderTextFieldView.heightAnchor.constraint(equalToConstant: 80),
            
            self.middleNameHeaderTextFieldView.leadingAnchor.constraint(equalTo: self.middleNameView.leadingAnchor),
            self.middleNameHeaderTextFieldView.trailingAnchor.constraint(equalTo: self.middleNameView.trailingAnchor),
            self.middleNameHeaderTextFieldView.topAnchor.constraint(equalTo: self.middleNameView.topAnchor),
            self.middleNameHeaderTextFieldView.heightAnchor.constraint(equalToConstant: 80),
            
            self.middleNameTipView.leadingAnchor.constraint(equalTo: self.middleNameView.leadingAnchor),
            self.middleNameTipView.trailingAnchor.constraint(equalTo: self.middleNameView.trailingAnchor),
            self.middleNameTipView.topAnchor.constraint(equalTo: self.middleNameHeaderTextFieldView.bottomAnchor, constant: -16),
            self.middleNameTipView.bottomAnchor.constraint(equalTo: self.middleNameView.bottomAnchor),
            self.middleNameTipView.heightAnchor.constraint(greaterThanOrEqualToConstant: 30),
            
            self.middleNameTipIconImageView.leadingAnchor.constraint(equalTo: self.middleNameTipView.leadingAnchor),
            self.middleNameTipIconImageView.topAnchor.constraint(equalTo: self.middleNameTipView.topAnchor),
            self.middleNameTipIconImageView.widthAnchor.constraint(equalToConstant: 16),
            self.middleNameTipIconImageView.heightAnchor.constraint(equalTo: self.middleNameTipIconImageView.widthAnchor),
            
            self.middleNameTipLabel.leadingAnchor.constraint(equalTo: self.middleNameTipIconImageView.trailingAnchor, constant: 5),
            self.middleNameTipLabel.trailingAnchor.constraint(equalTo: self.middleNameTipView.trailingAnchor),
            self.middleNameTipLabel.topAnchor.constraint(equalTo: self.middleNameTipView.topAnchor),
            self.middleNameTipLabel.bottomAnchor.constraint(equalTo: self.middleNameTipView.bottomAnchor),
            
            self.lastNameHeaderTextFieldView.heightAnchor.constraint(equalToConstant: 80),
        ])
        
        self.titleLabel.text = self.viewModel.title
        
        self.firstNameHeaderTextFieldView.setContextType(.givenName)
        self.middleNameHeaderTextFieldView.setContextType(.givenName)
        self.lastNameHeaderTextFieldView.setContextType(.familyName)

        self.firstNameHeaderTextFieldView.setReturnKeyType(.next)
        self.firstNameHeaderTextFieldView.setPlaceholderText(Localization.localized("first_name"))
        self.firstNameHeaderTextFieldView.didTapReturn = { [weak self] in
            self?.lastNameHeaderTextFieldView.becomeFirstResponder()
        }
        self.firstNameHeaderTextFieldView.keyboardType = .alphabet
        self.firstNameHeaderTextFieldView.isAlphabetMode = true
        
        self.middleNameHeaderTextFieldView.setReturnKeyType(.next)
        self.middleNameHeaderTextFieldView.setPlaceholderText(Localization.localized("middle_name"))
        self.middleNameHeaderTextFieldView.didTapReturn = { [weak self] in
            self?.middleNameHeaderTextFieldView.becomeFirstResponder()
        }
        self.middleNameHeaderTextFieldView.keyboardType = .alphabet
        self.middleNameHeaderTextFieldView.isMiddleNameMode = true
        
        self.lastNameHeaderTextFieldView.setReturnKeyType(.continue)
        self.lastNameHeaderTextFieldView.setPlaceholderText(Localization.localized("last_name"))
        self.lastNameHeaderTextFieldView.didTapReturn = { [weak self] in
            self?.lastNameHeaderTextFieldView.resignFirstResponder()
        }
        self.lastNameHeaderTextFieldView.keyboardType = .alphabet
        self.lastNameHeaderTextFieldView.isAlphabetMode = true
        
        self.firstNameHeaderTextFieldView.setText(self.viewModel.firstName.value ?? "")
        self.middleNameHeaderTextFieldView.setText(self.viewModel.middleName.value ?? "")
        self.lastNameHeaderTextFieldView.setText(self.viewModel.lastName.value ?? "")

        self.firstNameHeaderTextFieldView.textPublisher
            .sink { [weak self] text in
                self?.viewModel.setFirstName(text)
            }
            .store(in: &self.cancellables)
        
        self.middleNameHeaderTextFieldView.textPublisher
            .sink { [weak self] text in
                self?.viewModel.setMiddleName(text)
            }
            .store(in: &self.cancellables)
        
        self.middleNameHeaderTextFieldView.didBeginEditing = { [weak self]  in
            if let showMiddleNameTip = self?.showMiddleNameTip {
                if !showMiddleNameTip {
                    self?.showMiddleNameTip = true
                }
            }
        }


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
        
        self.descriptionLabel.textColor = AppColor.textSecondary

        self.firstNameHeaderTextFieldView.setViewColor(AppColor.inputBackground)
        self.firstNameHeaderTextFieldView.setHeaderLabelColor(AppColor.inputTextTitle)
        self.firstNameHeaderTextFieldView.setTextFieldColor(AppColor.inputText)
        
        self.middleNameHeaderTextFieldView.setViewColor(AppColor.inputBackground)
        self.middleNameHeaderTextFieldView.setHeaderLabelColor(AppColor.inputTextTitle)
        self.middleNameHeaderTextFieldView.setTextFieldColor(AppColor.inputText)

        self.lastNameHeaderTextFieldView.setViewColor(AppColor.inputBackground)
        self.lastNameHeaderTextFieldView.setHeaderLabelColor(AppColor.inputTextTitle)
        self.lastNameHeaderTextFieldView.setTextFieldColor(AppColor.inputText)
        
        self.middleNameView.backgroundColor = .clear
        
        self.middleNameTipView.backgroundColor = .clear
        
        self.middleNameTipIconImageView.tintColor = AppColor.iconSecondary
        
        self.middleNameTipLabel.textColor = AppColor.textSecondary
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
            self.firstNameHeaderTextFieldView.showError(withMessage: Localization.localized("name_invalid_length"))
        case ("lastName", "INVALID_LENGTH"):
            self.lastNameHeaderTextFieldView.showError(withMessage: Localization.localized("last_name_invalid_length"))
        case ("middleName", "INVALID_LENGTH"):
            self.middleNameHeaderTextFieldView.showError(withMessage: Localization.localized("name_invalid_length"))
            self.showMiddleNameTip = false
        case ("firstName", _):
            self.firstNameHeaderTextFieldView.showError(withMessage: Localization.localized("invalid_name"))
        case ("lastName", _):
            self.lastNameHeaderTextFieldView.showError(withMessage: Localization.localized("invalid_last_name"))
        case ("middleName", _):
            self.middleNameHeaderTextFieldView.showError(withMessage: Localization.localized("invalid_name"))
            self.showMiddleNameTip = false
        default:
            ()
        }
    }

}

extension NamesFormStepView {
    
    fileprivate static func createDescriptionLabel() -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = Localization.localized("signup_names_info")
        label.font = AppFont.with(type: .semibold, size: 12)
        label.numberOfLines = 0
        return label
    }

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
    
    fileprivate static func createMiddleNameHeaderTextFieldView() -> HeaderTextFieldView {
        let headerTextFieldView = HeaderTextFieldView()
        headerTextFieldView.setTextFieldFont(AppFont.with(type: .semibold, size: 16))
        headerTextFieldView.setHeaderLabelFont(AppFont.with(type: .semibold, size: 16))
        headerTextFieldView.translatesAutoresizingMaskIntoConstraints = false
        return headerTextFieldView
    }
    
    fileprivate static func createMiddleNameView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }
    
    fileprivate static func createMiddleNameTipView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }
    
    fileprivate static func createMiddleNameTipIconImageView() -> UIImageView {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.image = UIImage(named: "info_blue_icon")?.withRenderingMode(.alwaysTemplate)
        imageView.tintColor = AppColor.alertSuccess
        imageView.contentMode = .scaleAspectFit
        return imageView
    }
    
    fileprivate static func createMiddleNameTipLabel() -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = Localization.localized("middle_name_infope")
        label.font = AppFont.with(type: .regular, size: 11)
        label.numberOfLines = 0
        return label
    }

}
