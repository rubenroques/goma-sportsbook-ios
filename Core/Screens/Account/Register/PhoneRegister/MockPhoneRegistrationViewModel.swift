//
//  MockPhoneRegistrationViewModel.swift
//  Sportsbook
//
//  Created by André Lascas on 25/06/2025.
//

import Foundation
import GomaUI
import Combine

class MockPhoneRegistrationViewModel: PhoneRegistrationViewModelProtocol {
    let headerViewModel: PromotionalHeaderViewModelProtocol
    let highlightedTextViewModel: HighlightedTextViewModelProtocol
    let phoneFieldViewModel: BorderedTextFieldViewModelProtocol
    let passwordFieldViewModel: BorderedTextFieldViewModelProtocol
    let referralFieldViewModel: BorderedTextFieldViewModelProtocol
    let termsViewModel: TermsAcceptanceViewModelProtocol
    let buttonViewModel: ButtonViewModelProtocol

    private var cancellables = Set<AnyCancellable>()
    
    var isRegisterDataComplete: CurrentValueSubject<Bool, Never> = .init(false)
    
    init() {
        headerViewModel = MockPromotionalHeaderViewModel(headerData: PromotionalHeaderData(id: "registerHeader",
                                                                                           icon: "key_icon",
                                                                                           title: "Get in on the action!",
                                                                                           subtitle: nil))
        
        highlightedTextViewModel = MockHighlightedTextViewModel(data: HighlightedTextData(fullText: "Sign up securely in just 2 minutes", highlights: []))
        
        phoneFieldViewModel = MockBorderedTextFieldViewModel(textFieldData: BorderedTextFieldData(id: "phone",
                                                                                                  placeholder: "New number *",
                                                                                                  isSecure: false,
                                                                                                  visualState: .idle,
                                                                                                  keyboardType: .phonePad,
                                                                                                  textContentType: .telephoneNumber))

        passwordFieldViewModel = MockBorderedTextFieldViewModel(textFieldData: BorderedTextFieldData(id: "password",
                                                                                                     placeholder: "Password (4 characters minimum) *",
                                                                                                     isSecure: true,
                                                                                                     visualState: .idle,
                                                                                                     keyboardType: .default,
                                                                                                     textContentType: .password))
        
        referralFieldViewModel = MockBorderedTextFieldViewModel(textFieldData: BorderedTextFieldData(id: "referral",
                                                                                                     placeholder: "Referral Code",
                                                                                                     isSecure: false,
                                                                                                     visualState: .idle,
                                                                                                     keyboardType: .default,
                                                                                                     textContentType: .oneTimeCode))
        // swiftlint:disable line_length
        termsViewModel = MockTermsAcceptanceViewModel(data: TermsAcceptanceData(fullText: "By creating an account I agree that I am 21 years of age or older and have read and accepted our general Terms and Conditions and Privacy Policy",
                                                                                termsText: "Terms and Conditions",
                                                                                privacyText: "Privacy Policy"))
        
        buttonViewModel = MockButtonViewModel(buttonData: ButtonData(id: "register",
                                                                     title: "Create Account",
                                                                     style: .solidBackground,
                                                                     isEnabled: true))
        
        setupPublishers()
    }
    
    private func setupPublishers() {
        
        Publishers.CombineLatest4(phoneFieldViewModel.textPublisher, passwordFieldViewModel.textPublisher, termsViewModel.dataPublisher, passwordFieldViewModel.visualStatePublisher)
            .map { phone, password, termsAccepted, passwordVisualState in
                let isPasswordValid: Bool
                
                if case .error = passwordVisualState {
                    isPasswordValid = false
                }
                else {
                    if password.isEmpty {
                        isPasswordValid = false
                    }
                    else {
                        isPasswordValid = true
                    }
                }
                
                return !phone.isEmpty && isPasswordValid && termsAccepted.isAccepted
            }
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isEnabled in
                self?.buttonViewModel.setEnabled(isEnabled)
                self?.isRegisterDataComplete.send(isEnabled)
            }
            .store(in: &cancellables)
        
        phoneFieldViewModel.textPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] phoneText in
                guard let self = self else { return }
                let regex = try? NSRegularExpression(pattern: "^0?\\d{9}$")
                let range = NSRange(location: 0, length: phoneText.utf16.count)
                let isValid = regex?.firstMatch(in: phoneText, options: [], range: range) != nil
                
                if phoneText.isEmpty {
                    self.phoneFieldViewModel.clearError()
                } else if !isValid {
                    self.phoneFieldViewModel.setError("Enter a valid Cameroon number (9 digits, may start with 0)")
                } else {
                    self.phoneFieldViewModel.clearError()
                }
            }
            .store(in: &cancellables)
        
        passwordFieldViewModel.textPublisher
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] passwordText in
                
                if passwordText.count < 4 && passwordText.isNotEmpty {
                    self?.passwordFieldViewModel.setError("Password too small")
                }
                else {
                    self?.passwordFieldViewModel.clearError()
                }
            })
            .store(in: &cancellables)
        
        
    }
}
