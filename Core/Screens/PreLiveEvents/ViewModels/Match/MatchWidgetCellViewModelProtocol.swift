import Foundation
import UIKit
import Combine
import ServicesProvider

/// Protocol that defines the requirements for a MatchWidgetCellViewModel
protocol MatchWidgetCellViewModelProtocol {
        
    /// The match data
    var matchPublisher: AnyPublisher<Match, Never> { get }
    
    /// Match widget type (normal, boosted, etc.)
    var matchWidgetTypePublisher: AnyPublisher<MatchWidgetType, Never> { get }
    
    /// Match status (live, preLive)
    var matchWidgetStatusPublisher: AnyPublisher<MatchWidgetStatus, Never> { get }
    
    /// Publisher for home team name
    var homeTeamNamePublisher: AnyPublisher<String, Never> { get }
    
    /// Publisher for away team name
    var awayTeamNamePublisher: AnyPublisher<String, Never> { get }
    
    /// Publisher for active player serve
    var activePlayerServePublisher: AnyPublisher<Match.ActivePlayerServe?, Never> { get }
    
    /// Publisher for start date string
    var startDateStringPublisher: AnyPublisher<String, Never> { get }
    
    /// Publisher for start time string
    var startTimeStringPublisher: AnyPublisher<String, Never> { get }
    
    /// Publisher for event name
    var eventNamePublisher: AnyPublisher<String?, Never> { get }
    
    /// Publisher for match score
    var matchScorePublisher: AnyPublisher<String, Never> { get }
    
    /// Publisher for match time details
    var matchTimeDetailsPublisher: AnyPublisher<String?, Never> { get }
    
    /// Publisher for sport icon image
    var sportIconImageNamePublisher: AnyPublisher<String?, Never> { get }
    
    /// Publisher for country flag image
    var countryFlagImageNamePublisher: AnyPublisher<String?, Never> { get }
    
    /// Publisher for whether the match is a favorite
    var isFavoriteMatchPublisher: AnyPublisher<Bool, Never> { get }
    
    /// Publisher for whether the card should be drawn as live
    var isLiveCardPublisher: AnyPublisher<Bool, Never> { get }
    
    // MARK: - New Presentation Publishers
    
    /// Publisher for widget appearance settings
    var widgetAppearancePublisher: AnyPublisher<WidgetAppearance, Never> { get }
    
    /// Publisher for boosted odds information
    var boostedOddsPublisher: AnyPublisher<BoostedOddsInfo, Never> { get }
    
    /// Publisher for market presentation data
    var marketPresentationPublisher: AnyPublisher<MarketPresentation, Never> { get }
    
    /// Publisher for left outcome updates
    var leftOutcomeUpdatesPublisher: AnyPublisher<OutcomeUpdate, ServiceProviderError> { get }
    
    /// Publisher for middle outcome updates
    var middleOutcomeUpdatesPublisher: AnyPublisher<OutcomeUpdate, ServiceProviderError> { get }
    
    /// Publisher for right outcome updates
    var rightOutcomeUpdatesPublisher: AnyPublisher<OutcomeUpdate, ServiceProviderError> { get }
    
    /// Updates the match data
    func updateWithMatch(_ match: Match)
} 

