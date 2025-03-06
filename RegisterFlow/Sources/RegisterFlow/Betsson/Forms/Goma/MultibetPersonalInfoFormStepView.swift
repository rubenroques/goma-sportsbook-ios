//
//  MultibetPersonalInfoFormStepView.swift
//
//
//  Created by André Lascas on 08/01/2024.
//

import UIKit
import Theming
import Extensions
import Combine
import HeaderTextField
import ServicesProvider

class MultibetPersonalInfoFormStepViewModel {

    let title: String

    let fullName: CurrentValueSubject<String?, Never>
    let email: CurrentValueSubject<String?, Never>
    let nickname: CurrentValueSubject<String?, Never>

    var emailState: CurrentValueSubject<EmailState, Never> = .init(.empty)
    private var checkEmailRegisteredCancellables: AnyCancellable?
    
    private var serviceProvider: ServicesProvider.Client
    private var userRegisterEnvelopUpdater: UserRegisterEnvelopUpdater

    var isFormCompleted: AnyPublisher<Bool, Never> {
        return Publishers.CombineLatest3(self.fullName, self.emailState, self.nickname)
            .map { (fullName, emailState, nickname) in
                let isEmailValid = emailState == .valid
                
                if let fullName, let nickname {
                    return fullName.count > 1 && isEmailValid &&
                    nickname.count > 1
                }
                
                return false
            }
            .eraseToAnyPublisher()
    }
    
    private var cancellables = Set<AnyCancellable>()

    init(title: String,
         fullName: String? = nil,
         email: String? = nil,
         nickname: String? = nil,
         serviceProvider: ServicesProvider.Client,
         userRegisterEnvelopUpdater: UserRegisterEnvelopUpdater) {

        self.title = title
        self.fullName = .init(fullName)
        self.email = .init(email)
        self.nickname = .init(nickname)

        self.serviceProvider = serviceProvider
        self.userRegisterEnvelopUpdater = userRegisterEnvelopUpdater
        
        // Email validation
        self.email
            .removeDuplicates()
            .sink { [weak self] newEmail in

                self?.userRegisterEnvelopUpdater.setEmail(nil)
                self?.checkEmailRegisteredCancellables?.cancel()

                guard
                    let newEmail
                else {
                    self?.emailState.send(.empty)
                    return
                }

                if newEmail.isEmpty {
                    self?.emailState.send(.empty)
                }
                else if self?.isValidEmailAddress(newEmail) ?? false {
                    // Change here after email validation endpoint is enabled
//                    self?.emailState.send(.needsValidation)
                    self?.emailState.send(.valid)

                }
                else {
                    self?.emailState.send(EmailState.invalidSyntax)
                }
            }
            .store(in: &self.cancellables)

        //
        let clearedEmailState = self.emailState.removeDuplicates()
        let clearedEmail = self.email.removeDuplicates()

        // Enable after endpoint is available
//        Publishers.CombineLatest(clearedEmailState, clearedEmail)
//            .debounce(for: .seconds(0.6), scheduler: DispatchQueue.main)
//            .filter { emailState, email in
//                return emailState == .needsValidation
//            }
//            .map { _, email -> String? in
//                return email
//            }
//            .compactMap({ $0 })
//            .sink { [weak self] email in
//                self?.requestValidEmailCheck(email: email)
//            }
//            .store(in: &self.cancellables)

        Publishers.CombineLatest(self.emailState, self.email)
            .filter { emailState, email in
                return emailState == .valid
            }
            .map { _, email -> String? in
                return email
            }
            .compactMap({ $0 })
            .sink { validEmail in
                self.userRegisterEnvelopUpdater.setEmail(validEmail)
            }
            .store(in: &self.cancellables)
    }
    
