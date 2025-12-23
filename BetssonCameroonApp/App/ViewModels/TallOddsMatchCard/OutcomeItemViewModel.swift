import GomaUI
import ServicesProvider
import Combine
import UIKit
import GomaLogger

/// Production implementation of OutcomeItemViewModel that connects to real-time outcome updates
final class OutcomeItemViewModel: OutcomeItemViewModelProtocol {

    // MARK: - Dependencies
    private let outcomeId: String
    private let bettingOfferId: String?
    private let servicesProvider = Env.servicesProvider
    
    // MARK: - Subjects
    var outcomeDataSubject: CurrentValueSubject<GomaUI.OutcomeItemData, Never>
    private let displayStateSubject: CurrentValueSubject<GomaUI.OutcomeDisplayState, Never>
    private let titleSubject: CurrentValueSubject<String, Never>
    private let valueSubject: CurrentValueSubject<String, Never>
    private let isSelectedSubject: CurrentValueSubject<Bool, Never>
    private let isDisabledSubject: CurrentValueSubject<Bool, Never>
    private let oddsChangeEventSubject: PassthroughSubject<GomaUI.OutcomeItemOddsChangeEvent, Never>
    private let selectionDidChangeSubject: PassthroughSubject<GomaUI.OutcomeSelectionChangeEvent, Never>

    private var cancellables = Set<AnyCancellable>()

    // MARK: - Synchronous State Access
    var currentOutcomeData: GomaUI.OutcomeItemData {
        outcomeDataSubject.value
    }

    // MARK: - Protocol Conformance
    public var displayStatePublisher: AnyPublisher<GomaUI.OutcomeDisplayState, Never> {
        return self.displayStateSubject.eraseToAnyPublisher()
    }
    
    // Individual publishers
    public var titlePublisher: AnyPublisher<String, Never> {
        titleSubject.eraseToAnyPublisher()
    }
    
    public var valuePublisher: AnyPublisher<String, Never> {
        valueSubject.eraseToAnyPublisher()
    }
    
    public var isSelectedPublisher: AnyPublisher<Bool, Never> {
        isSelectedSubject.eraseToAnyPublisher()
    }
    
    public var isDisabledPublisher: AnyPublisher<Bool, Never> {
        isDisabledSubject.eraseToAnyPublisher()
    }
    
    public var oddsChangeEventPublisher: AnyPublisher<GomaUI.OutcomeItemOddsChangeEvent, Never> {
        oddsChangeEventSubject.eraseToAnyPublisher()
    }

    /// Publisher for selection changes triggered by user interaction.
    /// Parent ViewModels observe this to know when selection changes.
    public var selectionDidChangePublisher: AnyPublisher<GomaUI.OutcomeSelectionChangeEvent, Never> {
        selectionDidChangeSubject.eraseToAnyPublisher()
    }

    // MARK: - Initialization
    init(
        outcomeId: String,
        initialOutcomeData: GomaUI.OutcomeItemData
    ) {
        self.outcomeDataSubject = .init(initialOutcomeData)
        self.outcomeId = outcomeId
        self.bettingOfferId = initialOutcomeData.bettingOfferId
        self.titleSubject = CurrentValueSubject(initialOutcomeData.title)
        self.valueSubject = CurrentValueSubject(initialOutcomeData.value)
        self.isSelectedSubject = CurrentValueSubject(initialOutcomeData.isSelected)
        self.isDisabledSubject = CurrentValueSubject(initialOutcomeData.isDisabled)
        self.oddsChangeEventSubject = PassthroughSubject()
        self.selectionDidChangeSubject = PassthroughSubject()
        self.displayStateSubject = CurrentValueSubject(initialOutcomeData.displayState)

        setupOutcomeSubscription()
    }
    
    // MARK: - User Actions

    /// Called by the View when user taps the outcome.
    /// This is the single entry point for user-initiated selection changes.
    public func userDidTapOutcome() {
        let currentDisplayState = displayStateSubject.value

        // Only allow toggling if in normal state
        guard currentDisplayState.canBeSelected else { return }

        let newIsSelected = !isSelectedSubject.value
        isSelectedSubject.send(newIsSelected)

        // Update display state
        switch currentDisplayState {
        case .normal(_, let isBoosted):
            let newDisplayState = GomaUI.OutcomeDisplayState.normal(isSelected: newIsSelected, isBoosted: isBoosted)
            displayStateSubject.send(newDisplayState)
        default:
            break
        }

        // Publish selection change event for parent ViewModels to observe
        let event = GomaUI.OutcomeSelectionChangeEvent(
            outcomeId: outcomeId,
            bettingOfferId: bettingOfferId,
            isSelected: newIsSelected,
            timestamp: Date()
        )
        selectionDidChangeSubject.send(event)
    }
    
