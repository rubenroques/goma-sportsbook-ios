import Combine
import UIKit

// MARK: - Data Models
public struct TallOddsMatchData: Equatable, Hashable {
    public let matchId: String
    public let leagueInfo: MatchHeaderData
    public let homeParticipantName: String
    public let awayParticipantName: String
    public let marketInfo: MarketInfoData
    public let outcomes: MarketGroupData
    
    public init(
        matchId: String,
        leagueInfo: MatchHeaderData,
        homeParticipantName: String,
        awayParticipantName: String,
        marketInfo: MarketInfoData,
        outcomes: MarketGroupData
    ) {
        self.matchId = matchId
        self.leagueInfo = leagueInfo
        self.homeParticipantName = homeParticipantName
        self.awayParticipantName = awayParticipantName
        self.marketInfo = marketInfo
        self.outcomes = outcomes
    }
}

// MARK: - Display State
public struct TallOddsMatchCardDisplayState: Equatable {
    public let matchId: String
    public let homeParticipantName: String
    public let awayParticipantName: String
    
    public init(
        matchId: String,
        homeParticipantName: String,
        awayParticipantName: String
    ) {
        self.matchId = matchId
        self.homeParticipantName = homeParticipantName
        self.awayParticipantName = awayParticipantName
    }
}

// MARK: - View Model Protocol
public protocol TallOddsMatchCardViewModelProtocol {
    // Main display state
    var displayStatePublisher: AnyPublisher<TallOddsMatchCardDisplayState, Never> { get }
    
    // Child view model publishers
    var matchHeaderViewModelPublisher: AnyPublisher<MatchHeaderViewModelProtocol, Never> { get }
    var marketInfoLineViewModelPublisher: AnyPublisher<MarketInfoLineViewModelProtocol, Never> { get }
    var marketOutcomesViewModelPublisher: AnyPublisher<MarketOutcomesMultiLineViewModelProtocol, Never> { get }
    
    // Action handlers
    func onMatchHeaderAction()
    func onFavoriteToggle()
    func onOutcomeSelected(outcomeId: String)
    func onMarketInfoTapped()
}
