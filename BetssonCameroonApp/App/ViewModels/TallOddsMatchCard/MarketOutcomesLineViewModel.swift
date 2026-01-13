import GomaUI
import ServicesProvider
import Combine
import UIKit
import GomaLogger

/// Production implementation of MarketOutcomesLineViewModel that connects to real-time market updates
final class MarketOutcomesLineViewModel: MarketOutcomesLineViewModelProtocol {
    
    // MARK: - Dependencies
    private let marketId: String
    private let servicesProvider = Env.servicesProvider
    
    // MARK: - Subjects
    public let marketStateSubject: CurrentValueSubject<MarketOutcomesLineDisplayState, Never>
    private let oddsChangeEventSubject: PassthroughSubject<OddsChangeEvent, Never>
    private let outcomeSelectionDidChangeSubject: PassthroughSubject<MarketOutcomeSelectionEvent, Never>
    private var cancellables = Set<AnyCancellable>()
    private var childCancellables = Set<AnyCancellable>()
    
    // MARK: - Child ViewModels
    private var outcomeViewModels: [OutcomeType: OutcomeItemViewModel] = [:]
    
    // MARK: - Protocol Conformance
    public var marketStatePublisher: AnyPublisher<MarketOutcomesLineDisplayState, Never> {
        marketStateSubject.eraseToAnyPublisher()
    }
    
    public var oddsChangeEventPublisher: AnyPublisher<OddsChangeEvent, Never> {
        oddsChangeEventSubject.eraseToAnyPublisher()
    }

    /// Publisher for selection changes from child OutcomeItemViewModels.
    /// View observes this to notify external callbacks (proper MVVM pattern).
    public var outcomeSelectionDidChangePublisher: AnyPublisher<MarketOutcomeSelectionEvent, Never> {
        outcomeSelectionDidChangeSubject.eraseToAnyPublisher()
    }

    var matchCardContext: MatchCardContext
    
    // MARK: - Initialization
    init(
        marketId: String,
        initialDisplayState: MarketOutcomesLineDisplayState,
        matchCardContext: MatchCardContext = .lists
    ) {
        self.marketId = marketId
        self.marketStateSubject = CurrentValueSubject(initialDisplayState)
        self.oddsChangeEventSubject = PassthroughSubject()
        self.outcomeSelectionDidChangeSubject = PassthroughSubject()

        self.matchCardContext = matchCardContext

        // Create initial outcome view models
        createOutcomeViewModels(from: initialDisplayState)

        // Setup market subscription
        setupMarketSubscription()
    }
    
    // MARK: - Public Methods
    public func setOutcomeSelected(type: OutcomeType) {
        guard let outcomeViewModel = outcomeViewModels[type] else { return }
        
        outcomeViewModel.setSelected(true)
    }
    
    public func setOutcomeDeselected(type: OutcomeType) {
        guard let outcomeViewModel = outcomeViewModels[type] else { return }
        
        outcomeViewModel.setSelected(false)
    }
    
    public func updateOddsValue(type: OutcomeType, newValue: String) {
        guard let outcomeViewModel = outcomeViewModels[type] else {
            return
        }
        
        outcomeViewModel.updateOddsValue(newValue)
    }
    
    public func clearOddsChangeIndicator(type: OutcomeType) {
        guard let outcomeViewModel = outcomeViewModels[type] else {
            return
        }
        
        outcomeViewModel.clearOddsChangeIndicator()
    }
    
    public func createOutcomeViewModel(for outcomeType: OutcomeType) -> OutcomeItemViewModelProtocol? {
        return outcomeViewModels[outcomeType]
    }
    
    public func updateOddsValue(type: OutcomeType, value: String, changeDirection: GomaUI.OddsChangeDirection) {
        // Legacy method for manual direction specification - delegate to the automatic method
        updateOddsValue(type: type, newValue: value)
    }
    
    public func setDisplayMode(_ mode: MarketDisplayMode) {
        let currentState = marketStateSubject.value
        let newState = MarketOutcomesLineDisplayState(
            displayMode: mode,
            leftOutcome: currentState.leftOutcome,
            middleOutcome: currentState.middleOutcome,
            rightOutcome: currentState.rightOutcome
        )
        marketStateSubject.send(newState)
    }