    public func updateOddsValue(_ newValue: String) {
        let previousValue = valueSubject.value
        
        // Calculate odds change direction
        let direction = calculateOddsChangeDirection(from: previousValue, to: newValue)
        
        // Update value directly
        valueSubject.send(newValue)
        
        // Emit odds change event for animations
        if direction != .none {
            let changeEvent = GomaUI.OutcomeItemOddsChangeEvent(
                outcomeId: outcomeId,
                oldValue: previousValue,
                newValue: newValue,
                direction: direction,
                timestamp: Date()
            )
            oddsChangeEventSubject.send(changeEvent)
        }
    }
    
    // MARK: - Protocol Required Methods
    public func updateValue(_ newValue: String) {
        updateOddsValue(newValue)
    }
    
    public func updateValue(_ newValue: String, changeDirection: GomaUI.OddsChangeDirection) {
        let previousValue = valueSubject.value
        
        // Update value directly
        valueSubject.send(newValue)
        
        // Emit odds change event if direction is not none
        if changeDirection != .none {
            let changeEvent = GomaUI.OutcomeItemOddsChangeEvent(
                outcomeId: outcomeId,
                oldValue: previousValue,
                newValue: newValue,
                direction: changeDirection,
                timestamp: Date()
            )
            oddsChangeEventSubject.send(changeEvent)
        }
    }
    
    public func setSelected(_ selected: Bool) {
        isSelectedSubject.send(selected)
        
        let currentDisplayState = displayStateSubject.value
        switch currentDisplayState {
        case .normal(_ , let isBoosted):
            let newCurrentDisplayState = GomaUI.OutcomeDisplayState.normal(isSelected: selected, isBoosted: isBoosted)
            displayStateSubject.send(newCurrentDisplayState)
        default:
            break
        }
        
    }
    
    public func setDisabled(_ disabled: Bool) {
        updateSuspensionState(isSuspended: disabled)
    }
    
    public func updateSuspensionState(isSuspended: Bool) {
        isDisabledSubject.send(isSuspended)
    }
    
    public func clearOddsChangeIndicator() {
        // Clear any pending odds change animations
        // Implementation depends on the specific animation system used
    }
    
    public func setDisplayState(_ state: GomaUI.OutcomeDisplayState) {
        displayStateSubject.send(state)
        
        // Update individual subjects to maintain backward compatibility
        isSelectedSubject.send(state.isSelected)
        isDisabledSubject.send(state.isDisabled)
    }
    
    // MARK: - Private Methods
    private func setupOutcomeSubscription() {
        // Prefer BettingOffer subscription if we have the ID (for real-time odds updates)
        if let bettingOfferId = bettingOfferId {
            GomaLogger.debug(.realtime, category: "ODDS_FLOW",
                "OutcomeItemViewModel - SUBSCRIBING to BETTING_OFFER:\(bettingOfferId) for OUTCOME:\(outcomeId)")

            servicesProvider.subscribeToEventOnListsBettingOfferAsOutcomeUpdates(bettingOfferId: bettingOfferId)
                .receive(on: DispatchQueue.main)
                .sink(
                    receiveCompletion: { [weak self] completion in
                        if case .failure(let error) = completion {
                            GomaLogger.error(.realtime, category: "ODDS_FLOW",
                                "OutcomeItemViewModel - BETTING_OFFER subscription FAILED for BETTING_OFFER:\(bettingOfferId): \(error)")
                        }
                    },
                    receiveValue: { [weak self] serviceProviderOutcome in
                        if serviceProviderOutcome != nil {
                            GomaLogger.info(.realtime, category: "ODDS_FLOW",
                                "OutcomeItemViewModel - RECEIVED BettingOffer update for BETTING_OFFER:\(bettingOfferId)")
                        }
                        self?.processOutcomeUpdate(serviceProviderOutcome)
                    }
                )
                .store(in: &cancellables)
        } else {
            // Fallback to outcome subscription if no bettingOfferId available
            GomaLogger.debug(.realtime, category: "ODDS_FLOW",
                "OutcomeItemViewModel - No bettingOfferId, falling back to OUTCOME subscription for OUTCOME:\(outcomeId)")

            servicesProvider.subscribeToEventOnListsOutcomeUpdates(withId: outcomeId)
                .receive(on: DispatchQueue.main)
                .sink(
                    receiveCompletion: { [weak self] completion in
                        if case .failure(let error) = completion {
                            GomaLogger.error(.realtime, category: "ODDS_FLOW",
                                "OutcomeItemViewModel - OUTCOME subscription FAILED for OUTCOME:\(self?.outcomeId ?? "unknown"): \(error)")
                        }
                    },
                    receiveValue: { [weak self] serviceProviderOutcome in
                        GomaLogger.info(.realtime, category: "ODDS_FLOW",
                            "OutcomeItemViewModel - RECEIVED outcome update for OUTCOME:\(self?.outcomeId ?? "unknown")")
                        self?.processOutcomeUpdate(serviceProviderOutcome)
                    }
                )
                .store(in: &cancellables)
        }
    }
    
