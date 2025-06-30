//
//  MockPhonePasswordCodeVerificationViewModel.swift
//  Sportsbook
//
//  Created by André Lascas on 26/06/2025.
//

import Foundation
import GomaUI
import Combine

class MockPhonePasswordCodeVerificationViewModel: PhonePasswordCodeVerificationViewModelProtocol {
    let headerViewModel: PromotionalHeaderViewModelProtocol
    let highlightedTextViewModel: HighlightedTextViewModelProtocol
    let pinEntryViewModel: PinDigitEntryViewModelProtocol
    let resendCodeCountdownViewModel: ResendCodeCountdownViewModelProtocol
    let buttonViewModel: ButtonViewModelProtocol
    private let isLoadingSubject = CurrentValueSubject<Bool, Never>(false)
    var isLoadingPublisher: AnyPublisher<Bool, Never> { isLoadingSubject.eraseToAnyPublisher() }
    
    let shouldPasswordChange = PassthroughSubject<Void, Never>()

    private var cancellables = Set<AnyCancellable>()

    init() {
       
        headerViewModel = MockPromotionalHeaderViewModel(headerData: PromotionalHeaderData(id: "header",
                                                                                           icon: "phone_verify_icon",
                                                                                           title: "Verifying it’s really you",
                                                                                           subtitle: nil))
        
        let fullText = "Please enter the verification code we have sent to +237 7 12345678"
        let phoneNumber = "+237 7 12345678"
        let phoneRanges = HighlightedTextView.findRanges(of: phoneNumber, in: fullText)

        highlightedTextViewModel = MockHighlightedTextViewModel(data: HighlightedTextData(fullText: fullText,
                                                                                          highlights: [HighlightData(text: phoneNumber,
                                                                                                                     color: StyleProvider.Color.highlightPrimary,
                                                                                                                     ranges: phoneRanges)]))
        
        pinEntryViewModel = MockPinDigitEntryViewModel(data: PinDigitEntryData(id: "pin", digitCount: 4))
        
        resendCodeCountdownViewModel = MockResendCodeCountdownViewModel(startSeconds: 60)
        
        buttonViewModel = MockButtonViewModel(buttonData: ButtonData(id: "veirfy", title: "Verify", style: .solidBackground, isEnabled: false))
        
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
        // Simulate endpoint delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) { [weak self] in
            self?.isLoadingSubject.send(false)
            
            self?.shouldPasswordChange.send()
        }
    }
}
