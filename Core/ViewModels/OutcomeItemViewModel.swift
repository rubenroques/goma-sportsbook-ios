import GomaUI
import ServicesProvider
import Combine
import UIKit

/// Production implementation of OutcomeItemViewModel that connects to real-time outcome updates
final class OutcomeItemViewModel: OutcomeItemViewModelProtocol {
    
    // MARK: - Dependencies
    private let outcomeId: String
    private let servicesProvider = Env.servicesProvider
    
    // MARK: - Subjects
    private let displayStateSubject: CurrentValueSubject<GomaUI.OutcomeItemDisplayState, Never>
    private let oddsChangeEventSubject: PassthroughSubject<GomaUI.OutcomeItemOddsChangeEvent, Never>
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Protocol Conformance
    public var displayStatePublisher: AnyPublisher<GomaUI.OutcomeItemDisplayState, Never> {
        displayStateSubject.eraseToAnyPublisher()
    }
    
    public var oddsChangeEventPublisher: AnyPublisher<GomaUI.OutcomeItemOddsChangeEvent, Never> {
        oddsChangeEventSubject.eraseToAnyPublisher()
    }
    
    // Individual publishers
    public var titlePublisher: AnyPublisher<String, Never> {
        displayStateSubject.map(\.outcomeData.title).eraseToAnyPublisher()
    }
    
    public var valuePublisher: AnyPublisher<String, Never> {
        displayStateSubject.map(\.outcomeData.value).eraseToAnyPublisher()
    }
    
    public var isSelectedPublisher: AnyPublisher<Bool, Never> {
        displayStateSubject.map(\.outcomeData.isSelected).eraseToAnyPublisher()
    }
    
    public var isDisabledPublisher: AnyPublisher<Bool, Never> {
        displayStateSubject.map(\.outcomeData.isDisabled).eraseToAnyPublisher()
    }
    
    // MARK: - Initialization
    init(
        outcomeId: String,
        initialOutcomeData: GomaUI.OutcomeItemData
    ) {
        self.outcomeId = outcomeId
        self.displayStateSubject = CurrentValueSubject(GomaUI.OutcomeItemDisplayState(outcomeData: initialOutcomeData))
        self.oddsChangeEventSubject = PassthroughSubject()
        
        print("[OutcomeItemViewModel] 🟢 INIT - outcomeId: \(outcomeId), title: \(initialOutcomeData.title)")
        setupOutcomeSubscription()
    }
    
    // MARK: - Public Methods
    public func toggleSelection() -> Bool {
        let currentData = displayStateSubject.value.outcomeData
        let newIsSelected = !currentData.isSelected
        
        let newOutcomeData = GomaUI.OutcomeItemData(
            id: currentData.id,
            title: currentData.title,
            value: currentData.value,
            oddsChangeDirection: currentData.oddsChangeDirection,
            isSelected: newIsSelected,
            isDisabled: currentData.isDisabled,
            previousValue: currentData.previousValue,
            changeTimestamp: currentData.changeTimestamp
        )
        
        let newState = GomaUI.OutcomeItemDisplayState(outcomeData: newOutcomeData)
        displayStateSubject.send(newState)
        
        return newIsSelected
    }
    
    public func updateOddsValue(_ newValue: String) {
        let currentData = displayStateSubject.value.outcomeData
        let previousValue = currentData.value
        
        // Calculate odds change direction
        let direction = calculateOddsChangeDirection(from: previousValue, to: newValue)
        
        // Create new outcome data with updated values
        let newOutcomeData = GomaUI.OutcomeItemData(
            id: currentData.id,
            title: currentData.title,
            value: newValue,
            oddsChangeDirection: direction,
            isSelected: currentData.isSelected,
            isDisabled: currentData.isDisabled,
            previousValue: previousValue,
            changeTimestamp: Date()
        )
        
        // Send updated state
        let newState = GomaUI.OutcomeItemDisplayState(outcomeData: newOutcomeData)
        displayStateSubject.send(newState)
        
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
    
    public func clearOddsChangeIndicator() {
        let currentData = displayStateSubject.value.outcomeData
        
        let newOutcomeData = GomaUI.OutcomeItemData(
            id: currentData.id,
            title: currentData.title,
            value: currentData.value,
            oddsChangeDirection: .none,
            isSelected: currentData.isSelected,
            isDisabled: currentData.isDisabled,
            previousValue: currentData.previousValue,
            changeTimestamp: currentData.changeTimestamp
        )
        
        let newState = GomaUI.OutcomeItemDisplayState(outcomeData: newOutcomeData)
        displayStateSubject.send(newState)
    }
    
    // MARK: - Protocol Required Methods
    public func updateValue(_ newValue: String) {
        updateOddsValue(newValue)
    }
    
    public func updateValue(_ newValue: String, changeDirection: GomaUI.OddsChangeDirection) {
        // For manual direction specification, we'll create the outcome data directly
        let currentData = displayStateSubject.value.outcomeData
        
        let newOutcomeData = GomaUI.OutcomeItemData(
            id: currentData.id,
            title: currentData.title,
            value: newValue,
            oddsChangeDirection: changeDirection,
            isSelected: currentData.isSelected,
            isDisabled: currentData.isDisabled,
            previousValue: currentData.value,
            changeTimestamp: Date()
        )
        
        let newState = GomaUI.OutcomeItemDisplayState(outcomeData: newOutcomeData)
        displayStateSubject.send(newState)
        
        // Emit odds change event if direction is not none
        if changeDirection != .none {
            let changeEvent = GomaUI.OutcomeItemOddsChangeEvent(
                outcomeId: outcomeId,
                oldValue: currentData.value,
                newValue: newValue,
                direction: changeDirection,
                timestamp: Date()
            )
            oddsChangeEventSubject.send(changeEvent)
        }
    }
    
    public func setSelected(_ selected: Bool) {
        let currentData = displayStateSubject.value.outcomeData
        
        let newOutcomeData = GomaUI.OutcomeItemData(
            id: currentData.id,
            title: currentData.title,
            value: currentData.value,
            oddsChangeDirection: currentData.oddsChangeDirection,
            isSelected: selected,
            isDisabled: currentData.isDisabled,
            previousValue: currentData.previousValue,
            changeTimestamp: currentData.changeTimestamp
        )
        
        let newState = GomaUI.OutcomeItemDisplayState(outcomeData: newOutcomeData)
        displayStateSubject.send(newState)
    }
    
    public func setDisabled(_ disabled: Bool) {
        updateSuspensionState(isSuspended: disabled)
    }
    
    public func updateSuspensionState(isSuspended: Bool) {
        let currentData = displayStateSubject.value.outcomeData
        
        let newOutcomeData = GomaUI.OutcomeItemData(
            id: currentData.id,
            title: currentData.title,
            value: currentData.value,
            oddsChangeDirection: currentData.oddsChangeDirection,
            isSelected: currentData.isSelected,
            isDisabled: isSuspended,
            previousValue: currentData.previousValue,
            changeTimestamp: currentData.changeTimestamp
        )
        
        let newState = GomaUI.OutcomeItemDisplayState(outcomeData: newOutcomeData)
        displayStateSubject.send(newState)
    }
    
    // MARK: - Private Methods
    private func setupOutcomeSubscription() {
        servicesProvider.subscribeToEventOnListsOutcomeUpdates(withId: outcomeId)
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { [weak self] completion in
                    if case .failure(let error) = completion {
                        Logger.log("Outcome subscription failed for \(self?.outcomeId ?? "unknown"): \(error)", .error)
                        // Handle reconnection logic here if needed
                    }
                },
                receiveValue: { [weak self] serviceProviderOutcome in
                    self?.processOutcomeUpdate(serviceProviderOutcome)
                }
            )
            .store(in: &cancellables)
    }
    
