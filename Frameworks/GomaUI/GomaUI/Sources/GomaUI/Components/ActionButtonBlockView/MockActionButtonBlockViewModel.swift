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
    public let isEnabled: Bool
    
    public init(title: String, actionName: String, isEnabled: Bool = true) {
        self.title = title
        self.actionName = actionName
        self.isEnabled = isEnabled
    }
    
    public func didTapActionButton() {
        print("Action button tapped with action: \(actionName)")
    }
}

// MARK: - Mock Presets
extension MockActionButtonBlockViewModel {
    
    public static var defaultMock: MockActionButtonBlockViewModel {
        return MockActionButtonBlockViewModel(
            title: "Claim Bonus",
            actionName: "claim_bonus"
        )
    }
    
    public static var disabledMock: MockActionButtonBlockViewModel {
        return MockActionButtonBlockViewModel(
            title: "Claim Bonus",
            actionName: "claim_bonus",
            isEnabled: false
        )
    }
    
    public static var longTextMock: MockActionButtonBlockViewModel {
        return MockActionButtonBlockViewModel(
            title: "Get Your Welcome Bonus Now",
            actionName: "welcome_bonus"
        )
    }
}
