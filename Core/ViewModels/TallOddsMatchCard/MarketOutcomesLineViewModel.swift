import GomaUI
import ServicesProvider
import Combine
import UIKit

/// Production implementation of MarketOutcomesLineViewModel that connects to real-time market updates
final class MarketOutcomesLineViewModel: MarketOutcomesLineViewModelProtocol {
    
    // MARK: - Dependencies
    private let marketId: String
    private let servicesProvider = Env.servicesProvider
    
    // MARK: - Subjects
    private let marketStateSubject: CurrentValueSubject<MarketOutcomesLineDisplayState, Never>
    private let oddsChangeEventSubject: PassthroughSubject<OddsChangeEvent, Never>
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Child ViewModels
    private var outcomeViewModels: [OutcomeType: OutcomeItemViewModel] = [:]
    
    // MARK: - Protocol Conformance
    public var marketStatePublisher: AnyPublisher<MarketOutcomesLineDisplayState, Never> {
        marketStateSubject.eraseToAnyPublisher()
    }
    
    public var oddsChangeEventPublisher: AnyPublisher<OddsChangeEvent, Never> {
        oddsChangeEventSubject.eraseToAnyPublisher()
    }
    
    // MARK: - Initialization
    init(
        marketId: String,
        initialDisplayState: MarketOutcomesLineDisplayState
    ) {
        print("[MarketOutcomesLineViewModel] 🟢 INIT create new market outcome line \(marketId)")
        self.marketId = marketId
        self.marketStateSubject = CurrentValueSubject(initialDisplayState)
        self.oddsChangeEventSubject = PassthroughSubject()
        
        // Create initial outcome view models
        createOutcomeViewModels(from: initialDisplayState)
        
        // Setup market subscription
        setupMarketSubscription()
    }
    
    // MARK: - Public Methods
    public func toggleOutcome(type: OutcomeType) -> Bool {
        guard let outcomeViewModel = outcomeViewModels[type] else {
            return false
        }
        
        return outcomeViewModel.toggleSelection()
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
        var currentState = marketStateSubject.value
        let newState = MarketOutcomesLineDisplayState(
            displayMode: mode,
            leftOutcome: currentState.leftOutcome,
            middleOutcome: currentState.middleOutcome,
            rightOutcome: currentState.rightOutcome
        )
        marketStateSubject.send(newState)
    }
    
    // MARK: - Private Methods
    private func setupMarketSubscription() {
        servicesProvider.subscribeToEventOnListsMarketUpdates(withId: marketId)
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { [weak self] completion in
                    if case .failure(let error) = completion {
                        print("Market subscription failed for \(self?.marketId ?? "unknown"): \(error)")
                        // Handle market suspension on connection failure
                        self?.handleMarketSuspension(reason: "Connection Error")
                    }
                },
                receiveValue: { [weak self] serviceProviderMarket in
                    self?.processMarketUpdate(serviceProviderMarket)
                }
            )
            .store(in: &cancellables)
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
        
        // Map market outcomes to our outcome types
        let sortedOutcomes = market.outcomes.sorted { lhs, rhs in
            // Sort by orderValue if available, otherwise by id
            if let lhsOrder = lhs.orderValue, let rhsOrder = rhs.orderValue {
                return lhsOrder < rhsOrder
            }
            return lhs.id < rhs.id
        }
        
        // Determine display mode based on number of outcomes
        let displayMode: MarketDisplayMode
        if sortedOutcomes.count == 2 {
            displayMode = .double
            // Map to left/right
            if let first = sortedOutcomes.first {
                newOutcomes[.left] = createOutcomeData(from: first)
            }
            if sortedOutcomes.count > 1 {
                newOutcomes[.right] = createOutcomeData(from: sortedOutcomes[1])
            }
        } else if sortedOutcomes.count >= 3 {
            displayMode = .triple
            // Map to left/middle/right
            if let first = sortedOutcomes.first {
                newOutcomes[.left] = createOutcomeData(from: first)
            }
            if sortedOutcomes.count > 1 {
                newOutcomes[.middle] = createOutcomeData(from: sortedOutcomes[1])
            }
            if sortedOutcomes.count > 2 {
                newOutcomes[.right] = createOutcomeData(from: sortedOutcomes[2])
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
        return MarketOutcomeData(
            id: outcome.id,
            title: outcome.translatedName,
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
                    print("[MarketOutcomesLineViewModel] 🆕 Creating new OutcomeItemViewModel for outcomeType: \(outcomeType), outcomeId: \(matchingOutcome.id)")
                    let newOutcomeVM = OutcomeItemViewModel.create(from: matchingOutcome)
                    outcomeViewModels[outcomeType] = newOutcomeVM
                    
                    // Subscribe to odds change events from this outcome
                    subscribeToOutcomeEvents(outcomeVM: newOutcomeVM, outcomeType: outcomeType)
                }
            } else {
                print("[MarketOutcomesLineViewModel] ♻️ Reusing existing OutcomeItemViewModel for outcomeType: \(outcomeType)")
            }
            // Note: Individual outcome updates are handled by the OutcomeItemViewModel's own subscription
        }
    }
    
    private func subscribeToOutcomeEvents(outcomeVM: OutcomeItemViewModel, outcomeType: OutcomeType) {
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
    }
    
    private func createOutcomeViewModels(from displayState: MarketOutcomesLineDisplayState) {
        // Create outcome view models for initial outcomes
        if let leftOutcome = displayState.leftOutcome {
            let leftVM = OutcomeItemViewModel.create(
                outcomeId: leftOutcome.id,
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
        print("[MarketOutcomesLineViewModel] 🔴 DEINIT - marketId: \(marketId)")
        
        cancellables.removeAll()
        outcomeViewModels.removeAll()
    }
}

// MARK: - Factory Methods
extension MarketOutcomesLineViewModel {
    
    /// Creates a MarketOutcomesLineViewModel from an internal app Market model
    static func create(from market: Market) -> MarketOutcomesLineViewModel {
        let displayState = createDisplayState(from: market)
        
        return MarketOutcomesLineViewModel(
            marketId: market.id,
            initialDisplayState: displayState
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
        
        let sortedOutcomes = market.outcomes.sorted { lhs, rhs in
            // Sort by orderValue if available, otherwise by id
            if let lhsOrder = lhs.orderValue, let rhsOrder = rhs.orderValue {
                return lhsOrder < rhsOrder
            }
            return lhs.id < rhs.id
        }
        
        let displayMode: MarketDisplayMode = sortedOutcomes.count >= 3 ? .triple : .double
        
        let leftOutcome = sortedOutcomes.count > 0 ? createOutcomeData(from: sortedOutcomes[0]) : nil
        let middleOutcome = sortedOutcomes.count > 2 ? createOutcomeData(from: sortedOutcomes[1]) : nil
        let rightOutcome = sortedOutcomes.count > 1 ? createOutcomeData(from: sortedOutcomes[sortedOutcomes.count >= 3 ? 2 : 1]) : nil
        
        return MarketOutcomesLineDisplayState(
            displayMode: displayMode,
            leftOutcome: leftOutcome,
            middleOutcome: middleOutcome,
            rightOutcome: rightOutcome
        )
    }
    
    private static func createOutcomeData(from outcome: Outcome) -> MarketOutcomeData {
        return MarketOutcomeData(
            id: outcome.id,
            title: outcome.translatedName,
            value: OddFormatter.formatOdd(withValue: outcome.bettingOffer.decimalOdd),
            oddsChangeDirection: .none,
            isSelected: false,
            isDisabled: !outcome.bettingOffer.isAvailable
        )
    }
}
