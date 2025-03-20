import Foundation
import UIKit
import Combine
import ServicesProvider

/// A mock implementation of MatchWidgetCellViewModelProtocol for testing and previews
class MockMatchWidgetCellViewModel: MatchWidgetCellViewModelProtocol {
    // MARK: - Properties

    /// The current match data
    @Published private(set) var match: Match

    /// Current match widget type
    @Published private(set) var matchWidgetType: MatchWidgetType

    /// Current match widget status
    @Published private(set) var matchWidgetStatus: MatchWidgetStatus

    // MARK: - Publishers

    /// Publisher for home team name
    var homeTeamNamePublisher: AnyPublisher<String, Never> {
        return self.$match
            .map { $0.homeParticipant.name }
            .removeDuplicates()
            .eraseToAnyPublisher()
    }

    /// Publisher for away team name
    var awayTeamNamePublisher: AnyPublisher<String, Never> {
        return self.$match
            .map { $0.awayParticipant.name }
            .removeDuplicates()
            .eraseToAnyPublisher()
    }

    /// Publisher for active player serve
    var activePlayerServePublisher: AnyPublisher<Match.ActivePlayerServe?, Never> {
        return self.$match
            .map { $0.activePlayerServe }
            .removeDuplicates()
            .eraseToAnyPublisher()
    }

    /// Publisher for start date string
    var startDateStringPublisher: AnyPublisher<String, Never> {
        return self.$match
            .map { match in
                guard let date = match.date else { return "" }

                let formatter = DateFormatter()
                formatter.dateFormat = "E d MMM"
                return formatter.string(from: date)
            }
            .removeDuplicates()
            .eraseToAnyPublisher()
    }

    /// Publisher for start time string
    var startTimeStringPublisher: AnyPublisher<String, Never> {
        return self.$match
            .map { match in
                guard let date = match.date else { return "" }

                let formatter = DateFormatter()
                formatter.dateFormat = "HH:mm"
                return formatter.string(from: date)
            }
            .removeDuplicates()
            .eraseToAnyPublisher()
    }

    /// Publisher for event name
    var eventNamePublisher: AnyPublisher<String?, Never> {
        return self.$match
            .map { match in
                return match.venue?.name ?? match.competitionName
            }
            .removeDuplicates()
            .eraseToAnyPublisher()
    }

    /// Publisher for match score
    var matchScorePublisher: AnyPublisher<String, Never> {
        return self.$match
            .map { match in
                let homeScore = match.homeParticipantScore ?? 0
                let awayScore = match.awayParticipantScore ?? 0
                return "\(homeScore) - \(awayScore)"
            }
            .removeDuplicates()
            .eraseToAnyPublisher()
    }

    /// Publisher for match time details
    var matchTimeDetailsPublisher: AnyPublisher<String?, Never> {
        return self.$match.map { match in
            let details = [match.matchTime, match.detailedStatus]
            return details.compactMap({ $0 }).joined(separator: " - ")
        }
        .removeDuplicates()
        .eraseToAnyPublisher()
    }

    /// Publisher for sport icon image
    var sportIconImagePublisher: AnyPublisher<UIImage, Never> {
        return self.$match
            .map { match in
                if let sportIconImage = UIImage(named: "sport_type_icon_\(match.sport.id)") {
                    return sportIconImage
                }
                else if let defaultImage = UIImage(named: "sport_type_icon_default") {
                    return defaultImage
                }
                else {
                    return UIImage()
                }
            }
            .eraseToAnyPublisher()
    }

    /// Publisher for country flag image
    var countryFlagImagePublisher: AnyPublisher<UIImage, Never> {
        return self.$match
            .map { match in
                let isoCode = match.venue?.isoCode ?? ""
                let countryId = match.venue?.id ?? ""
                let assetName = isoCode.isEmpty ? countryId : isoCode
                return UIImage(named: "flag_\(assetName.lowercased())") ?? UIImage()
            }
            .eraseToAnyPublisher()
    }

    /// Publisher for whether the match is a favorite
    var isFavoriteMatchPublisher: AnyPublisher<Bool, Never> {
        // In mock, we don't need to access FavoritesManager
        return Just(false).eraseToAnyPublisher()
    }

    /// Publisher for whether the card should be drawn as live
    var isLiveCardPublisher: AnyPublisher<Bool, Never> {
        return Publishers.CombineLatest(self.$matchWidgetStatus, self.$match)
            .map { matchWidgetStatus, match in
                if matchWidgetStatus == .live {
                    return true
                }

                switch match.status {
                case .notStarted, .unknown:
                    return false
                case .inProgress, .ended:
                    return true
                }
            }
            .removeDuplicates()
            .eraseToAnyPublisher()
    }
    
    // MARK: - New Mock Publishers
    
