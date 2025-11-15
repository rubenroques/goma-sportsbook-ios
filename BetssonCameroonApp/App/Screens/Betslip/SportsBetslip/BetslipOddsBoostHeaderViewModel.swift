
import Foundation
import Combine
import GomaUI

/// Production implementation of BetslipOddsBoostHeaderViewModelProtocol
final class BetslipOddsBoostHeaderViewModel: BetslipOddsBoostHeaderViewModelProtocol {

    // MARK: - Properties
    private let dataSubject: CurrentValueSubject<BetslipOddsBoostHeaderData, Never>
    private var cancellables = Set<AnyCancellable>()

    // MARK: - Dependencies
    private let betslipManager: BetslipManager

    // MARK: - State
    private var oddsBoostState: OddsBoostStairsState?

    // MARK: - Callback closures
    public var onHeaderTapped: (() -> Void)?

    // MARK: - Protocol Conformance
    public var dataPublisher: AnyPublisher<BetslipOddsBoostHeaderData, Never> {
        return dataSubject.eraseToAnyPublisher()
    }

    public var currentData: BetslipOddsBoostHeaderData {
        return dataSubject.value
    }

    // MARK: - Initialization
    public init(betslipManager: BetslipManager = Env.betslipManager) {
        self.betslipManager = betslipManager

        // Initialize with empty state
        let initialState = BetslipOddsBoostHeaderState(
            selectionCount: 0,
            totalEligibleCount: 0,
            minOdds: nil,
            headingText: LocalizationProvider.string("win_boost_available"),
            descriptionText: LocalizationProvider.string("all_qualifying_events_added")
        )
        let initialData = BetslipOddsBoostHeaderData(state: initialState, isEnabled: true)
        self.dataSubject = CurrentValueSubject(initialData)

        setupBindings()
    }

    // MARK: - Private Methods
    private func setupBindings() {
        // Combine both publishers to automatically sync tickets and odds boost data
        Publishers.CombineLatest(
            betslipManager.bettingTicketsPublisher,
            betslipManager.oddsBoostStairsPublisher
        )
        .receive(on: DispatchQueue.main)
        .sink { [weak self] (_, oddsBoostState) in
            self?.oddsBoostState = oddsBoostState
            self?.updateHeaderState()
        }
        .store(in: &cancellables)
    }

    private func updateHeaderState() {
        // CRITICAL: Use API's eligibleEventIds.count as source of truth
        // This correctly handles duplicate events (multiple selections from same event)
        let eligibleEventsCount = oddsBoostState?.eligibleEventIds.count ?? 0

        // Extract real odds boost data from API response
        let displayData = extractOddsBoostData()

        // Extract and format minimum odds requirement
        let minOdds: String? = oddsBoostState?.minOdds.map { String(format: "%.2f", $0) }

        // Compute pre-assembled heading text (business logic in ViewModel)
        let headingText = computeHeadingText()

        // Compute pre-assembled description text (business logic in ViewModel)
        let descriptionText = computeDescriptionText()

        // Create new state
        let state = BetslipOddsBoostHeaderState(
            selectionCount: eligibleEventsCount,  // From API, not betslip tickets
            totalEligibleCount: displayData.totalEligibleCount,
            minOdds: minOdds,
            headingText: headingText,  // Pre-assembled message ready to display
            descriptionText: descriptionText  // Pre-assembled message ready to display
        )

        // Update data subject
        let newData = BetslipOddsBoostHeaderData(
            state: state,
            isEnabled: currentData.isEnabled
        )
        dataSubject.send(newData)
    }

    // MARK: - Display Data Model

    /// Represents the UI display state for odds boost header
    /// Maps API state (currentTier/nextTier) to UI presentation logic
    private struct OddsBoostDisplayData {
        /// Percentage to show when user has reached THE MAXIMUM tier
        /// Triggers "Max win boost activated! (X%)" message
        /// nil for all intermediate tiers (even if currentTier exists in API)
        let maxTierPercentage: String?

        /// Total segments to display in progress bar
        /// Equals next tier's minSelections, or current tier's if at max
        let totalEligibleCount: Int

        /// Percentage to show for the NEXT achievable tier
        /// Triggers "Get X% win boost" message
        /// nil only when at absolute maximum tier
        let nextTierPercentage: String?

        /// Whether user has reached the absolute maximum tier
        var isAtMaxTier: Bool {
            return maxTierPercentage != nil && nextTierPercentage == nil
        }
    }

    /// ODDS BOOST UI STATE MACHINE:
    ///
    /// ┌─────────────────────────────────────────────────────────────┐
    /// │ API State               │ UI Display                         │
    /// ├─────────────────────────────────────────────────────────────┤
    /// │ No bonus                │ [Component Hidden]                 │
    /// ├─────────────────────────────────────────────────────────────┤
    /// │ Below first tier        │ "Get 10% boost"                    │
    /// │ currentTier: nil        │ Progress: 2/3 segments             │
    /// │ nextTier: 3 → 10%       │ Description: "add 1 more legs..."  │
    /// ├─────────────────────────────────────────────────────────────┤
    /// │ At tier 2 of 5          │ "Get 15% boost" ← NOT "Max!"       │
    /// │ currentTier: 3 → 10%    │ Progress: 3/4 segments             │
    /// │ nextTier: 4 → 15%       │ Description: "add 1 more legs..."  │
    /// ├─────────────────────────────────────────────────────────────┤
    /// │ At max tier 5           │ "Max win boost activated! (40%)"   │
    /// │ currentTier: 10 → 40%   │ Progress: 10/10 segments (full)    │
    /// │ nextTier: nil           │ Description: "All qualifying..."   │
    /// └─────────────────────────────────────────────────────────────┘

