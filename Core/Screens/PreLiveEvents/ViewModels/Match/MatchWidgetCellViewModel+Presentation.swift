//
//  MatchWidgetCellViewModel+Presentation.swift
//  Sportsbook
//
//  Created for refactoring in 2024.
//

import UIKit
import Combine
import ServicesProvider

// MARK: - Presentation Models

/// Represents the widget's appearance state
struct WidgetAppearance {
    let widgetType: MatchWidgetType
    let isLive: Bool
    let isLiveCard: Bool
    let shouldHideNormalGradient: Bool
    let shouldHideLiveGradient: Bool
}

/// Represents boosted odds information
struct BoostedOddsInfo {
    let title: String
    let oldValue: String
    let newValue: String
    let oldValueAttributed: NSAttributedString?
}

/// Position of an outcome in the cell
enum OutcomePosition {
    case left
    case middle
    case right
}

/// Direction of odds change
enum OddsChangeDirection {
    case up
    case down
    case none
}

/// Presentation model for an outcome
struct OutcomePresentation {
    let outcome: Outcome?
    let position: OutcomePosition
    let title: String
    let formattedValue: String
    let value: Double
    let isSelected: Bool
    let isInteractive: Bool
}

/// Presentation model for outcome updates (for highlighting changes)
struct OutcomeUpdate {
    let outcome: Outcome?
    let isAvailable: Bool
    let newValue: Double
    let formattedValue: String
    let changeDirection: OddsChangeDirection?
    let isSelected: Bool
}

/// Presentation model for market data
struct MarketPresentation {
    let market: Market?
    let marketName: String
    let widgetType: MatchWidgetType
    let isMarketAvailable: Bool
    let isCustomBetAvailable: Bool
    let shouldShowMarketPill: Bool
    let outcomes: [OutcomePresentation]
    let boostedOutcome: Bool?
}

// MARK: - ViewModel Extensions

extension MatchWidgetCellViewModel {
    
    // MARK: - Widget Appearance Publisher
    
    /// Publisher for widget appearance settings (live status, border visibility, etc.)
    var widgetAppearancePublisher: AnyPublisher<WidgetAppearance, Never> {
        return Publishers.CombineLatest3(
            self.matchWidgetStatusPublisher,
            self.matchWidgetTypePublisher,
            self.isLiveCardPublisher
        )
        .map { status, type, isLiveCard -> WidgetAppearance in
            let isLive = status == .live
            
            // Determine gradient visibility based on widget type and status
            let shouldHideNormalGradient: Bool
            let shouldHideLiveGradient: Bool
            
            switch type {
            case .normal, .boosted, .topImage, .topImageWithMixMatch:
                shouldHideNormalGradient = isLive
                shouldHideLiveGradient = !isLive
            case .backgroundImage, .topImageOutright:
                shouldHideNormalGradient = true
                shouldHideLiveGradient = true
            }
            
            return WidgetAppearance(
                widgetType: type,
                isLive: isLive,
                isLiveCard: isLiveCard,
                shouldHideNormalGradient: shouldHideNormalGradient,
                shouldHideLiveGradient: shouldHideLiveGradient
            )
        }
        .removeDuplicates { lhs, rhs in
            return lhs.widgetType == rhs.widgetType &&
                   lhs.isLive == rhs.isLive &&
                   lhs.isLiveCard == rhs.isLiveCard &&
                   lhs.shouldHideNormalGradient == rhs.shouldHideNormalGradient &&
                   lhs.shouldHideLiveGradient == rhs.shouldHideLiveGradient
        }
        .eraseToAnyPublisher()
    }

    
    // MARK: - Boosted Odds Publisher
    
    /// Publisher for boosted odds information
    var boostedOddsPublisher: AnyPublisher<BoostedOddsInfo, Never> {
        return Publishers.CombineLatest(
            self.matchPublisher,
            self.$oldBoostedOddOutcome
        )
        .map { match, oldBoostedOddOutcome -> BoostedOddsInfo in
            // Default values
            var title = ""
            var oldValue = "-"
            var newValue = "-"
            var oldValueAttributed: NSAttributedString?
            
            // Process market and outcome data if available
            if let newMarket = match.markets.first,
               let newOutcome = newMarket.outcomes.first {
                
                title = newOutcome.typeName
                newValue = OddFormatter.formatOdd(withValue: newOutcome.bettingOffer.decimalOdd)
                
                if let oldOutcome = oldBoostedOddOutcome {
                    oldValueAttributed = oldOutcome.valueAttributedString
                    oldValue = oldValue
                }
            }
            
            return BoostedOddsInfo(
                title: title,
                oldValue: oldValue,
                newValue: newValue,
                oldValueAttributed: oldValueAttributed
            )
        }
        .removeDuplicates { lhs, rhs in
            return lhs.title == rhs.title &&
                   lhs.oldValue == rhs.oldValue &&
                   lhs.newValue == rhs.newValue
        }
        .eraseToAnyPublisher()
    }
    
