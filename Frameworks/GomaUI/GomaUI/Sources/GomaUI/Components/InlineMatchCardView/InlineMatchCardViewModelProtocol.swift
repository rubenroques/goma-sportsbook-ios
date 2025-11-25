import UIKit
import Combine

// MARK: - Data Models

/// Main data structure for inline match card
public struct InlineMatchData: Equatable, Hashable {
    public let matchId: String
    public let homeParticipantName: String
    public let awayParticipantName: String
    public let isLive: Bool
    public let headerData: CompactMatchHeaderDisplayState
    public let outcomesData: CompactOutcomesLineDisplayState
    public let scoreData: InlineScoreDisplayState?

    public init(
        matchId: String,
        homeParticipantName: String,
        awayParticipantName: String,
        isLive: Bool,
        headerData: CompactMatchHeaderDisplayState,
        outcomesData: CompactOutcomesLineDisplayState,
        scoreData: InlineScoreDisplayState? = nil
    ) {
        self.matchId = matchId
        self.homeParticipantName = homeParticipantName
        self.awayParticipantName = awayParticipantName
        self.isLive = isLive
        self.headerData = headerData
        self.outcomesData = outcomesData
        self.scoreData = scoreData
    }
}

/// Display state for InlineMatchCardView
public struct InlineMatchCardDisplayState: Equatable {
    public let matchId: String
    public let homeParticipantName: String
    public let awayParticipantName: String
    public let isLive: Bool

    public init(
        matchId: String,
        homeParticipantName: String,
        awayParticipantName: String,
        isLive: Bool
    ) {
        self.matchId = matchId
        self.homeParticipantName = homeParticipantName
        self.awayParticipantName = awayParticipantName
        self.isLive = isLive
    }
}

// MARK: - Protocol

/// Protocol defining the interface for InlineMatchCardView ViewModels
public protocol InlineMatchCardViewModelProtocol: AnyObject {
    // MARK: - Display State
    /// Publisher for the display state
    var displayStatePublisher: AnyPublisher<InlineMatchCardDisplayState, Never> { get }

    /// Current display state (for synchronous access)
    var currentDisplayState: InlineMatchCardDisplayState { get }

    // MARK: - Child View Models (Publishers)
    var headerViewModelPublisher: AnyPublisher<CompactMatchHeaderViewModelProtocol, Never> { get }
    var outcomesViewModelPublisher: AnyPublisher<CompactOutcomesLineViewModelProtocol, Never> { get }
    var scoreViewModelPublisher: AnyPublisher<InlineScoreViewModelProtocol?, Never> { get }

    // MARK: - Child View Models (Synchronous)
    var currentHeaderViewModel: CompactMatchHeaderViewModelProtocol { get }
    var currentOutcomesViewModel: CompactOutcomesLineViewModelProtocol { get }
    var currentScoreViewModel: InlineScoreViewModelProtocol? { get }

    // MARK: - Actions
    /// Called when the card is tapped (navigate to match details)
    func onCardTapped()

    /// Called when an outcome is selected
    func onOutcomeSelected(outcomeId: String)

    /// Called when an outcome is deselected
    func onOutcomeDeselected(outcomeId: String)

    /// Called when the "more markets" icon/count is tapped
    func onMoreMarketsTapped()
}
