//
//  BonusInfoCardViewModelProtocol.swift
//  GomaUI
//
//  Created by Claude on October 24, 2025.
//

import Foundation
import Combine

// MARK: - Data Models

/// Data model for bonus information card
public struct BonusInfoCardData: Equatable, Hashable {
    public let id: String
    public let title: String
    public let subtitle: String?
    public let status: BonusStatus
    public let headerImageURL: String?
    public let bonusAmountType: BonusAmountType
    public let bonusAmount: Double
    public let remainingAmount: Double
    public let currency: String
    public let initialWagerAmount: Double
    public let remainingToWagerAmount: Double
    public let expiryText: String
    public let actionUrl: String?
    
    public init(
        id: String,
        title: String,
        subtitle: String? = nil,
        status: BonusStatus,
        headerImageURL: String? = nil,
        bonusAmountType: BonusAmountType = .combo,
        bonusAmount: Double,
        remainingAmount: Double,
        currency: String,
        initialWagerAmount: Double,
        remainingToWagerAmount: Double,
        expiryText: String,
        actionUrl: String? = nil
    ) {
        self.id = id
        self.title = title
        self.subtitle = subtitle
        self.status = status
        self.headerImageURL = headerImageURL
        self.bonusAmountType = bonusAmountType
        self.bonusAmount = bonusAmount
        self.remainingAmount = remainingAmount
        self.currency = currency
        self.initialWagerAmount = initialWagerAmount
        self.remainingToWagerAmount = remainingToWagerAmount
        self.expiryText = expiryText
        self.actionUrl = actionUrl
    }
}

// MARK: - Display State

/// Display state for bonus information card
public struct BonusInfoCardDisplayState: Equatable {
    public let cardData: BonusInfoCardData
    public let isVisible: Bool
    
    public init(cardData: BonusInfoCardData, isVisible: Bool = true) {
        self.cardData = cardData
        self.isVisible = isVisible
    }
    
    // Convenience properties for easier access
    public var id: String { cardData.id }
    public var title: String { cardData.title }
    public var subtitle: String? { cardData.subtitle }
    public var status: BonusStatus { cardData.status }
    public var headerImageURL: String? { cardData.headerImageURL }
    public var bonusAmountType: BonusAmountType { cardData.bonusAmountType }
    public var expiryText: String { cardData.expiryText }
    public var hasHeaderImage: Bool { cardData.headerImageURL != nil }
    
    // Calculated properties
    public var wageringProgress: Float {
        guard cardData.initialWagerAmount > 0 else { return 0.0 }
        guard cardData.remainingToWagerAmount >= 0 else { return 0.0 }
        
        let wagered = cardData.initialWagerAmount - cardData.remainingToWagerAmount
        let progress = Float(wagered / cardData.initialWagerAmount)
        return min(max(progress, 0.0), 1.0)
    }
    
    // Formatted display strings
    public var bonusAmountText: String {
        formatCurrency(cardData.bonusAmount, currency: cardData.currency)
    }
    
    public var remainingAmountText: String {
        formatCurrency(cardData.remainingAmount, currency: cardData.currency)
    }
    
    public var remainingToWagerText: String? {
        guard cardData.remainingToWagerAmount > 0 else {
            return nil
        }
        return "+ \(formatCurrency(cardData.remainingToWagerAmount, currency: cardData.currency)) remaining to wager"
    }
    
    // Helper method for currency formatting
    private func formatCurrency(_ amount: Double, currency: String) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.minimumFractionDigits = 2
        formatter.maximumFractionDigits = 2
        formatter.groupingSeparator = " "
        
        if let formattedAmount = formatter.string(from: NSNumber(value: amount)) {
            return "\(currency) \(formattedAmount)"
        }
        return "\(currency) \(String(format: "%.2f", amount))"
    }
}

// MARK: - View Model Protocol

/// Protocol defining the interface for BonusInfoCardView view model
public protocol BonusInfoCardViewModelProtocol {
    /// Publisher for reactive updates
    var displayStatePublisher: AnyPublisher<BonusInfoCardDisplayState, Never> { get }
    
    /// Actions
    func didTapTermsAndConditions()
    
    /// Configuration
    func configure(with cardData: BonusInfoCardData)
}

