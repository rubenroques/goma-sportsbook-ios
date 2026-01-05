import Foundation
import Combine

/// Protocol defining the interface for MatchBannerView view model
public protocol MatchBannerViewModelProtocol {

    // MARK: - Data Access

    /// Current match data - must be immediately available for collection view sizing
    var currentMatchData: MatchBannerModel { get }

    /// View model for market outcomes line
    var marketOutcomesViewModel: MarketOutcomesLineViewModelProtocol { get }

    // MARK: - Callbacks (set by parent ViewModels)

    /// Called when user taps the match banner - passes match/event ID
    var onMatchTap: ((String) -> Void)? { get set }

    /// Called when user selects an outcome - passes outcome ID
    var onOutcomeSelected: ((String) -> Void)? { get set }

    /// Called when user deselects an outcome - passes outcome ID
    var onOutcomeDeselected: ((String) -> Void)? { get set }

    // MARK: - User Interactions

    /// Called when user taps on the banner
    func userDidTapBanner()

    // MARK: - Outcome Selection

    /// Called when user selects an outcome
    func onOutcomeSelected(outcomeId: String)

    /// Called when user deselects an outcome
    func onOutcomeDeselected(outcomeId: String)
}