//
//  MockButtonViewModel.swift
//  GomaUI
//
//  Created by André Lascas on 09/06/2025.
//

import Foundation
import Combine
import UIKit

/// Mock implementation of `ButtonViewModelProtocol` for testing.
final public class MockButtonViewModel: ButtonViewModelProtocol {
    
    // MARK: - Properties
    private let buttonDataSubject: CurrentValueSubject<ButtonData, Never>
    public var buttonDataPublisher: AnyPublisher<ButtonData, Never> {
        return buttonDataSubject.eraseToAnyPublisher()
    }
    
    // MARK: - Initialization
    public init(buttonData: ButtonData) {
        self.buttonDataSubject = CurrentValueSubject(buttonData)
    }
    
    // MARK: - ButtonViewModelProtocol
    public func buttonTapped() {
        let currentData = buttonDataSubject.value
        print("Button tapped: \(currentData.id)")
    }
    
    public func setEnabled(_ isEnabled: Bool) {
        let currentData = buttonDataSubject.value
        let updatedData = ButtonData(
            id: currentData.id,
            title: currentData.title,
            style: currentData.style,
            isEnabled: isEnabled
        )
        buttonDataSubject.send(updatedData)
    }
    
    public func updateTitle(_ title: String) {
        let currentData = buttonDataSubject.value
        let updatedData = ButtonData(
            id: currentData.id,
            title: title,
            style: currentData.style,
            isEnabled: currentData.isEnabled
        )
        buttonDataSubject.send(updatedData)
    }
}

// MARK: - Mock Factory
extension MockButtonViewModel {
    
    // MARK: - Solid Background Buttons
    public static var solidBackgroundMock: MockButtonViewModel {
        let buttonData = ButtonData(
            id: "confirm_payment",
            title: "Confirm Payment",
            style: .solidBackground,
            isEnabled: true
        )
        return MockButtonViewModel(buttonData: buttonData)
    }
    
    public static var solidBackgroundDisabledMock: MockButtonViewModel {
        let buttonData = ButtonData(
            id: "confirm_payment_disabled",
            title: "Confirm Payment",
            style: .solidBackground,
            isEnabled: false
        )
        return MockButtonViewModel(buttonData: buttonData)
    }
    
    public static var claimBonusMock: MockButtonViewModel {
        let buttonData = ButtonData(
            id: "claim_bonus",
            title: "Claim bonus",
            style: .solidBackground,
            isEnabled: true
        )
        return MockButtonViewModel(buttonData: buttonData)
    }
    
    // MARK: - Bordered Buttons
    public static var borderedMock: MockButtonViewModel {
        let buttonData = ButtonData(
            id: "resend_ussd",
            title: "Resend USSD Push",
            style: .bordered,
            isEnabled: true
        )
        return MockButtonViewModel(buttonData: buttonData)
    }
    
    public static var borderedDisabledMock: MockButtonViewModel {
        let buttonData = ButtonData(
            id: "resend_ussd_disabled",
            title: "Resend USSD Push",
            style: .bordered,
            isEnabled: false
        )
        return MockButtonViewModel(buttonData: buttonData)
    }
    
    // MARK: - Transparent Buttons
    public static var transparentMock: MockButtonViewModel {
        let buttonData = ButtonData(
            id: "terms_conditions",
            title: "Terms and Conditions",
            style: .transparent,
            isEnabled: true
        )
        return MockButtonViewModel(buttonData: buttonData)
    }
    
    public static var transparentDisabledMock: MockButtonViewModel {
        let buttonData = ButtonData(
            id: "terms_conditions_disabled",
            title: "Terms and Conditions",
            style: .transparent,
            isEnabled: false
        )
        return MockButtonViewModel(buttonData: buttonData)
    }
    
    // MARK: - Additional Common Buttons
    public static var submitMock: MockButtonViewModel {
        let buttonData = ButtonData(
            id: "submit",
            title: "Submit",
            style: .solidBackground,
            isEnabled: true
        )
        return MockButtonViewModel(buttonData: buttonData)
    }
    
    public static var cancelMock: MockButtonViewModel {
        let buttonData = ButtonData(
            id: "cancel",
            title: "Cancel",
            style: .bordered,
            isEnabled: true
        )
        return MockButtonViewModel(buttonData: buttonData)
    }
    
    public static var learnMoreMock: MockButtonViewModel {
        let buttonData = ButtonData(
            id: "learn_more",
            title: "Learn More",
            style: .transparent,
            isEnabled: true
        )
        return MockButtonViewModel(buttonData: buttonData)
    }
}
