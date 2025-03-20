//
//  BoostedOddsCardViewModel.swift
//  Sportsbook
//
//  Created for refactoring in 2024.
//

import Foundation
import UIKit
import Combine
import ServicesProvider

/// Dedicated view model for boosted odds cards
class BoostedOddsCardViewModel: BaseMatchCardViewModel {
    // MARK: - Properties
    
    /// The boosted outcome with old value
    @Published private(set) var oldBoostedOddOutcome: MatchWidgetCellViewModel.BoostedOutcome?
    
    private var cancellables: Set<AnyCancellable> = []
    
    // MARK: - Publishers
    
    /// Publisher for boosted odds information
    var boostedOddsInfoPublisher: AnyPublisher<BoostedOddsInfo, Never> {
        return Publishers.CombineLatest(
            self.$match,
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
                    oldValue = OddFormatter.formatOdd(withValue: Double(oldOutcome.valueAttributedString.string) ?? 0)
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
    
    /// Publisher for whether the boosted outcome is selected
    var isSelectedPublisher: AnyPublisher<Bool, Never> {
        return self.$match
            .map { match -> Bool in
                guard let outcome = match.markets.first?.outcomes.first else {
                    return false
                }
                return Env.betslipManager.hasBettingTicket(withId: outcome.bettingOffer.id)
            }
            .removeDuplicates()
            .eraseToAnyPublisher()
    }
    
    // MARK: - Initialization
    
    override init(match: Match, matchWidgetType: MatchWidgetType = .boosted, matchWidgetStatus: MatchWidgetStatus = .unknown) {
        super.init(match: match, matchWidgetType: .boosted, matchWidgetStatus: matchWidgetStatus)
        loadBoostedOddOldValueIfNeeded()
    }
    
    /// Initialize from an existing MatchWidgetCellViewModel
    init(fromViewModel viewModel: MatchWidgetCellViewModel) {
        super.init(match: viewModel.match, matchWidgetType: .boosted, matchWidgetStatus: viewModel.matchWidgetStatus)
        
        // Copy over the old boosted odd outcome if available
        if let oldBoostedOdd = viewModel.oldBoostedOddOutcome {
            self.oldBoostedOddOutcome = oldBoostedOdd
        }
        else {
            loadBoostedOddOldValueIfNeeded()
        }
    }
    
    // MARK: - Private Methods
    
    /// Load the old boosted odd value if needed
    private func loadBoostedOddOldValueIfNeeded() {
        guard let originalMarketId = self.match.oldMainMarketId else {
            return
        }
        
        Publishers.CombineLatest(
            Env.servicesProvider.getMarketInfo(marketId: originalMarketId)
                .map(ServiceProviderModelMapper.market(fromServiceProviderMarket:)),
            Just(self.match)
                .setFailureType(to: ServicesProvider.ServiceProviderError.self)
        )
        .sink { _ in
            print("Loaded old boosted market info")
        } receiveValue: { [weak self] market, match in
            if let firstCurrentOutcomeName = match.markets.first?.outcomes[safe: 0]?.typeName.lowercased(),
               let outcome = market.outcomes.first(where: { outcome in outcome.typeName.lowercased() == firstCurrentOutcomeName })
            {
                let oddValue = OddFormatter.formatOdd(withValue: outcome.bettingOffer.decimalOdd)
                let attributes = [NSAttributedString.Key.strikethroughStyle: NSUnderlineStyle.single.rawValue]
                let attributedString = NSAttributedString(string: oddValue, attributes: attributes)
                self?.oldBoostedOddOutcome = MatchWidgetCellViewModel.BoostedOutcome(
                    type: "home",
                    name: firstCurrentOutcomeName,
                    valueAttributedString: attributedString
                )
            }
            else if let secondCurrentOutcomeName = match.markets.first?.outcomes[safe: 1]?.typeName.lowercased(),
                    let outcome = market.outcomes.first(where: { outcome in outcome.typeName.lowercased() == secondCurrentOutcomeName })
            {
                let oddValue = OddFormatter.formatOdd(withValue: outcome.bettingOffer.decimalOdd)
                let attributes = [NSAttributedString.Key.strikethroughStyle: NSUnderlineStyle.single.rawValue]
                let attributedString = NSAttributedString(string: oddValue, attributes: attributes)
                self?.oldBoostedOddOutcome = MatchWidgetCellViewModel.BoostedOutcome(
                    type: "draw",
                    name: secondCurrentOutcomeName,
                    valueAttributedString: attributedString
                )
            }
        }
        .store(in: &cancellables)
    }
} 
