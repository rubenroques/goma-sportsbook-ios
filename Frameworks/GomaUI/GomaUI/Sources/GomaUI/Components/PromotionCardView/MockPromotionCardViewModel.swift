//
//  MockPromotionCardViewModel.swift
//  GomaUI
//
//  Created on 29/08/2025.
//

import Foundation
import Combine
import UIKit

public class MockPromotionCardViewModel: PromotionCardViewModelProtocol {
    
    // MARK: - Properties
    private let displayStateSubject = CurrentValueSubject<PromotionCardDisplayState, Never>(PromotionCardDisplayState(cardData: PromotionCardData(id: "", title: "", description: "", imageURL: "")))
    
    public var displayStatePublisher: AnyPublisher<PromotionCardDisplayState, Never> {
        displayStateSubject.eraseToAnyPublisher()
    }
    
    // MARK: - Button ViewModels
    public let ctaButtonViewModel: ButtonViewModelProtocol
    public let readMoreButtonViewModel: ButtonViewModelProtocol
    
    // MARK: - Callbacks
    public var onCTATapped: ((String) -> Void)?
    public var onReadMoreTapped: (() -> Void)?
    public var onCardTapped: (() -> Void)?
    
    // MARK: - Initialization
    public init(cardData: PromotionCardData) {
        // Initialize display state
        self.displayStateSubject.send(PromotionCardDisplayState(cardData: cardData))
        
        // Initialize CTA button ViewModel
        let ctaButtonData = ButtonData(
            id: "promotion_cta_\(cardData.id)",
            title: cardData.ctaText ?? "Action",
            style: .solidBackground,
            isEnabled: cardData.ctaText != nil
        )
        self.ctaButtonViewModel = MockButtonViewModel(buttonData: ctaButtonData)
        
        // Initialize Read More button ViewModel
        let readMoreButtonData = ButtonData(
            id: "promotion_read_more_\(cardData.id)",
            title: "Read more",
            style: .solidBackground,
            backgroundColor: .clear,
            disabledBackgroundColor: .clear,
            textColor: StyleProvider.Color.highlightPrimary,
            isEnabled: cardData.showReadMoreButton
        )
        self.readMoreButtonViewModel = MockButtonViewModel(buttonData: readMoreButtonData)
        
        // Setup button callbacks
        self.setupButtonCallbacks()
    }
    
    // MARK: - Actions
    public func didTapCTAButton() {
        let currentState = displayStateSubject.value
        print("Mock PromotionCardViewModel: CTA button tapped for promotion '\(currentState.title)'")
        
        // Call external callback if set
        if let ctaURL = currentState.ctaURL {
            onCTATapped?(ctaURL)
        }
                
    }
    
    public func didTapReadMoreButton() {
        let currentState = displayStateSubject.value
        print("Mock PromotionCardViewModel: Read more button tapped for promotion '\(currentState.title)'")
        
        // Call external callback if set
        onReadMoreTapped?()
        
    }
    
    public func didTapCard() {
        let currentState = displayStateSubject.value
        print("Mock PromotionCardViewModel: Card tapped for promotion '\(currentState.title)'")
        
        // Call external callback if set
        onCardTapped?()
    }
    
    // MARK: - Configuration
    public func configure(with cardData: PromotionCardData) {
        self.displayStateSubject.send(PromotionCardDisplayState(cardData: cardData))
        
        // Update button states
        self.ctaButtonViewModel.updateTitle(cardData.ctaText ?? "Action")
        self.ctaButtonViewModel.setEnabled(cardData.ctaText != nil)
        self.readMoreButtonViewModel.setEnabled(cardData.showReadMoreButton)
    }
    
