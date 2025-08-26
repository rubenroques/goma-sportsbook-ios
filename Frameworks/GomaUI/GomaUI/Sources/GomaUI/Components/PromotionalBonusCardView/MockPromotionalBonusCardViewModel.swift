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
            termsButtonTitle: "Terms and Conditions",
            bonusAmount: 1000
        )
        
        return MockPromotionalBonusCardViewModel(cardData: cardData)
    }
    
    /// No gradient mock
    public static var noGradientMock: MockPromotionalBonusCardViewModel {
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
            hasGradientView: false,
            claimButtonTitle: "Claim bonus",
            termsButtonTitle: "Terms and Conditions",
            bonusAmount: 1000
        )
        
        return MockPromotionalBonusCardViewModel(cardData: cardData)
    }
    
}
