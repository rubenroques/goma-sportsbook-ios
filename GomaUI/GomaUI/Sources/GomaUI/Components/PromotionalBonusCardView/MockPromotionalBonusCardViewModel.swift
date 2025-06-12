//
//  MockPromotionalBonusCardViewModel.swift
//  GomaUI
//
//  Created by André Lascas on 09/06/2025.
//

import Foundation
import Combine
import UIKit

/// Mock implementation of `PromotionalBonusCardViewModelProtocol` for testing.
final public class MockPromotionalBonusCardViewModel: PromotionalBonusCardViewModelProtocol {
    
    // MARK: - Properties
    private let cardDataSubject: CurrentValueSubject<PromotionalBonusCardData, Never>
    public var cardDataPublisher: AnyPublisher<PromotionalBonusCardData, Never> {
        return cardDataSubject.eraseToAnyPublisher()
    }
    
    // MARK: - Initialization
    public init(cardData: PromotionalBonusCardData) {
        self.cardDataSubject = CurrentValueSubject(cardData)
    }
    
    // MARK: - PromotionalBonusCardViewModelProtocol
    public func claimBonusTapped() {
        let currentData = cardDataSubject.value
        print("Claim bonus tapped for: \(currentData.id)")
        // In real implementation, this would trigger bonus claiming logic
    }
    
    public func termsTapped() {
        let currentData = cardDataSubject.value
        print("Terms tapped for: \(currentData.id)")
        // In real implementation, this would show terms and conditions
    }
}

// MARK: - Mock Factory
extension MockPromotionalBonusCardViewModel {
    
    /// Default mock matching the image
    public static var defaultMock: MockPromotionalBonusCardViewModel {
        let userAvatars = [
            UserAvatar(id: "user1", imageName: "avatar1"),
            UserAvatar(id: "user2", imageName: "avatar2"),
            UserAvatar(id: "user3", imageName: "avatar3"),
            UserAvatar(id: "user4", imageName: "avatar4")
        ]
        
        let cardData = PromotionalBonusCardData(
            id: "betsson_double",
            headerText: "The Betsson Double",
            mainTitle: "Deposit XAF 1000 and play with XAF 2000",
            userAvatars: userAvatars,
            playersCount: "12.6k",
            backgroundImageName: "promo_card_background",
            claimButtonTitle: "Claim bonus",
            termsButtonTitle: "Terms and Conditions"
        )
        
        return MockPromotionalBonusCardViewModel(cardData: cardData)
    }
    
    /// Alternative promotion mock
    public static var welcomeBonusMock: MockPromotionalBonusCardViewModel {
        let userAvatars = [
            UserAvatar(id: "user1", imageName: nil), // Will use placeholder
            UserAvatar(id: "user2", imageName: nil),
            UserAvatar(id: "user3", imageName: nil)
        ]
        
        let cardData = PromotionalBonusCardData(
            id: "welcome_bonus",
            headerText: "Welcome Bonus",
            mainTitle: "Get 100% match bonus up to XAF 5000",
            userAvatars: userAvatars,
            playersCount: "8.2k",
            backgroundImageName: nil,
            claimButtonTitle: "Get Welcome Bonus",
            termsButtonTitle: "Terms and Conditions"
        )
        
        return MockPromotionalBonusCardViewModel(cardData: cardData)
    }
    
    /// Weekend special mock
    public static var weekendSpecialMock: MockPromotionalBonusCardViewModel {
        let userAvatars = [
            UserAvatar(id: "user1", imageName: nil),
            UserAvatar(id: "user2", imageName: nil),
            UserAvatar(id: "user3", imageName: nil),
            UserAvatar(id: "user4", imageName: nil)
        ]
        
        let cardData = PromotionalBonusCardData(
            id: "weekend_special",
            headerText: "Weekend Special",
            mainTitle: "50% Bonus on all deposits this weekend",
            userAvatars: userAvatars,
            playersCount: "3.1k",
            backgroundImageName: nil,
            claimButtonTitle: "Claim Weekend Bonus",
            termsButtonTitle: "View Terms"
        )
        
        return MockPromotionalBonusCardViewModel(cardData: cardData)
    }
}
