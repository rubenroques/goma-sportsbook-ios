import Foundation
import Combine

/// Protocol defining the interface for MatchBannerView view model
public protocol MatchBannerViewModelProtocol {

    // MARK: - Synchronous Data Access (Required for Collection View)

    /// Current match data - must be immediately available for collection view sizing
    var currentMatchData: MatchBannerModel { get }

    /// View model for market outcomes line
    var marketOutcomesViewModel: MarketOutcomesLineViewModelProtocol { get }

    /// View model for score display (only for live matches)
    var scoreViewModel: ScoreViewModelProtocol? { get }

    // MARK: - Reactive Updates (Optional)

    /// Publisher that emits updates to match data
    var matchDataPublisher: AnyPublisher<MatchBannerModel, Never> { get }

    /// Publisher that emits when match live status changes
    var matchLiveStatusChangedPublisher: AnyPublisher<Bool, Never> { get }

    // MARK: - User Interactions

    /// Called when user taps on the banner
    func userDidTapBanner()

    /// Called when user taps on an outcome
    /// - Parameters:
    ///   - outcomeId: The ID of the tapped outcome
    ///   - isSelected: Whether the outcome is now selected
    func userDidTapOutcome(outcomeId: String, isSelected: Bool)

    /// Called when user long presses on an outcome
    /// - Parameter outcomeId: The ID of the long-pressed outcome
    func userDidLongPressOutcome(outcomeId: String)

    // MARK: - Data Loading

    /// Load the latest match data
    func loadMatchData()

    /// Refresh match data from server
    func refreshMatchData()
}