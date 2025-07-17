//
//  MatchDetailsTextualViewModelProtocol.swift
//  Sportsbook
//
//  Created on 2025-07-16.
//

import Foundation
import Combine
import GomaUI

public protocol MatchDetailsTextualViewModelProtocol: AnyObject {
    
    // MARK: - Child ViewModels (Vertical Pattern)
    
    var multiWidgetToolbarViewModel: MultiWidgetToolbarViewModelProtocol { get }
    
    var matchDateNavigationBarViewModel: MatchDateNavigationBarViewModelProtocol { get }
    
    var matchHeaderCompactViewModel: MatchHeaderCompactViewModelProtocol { get }
    
    var statisticsWidgetViewModel: StatisticsWidgetViewModelProtocol { get }
    
    var marketGroupSelectorTabViewModel: MarketGroupSelectorTabViewModelProtocol { get }
    
    // MARK: - Publishers
    
    /// Published when the market group selector tab view model changes (for UI reconfiguration)
    var marketGroupSelectorTabViewModelPublisher: AnyPublisher<MarketGroupSelectorTabViewModelProtocol, Never> { get }
    
    /// Published when the view model is ready to display content
    var isLoadingPublisher: AnyPublisher<Bool, Never> { get }
    
    /// Published when an error occurs
    var errorPublisher: AnyPublisher<String?, Never> { get }
    
    // MARK: - Statistics Widget
    
    /// Published when statistics visibility should change
    var statisticsVisibilityPublisher: AnyPublisher<Bool, Never> { get }
    
    // MARK: - Methods
    
    /// Load match details data
    func loadMatchDetails()
    
    /// Toggle statistics widget visibility
    func toggleStatistics()
    
    /// Refresh all content
    func refresh()
}
