//
//  MockBonusCardViewModel.swift
//  GomaUI
//
//  Created by Claude on 23/10/2025.
//

import Foundation
import Combine
import UIKit

public class MockBonusCardViewModel: BonusCardViewModelProtocol {
    
    // MARK: - Properties
    private let displayStateSubject = CurrentValueSubject<BonusCardDisplayState, Never>(
        BonusCardDisplayState(
            cardData: BonusCardData(
                id: "",
                title: "",
                description: "",
                imageURL: "",
                ctaText: "",
                termsText: ""
            )
        )
    )
    
    public var displayStatePublisher: AnyPublisher<BonusCardDisplayState, Never> {
        displayStateSubject.eraseToAnyPublisher()
    }
    
    // MARK: - Button ViewModels
    public let ctaButtonViewModel: ButtonViewModelProtocol
    public let termsButtonViewModel: ButtonViewModelProtocol
    
    // MARK: - Callbacks
    public var onCTATapped: ((String?) -> Void)?
    public var onTermsTapped: ((String?) -> Void)?
    public var onCardTapped: (() -> Void)?
    
    // MARK: - Initialization
    public init(cardData: BonusCardData) {
        // Initialize display state
        self.displayStateSubject.send(BonusCardDisplayState(cardData: cardData))
        
        // Initialize CTA button ViewModel
        let ctaButtonData = ButtonData(
            id: "bonus_cta_\(cardData.id)",
            title: cardData.ctaText,
            style: .solidBackground,
            isEnabled: true
        )
        self.ctaButtonViewModel = MockButtonViewModel(buttonData: ctaButtonData)
        
        // Initialize Terms button ViewModel
        let termsButtonData = ButtonData(
            id: "bonus_terms_\(cardData.id)",
            title: cardData.termsText,
            style: .solidBackground,
            backgroundColor: .clear,
            disabledBackgroundColor: .clear,
            textColor: StyleProvider.Color.highlightPrimary,
            isEnabled: true
        )
        self.termsButtonViewModel = MockButtonViewModel(buttonData: termsButtonData)
        
        // Setup button callbacks
        self.setupButtonCallbacks()
    }
    
    // MARK: - Actions
    public func didTapCTAButton() {
        let currentState = displayStateSubject.value
        print("Mock BonusCardViewModel: CTA button tapped for bonus '\(currentState.title)'")
        
        // Call external callback if set
        onCTATapped?(currentState.ctaURL)
    }
    
    public func didTapTerms() {
        let currentState = displayStateSubject.value
        print("Mock BonusCardViewModel: Terms tapped for bonus '\(currentState.title)'")
        
        // Call externak callback if set
        onTermsTapped?(currentState.termsURL)
    }
    
    public func didTapCard() {
        let currentState = displayStateSubject.value
        print("Mock BonusCardViewModel: Card tapped for bonus '\(currentState.title)'")
        
        // Call external callback if set
        onCardTapped?()
    }
    
    // MARK: - Configuration
    public func configure(with cardData: BonusCardData) {
        self.displayStateSubject.send(BonusCardDisplayState(cardData: cardData))
        
        // Update CTA button state
        self.ctaButtonViewModel.updateTitle(cardData.ctaText)
        self.ctaButtonViewModel.setEnabled(true)
        
        // Update Terms button state
        self.termsButtonViewModel.updateTitle(cardData.termsText)
        self.termsButtonViewModel.setEnabled(cardData.termsURL != nil)
    }
    
    // MARK: - Private Methods
    private func setupButtonCallbacks() {
        // Setup CTA button callback
        if let ctaButtonViewModel = self.ctaButtonViewModel as? MockButtonViewModel {
            ctaButtonViewModel.onButtonTapped = { [weak self] in
                self?.didTapCTAButton()
            }
        }
        
        // Setup Terms button callback
        if let termsButtonViewModel = self.termsButtonViewModel as? MockButtonViewModel {
            termsButtonViewModel.onButtonTapped = { [weak self] in
                self?.didTapTerms()
            }
        }
    }
}