    func requestValidEmailCheck(email: String) {

        self.checkEmailRegisteredCancellables?.cancel()

        self.emailState.send(.validating)

        self.checkEmailRegisteredCancellables = self.serviceProvider.checkEmailRegistered(email)
                    .receive(on: DispatchQueue.main)
                    .sink { [weak self] completion in
                        switch completion {
                        case .failure(_):
                            self?.emailState.send(.serverError)
                        case .finished:
                            ()
                        }
                    }
                    receiveValue: { [weak self] isEmailInUse in
                        if isEmailInUse {
                            self?.emailState.send(.alreadyInUse)
                        }
                        else {
                            self?.emailState.send(.valid)
                        }
                    }

    }
    
    private func isValidEmailAddress(_ email: String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPred = NSPredicate(format: "SELF MATCHES %@", emailRegEx)
        return emailPred.evaluate(with: email)
    }
    
    func setFullName(_ fullName: String) {
        self.fullName.send(fullName)
        self.userRegisterEnvelopUpdater.setFullName(fullName)
    }
    
    func setEmail(_ email: String) {
        self.email.send(email)
        self.userRegisterEnvelopUpdater.setEmail(email)
    }
    
    func setNickname(_ nickname: String) {
        self.nickname.send(nickname)
        self.userRegisterEnvelopUpdater.setNickname(nickname)
    }

}

class MultibetPersonalInfoFormStepView: FormStepView {

    private lazy var fullNameHeaderTextFieldView: HeaderTextFieldView = Self.createFullNameHeaderTextFieldView()
    private lazy var emailHeaderTextFieldView: HeaderTextFieldView = Self.createEmailHeaderTextFieldView()
    private lazy var nicknameHeaderTextFieldView: HeaderTextFieldView = Self.createNicknameHeaderTextFieldView()
    
    private lazy var loadingView: UIActivityIndicatorView = Self.createLoadingView()
    
    private let viewModel: MultibetPersonalInfoFormStepViewModel

    private var cancellables = Set<AnyCancellable>()

    init(viewModel: MultibetPersonalInfoFormStepViewModel) {
        self.viewModel = viewModel

        super.init()

        self.configureSubviews()
    }

    override var isFormCompleted: AnyPublisher<Bool, Never> {
        return self.viewModel.isFormCompleted
    }

