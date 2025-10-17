//
//  PhonePasswordCodeVerificationViewModel.swift
//  Sportsbook
//
//  Created by André Lascas on 26/06/2025.
//

import Foundation
import GomaUI
import Combine
import ServicesProvider

class PhonePasswordCodeVerificationViewModel: PhonePasswordCodeVerificationViewModelProtocol {
    let tokenId: String
    let phoneNumber: String
    let resetPasswordType: ResetPasswordType
    let headerViewModel: PromotionalHeaderViewModelProtocol
    let highlightedTextViewModel: HighlightedTextViewModelProtocol
    let pinEntryViewModel: PinDigitEntryViewModelProtocol
    let resendCodeCountdownViewModel: ResendCodeCountdownViewModelProtocol
    let buttonViewModel: ButtonViewModelProtocol
    private let isLoadingSubject = CurrentValueSubject<Bool, Never>(false)
    var isLoadingPublisher: AnyPublisher<Bool, Never> { isLoadingSubject.eraseToAnyPublisher() }
    
    let shouldPasswordChange = PassthroughSubject<String, Never>()
    let showError = PassthroughSubject<String, Never>()

    private var cancellables = Set<AnyCancellable>()

    init(tokenId: String, phoneNumber: String, resetPasswordType: ResetPasswordType) {
        
        self.tokenId = tokenId
        self.phoneNumber = phoneNumber
        self.resetPasswordType = resetPasswordType
        
        headerViewModel = MockPromotionalHeaderViewModel(headerData: PromotionalHeaderData(id: "header",
                                                                                           icon: "phone_verify_icon",
                                                                                           title: "Verifying it’s really you",
                                                                                           subtitle: nil))
        
        let fullText = "Please enter the verification code we have sent to \(phoneNumber)"
        let phoneNumber = phoneNumber
        let phoneRanges = HighlightedTextView.findRanges(of: phoneNumber, in: fullText)

        highlightedTextViewModel = MockHighlightedTextViewModel(data: HighlightedTextData(fullText: fullText,
                                                                                          highlights: [HighlightData(text: phoneNumber,
                                                                                                                     color: StyleProvider.Color.highlightPrimary,
                                                                                                                     ranges: phoneRanges)]))
        
        pinEntryViewModel = MockPinDigitEntryViewModel(data: PinDigitEntryData(id: "pin", digitCount: 4))
        
        resendCodeCountdownViewModel = MockResendCodeCountdownViewModel(startSeconds: 60)
        
        buttonViewModel = MockButtonViewModel(buttonData: ButtonData(id: "verify", title: "Verify", style: .solidBackground, isEnabled: false))
        
        setupPublishers()

    }
    
    private func setupPublishers() {
        
        pinEntryViewModel.isPinComplete
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] isPinComplete in
                
                self?.buttonViewModel.setEnabled(isPinComplete)
            })
            .store(in: &cancellables)
    }
    
    func requestPasswordChange() {
        isLoadingSubject.send(true)
        
        // Get the validation code from the PIN entry
        let validationCode = pinEntryViewModel.data.currentPin
        
        // Call the API to validate the reset password code
        Env.servicesProvider
            .validateResetPasswordCode(tokenId: tokenId, validationCode: validationCode)
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
                // Send the hashKey to the next screen
                self.shouldPasswordChange.send(response.hashKey)
            })
            .store(in: &cancellables)
    }
}