    public func updateSelectionStates(selectedOfferIds: Set<String>) {
        let currentState = marketStateSubject.value

        // Always call setSelected unconditionally - the displayState's isSelected is stale
        // (createOutcomeData always sets isSelected: false). The actual selection state
        // lives in OutcomeItemViewModel.isSelectedSubject.

        if let leftOutcome = currentState.leftOutcome,
           let bettingOfferId = leftOutcome.bettingOfferId {
            let shouldBeSelected = selectedOfferIds.contains(bettingOfferId)
            outcomeViewModels[.left]?.setSelected(shouldBeSelected)
        }

        if let middleOutcome = currentState.middleOutcome,
           let bettingOfferId = middleOutcome.bettingOfferId {
            let shouldBeSelected = selectedOfferIds.contains(bettingOfferId)
            outcomeViewModels[.middle]?.setSelected(shouldBeSelected)
        }

        if let rightOutcome = currentState.rightOutcome,
           let bettingOfferId = rightOutcome.bettingOfferId {
            let shouldBeSelected = selectedOfferIds.contains(bettingOfferId)
            outcomeViewModels[.right]?.setSelected(shouldBeSelected)
        }
    }

    // MARK: - Private Methods
    private func setupMarketSubscription() {
        if matchCardContext == .lists {
            GomaLogger.debug(.realtime, category: "ODDS_FLOW", "MarketOutcomesLineViewModel.setupMarketSubscription - SUBSCRIBING to market updates for MARKET:\(marketId)")
            servicesProvider.subscribeToEventOnListsMarketUpdates(withId: marketId)
                .receive(on: DispatchQueue.main)
                .sink(
                    receiveCompletion: { [weak self] completion in
                        if case .failure(let error) = completion {
                            GomaLogger.error(.realtime, category: "ODDS_FLOW", "MarketOutcomesLineViewModel - SUBSCRIPTION FAILED for MARKET:\(self?.marketId ?? "unknown"): \(error)")
                            // Handle market suspension on connection failure
                            self?.handleMarketSuspension(reason: "Connection Error")
                        }
                    },
                    receiveValue: { [weak self] serviceProviderMarket in
                        GomaLogger.info(.realtime, category: "ODDS_FLOW", "MarketOutcomesLineViewModel - RECEIVED market update for MARKET:\(self?.marketId ?? "unknown")")
                        self?.processMarketUpdate(serviceProviderMarket)
                    }
                )
                .store(in: &cancellables)
        }
        else {
            GomaLogger.debug(.realtime, category: "ODDS_FLOW", "MarketOutcomesLineViewModel - SKIPPING subscription (matchCardContext=search) for MARKET:\(marketId)")
        }
    }
    
    private func processMarketUpdate(_ serviceProviderMarket: ServicesProvider.Market?) {
        guard let serviceProviderMarket = serviceProviderMarket else {
            // Market was removed - suspend the entire line
            handleMarketSuspension(reason: "Market Removed")
            return
        }
        
        // Convert ServicesProvider.Market to internal Market using mapper
        let market = ServiceProviderModelMapper.market(fromServiceProviderMarket: serviceProviderMarket)
        
        // Check if market is suspended/closed
        if !market.isAvailable {
            handleMarketSuspension(reason: "Market Suspended")
            return
        }
        
        // Process market changes - outcomes added/removed/updated
        updateOutcomesFromMarket(market)
    }
    
    private func updateOutcomesFromMarket(_ market: Market) {
        let currentState = marketStateSubject.value
        var newOutcomes: [OutcomeType: MarketOutcomeData] = [:]
        
        let outcomes = market.outcomes
        
        // Determine display mode based on number of outcomes
        let displayMode: MarketDisplayMode
        if outcomes.count == 2 {
            displayMode = .double
            // Map to left/right
            if let first = outcomes.first {
                newOutcomes[.left] = createOutcomeData(from: first)
            }
            if outcomes.count > 1 {
                newOutcomes[.right] = createOutcomeData(from: outcomes[1])
            }
        } else if outcomes.count >= 3 {
            displayMode = .triple
            // Map to left/middle/right
            if let first = outcomes.first {
                newOutcomes[.left] = createOutcomeData(from: first)
            }
            if outcomes.count > 1 {
                newOutcomes[.middle] = createOutcomeData(from: outcomes[1])
            }
            if outcomes.count > 2 {
                newOutcomes[.right] = createOutcomeData(from: outcomes[2])
            }
        } else {
            // No outcomes available
            handleMarketSuspension(reason: "No Outcomes Available")
            return
        }
        
        // Update the display state
        let newDisplayState = MarketOutcomesLineDisplayState(
            displayMode: displayMode,
            leftOutcome: newOutcomes[.left],
            middleOutcome: newOutcomes[.middle],
            rightOutcome: newOutcomes[.right]
        )
        
        // Update or create outcome view models as needed
        updateOutcomeViewModels(newOutcomes: newOutcomes, fromMarket: market)
        
        // Send the updated state
        marketStateSubject.send(newDisplayState)
    }
    