    /// Extracts odds boost UI data from current state
    /// - Returns: Display data struct with named properties for UI rendering
    private func extractOddsBoostData() -> OddsBoostDisplayData {
        guard let oddsBoostState = self.oddsBoostState else {
            // No odds boost available (not logged in, no bonus configured, or API error)
            return OddsBoostDisplayData(
                maxTierPercentage: nil,
                totalEligibleCount: 0,
                nextTierPercentage: nil
            )
        }

        // CRITICAL LOGIC: Only return currentPercentage when user has reached THE MAXIMUM tier
        // Even though API provides currentTier at tier 2/5, we return nil here because
        // the UI should show "Get next boost" message, NOT "Max boost activated"
        //
        // Example at tier 2 of 5:
        //   API: currentTier = 10%, nextTier = 15%
        //   We return: (nil, 4, "15%") → UI shows "Get 15% win boost"
        //
        // Example at max tier 5 of 5:
        //   API: currentTier = 40%, nextTier = nil
        //   We return: ("40%", 10, nil) → UI shows "Max win boost activated! (40%)"
        let currentPercentage: String? = {
            // Only show "max boost activated" when there's NO next tier available
            guard oddsBoostState.nextTier == nil,
                  let currentTier = oddsBoostState.currentTier else {
                return nil
            }
            return "\(Int(currentTier.percentage * 100))%"
        }()

        // Extract next tier data for progress bar and call-to-action
        // If nextTier is nil, user has reached max tier - use currentTier to show all segments filled
        let totalEligibleCount: Int = oddsBoostState.nextTier?.minSelections
            ?? oddsBoostState.currentTier?.minSelections
            ?? 0
        let nextTierPercentage: String? = oddsBoostState.nextTier.map { tier in
            return "\(Int(tier.percentage * 100))%"
        }

        return OddsBoostDisplayData(
            maxTierPercentage: currentPercentage,
            totalEligibleCount: totalEligibleCount,
            nextTierPercentage: nextTierPercentage
        )
    }

    /// Computes the heading text based on current odds boost state
    /// Encapsulates all localization and message assembly logic
    /// View simply displays this pre-assembled message
    private func computeHeadingText() -> String {
        let displayData = extractOddsBoostData()

        // Priority 1: At max tier - show "Max boost activated!"
        if let maxTierPercentage = displayData.maxTierPercentage {
            return LocalizationProvider.string("max_win_boost_activated") + " (\(maxTierPercentage))"
        }

        // Priority 2: Next tier available - show "Get X% boost"
        if let nextPercentage = displayData.nextTierPercentage {
            return LocalizationProvider.string("get_win_boost")
                .replacingOccurrences(of: "{percentage}", with: nextPercentage)
        }

        // Fallback: Generic message
        return LocalizationProvider.string("win_boost_available")
    }

    /// Computes the description text based on current odds boost state
    /// Encapsulates all localization and message assembly logic
    /// View simply displays this pre-assembled message
    private func computeDescriptionText() -> String {
        let displayData = extractOddsBoostData()
        let eligibleEventsCount = oddsBoostState?.eligibleEventIds.count ?? 0
        let remainingSelections = max(0, displayData.totalEligibleCount - eligibleEventsCount)

        if remainingSelections > 0, let minOdds = oddsBoostState?.minOdds {
            // Priority 1: Use minOdds message
            let minOddsStr = String(format: "%.2f", minOdds)
            return LocalizationProvider.string("add_more_to_betslip")
                .replacingOccurrences(of: "{legNumber}", with: "\(remainingSelections)")
                .replacingOccurrences(of: "{minOdd}", with: minOddsStr)

        } else if remainingSelections > 0, let nextPercentage = displayData.nextTierPercentage {
            // Priority 2: Fallback to percentage-based message
            return LocalizationProvider.string("add_matches_bonus")
                .replacingOccurrences(of: "{nMatches}", with: "\(remainingSelections)")
                .replacingOccurrences(of: "{percentage}", with: nextPercentage)
        } else {
            // All selections added
            return LocalizationProvider.string("all_qualifying_events_added")
        }
    }

    // MARK: - Protocol Methods
    public func updateState(_ state: BetslipOddsBoostHeaderState) {
        let newData = BetslipOddsBoostHeaderData(
            state: state,
            isEnabled: currentData.isEnabled
        )
        dataSubject.send(newData)
    }

    public func setEnabled(_ isEnabled: Bool) {
        let newData = BetslipOddsBoostHeaderData(
            state: currentData.state,
            isEnabled: isEnabled
        )
        dataSubject.send(newData)
    }
}