    // MARK: - Market Presentation Publisher
    
    /// Publisher for market and outcomes presentation data
    var marketPresentationPublisher: AnyPublisher<MarketPresentation, Never> {
        return Publishers.CombineLatest4(
            self.defaultMarketPublisher,
            self.isDefaultMarketAvailablePublisher,
            self.matchWidgetTypePublisher,
            self.matchWidgetStatusPublisher
        )
        .map { [weak self] market, isAvailable, widgetType, status -> MarketPresentation in
            guard let self = self else {
                return MarketPresentation(
                    market: nil,
                    marketName: "",
                    widgetType: widgetType,
                    isMarketAvailable: false,
                    isCustomBetAvailable: false,
                    shouldShowMarketPill: false,
                    outcomes: [],
                    boostedOutcome: nil
                )
            }
            
            let marketName = market?.name ?? ""
            
            // Determine if the market pill should be shown
            let shouldShowMarketPill = (widgetType == .normal && status == .live && market != nil) || 
                                       widgetType == .boosted
            
            // Check for custom bet availability
            let isCustomBetAvailable = market?.customBetAvailable ?? false
            
            var outcomes: [OutcomePresentation] = []
            var boostedOutcome: Bool? = nil
            
            if let market = market {
                if widgetType == .boosted, let outcome = market.outcomes.first {
                    // For boosted type, we just need to track selection
                    boostedOutcome = Env.betslipManager.hasBettingTicket(withId: outcome.bettingOffer.id)
                } else {
                    // For regular markets, create presentation models for each outcome
                    outcomes = self.createOutcomePresentations(from: market)
                }
            }
            
            return MarketPresentation(
                market: market,
                marketName: marketName,
                widgetType: widgetType,
                isMarketAvailable: isAvailable,
                isCustomBetAvailable: isCustomBetAvailable,
                shouldShowMarketPill: shouldShowMarketPill,
                outcomes: outcomes,
                boostedOutcome: boostedOutcome
            )
        }
        .eraseToAnyPublisher()
    }
    
    // MARK: - Outcome Update Publishers
    
    /// Publisher for left outcome updates
    var leftOutcomeUpdatesPublisher: AnyPublisher<OutcomeUpdate, ServiceProviderError> {
        return self.defaultMarketPublisher
            .compactMap { $0?.outcomes[safe: 0] }
            .flatMap { [weak self] outcome -> AnyPublisher<OutcomeUpdate, ServiceProviderError> in
                guard let self = self else {
                    return Just(OutcomeUpdate(
                        outcome: nil,
                        isAvailable: false,
                        newValue: 0,
                        formattedValue: "-",
                        changeDirection: nil,
                        isSelected: false
                    ))
                    .setFailureType(to: ServiceProviderError.self)
                    .eraseToAnyPublisher()
                }
                
                // Create the initial outcome update
                let initialUpdate = self.createOutcomeUpdate(outcome, currentValue: nil)
                
                // Subscribe to outcome updates from service provider
                return Env.servicesProvider
                    .subscribeToEventOnListsOutcomeUpdates(withId: outcome.bettingOffer.id)
                    .compactMap { $0 }
                    .map(ServiceProviderModelMapper.outcome(fromServiceProviderOutcome:))
                    .map { [weak self] updatedOutcome -> OutcomeUpdate in
                        guard let self = self else {
                            return initialUpdate
                        }
                        return self.createOutcomeUpdate(
                            updatedOutcome,
                            currentValue: initialUpdate.newValue
                        )
                    }
                    .prepend(initialUpdate)
                    .eraseToAnyPublisher()
            }
            .eraseToAnyPublisher()
    }
    
    /// Publisher for middle outcome updates
    var middleOutcomeUpdatesPublisher: AnyPublisher<OutcomeUpdate, ServiceProviderError> {
        return self.defaultMarketPublisher
            .compactMap { $0?.outcomes[safe: 1] }
            .flatMap { [weak self] outcome -> AnyPublisher<OutcomeUpdate, ServiceProviderError> in
                guard let self = self else {
                    return Just(OutcomeUpdate(
                        outcome: nil,
                        isAvailable: false,
                        newValue: 0,
                        formattedValue: "-",
                        changeDirection: nil,
                        isSelected: false
                    ))
                    .setFailureType(to: ServiceProviderError.self)
                    .eraseToAnyPublisher()
                }
                
                // Create the initial outcome update
                let initialUpdate = self.createOutcomeUpdate(outcome, currentValue: nil)
                
                // Subscribe to outcome updates from service provider
                return Env.servicesProvider
                    .subscribeToEventOnListsOutcomeUpdates(withId: outcome.bettingOffer.id)
                    .compactMap { $0 }
                    .map(ServiceProviderModelMapper.outcome(fromServiceProviderOutcome:))
                    .map { [weak self] updatedOutcome -> OutcomeUpdate in
                        guard let self = self else {
                            return initialUpdate
                        }
                        return self.createOutcomeUpdate(
                            updatedOutcome,
                            currentValue: initialUpdate.newValue
                        )
                    }
                    .prepend(initialUpdate)
                    .eraseToAnyPublisher()
            }
            .eraseToAnyPublisher()
    }
    
