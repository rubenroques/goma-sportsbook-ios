//
//  MockDescriptionBlockViewModel.swift
//  GomaUI
//
//  Created by André Lascas on 12/03/2025.
//

import Foundation

public class MockDescriptionBlockViewModel: DescriptionBlockViewModelProtocol {
    
    public let description: String
    
    public init(description: String) {
        self.description = description
    }
}

// MARK: - Mock Presets
extension MockDescriptionBlockViewModel {
    
    public static var defaultMock: MockDescriptionBlockViewModel {
        return MockDescriptionBlockViewModel(
            description: "Welcome to our amazing promotion! Get ready to experience the best betting platform with exclusive bonuses and rewards."
        )
    }
    
    public static var shortMock: MockDescriptionBlockViewModel {
        return MockDescriptionBlockViewModel(
            description: "Limited time offer available now."
        )
    }
    
    public static var longMock: MockDescriptionBlockViewModel {
        return MockDescriptionBlockViewModel(
            description: "Join thousands of satisfied customers who have already discovered the thrill of our premium betting experience. This exclusive promotion offers you the perfect opportunity to maximize your winnings while enjoying our world-class platform. Don't miss out on this incredible offer that combines the best odds, fastest payouts, and most exciting games all in one place."
        )
    }
}
