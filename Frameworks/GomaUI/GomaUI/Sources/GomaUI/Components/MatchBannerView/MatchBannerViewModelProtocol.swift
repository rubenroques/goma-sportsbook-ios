import Foundation
import Combine

/// Protocol defining the interface for MatchBannerView view model
public protocol MatchBannerViewModelProtocol {

    // MARK: - Data Access

    /// Current match data - must be immediately available for collection view sizing
    var currentMatchData: MatchBannerModel { get }

    /// View model for market outcomes line
    var marketOutcomesViewModel: MarketOutcomesLineViewModelProtocol { get }

    // MARK: - User Interactions

    /// Called when user taps on the banner
    func userDidTapBanner()

    // MARK: - Outcome Selection

    /// Called when user selects an outcome
    func onOutcomeSelected(outcomeId: String)

    /// Called when user deselects an outcome
    func onOutcomeDeselected(outcomeId: String)
}