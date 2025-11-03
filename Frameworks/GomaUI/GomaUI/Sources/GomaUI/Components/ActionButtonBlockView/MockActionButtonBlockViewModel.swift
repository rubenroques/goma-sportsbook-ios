//
//  MockActionButtonBlockViewModel.swift
//  GomaUI
//
//  Created by André Lascas on 13/03/2025.
//

import Foundation

public class MockActionButtonBlockViewModel: ActionButtonBlockViewModelProtocol {
    
    public let title: String
    public let actionName: String
    public let actionURL: String?
    public let isEnabled: Bool
    
    // Callback for when button is tapped
    public var onActionTapped: ((String?) -> Void)?
    
    public init(title: String, actionName: String, actionURL: String? = nil, isEnabled: Bool = true) {
        self.title = title
        self.actionName = actionName
        self.actionURL = actionURL
        self.isEnabled = isEnabled
    }
    
    public func didTapActionButton() {
        print("Action button tapped with action: \(actionName)")
        onActionTapped?(actionURL)
    }
}

// MARK: - Mock Presets
extension MockActionButtonBlockViewModel {
    
    public static var defaultMock: MockActionButtonBlockViewModel {
        return MockActionButtonBlockViewModel(
            title: "Claim Bonus",
            actionName: "claim_bonus",
            actionURL: "https://www.google.com"
        )
    }
    
    public static var disabledMock: MockActionButtonBlockViewModel {
        return MockActionButtonBlockViewModel(
            title: "Claim Bonus",
            actionName: "claim_bonus",
            actionURL: "https://www.google.com",
            isEnabled: false
        )
    }
    
    public static var longTextMock: MockActionButtonBlockViewModel {
        return MockActionButtonBlockViewModel(
            title: "Get Your Welcome Bonus Now",
            actionName: "welcome_bonus",
            actionURL: "https://www.google.com"
        )
    }
}