    func configureSubviews() {
        
        self.stackView.addArrangedSubview(self.fullNameHeaderTextFieldView)
        
        self.stackView.addArrangedSubview(self.emailHeaderTextFieldView)
        
        self.stackView.addArrangedSubview(self.nicknameHeaderTextFieldView)
        
        self.emailHeaderTextFieldView.addSubview(self.loadingView)
        
        NSLayoutConstraint.activate([
            self.fullNameHeaderTextFieldView.heightAnchor.constraint(equalToConstant: 80),
            
            self.emailHeaderTextFieldView.heightAnchor.constraint(equalToConstant: 80),

            self.nicknameHeaderTextFieldView.heightAnchor.constraint(equalToConstant: 80),
            
            self.loadingView.centerYAnchor.constraint(equalTo: self.emailHeaderTextFieldView.contentCenterYConstraint),
            self.loadingView.trailingAnchor.constraint(equalTo: self.emailHeaderTextFieldView.trailingAnchor, constant: -10),

        ])
        
        self.titleLabel.text = self.viewModel.title

        self.fullNameHeaderTextFieldView.setContextType(.name)

        self.fullNameHeaderTextFieldView.setReturnKeyType(.next)
        self.fullNameHeaderTextFieldView.setPlaceholderText(Localization.localized("full_name"))
        self.fullNameHeaderTextFieldView.didTapReturn = { [weak self] in
            self?.emailHeaderTextFieldView.becomeFirstResponder()
        }
        
        self.emailHeaderTextFieldView.setContextType(.emailAddress)

        self.emailHeaderTextFieldView.setReturnKeyType(.next)
        self.emailHeaderTextFieldView.setPlaceholderText(Localization.localized("email"))
        self.emailHeaderTextFieldView.didTapReturn = { [weak self] in
            self?.nicknameHeaderTextFieldView.becomeFirstResponder()
        }
        
        self.nicknameHeaderTextFieldView.setContextType(.nickname)
        
        self.nicknameHeaderTextFieldView.setReturnKeyType(.continue)
        self.nicknameHeaderTextFieldView.setPlaceholderText(Localization.localized("nickname"))
        self.nicknameHeaderTextFieldView.didTapReturn = { [weak self] in
            self?.nicknameHeaderTextFieldView.resignFirstResponder()
        }
        
        self.fullNameHeaderTextFieldView.setText(self.viewModel.fullName.value ?? "")

        self.fullNameHeaderTextFieldView.textPublisher
            .sink { [weak self] text in
                self?.viewModel.setFullName(text)
            }
            .store(in: &self.cancellables)
        
        self.emailHeaderTextFieldView.setText(self.viewModel.email.value ?? "")

        self.emailHeaderTextFieldView.textPublisher
            .sink { [weak self] text in
                self?.viewModel.setEmail(text)
            }
            .store(in: &self.cancellables)
        
        self.nicknameHeaderTextFieldView.setText(self.viewModel.nickname.value ?? "")

        self.nicknameHeaderTextFieldView.textPublisher
            .sink { [weak self] text in
                self?.viewModel.setNickname(text)
            }
            .store(in: &self.cancellables)

        // Email validation
        self.viewModel.emailState
            .receive(on: DispatchQueue.main)
            .debounce(for: .seconds(2.0), scheduler: DispatchQueue.main)
            .filter({ state in
                return state == .invalidSyntax
            })
            .sink { [weak self] _ in
                self?.emailHeaderTextFieldView.showError(withMessage: Localization.localized("invalid_email_format"))
            }
            .store(in: &self.cancellables)
        
        self.viewModel.emailState
            .receive(on: DispatchQueue.main)
            .sink { [weak self] emailState in
                if emailState == .validating {
                    self?.loadingView.startAnimating()
                }
                else {
                    self?.loadingView.stopAnimating()
                }

                switch emailState {
                case .empty:
                    self?.emailHeaderTextFieldView.hideTipAndError()
                case .needsValidation:
                    self?.emailHeaderTextFieldView.hideTipAndError()
                case .validating:
                    self?.emailHeaderTextFieldView.hideTipAndError()
                case .serverError:
                    self?.emailHeaderTextFieldView.showError(withMessage: Localization.localized("email_not_verifiable"))
                case .alreadyInUse:
                    self?.emailHeaderTextFieldView.showError(withMessage: Localization.localized("email_already_in_use"))
                case .invalidSyntax:
                    self?.emailHeaderTextFieldView.hideTipAndError()
                case .valid:
                    self?.emailHeaderTextFieldView.hideTipAndError()
                }

            }
            .store(in: &self.cancellables)
    }

    public override func layoutSubviews() {
        super.layoutSubviews()
    }

    override func setupWithTheme() {
        super.setupWithTheme()

        self.fullNameHeaderTextFieldView.setViewColor(AppColor.inputBackground)
        self.fullNameHeaderTextFieldView.setHeaderLabelColor(AppColor.inputTextTitle)
        self.fullNameHeaderTextFieldView.setTextFieldColor(AppColor.inputText)
        
        self.emailHeaderTextFieldView.setViewColor(AppColor.inputBackground)
        self.emailHeaderTextFieldView.setHeaderLabelColor(AppColor.inputTextTitle)
        self.emailHeaderTextFieldView.setTextFieldColor(AppColor.inputText)
        
        self.nicknameHeaderTextFieldView.setViewColor(AppColor.inputBackground)
        self.nicknameHeaderTextFieldView.setHeaderLabelColor(AppColor.inputTextTitle)
        self.nicknameHeaderTextFieldView.setTextFieldColor(AppColor.inputText)
    }