    private func processOutcomeUpdate(_ serviceProviderOutcome: ServicesProvider.Outcome?) {
        print("[OutcomeItemViewModel] 📡 Outcome update received for outcomeId: \(outcomeId)")
        
        guard let serviceProviderOutcome = serviceProviderOutcome else {
            // Outcome was removed - mark as disabled/suspended
            print("[OutcomeItemViewModel] ⚠️ Outcome removed, suspending outcomeId: \(outcomeId)")
            updateSuspensionState(isSuspended: true)
            return
        }
        
        // Convert ServicesProvider.Outcome to internal Outcome using mapper
        let outcome = ServiceProviderModelMapper.outcome(fromServiceProviderOutcome: serviceProviderOutcome)
        
        let currentData = displayStateSubject.value.outcomeData
        
        // Check if we need to update anything
        let newTitle = outcome.translatedName
        let newIsDisabled = !outcome.bettingOffer.isAvailable
        let formattedOdds = OddFormatter.formatOdd(withValue: outcome.bettingOffer.decimalOdd)
        
        // If odds changed, use updateOddsValue to handle direction calculation
        if currentData.value != formattedOdds {
            print("[OutcomeItemViewModel] 💰 Odds changed for outcomeId: \(outcomeId) - from: \(currentData.value) to: \(formattedOdds)")
            updateOddsValue(formattedOdds)
            // Then update other properties if needed
            if currentData.title != newTitle || currentData.isDisabled != newIsDisabled {
                let latestData = displayStateSubject.value.outcomeData
                let updatedData = GomaUI.OutcomeItemData(
                    id: latestData.id,
                    title: newTitle,
                    value: latestData.value,
                    oddsChangeDirection: latestData.oddsChangeDirection,
                    isSelected: latestData.isSelected,
                    isDisabled: newIsDisabled,
                    previousValue: latestData.previousValue,
                    changeTimestamp: latestData.changeTimestamp
                )
                let newState = GomaUI.OutcomeItemDisplayState(outcomeData: updatedData)
                displayStateSubject.send(newState)
            }
        } else if currentData.title != newTitle || currentData.isDisabled != newIsDisabled {
            // Only title or disabled state changed
            let updatedData = GomaUI.OutcomeItemData(
                id: currentData.id,
                title: newTitle,
                value: currentData.value,
                oddsChangeDirection: currentData.oddsChangeDirection,
                isSelected: currentData.isSelected,
                isDisabled: newIsDisabled,
                previousValue: currentData.previousValue,
                changeTimestamp: currentData.changeTimestamp
            )
            let newState = GomaUI.OutcomeItemDisplayState(outcomeData: updatedData)
            displayStateSubject.send(newState)
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
        print("[OutcomeItemViewModel] 🔴 DEINIT - outcomeId: \(outcomeId)")
        cancellables.removeAll()
    }
}

// MARK: - Factory Methods
extension OutcomeItemViewModel {
    
    /// Creates an OutcomeItemViewModel from an internal app Outcome model
    static func create(from outcome: Outcome) -> OutcomeItemViewModel {
        let outcomeData = GomaUI.OutcomeItemData(
            id: outcome.id,
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
        title: String,
        odds: Double,
        isAvailable: Bool = true
    ) -> OutcomeItemViewModel {
        let outcomeData = GomaUI.OutcomeItemData(
            id: outcomeId,
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