// MARK: - Static Factory Methods
extension MockBonusCardViewModel {
    
    public static var defaultMock: MockBonusCardViewModel {
        return MockBonusCardViewModel(cardData: BonusCardData(
            id: "1",
            title: "Welcome Bonus Package",
            description: "Get 100% match bonus up to $500 on your first deposit. Plus 50 free spins on selected slots.",
            imageURL: "https://cms.gomademo.com/storage/323/01K5RJXQY7YEZKSXNBWF7TKBFS.jpg",
            tag: "Popular",
            ctaText: "Claim Bonus",
            ctaURL: "https://example.com/claim-bonus",
            termsText: "Terms & Conditions Apply",
            termsURL: "https://example.com/terms"
        ))
    }
    
    public static var noURLsMock: MockBonusCardViewModel {
        return MockBonusCardViewModel(cardData: BonusCardData(
            id: "2",
            title: "Daily Rewards Program",
            description: "Earn points every day you play. Redeem points for cash bonuses and exclusive prizes.",
            imageURL: "https://cms.gomademo.com/storage/325/01K5S2EKCJP8P3BF4S6VXJ6X5Y.svg",
            tag: "New",
            ctaText: "Join Now",
            ctaURL: nil,
            termsText: "Wagering requirements apply",
            termsURL: nil
        ))
    }
    
    public static var casinoBonusMock: MockBonusCardViewModel {
        return MockBonusCardViewModel(cardData: BonusCardData(
            id: "3",
            title: "Casino Cashback Bonus",
            description: "Get 10% cashback on all casino losses every week. No maximum limit.",
            imageURL: "https://cms.gomademo.com/storage/323/01K5RJXQY7YEZKSXNBWF7TKBFS.jpg",
            tag: "Casino",
            ctaText: "Activate Cashback",
            ctaURL: "https://example.com/activate-cashback",
            termsText: "See full terms",
            termsURL: "https://example.com/cashback-terms"
        ))
    }
    
    public static var sportsBonusMock: MockBonusCardViewModel {
        return MockBonusCardViewModel(cardData: BonusCardData(
            id: "4",
            title: "Sports Free Bet",
            description: "Place a qualifying bet and get a risk-free bet up to $50 if you lose.",
            imageURL: "https://cms.gomademo.com/storage/325/01K5S2EKCJP8P3BF4S6VXJ6X5Y.svg",
            tag: "Sports",
            ctaText: "Get Free Bet",
            ctaURL: "https://example.com/free-bet",
            termsText: "18+. Bet responsibly",
            termsURL: nil
        ))
    }
    
    public static var vipBonusMock: MockBonusCardViewModel {
        return MockBonusCardViewModel(cardData: BonusCardData(
            id: "5",
            title: "VIP Exclusive Bonus",
            description: "Exclusive bonus for VIP members. Enhanced odds, priority support, and monthly cashback.",
            imageURL: "https://cms.gomademo.com/storage/323/01K5RJXQY7YEZKSXNBWF7TKBFS.jpg",
            tag: "VIP Only",
            ctaText: "Claim VIP Bonus",
            ctaURL: "https://example.com/vip-bonus",
            termsText: "VIP terms and conditions",
            termsURL: "https://example.com/vip-terms"
        ))
    }
    
    public static var noTagMock: MockBonusCardViewModel {
        return MockBonusCardViewModel(cardData: BonusCardData(
            id: "6",
            title: "Reload Bonus",
            description: "Get a 50% bonus on every deposit you make this month. Available for all players.",
            imageURL: "https://cms.gomademo.com/storage/325/01K5S2EKCJP8P3BF4S6VXJ6X5Y.svg",
            tag: nil,
            ctaText: "Deposit Now",
            ctaURL: "https://example.com/deposit",
            termsText: "Minimum deposit $20. Terms apply.",
            termsURL: "https://example.com/reload-terms"
        ))
    }
}

