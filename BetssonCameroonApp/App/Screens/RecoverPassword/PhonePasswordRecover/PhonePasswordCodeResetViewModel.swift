//
//  PhonePasswordCodeResetViewModel.swift
//  Sportsbook
//
//  Created by André Lascas on 27/06/2025.
//

import Foundation
import GomaUI
import Combine
import ServicesProvider

class PhonePasswordCodeResetViewModel: PhonePasswordCodeResetViewModelProtocol {
    var phoneNumber: String = ""
    let headerViewModel: PromotionalHeaderViewModelProtocol
    let highlightedTextViewModel: HighlightedTextViewModelProtocol
    let phoneFieldViewModel: BorderedTextFieldViewModelProtocol
    let buttonViewModel: ButtonViewModelProtocol
    
    private let isLoadingSubject = CurrentValueSubject<Bool, Never>(false)
    var isLoadingPublisher: AnyPublisher<Bool, Never> { isLoadingSubject.eraseToAnyPublisher() }
    
    let shouldVerifyCode = PassthroughSubject<String, Never>()
    let showError = PassthroughSubject<String, Never>()

    private var cancellables = Set<AnyCancellable>()

    init() {
        
        headerViewModel = MockPromotionalHeaderViewModel(headerData: PromotionalHeaderData(id: "header",
                                                                                           icon: "key_icon",
                                                                                           title: "Password reset code",
                                                                                           subtitle: nil))
        
        highlightedTextViewModel = MockHighlightedTextViewModel(data: HighlightedTextData(fullText: "Enter your phone number to request reset code",
                                                                                          highlights: []))
        
        phoneFieldViewModel = MockBorderedTextFieldViewModel(textFieldData: BorderedTextFieldData(id: "phone",
                                                                                                  placeholder: "Phone number",
                                                                                                  prefix: "+237",
                                                                                                  isSecure: false,
                                                                                                  isRequired: true,
                                                                                                  visualState: .idle,
                                                                                                  keyboardType: .phonePad,
                                                                                                  textContentType: .telephoneNumber))
        
        buttonViewModel = MockButtonViewModel(buttonData: ButtonData(id: "request_code",
                                                                     title: "Request Code",
                                                                     style: .solidBackground,
                                                                     isEnabled: true))
        
        setupPublishers()

    }
    
    private func setupPublishers() {
        
        phoneFieldViewModel.textPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] phoneText in
                guard let self = self else { return }
                
                phoneNumber = phoneText
                
                let regex = try? NSRegularExpression(pattern: "^0?\\d{9}$")
                let range = NSRange(location: 0, length: phoneText.utf16.count)
                let isValid = regex?.firstMatch(in: phoneText, options: [], range: range) != nil
                
                if phoneText.isEmpty {
                    self.phoneFieldViewModel.clearError()
                    self.buttonViewModel.setEnabled(false)
                } else if !isValid {
                    self.phoneFieldViewModel.setError("Enter a valid number (9 digits, may start with 0)")
                    self.buttonViewModel.setEnabled(false)

                } else {
                    self.phoneFieldViewModel.clearError()
                    self.buttonViewModel.setEnabled(true)
                }
            }
            .store(in: &cancellables)
    }
    
    func requestPasswordResetCode() {
        isLoadingSubject.send(true)
        
        // Get phone number and prefix
        let phoneNumber = phoneNumber
        let phonePrefix = phoneFieldViewModel.prefixText ?? ""
        
        // Call the API
        Env.servicesProvider
            .getResetPasswordTokenId(mobileNumber: phoneNumber, mobilePrefix: phonePrefix)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { [weak self] completion in
                guard let self = self else { return }
                self.isLoadingSubject.send(false)
                
                switch completion {
                case .finished:
                    break
                case .failure(let error):
                    self.showError.send(error.localizedDescription)
                }
            }, receiveValue: { [weak self] response in
                guard let self = self else { return }
                // Send the tokenId to the next screen
                self.shouldVerifyCode.send(response.tokenId)
            })
            .store(in: &cancellables)
    }
}
