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
    
    /// Step 2: MultiWidgetToolbarView
    var multiWidgetToolbarViewModel: MultiWidgetToolbarViewModelProtocol { get }
    
    /// Step 3: MatchDateNavigationBarView
    var matchDateNavigationBarViewModel: MatchDateNavigationBarViewModelProtocol { get }
    
    /// Step 4: MatchHeaderCompactView
    var matchHeaderCompactViewModel: MatchHeaderCompactViewModelProtocol { get }
    
    /// Step 5: StatisticsWidgetView (collapsible)
    var statisticsWidgetViewModel: StatisticsWidgetViewModelProtocol { get }
    
    /// Step 6: MarketGroupSelectorTabView
    var marketGroupSelectorTabViewModel: MarketGroupSelectorTabViewModelProtocol { get }
    
    // MARK: - Publishers
    
    /// Published when the view model is ready to display content
    var isLoadingPublisher: AnyPublisher<Bool, Never> { get }
    
    /// Published when an error occurs
    var errorPublisher: AnyPublisher<String?, Never> { get }
    
    // MARK: - Navigation
    
    /// Published when navigation is requested
    var navigationRequestPublisher: AnyPublisher<MatchDetailsNavigationAction, Never> { get }
    
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

// MARK: - Navigation Actions

public enum MatchDetailsNavigationAction {
    case back
    case share
    case favorite
}