    private func processOutcomeUpdate(_ serviceProviderOutcome: ServicesProvider.Outcome?) {
        
        guard let serviceProviderOutcome = serviceProviderOutcome else {
            // Outcome was removed - mark as disabled/suspended
            updateSuspensionState(isSuspended: true)
            return
        }
        
        // Convert ServicesProvider.Outcome to internal Outcome using mapper
        let outcome = ServiceProviderModelMapper.outcome(fromServiceProviderOutcome: serviceProviderOutcome)
        
        // Get current values
        let currentTitle = titleSubject.value
        let currentValue = valueSubject.value
        let currentIsDisabled = isDisabledSubject.value
        
        // Check if we need to update anything
        let newTitle = outcome.translatedName
        let newIsDisabled = !outcome.bettingOffer.isAvailable
        let formattedOdds = OddFormatter.formatOdd(withValue: outcome.bettingOffer.decimalOdd)
        
        // Update individual properties as needed
        if currentValue != formattedOdds {
            GomaLogger.info(.realtime, category: "ODDS_FLOW", "OutcomeItemViewModel.processOutcomeUpdate - ODDS CHANGED for OUTCOME:\(outcomeId) from \(currentValue) to \(formattedOdds)")
            updateOddsValue(formattedOdds)
        }
        
        if currentTitle != newTitle {
            titleSubject.send(newTitle)
        }
        
        if currentIsDisabled != newIsDisabled {
            isDisabledSubject.send(newIsDisabled)
        }
    }
    
    private func calculateOddsChangeDirection(from oldValue: String, to newValue: String) -> GomaUI.OddsChangeDirection {
        // Convert to double for comparison
        guard let oldDouble = Double(oldValue),
              let newDouble = Double(newValue) else {
            return .none
        }
        
        if newDouble > oldDouble {
            return .up
        } else if newDouble < oldDouble {
            return .down
        } else {
            return .none
        }
    }
    
    // MARK: - Cleanup
    deinit {
        cancellables.removeAll()
    }
}

// MARK: - Factory Methods
extension OutcomeItemViewModel {
    
    /// Creates an OutcomeItemViewModel from an internal app Outcome model
    static func create(from outcome: Outcome) -> OutcomeItemViewModel {
        let outcomeData = GomaUI.OutcomeItemData(
            id: outcome.id,
            bettingOfferId: outcome.bettingOffer.id,
            title: outcome.translatedName,
            value: OddFormatter.formatOdd(withValue: outcome.bettingOffer.decimalOdd),
            oddsChangeDirection: .none,
            isSelected: false,
            isDisabled: !outcome.bettingOffer.isAvailable,
            previousValue: nil,
            changeTimestamp: nil
        )
        
        return OutcomeItemViewModel(
            outcomeId: outcome.id,
            initialOutcomeData: outcomeData
        )
    }
    
    /// Creates with initial data for immediate display while subscription loads
    static func create(
        outcomeId: String,
        bettingOfferId: String?,
        title: String,
        odds: Double,
        isAvailable: Bool = true
    ) -> OutcomeItemViewModel {
        let outcomeData = GomaUI.OutcomeItemData(
            id: outcomeId,
            bettingOfferId: bettingOfferId,
            
            title: title,
            value: OddFormatter.formatOdd(withValue: odds),
            oddsChangeDirection: .none,
            isSelected: false,
            isDisabled: !isAvailable,
            previousValue: nil,
            changeTimestamp: nil
        )
        
        return OutcomeItemViewModel(
            outcomeId: outcomeId,
            initialOutcomeData: outcomeData
        )
    }
}
