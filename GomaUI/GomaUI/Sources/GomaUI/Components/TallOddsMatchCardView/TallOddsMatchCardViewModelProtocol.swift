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
    public let liveScoreData: LiveScoreData?
    
    public init(
        matchId: String,
        leagueInfo: MatchHeaderData,
        homeParticipantName: String,
        awayParticipantName: String,
        marketInfo: MarketInfoData,
        outcomes: MarketGroupData,
        liveScoreData: LiveScoreData? = nil
    ) {
        self.matchId = matchId
        self.leagueInfo = leagueInfo
        self.homeParticipantName = homeParticipantName
        self.awayParticipantName = awayParticipantName
        self.marketInfo = marketInfo
        self.outcomes = outcomes
        self.liveScoreData = liveScoreData
    }
}

// MARK: - Live Score Data
public struct LiveScoreData: Equatable, Hashable {
    public let scoreCells: [ScoreDisplayData]
    
    public init(scoreCells: [ScoreDisplayData]) {
        self.scoreCells = scoreCells
    }
}

// MARK: - Display State
public struct TallOddsMatchCardDisplayState: Equatable {
    public let matchId: String
    public let homeParticipantName: String
    public let awayParticipantName: String
    public let isLive: Bool
    
    public init(
        matchId: String,
        homeParticipantName: String,
        awayParticipantName: String,
        isLive: Bool = false
    ) {
        self.matchId = matchId
        self.homeParticipantName = homeParticipantName
        self.awayParticipantName = awayParticipantName
        self.isLive = isLive
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
    var scoreViewModelPublisher: AnyPublisher<ScoreViewModelProtocol?, Never> { get }
    
    // Action handlers
    func onMatchHeaderAction()
    func onFavoriteToggle()
    func onOutcomeSelected(outcomeId: String)
    func onMarketInfoTapped()
}