    override func canPresentError(forFormStep formStep: FormStep) -> Bool {
        switch formStep {
        case .names: return true
        case .contacts: return true
        case .nickname: return true
        case .personalInfo: return true
        default: return false
        }
    }

    override func presentError(_ error: RegisterError, forFormStep formStep: FormStep) {
        if !self.canPresentError(forFormStep: formStep) { return }
        switch (error.field, error.error) {
        case ("names", "INVALID_LENGTH"):
            self.fullNameHeaderTextFieldView.showError(withMessage: Localization.localized("name_invalid_length"))
        case ("names", _):
            self.fullNameHeaderTextFieldView.showError(withMessage: Localization.localized("invalid_name"))
        case ("email", "INVALID_LENGTH"):
            self.emailHeaderTextFieldView.showError(withMessage: Localization.localized("place_too_long"))
        case ("email", "DUPLICATE"):
            self.emailHeaderTextFieldView.showError(withMessage: Localization.localized("email_already_in_use"))
        case ("email", _):
            self.emailHeaderTextFieldView.showError(withMessage: Localization.localized("invalid_email"))
        case ("nickname", "INVALID_LENGTH"):
            self.nicknameHeaderTextFieldView.showError(withMessage: Localization.localized("nickname_invalid_length"))
        case ("nickname", _):
            self.nicknameHeaderTextFieldView.showError(withMessage: Localization.localized("invalid_nickname"))
        case ("nickname", "DUPLICATE"):
            self.nicknameHeaderTextFieldView.showError(withMessage: Localization.localized("nickname_already_in_use"))
        case ("personalInfo", "EMAIL_DUPLICATE"):
            self.emailHeaderTextFieldView.showError(withMessage: Localization.localized("email_already_in_use"))
        case ("personalInfo", "USERNAME_DUPLICATE"):
            self.nicknameHeaderTextFieldView.showError(withMessage: Localization.localized("nickname_already_in_use"))
        case ("personalInfo", _):
            self.emailHeaderTextFieldView.showError(withMessage: Localization.localized("email_already_in_use"))
            self.nicknameHeaderTextFieldView.showError(withMessage: Localization.localized("nickname_already_in_use"))
        default:
            ()
        }
    }

}

extension MultibetPersonalInfoFormStepView {

    fileprivate static func createFullNameHeaderTextFieldView() -> HeaderTextFieldView {
        let headerTextFieldView = HeaderTextFieldView()
        headerTextFieldView.setTextFieldFont(AppFont.with(type: .semibold, size: 16))
        headerTextFieldView.setHeaderLabelFont(AppFont.with(type: .semibold, size: 16))
        headerTextFieldView.translatesAutoresizingMaskIntoConstraints = false
        return headerTextFieldView
    }
    
    fileprivate static func createEmailHeaderTextFieldView() -> HeaderTextFieldView {
        let headerTextFieldView = HeaderTextFieldView()
        headerTextFieldView.setTextFieldFont(AppFont.with(type: .semibold, size: 16))
        headerTextFieldView.setHeaderLabelFont(AppFont.with(type: .semibold, size: 16))
        headerTextFieldView.translatesAutoresizingMaskIntoConstraints = false
        return headerTextFieldView
    }
    
    fileprivate static func createNicknameHeaderTextFieldView() -> HeaderTextFieldView {
        let headerTextFieldView = HeaderTextFieldView()
        headerTextFieldView.setTextFieldFont(AppFont.with(type: .semibold, size: 16))
        headerTextFieldView.setHeaderLabelFont(AppFont.with(type: .semibold, size: 16))
        headerTextFieldView.translatesAutoresizingMaskIntoConstraints = false
        return headerTextFieldView
    }
    
    fileprivate static func createLoadingView() -> UIActivityIndicatorView {
        let loadingView = UIActivityIndicatorView(style: .medium)
        loadingView.hidesWhenStopped = true
        loadingView.translatesAutoresizingMaskIntoConstraints = false
        return loadingView
    }

}

