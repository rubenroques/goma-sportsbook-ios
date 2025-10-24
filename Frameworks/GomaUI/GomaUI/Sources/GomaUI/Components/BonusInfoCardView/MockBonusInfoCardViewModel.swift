//
//  MockBonusInfoCardViewModel.swift
//  GomaUI
//
//  Created by Claude on October 24, 2025.
//

import Foundation
import Combine

/// Mock implementation of BonusInfoCardViewModelProtocol for testing and previews
public class MockBonusInfoCardViewModel: BonusInfoCardViewModelProtocol {
    
    // MARK: - Properties
    private let displayStateSubject = CurrentValueSubject<BonusInfoCardDisplayState, Never>(
        BonusInfoCardDisplayState(
            cardData: BonusInfoCardData(
                id: "",
                title: "",
                status: .active,
                bonusAmount: 0.0,
                remainingAmount: 0.0,
                currency: "XAF",
                initialWagerAmount: 0.0,
                remainingToWagerAmount: 0.0,
                expiryText: ""
            )
        )
    )
    
    public var displayStatePublisher: AnyPublisher<BonusInfoCardDisplayState, Never> {
        displayStateSubject.eraseToAnyPublisher()
    }
    
    // MARK: - Callbacks
    public var onTermsTapped: ((String) -> Void)?
    
    // MARK: - Initialization
    public init(cardData: BonusInfoCardData) {
        self.displayStateSubject.send(BonusInfoCardDisplayState(cardData: cardData))
    }
    
    // MARK: - Actions
    public func didTapTermsAndConditions() {
        let currentState = displayStateSubject.value
        print("📄 Terms & Conditions tapped for: \(currentState.title)")
        onTermsTapped?(currentState.cardData.actionUrl ?? "")
    }
    
    // MARK: - Configuration
    public func configure(with cardData: BonusInfoCardData) {
        self.displayStateSubject.send(BonusInfoCardDisplayState(cardData: cardData))
    }
    
    // MARK: - Preset Mocks
    
    /// Complete bonus with all features including header image (combo type)
    public static var complete: MockBonusInfoCardViewModel {
        MockBonusInfoCardViewModel(cardData: BonusInfoCardData(
            id: "1",
            title: "Casino Welcome Bonus",
            subtitle: "oddsBoost",
            status: .active,
            headerImageURL: "https://cms.gomademo.com/storage/323/01K5RJXQY7YEZKSXNBWF7TKBFS.jpg",
            bonusAmountType: .combo,
            bonusAmount: 2000.00,
            remainingAmount: 3000.00,
            currency: "XAF",
            initialWagerAmount: 4500.00,
            remainingToWagerAmount: 1500.00,
            expiryText: "Sun 01/01 - 18:59"
        ))
    }
    
    /// Simple bonus with header image (simple type)
    public static var simple: MockBonusInfoCardViewModel {
        MockBonusInfoCardViewModel(cardData: BonusInfoCardData(
            id: "1b",
            title: "Casino Welcome Bonus",
            subtitle: "oddsBoost",
            status: .active,
            headerImageURL: "https://cms.gomademo.com/storage/323/01K5RJXQY7YEZKSXNBWF7TKBFS.jpg",
            bonusAmountType: .simple,
            bonusAmount: 2000.00,
            remainingAmount: 3000.00,
            currency: "XAF",
            initialWagerAmount: 4500.00,
            remainingToWagerAmount: 1500.00,
            expiryText: "Sun 01/01 - 18:59",
            actionUrl: "https://www.google.com"
        ))
    }
    
    /// Bonus without header image
    public static var withoutHeader: MockBonusInfoCardViewModel {
        MockBonusInfoCardViewModel(cardData: BonusInfoCardData(
            id: "2",
            title: "Weekly Cashback Bonus",
            subtitle: "cashback",
            status: .active,
            headerImageURL: nil,
            bonusAmount: 5000.00,
            remainingAmount: 5000.00,
            currency: "XAF",
            initialWagerAmount: 15000.00,
            remainingToWagerAmount: 15000.00,
            expiryText: "Fri 12/31 - 23:59"
        ))
    }
    
    /// Bonus without remaining wager text
    public static var withoutRemainingText: MockBonusInfoCardViewModel {
        MockBonusInfoCardViewModel(cardData: BonusInfoCardData(
            id: "3",
            title: "Birthday Bonus",
            subtitle: nil,
            status: .active,
            headerImageURL: "https://cms.gomademo.com/storage/325/01K5S2EKCJP8P3BF4S6VXJ6X5Y.svg",
            bonusAmount: 1000.00,
            remainingAmount: 4000.00,
            currency: "XAF",
            initialWagerAmount: 3000.00,
            remainingToWagerAmount: 0.00,
            expiryText: "Mon 05/15 - 12:00"
        ))
    }
    
    /// Released bonus (completed)
    public static var released: MockBonusInfoCardViewModel {
        MockBonusInfoCardViewModel(cardData: BonusInfoCardData(
            id: "4",
            title: "First Deposit Bonus",
            subtitle: "welcome",
            status: .released,
            headerImageURL: nil,
            bonusAmount: 10000.00,
            remainingAmount: 10000.00,
            currency: "XAF",
            initialWagerAmount: 30000.00,
            remainingToWagerAmount: 0.00,
            expiryText: "Released on 10/20"
        ))
    }
    
    /// Minimal bonus (no header, no subtitle, no remaining text)
    public static var minimal: MockBonusInfoCardViewModel {
        MockBonusInfoCardViewModel(cardData: BonusInfoCardData(
            id: "5",
            title: "Loyalty Reward",
            subtitle: nil,
            status: .active,
            headerImageURL: nil,
            bonusAmount: 500.00,
            remainingAmount: 1000.00,
            currency: "XAF",
            initialWagerAmount: 2000.00,
            remainingToWagerAmount: 1000.00,
            expiryText: "Today - 18:00"
        ))
    }
    
    /// High progress bonus (almost complete)
    public static var almostComplete: MockBonusInfoCardViewModel {
        MockBonusInfoCardViewModel(cardData: BonusInfoCardData(
            id: "6",
            title: "VIP Exclusive Bonus",
            subtitle: "vipBonus",
            status: .active,
            headerImageURL: "https://cms.gomademo.com/storage/323/01K5RJXQY7YEZKSXNBWF7TKBFS.jpg",
            bonusAmount: 25000.00,
            remainingAmount: 26250.00,
            currency: "XAF",
            initialWagerAmount: 12500.00,
            remainingToWagerAmount: 625.00,
            expiryText: "Tomorrow - 23:59"
        ))
    }
}

