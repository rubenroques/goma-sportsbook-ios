import Foundation
import Combine
import UIKit

// MARK: - Data Models
public struct PromotionalBonusCardsData: Equatable {
    public let id: String
    public let cards: [PromotionalBonusCardData]
    
    public init(id: String, cards: [PromotionalBonusCardData]) {
        self.id = id
        self.cards = cards
    }
}

// MARK: - View Model Protocol
public protocol PromotionalBonusCardsScrollViewModelProtocol {
    /// Publisher for reactive updates
    var cardsDataPublisher: AnyPublisher<PromotionalBonusCardsData, Never> { get }
    
    /// Actions
    func cardClaimBonusTapped(cardId: String)
    func cardTermsTapped(cardId: String)
}