    // MARK: - Private Methods
    private func setupButtonCallbacks() {
        // Setup CTA button callback
        if let ctaButtonViewModel = self.ctaButtonViewModel as? MockButtonViewModel {
            ctaButtonViewModel.onButtonTapped = { [weak self] in
                self?.didTapCTAButton()
            }
        }
        
        // Setup Read More button callback
        if let readMoreButtonViewModel = self.readMoreButtonViewModel as? MockButtonViewModel {
            readMoreButtonViewModel.onButtonTapped = { [weak self] in
                self?.didTapReadMoreButton()
            }
        }
    }
}

// MARK: - Static Factory Methods
extension MockPromotionCardViewModel {
    
    public static var defaultMock: MockPromotionCardViewModel {
        return MockPromotionCardViewModel(cardData: PromotionCardData(
            id: "1",
            title: "Welcome Bonus",
            description: "Get a 100% match bonus up to $500 on your first deposit. Perfect for new players looking to maximize their gaming experience.",
            imageURL: "https://cms.gomademo.com/storage/323/01K5RJXQY7YEZKSXNBWF7TKBFS.jpg",
            tag: "Limited",
            ctaText: "Claim Bonus",
            ctaURL: "https://www.google.com",
            showReadMoreButton: true
        ))
    }
    
    public static var casinoMock: MockPromotionCardViewModel {
        return MockPromotionCardViewModel(cardData: PromotionCardData(
            id: "2",
            title: "Casino Tournament",
            description: "Join our weekly casino tournament and compete for amazing prizes. Top players win cash rewards and exclusive bonuses.",
            imageURL: "https://cms.gomademo.com/storage/325/01K5S2EKCJP8P3BF4S6VXJ6X5Y.svg",
            tag: "Casino",
            ctaText: "Join Now",
            ctaURL: "https://www.google.com",
            showReadMoreButton: true
        ))
    }
    
    public static var sportsbookMock: MockPromotionCardViewModel {
        return MockPromotionCardViewModel(cardData: PromotionCardData(
            id: "3",
            title: "Sports Betting Bonus",
            description: "Enhanced odds on major sports events. Get better returns on your favorite teams and sports.",
            imageURL: "https://cms.gomademo.com/storage/323/01K5RJXQY7YEZKSXNBWF7TKBFS.jpg",
            tag: "Sportsbook",
            ctaText: "Place Bet",
            ctaURL: "https://www.google.com",
            showReadMoreButton: false
        ))
    }
    
    public static var noCTAMock: MockPromotionCardViewModel {
        return MockPromotionCardViewModel(cardData: PromotionCardData(
            id: "4",
            title: "Information Only",
            description: "This is an informational promotion with no call-to-action button. Users can read more to get additional details.",
            imageURL: "https://cms.gomademo.com/storage/325/01K5S2EKCJP8P3BF4S6VXJ6X5Y.svg",
            tag: "Info",
            ctaText: nil,
            ctaURL: nil,
            showReadMoreButton: true
        ))
    }
    
    public static var longTitleMock: MockPromotionCardViewModel {
        return MockPromotionCardViewModel(cardData: PromotionCardData(
            id: "5",
            title: "This is a Very Long Promotion Title That Should Test How the Component Handles Multiple Lines",
            description: "This promotion has an extremely long title to test the layout and text wrapping capabilities of the component. It should properly handle multiple lines and maintain good visual hierarchy.",
            imageURL: "https://cms.gomademo.com/storage/323/01K5RJXQY7YEZKSXNBWF7TKBFS.jpg",
            tag: "Long Title Test",
            ctaText: "Learn More",
            ctaURL: "https://www.google.com",
            showReadMoreButton: true
        ))
    }
    
    public static var noTagMock: MockPromotionCardViewModel {
        return MockPromotionCardViewModel(cardData: PromotionCardData(
            id: "6",
            title: "No Tag Promotion",
            description: "This promotion has no tag to test the layout when the tag view is hidden.",
            imageURL: "https://cms.gomademo.com/storage/325/01K5S2EKCJP8P3BF4S6VXJ6X5Y.svg",
            tag: nil,
            ctaText: "Get Started",
            ctaURL: "https://www.google.com",
            showReadMoreButton: true
        ))
    }
}
