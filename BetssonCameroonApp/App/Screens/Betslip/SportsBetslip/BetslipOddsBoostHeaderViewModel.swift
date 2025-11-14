
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
            nextTierPercentage: nil,
            currentBoostPercentage: nil
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
        let (currentBoostPercentage, totalEligibleCount, nextTierPercentage) = extractOddsBoostData()

        // Extract and format minimum odds requirement
        let minOdds: String? = oddsBoostState?.minOdds.map { String(format: "%.2f", $0) }

        // Create new state
        let state = BetslipOddsBoostHeaderState(
            selectionCount: eligibleEventsCount,  // From API, not betslip tickets
            totalEligibleCount: totalEligibleCount,
            nextTierPercentage: nextTierPercentage,
            currentBoostPercentage: currentBoostPercentage,
            minOdds: minOdds
        )

        // Update data subject
        let newData = BetslipOddsBoostHeaderData(
            state: state,
            isEnabled: currentData.isEnabled
        )
        dataSubject.send(newData)
    }

    /// Extracts odds boost UI data from current state
    /// - Returns: Tuple of (maxTierPercentage, totalEligibleCount, nextTierPercentage) for UI display
    ///
    /// IMPORTANT: The tuple values determine which UI state is shown:
    /// - When maxTierPercentage != nil → Shows "Max win boost activated! (X%)"
    /// - When nextTierPercentage != nil → Shows "Get X% win boost"
    /// - When both are nil → Shows generic "Win boost available"
    private func extractOddsBoostData() -> (String?, Int, String?) {
        guard let oddsBoostState = self.oddsBoostState else {
            // No odds boost available (not logged in, no bonus configured, or API error)
            return (nil, 0, nil)
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

        return (currentPercentage, totalEligibleCount, nextTierPercentage)
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