    private func createOutcomeData(from outcome: Outcome) -> MarketOutcomeData {
        let completeName = outcome.codeName != outcome.typeName ? "\(outcome.codeName) (\(outcome.typeName))" : outcome.codeName

        return MarketOutcomeData(
            id: outcome.id,
            bettingOfferId: outcome.bettingOffer.id,
            title: outcome.translatedName,
            completeName: completeName,
            value: OddFormatter.formatOdd(withValue: outcome.bettingOffer.decimalOdd),
            oddsChangeDirection: .none,
            isSelected: false,
            isDisabled: !outcome.bettingOffer.isAvailable
        )
    }
    
    private func updateOutcomeViewModels(newOutcomes: [OutcomeType: MarketOutcomeData], fromMarket market: Market) {
        // Remove outcome VMs that are no longer needed
        let currentTypes = Set(outcomeViewModels.keys)
        let newTypes = Set(newOutcomes.keys)
        let typesToRemove = currentTypes.subtracting(newTypes)
        
        for typeToRemove in typesToRemove {
            outcomeViewModels.removeValue(forKey: typeToRemove)
        }
        
        // Add or update outcome VMs for current outcomes
        for (outcomeType, outcomeData) in newOutcomes {
            if outcomeViewModels[outcomeType] == nil {
                // Create new outcome view model
                if let matchingOutcome = market.outcomes.first(where: { $0.id == outcomeData.id }) {
                    let newOutcomeVM = OutcomeItemViewModel.create(from: matchingOutcome)
                    outcomeViewModels[outcomeType] = newOutcomeVM
                    
                    // Subscribe to odds change events from this outcome
                    subscribeToOutcomeEvents(outcomeVM: newOutcomeVM, outcomeType: outcomeType)
                }
            } else {
                
            }
            // Note: Individual outcome updates are handled by the OutcomeItemViewModel's own subscription
        }
    }
    
    private func subscribeToOutcomeEvents(outcomeVM: OutcomeItemViewModel, outcomeType: OutcomeType) {
        // Subscribe to odds change events
        outcomeVM.oddsChangeEventPublisher
            .sink { [weak self] outcomeEvent in
                // Convert OutcomeItemOddsChangeEvent to OddsChangeEvent for the line level
                let lineEvent = OddsChangeEvent(
                    outcomeType: outcomeType,
                    oldValue: outcomeEvent.oldValue,
                    newValue: outcomeEvent.newValue,
                    direction: outcomeEvent.direction,
                    timestamp: outcomeEvent.timestamp
                )
                self?.oddsChangeEventSubject.send(lineEvent)
            }
            .store(in: &cancellables)

        // Subscribe to selection change events (proper MVVM - parent observes child)
        outcomeVM.selectionDidChangePublisher
            .sink { [weak self] event in
                // Transform child event to parent event (adding OutcomeType)
                let parentEvent = MarketOutcomeSelectionEvent(
                    outcomeId: event.outcomeId,
                    bettingOfferId: event.bettingOfferId,
                    outcomeType: outcomeType,
                    isSelected: event.isSelected,
                    timestamp: event.timestamp
                )
                self?.outcomeSelectionDidChangeSubject.send(parentEvent)
            }
            .store(in: &childCancellables)
    }
    
