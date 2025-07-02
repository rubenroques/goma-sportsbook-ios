//
//  MockPromotionalBonusCardsScrollViewModel.swift
//  GomaUI
//
//  Created by André Lascas on 11/06/2025.
//

import Foundation
import Combine
import UIKit

/// Mock implementation of `PromotionalBonusCardsScrollViewModelProtocol` for testing.
final public class MockPromotionalBonusCardsScrollViewModel: PromotionalBonusCardsScrollViewModelProtocol {
    
    // MARK: - Properties
    private let cardsDataSubject: CurrentValueSubject<PromotionalBonusCardsData, Never>
    public var cardsDataPublisher: AnyPublisher<PromotionalBonusCardsData, Never> {
        return cardsDataSubject.eraseToAnyPublisher()
    }
    
    // MARK: - Initialization
    public init(cardsData: PromotionalBonusCardsData) {
        self.cardsDataSubject = CurrentValueSubject(cardsData)
    }
    
    // MARK: - PromotionalBonusCardsScrollViewModelProtocol
    public func cardClaimBonusTapped(cardId: String) {
        print("Claim bonus tapped for card: \(cardId)")
        // In real implementation, this would trigger the appropriate bonus claiming flow
    }
    
    public func cardTermsTapped(cardId: String) {
        print("Terms tapped for card: \(cardId)")
        // In real implementation, this would show terms and conditions for that specific bonus
    }
}

// MARK: - Mock Factory
extension MockPromotionalBonusCardsScrollViewModel {
    
    /// Default mock with multiple cards matching the image
    public static var defaultMock: MockPromotionalBonusCardsScrollViewModel {
        
        // First card - The Betsson Double
        let userAvatars1 = [
            UserAvatar(id: "user1", imageName: "avatar1"),
            UserAvatar(id: "user2", imageName: "avatar2"),
            UserAvatar(id: "user3", imageName: "avatar3"),
            UserAvatar(id: "user4", imageName: "avatar4")
        ]
        
        let card1 = PromotionalBonusCardData(
            id: "betsson_double",
            headerText: "The Betsson Double",
            mainTitle: "Deposit XAF 1000 and play with XAF 2000",
            userAvatars: userAvatars1,
            playersCount: "12.6k",
            backgroundImageName: "bonus_card_background",
            bonusAmount: 1000
        )
        
        // Second card - Welcome Bonus
        let userAvatars2 = [
            UserAvatar(id: "user5", imageName: nil),
            UserAvatar(id: "user6", imageName: nil),
            UserAvatar(id: "user7", imageName: nil)
        ]
        
        let card2 = PromotionalBonusCardData(
            id: "welcome_bonus",
            headerText: "Welcome Bonus",
            mainTitle: "Get 100% match bonus up to XAF 5000",
            userAvatars: userAvatars2,
            playersCount: "8.2k",
            backgroundImageName: nil,
            bonusAmount: 100
        )
        
        // Third card - Weekend Special
        let userAvatars3 = [
            UserAvatar(id: "user8", imageName: nil),
            UserAvatar(id: "user9", imageName: nil),
            UserAvatar(id: "user10", imageName: nil),
            UserAvatar(id: "user11", imageName: nil)
        ]
        
        let card3 = PromotionalBonusCardData(
            id: "weekend_special",
            headerText: "Weekend Special",
            mainTitle: "50% Bonus on all deposits this weekend",
            userAvatars: userAvatars3,
            playersCount: "3.1k",
            backgroundImageName: nil,
            bonusAmount: 50
        )
        
        // Fourth card - VIP Bonus
        let userAvatars4 = [
            UserAvatar(id: "user12", imageName: nil),
            UserAvatar(id: "user13", imageName: nil)
        ]
        
        let card4 = PromotionalBonusCardData(
            id: "vip_bonus",
            headerText: "VIP Exclusive",
            mainTitle: "Triple your deposit for VIP members only",
            userAvatars: userAvatars4,
            playersCount: "1.8k",
            backgroundImageName: nil,
            bonusAmount: 300
        )
        
        let cardsData = PromotionalBonusCardsData(
            id: "promotional_cards_scroll",
            cards: [card1, card2, card3, card4]
        )
        
        return MockPromotionalBonusCardsScrollViewModel(cardsData: cardsData)
    }
    
    /// Mock with fewer cards
    public static var shortListMock: MockPromotionalBonusCardsScrollViewModel {
        let userAvatars = [
            UserAvatar(id: "user1", imageName: nil),
            UserAvatar(id: "user2", imageName: nil)
        ]
        
        let card1 = PromotionalBonusCardData(
            id: "quick_bonus",
            headerText: "Quick Start",
            mainTitle: "Instant 50% bonus on first deposit",
            userAvatars: userAvatars,
            playersCount: "2.5k",
            backgroundImageName: nil,
            bonusAmount: 50
        )
        
        let card2 = PromotionalBonusCardData(
            id: "daily_bonus",
            headerText: "Daily Special",
            mainTitle: "Daily cashback up to 10%",
            userAvatars: userAvatars,
            playersCount: "4.1k",
            backgroundImageName: nil,
            bonusAmount: 10
        )
        
        let cardsData = PromotionalBonusCardsData(
            id: "short_promotional_cards",
            cards: [card1, card2]
        )
        
        return MockPromotionalBonusCardsScrollViewModel(cardsData: cardsData)
    }
}