    /// Publisher for widget appearance
    var widgetAppearancePublisher: AnyPublisher<WidgetAppearance, Never> {
        return Publishers.CombineLatest3(
            self.$matchWidgetStatus,
            self.$matchWidgetType,
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
        .eraseToAnyPublisher()
    }
 
    /// Publisher for boosted odds info
    var boostedOddsPublisher: AnyPublisher<BoostedOddsInfo, Never> {
        return self.$match
            .map { _ in
                return BoostedOddsInfo(
                    title: "Home Win",
                    oldValue: "2.10",
                    newValue: "2.50",
                    oldValueAttributed: nil
                )
            }
            .eraseToAnyPublisher()
    }
    
    /// Publisher for market presentation
    var marketPresentationPublisher: AnyPublisher<MarketPresentation, Never> {
        return Publishers.CombineLatest(
            self.$match,
            self.$matchWidgetType
        )
        .map { match, widgetType -> MarketPresentation in
            // Create mock outcomes
            let outcomes: [OutcomePresentation] = [
                OutcomePresentation(
                    outcome: nil,
                    position: .left,
                    title: "Home",
                    formattedValue: "1.85",
                    value: 1.85,
                    isSelected: false,
                    isInteractive: true
                ),
                OutcomePresentation(
                    outcome: nil,
                    position: .middle,
                    title: "Draw",
                    formattedValue: "3.40",
                    value: 3.40,
                    isSelected: false,
                    isInteractive: true
                ),
                OutcomePresentation(
                    outcome: nil,
                    position: .right,
                    title: "Away",
                    formattedValue: "4.20",
                    value: 4.20,
                    isSelected: false,
                    isInteractive: true
                )
            ]
            
            return MarketPresentation(
                market: match.markets.first,
                marketName: "1X2",
                widgetType: widgetType,
                isMarketAvailable: true,
                isCustomBetAvailable: false,
                shouldShowMarketPill: widgetType == .boosted,
                outcomes: outcomes,
                boostedOutcome: widgetType == .boosted ? false : nil
            )
        }
        .eraseToAnyPublisher()
    }
    
    /// Publisher for left outcome updates
    var leftOutcomeUpdatesPublisher: AnyPublisher<OutcomeUpdate, ServiceProviderError> {
        return Just(OutcomeUpdate(
            outcome: nil,
            isAvailable: true,
            newValue: 1.85,
            formattedValue: "1.85",
            changeDirection: nil,
            isSelected: false
        ))
        .setFailureType(to: ServiceProviderError.self)
        .eraseToAnyPublisher()
    }
    
    /// Publisher for middle outcome updates
    var middleOutcomeUpdatesPublisher: AnyPublisher<OutcomeUpdate, ServiceProviderError> {
        return Just(OutcomeUpdate(
            outcome: nil,
            isAvailable: true,
            newValue: 3.40,
            formattedValue: "3.40",
            changeDirection: nil,
            isSelected: false
        ))
        .setFailureType(to: ServiceProviderError.self)
        .eraseToAnyPublisher()
    }
    
    /// Publisher for right outcome updates
    var rightOutcomeUpdatesPublisher: AnyPublisher<OutcomeUpdate, ServiceProviderError> {
        return Just(OutcomeUpdate(
            outcome: nil,
            isAvailable: true,
            newValue: 4.20,
            formattedValue: "4.20",
            changeDirection: nil,
            isSelected: false
        ))
        .setFailureType(to: ServiceProviderError.self)
        .eraseToAnyPublisher()
    }

    // MARK: - Initialization

    /// Initializes a new mock view model with the provided match and optional type/status
    init(match: Match, matchWidgetType: MatchWidgetType = .normal, matchWidgetStatus: MatchWidgetStatus = .unknown) {
        self.match = match
        self.matchWidgetType = matchWidgetType

        // Determine status if not explicitly provided
        if matchWidgetStatus != .unknown {
            self.matchWidgetStatus = matchWidgetStatus
        }
        else if match.status.isLive || match.status.isPostLive {
            self.matchWidgetStatus = .live
        }
        else {
            self.matchWidgetStatus = .preLive
        }
    }

    // MARK: - Methods

    /// Updates the match data
    func updateWithMatch(_ match: Match) {
        self.match = match
    }
}

// MARK: - Factory Methods
extension MockMatchWidgetCellViewModel {

    /// Creates a mock view model for a pre-live football match
    static func createPreLiveMatch() -> MockMatchWidgetCellViewModel {
        return MockMatchWidgetCellViewModel(
            match: PreviewModelsHelper.createFootballMatch(),
            matchWidgetType: .normal,
            matchWidgetStatus: .preLive
        )
    }

    /// Creates a mock view model for a live football match
    static func createLiveMatch() -> MockMatchWidgetCellViewModel {
        return MockMatchWidgetCellViewModel(
            match: PreviewModelsHelper.createLiveFootballMatch(),
            matchWidgetType: .normal,
            matchWidgetStatus: .live
        )
    }

    /// Creates a mock view model for a completed football match
    static func createCompletedMatch() -> MockMatchWidgetCellViewModel {
        return MockMatchWidgetCellViewModel(
            match: PreviewModelsHelper.createCompletedFootballMatch(),
            matchWidgetType: .normal
        )
    }

    /// Creates a mock view model for a boosted football match
    static func createBoostedMatch() -> MockMatchWidgetCellViewModel {
        return MockMatchWidgetCellViewModel(
            match: PreviewModelsHelper.createFootballMatch(),
            matchWidgetType: .boosted
        )
    }

    /// Creates a mock view model for a tennis match
    static func createTennisMatch() -> MockMatchWidgetCellViewModel {
        return MockMatchWidgetCellViewModel(
            match: PreviewModelsHelper.createTennisMatch(),
            matchWidgetType: .normal
        )
    }

    /// Creates a mock view model for a basketball match
    static func createBasketballMatch() -> MockMatchWidgetCellViewModel {
        return MockMatchWidgetCellViewModel(
            match: PreviewModelsHelper.createBasketballMatch(),
            matchWidgetType: .normal
        )
    }
}
