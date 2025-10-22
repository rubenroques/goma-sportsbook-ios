//
//  PhoneForgotPasswordViewModel.swift
//  Sportsbook
//
//  Created by André Lascas on 27/06/2025.
//

import Foundation
import GomaUI
import Combine
import ServicesProvider

class PhoneForgotPasswordViewModel: PhoneForgotPasswordViewModelProtocol {
    let hashKey: String
    var newPassword: String = ""
    let resetPasswordType: ResetPasswordType
    let headerViewModel: PromotionalHeaderViewModelProtocol
    let highlightedTextViewModel: HighlightedTextViewModelProtocol
    let newPasswordFieldViewModel: BorderedTextFieldViewModelProtocol
    let confirmNewPasswordFieldViewModel: BorderedTextFieldViewModelProtocol
    let buttonViewModel: ButtonViewModelProtocol
    
    private let isLoadingSubject = CurrentValueSubject<Bool, Never>(false)
    var isLoadingPublisher: AnyPublisher<Bool, Never> { isLoadingSubject.eraseToAnyPublisher() }
    
    let passwordChanged = PassthroughSubject<Void, Never>()
    let showError = PassthroughSubject<String, Never>()

    private var cancellables = Set<AnyCancellable>()

    init(hashKey: String, resetPasswordType: ResetPasswordType) {
        
        self.hashKey = hashKey
        self.resetPasswordType = resetPasswordType
        
        headerViewModel = MockPromotionalHeaderViewModel(headerData: PromotionalHeaderData(id: "header",
                                                                                           icon: "key_icon",
                                                                                           title: "Password reset code",
                                                                                           subtitle: nil))
        
        highlightedTextViewModel = MockHighlightedTextViewModel(data: HighlightedTextData(fullText: "Enter your phone number to request reset code",
                                                                                          highlights: []))
        
        newPasswordFieldViewModel = MockBorderedTextFieldViewModel(textFieldData: BorderedTextFieldData(id: "new_password",

                                                                                                        placeholder: "New Password",

                                                                                                        isSecure: true,
                                                                                                        isRequired: true,

                                                                                                        visualState: .idle,
                                                                                                        keyboardType: .default,

                                                                                                        textContentType: .newPassword))

        confirmNewPasswordFieldViewModel = MockBorderedTextFieldViewModel(textFieldData: BorderedTextFieldData(id: "new_password",

                                                                                                        placeholder: "Confirm New Password",

                                                                                                        isSecure: true,
                                                                                                        isRequired: true,

                                                                                                        visualState: .idle,
                                                                                                        keyboardType: .default,

                                                                                                               textContentType: .newPassword))
        
        buttonViewModel = MockButtonViewModel(buttonData: ButtonData(id: "change_password",
                                                                     title: "Change Password",
                                                                     style: .solidBackground,
                                                                     isEnabled: true))
        
        setupPublishers()

    }
    
    private func setupPublishers() {
        
        Publishers.CombineLatest(newPasswordFieldViewModel.textPublisher, confirmNewPasswordFieldViewModel.textPublisher)
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] newPassword, confirmNewPassword in
                var isNewPasswordValid = false
                var isConfirmNewPasswordValid = false
                
                self?.newPassword = newPassword
                
                if newPassword.count < 4 && newPassword.isNotEmpty {
                    isNewPasswordValid = false
                    self?.newPasswordFieldViewModel.setError("Password too small")
                }
                else {
                    self?.newPasswordFieldViewModel.clearError()
                    
                    if newPassword.isNotEmpty {
                        isNewPasswordValid = true
                    }

                }
                
                if confirmNewPassword != newPassword && confirmNewPassword.isNotEmpty {
                    isConfirmNewPasswordValid = false
                    self?.confirmNewPasswordFieldViewModel.setError("Passwords do not match")
                }
                else {
                    self?.confirmNewPasswordFieldViewModel.clearError()
                    
                    if confirmNewPassword.isNotEmpty {
                        isConfirmNewPasswordValid = true
                    }
                }
                
                if isNewPasswordValid && isConfirmNewPasswordValid {
                    self?.buttonViewModel.setEnabled(true)
                }
                else {
                    self?.buttonViewModel.setEnabled(false)
                }
                
                
            })
            .store(in: &cancellables)
    }
    
    func requestPasswordChange() {
        isLoadingSubject.send(true)
        
        // Get the new password from the text field
        let newPassword = newPassword
        
        // Call the API to reset the password with the hashKey
        Env.servicesProvider
            .resetPasswordWithHashKey(hashKey: hashKey, plainTextPassword: newPassword, isUserHash: true)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { [weak self] completion in
                guard let self = self else { return }
                self.isLoadingSubject.send(false)
                
                switch completion {
                case .finished:
                    break
                case .failure(let error):
                    switch error {
                    case .errorMessage(let message):
                        self.showError.send(message)
                    default:
                        self.showError.send(error.localizedDescription)
                    }
                }
            }, receiveValue: { [weak self] response in
                guard let self = self else { return }
                self.passwordChanged.send()
            })
            .store(in: &cancellables)
    }
}
