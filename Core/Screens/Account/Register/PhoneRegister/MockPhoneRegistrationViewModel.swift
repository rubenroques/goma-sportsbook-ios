//
//  MockPhoneRegistrationViewModel.swift
//  Sportsbook
//
//  Created by André Lascas on 25/06/2025.
//

import Foundation
import GomaUI
import Combine
import ServicesProvider

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
    
    var registrationConfig: RegistrationConfigContent
    
    init(registrationConfig: RegistrationConfigContent) {
        
        self.registrationConfig = registrationConfig
        
        headerViewModel = MockPromotionalHeaderViewModel(headerData: PromotionalHeaderData(id: "registerHeader",
                                                                                           icon: "key_icon",
                                                                                           title: "Get in on the action!",
                                                                                           subtitle: nil))
        
        highlightedTextViewModel = MockHighlightedTextViewModel(data: HighlightedTextData(fullText: "Sign up securely in just 2 minutes", highlights: []))
        
        let phoneConfig = registrationConfig.fields.first(where: {
            $0.name == "Mobile"
        })
        
        phoneFieldViewModel = MockBorderedTextFieldViewModel(textFieldData: BorderedTextFieldData(id: "phone",
                                                                                                  placeholder: "New number *",
                                                                                                  prefix: phoneConfig?.defaultValue ?? "",
                                                                                                  isSecure: false,
                                                                                                  visualState: .idle,
                                                                                                  keyboardType: .phonePad,
                                                                                                  textContentType: .telephoneNumber))

        let passwordConfig = registrationConfig.fields.first(where: {
            $0.name == "Password"
        })
        
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
        
        let extractedTermsHTMLData = Env.legislationManager.extractedTermsHTMLData

        // swiftlint:disable line_length
        let fullText = extractedTermsHTMLData?.fullText ?? "By creating an account I agree that I am 21 years of age or older and have read and accepted our general Terms and Conditions and Privacy Policy"
        
        let termsData = extractedTermsHTMLData?.extractedLinks.first(where: {
            $0.type == .terms
        })
        
        let privacyData = extractedTermsHTMLData?.extractedLinks.first(where: {
            $0.type == .privacyPolicy
        })
        
        let cookiesData = extractedTermsHTMLData?.extractedLinks.first(where: {
            $0.type == .cookies
        })
        
        // swiftlint:disable line_length
        termsViewModel = MockTermsAcceptanceViewModel(data: TermsAcceptanceData(fullText: fullText,
                                                                                termsText: termsData?.text ?? "Terms and Conditions",
                                                                                privacyText: privacyData?.text ?? "Privacy Policy",
                                                                                cookiesText: cookiesData?.text))
        
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
                
                let isValidPhoneNumberData = Env.legislationManager.isValidPhoneNumber(phoneText: phoneText)
                
                if phoneText.isEmpty {
                    self.phoneFieldViewModel.clearError()
                } else if !isValidPhoneNumberData.0 {
                    self.phoneFieldViewModel.setError("\(isValidPhoneNumberData.1)")
                } else {
                    self.phoneFieldViewModel.clearError()
                }
            }
            .store(in: &cancellables)
        
        passwordFieldViewModel.textPublisher
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] passwordText in
                
                let isValidPasswordData = Env.legislationManager.isValidPassword(passwordText: passwordText)
                
                if !isValidPasswordData.0 && passwordText.isNotEmpty {
                    self?.passwordFieldViewModel.setError("\(isValidPasswordData.1)")
                }
                else {
                    self?.passwordFieldViewModel.clearError()
                }
            })
            .store(in: &cancellables)
        
    }
    
}