    private func createOutcomeViewModels(from displayState: MarketOutcomesLineDisplayState) {
        // Create outcome view models for initial outcomes
        if let leftOutcome = displayState.leftOutcome {
            let leftVM = OutcomeItemViewModel.create(
                outcomeId: leftOutcome.id,
                bettingOfferId: leftOutcome.bettingOfferId,
                title: leftOutcome.title,
                odds: Double(leftOutcome.value) ?? 1.0,
                isAvailable: !leftOutcome.isDisabled
            )
            outcomeViewModels[.left] = leftVM
            subscribeToOutcomeEvents(outcomeVM: leftVM, outcomeType: .left)
        }
        
        if let middleOutcome = displayState.middleOutcome {
            let middleVM = OutcomeItemViewModel.create(
                outcomeId: middleOutcome.id,
                bettingOfferId: middleOutcome.bettingOfferId,
                title: middleOutcome.title,
                odds: Double(middleOutcome.value) ?? 1.0,
                isAvailable: !middleOutcome.isDisabled
            )
            outcomeViewModels[.middle] = middleVM
            subscribeToOutcomeEvents(outcomeVM: middleVM, outcomeType: .middle)
        }
        
        if let rightOutcome = displayState.rightOutcome {
            let rightVM = OutcomeItemViewModel.create(
                outcomeId: rightOutcome.id,
                bettingOfferId: rightOutcome.bettingOfferId,
                title: rightOutcome.title,
                odds: Double(rightOutcome.value) ?? 1.0,
                isAvailable: !rightOutcome.isDisabled
            )
            outcomeViewModels[.right] = rightVM
            subscribeToOutcomeEvents(outcomeVM: rightVM, outcomeType: .right)
        }
    }
    
    private func handleMarketSuspension(reason: String) {
        let suspendedState = MarketOutcomesLineDisplayState(
            displayMode: .suspended(text: reason),
            leftOutcome: nil,
            middleOutcome: nil,
            rightOutcome: nil
        )
        
        // Clear outcome view models when market is suspended
        outcomeViewModels.removeAll()
        
        marketStateSubject.send(suspendedState)
    }
    
    // MARK: - Cleanup
    deinit {
        cancellables.removeAll()
        outcomeViewModels.removeAll()
    }
}

// MARK: - Factory Methods
extension MarketOutcomesLineViewModel {
    
    /// Creates a MarketOutcomesLineViewModel from an internal app Market model
    static func create(from market: Market, with matchCardContext: MatchCardContext) -> MarketOutcomesLineViewModel {
        let displayState = createDisplayState(from: market)
        
        return MarketOutcomesLineViewModel(
            marketId: market.id,
            initialDisplayState: displayState,
            matchCardContext: matchCardContext
        )
    }
    
    /// Creates initial display state from Market data
    private static func createDisplayState(from market: Market) -> MarketOutcomesLineDisplayState {
        guard market.isAvailable && !market.outcomes.isEmpty else {
            return MarketOutcomesLineDisplayState(
                displayMode: .seeAll(text: "See all Markets"),
                leftOutcome: nil,
                middleOutcome: nil,
                rightOutcome: nil
            )
        }
        
        let outcomes = market.outcomes
        
        let displayMode: MarketDisplayMode = outcomes.count >= 3 ? .triple : .double
        
        let leftOutcome = !outcomes.isEmpty ? createOutcomeData(from: outcomes[0]) : nil
        let middleOutcome = outcomes.count > 2 ? createOutcomeData(from: outcomes[1]) : nil
        let rightOutcome = outcomes.count > 1 ? createOutcomeData(from: outcomes[outcomes.count >= 3 ? 2 : 1]) : nil
        
        return MarketOutcomesLineDisplayState(
            displayMode: displayMode,
            leftOutcome: leftOutcome,
            middleOutcome: middleOutcome,
            rightOutcome: rightOutcome
        )
    }
    
    private static func createOutcomeData(from outcome: Outcome) -> MarketOutcomeData {
        let completeName = outcome.translatedName != outcome.typeName ? "\(outcome.translatedName) (\(outcome.typeName)" : outcome.translatedName

        return MarketOutcomeData(
            id: outcome.id,
            bettingOfferId: outcome.bettingOffer.id,
            title: outcome.translatedName,
            completeName: completeName,
            value: OddFormatter.formatOdd(withValue: outcome.bettingOffer.decimalOdd),
            oddsChangeDirection: .none,
            isSelected: false,
            isDisabled: !outcome.bettingOffer.isAvailable
        )
    }
}