    /// Publisher for right outcome updates
    var rightOutcomeUpdatesPublisher: AnyPublisher<OutcomeUpdate, ServiceProviderError> {
        return self.defaultMarketPublisher
            .compactMap { $0?.outcomes[safe: 2] }
            .flatMap { [weak self] outcome -> AnyPublisher<OutcomeUpdate, ServiceProviderError> in
                guard let self = self else {
                    return Just(OutcomeUpdate(
                        outcome: nil,
                        isAvailable: false,
                        newValue: 0,
                        formattedValue: "-",
                        changeDirection: nil,
                        isSelected: false
                    ))
                    .setFailureType(to: ServiceProviderError.self)
                    .eraseToAnyPublisher()
                }
                
                // Create the initial outcome update
                let initialUpdate = self.createOutcomeUpdate(outcome, currentValue: nil)
                
                // Subscribe to outcome updates from service provider
                return Env.servicesProvider
                    .subscribeToEventOnListsOutcomeUpdates(withId: outcome.bettingOffer.id)
                    .compactMap { $0 }
                    .map(ServiceProviderModelMapper.outcome(fromServiceProviderOutcome:))
                    .map { [weak self] updatedOutcome -> OutcomeUpdate in
                        guard let self = self else {
                            return initialUpdate
                        }
                        return self.createOutcomeUpdate(
                            updatedOutcome,
                            currentValue: initialUpdate.newValue
                        )
                    }
                    .prepend(initialUpdate)
                    .eraseToAnyPublisher()
            }
            .eraseToAnyPublisher()
    }
    
    // MARK: - Helper Methods
    
    /// Creates outcome update objects for real-time odds changes
    private func createOutcomeUpdate(_ outcome: Outcome, currentValue: Double?) -> OutcomeUpdate {
        let bettingOffer = outcome.bettingOffer
        let newValue = bettingOffer.decimalOdd
        let isAvailable = bettingOffer.isAvailable && !newValue.isNaN
        let formattedValue = isAvailable ? OddFormatter.formatOdd(withValue: newValue) : "-"
        let isSelected = Env.betslipManager.hasBettingTicket(withId: bettingOffer.id)
        
        // Determine change direction if we have a current value
        var changeDirection: OddsChangeDirection = .none
        if let currentValue = currentValue, isAvailable {
            if newValue > currentValue {
                changeDirection = .up
            } else if newValue < currentValue {
                changeDirection = .down
            }
        }
        
        return OutcomeUpdate(
            outcome: outcome,
            isAvailable: isAvailable,
            newValue: newValue,
            formattedValue: formattedValue,
            changeDirection: changeDirection,
            isSelected: isSelected
        )
    }
    
    /// Creates outcome presentation models from a market
    private func createOutcomePresentations(from market: Market) -> [OutcomePresentation] {
        var presentations: [OutcomePresentation] = []
        
        // Process left (home) outcome
        if let outcome = market.outcomes[safe: 0] {
            presentations.append(createOutcomePresentation(
                outcome: outcome,
                position: .left,
                market: market
            ))
        }
        
        // Process middle (draw) outcome
        if let outcome = market.outcomes[safe: 1] {
            presentations.append(createOutcomePresentation(
                outcome: outcome,
                position: .middle,
                market: market
            ))
        }
        
        // Process right (away) outcome
        if let outcome = market.outcomes[safe: 2] {
            presentations.append(createOutcomePresentation(
                outcome: outcome,
                position: .right,
                market: market
            ))
        }
        
        return presentations
    }
    
    /// Creates a single outcome presentation model
    private func createOutcomePresentation(outcome: Outcome, position: OutcomePosition, market: Market) -> OutcomePresentation {
        // Format the title
        var title = outcome.typeName
        if let nameDigit1 = market.nameDigit1, !outcome.typeName.contains("\(nameDigit1)") {
            title = "\(outcome.typeName) \(nameDigit1)"
        }
        
        // Check validity and availability
        let isValidOdd = !outcome.bettingOffer.decimalOdd.isNaN
        let isInteractive = isValidOdd
        let value = outcome.bettingOffer.decimalOdd
        let formattedValue = isValidOdd ? OddFormatter.formatOdd(withValue: value) : "-"
        
        // Check selection state
        let isSelected = Env.betslipManager.hasBettingTicket(withId: outcome.bettingOffer.id)
        
        return OutcomePresentation(
            outcome: outcome,
            position: position,
            title: title,
            formattedValue: formattedValue,
            value: value,
            isSelected: isSelected,
            isInteractive: isInteractive
        )
    }
} 
