//
//  MockPhoneForgotPasswordViewModel.swift
//  Sportsbook
//
//  Created by André Lascas on 27/06/2025.
//

import Foundation
import GomaUI
import Combine

class MockPhoneForgotPasswordViewModel: PhoneForgotPasswordViewModelProtocol {
    let headerViewModel: PromotionalHeaderViewModelProtocol
    let highlightedTextViewModel: HighlightedTextViewModelProtocol
    let newPasswordFieldViewModel: BorderedTextFieldViewModelProtocol
    let confirmNewPasswordFieldViewModel: BorderedTextFieldViewModelProtocol
    let buttonViewModel: ButtonViewModelProtocol
    
    private let isLoadingSubject = CurrentValueSubject<Bool, Never>(false)
    var isLoadingPublisher: AnyPublisher<Bool, Never> { isLoadingSubject.eraseToAnyPublisher() }
    
    let passwordChanged = PassthroughSubject<Void, Never>()

    private var cancellables = Set<AnyCancellable>()

    init() {
        
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
        // Simulate endpoint delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) { [weak self] in
            self?.isLoadingSubject.send(false)
            
            self?.passwordChanged.send()
        }
    }
}
