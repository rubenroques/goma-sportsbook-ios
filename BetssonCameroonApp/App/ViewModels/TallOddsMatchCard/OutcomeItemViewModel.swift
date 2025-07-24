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
    private let displayStateSubject: CurrentValueSubject<GomaUI.OutcomeDisplayState, Never>
    private let titleSubject: CurrentValueSubject<String, Never>
    private let valueSubject: CurrentValueSubject<String, Never>
    private let isSelectedSubject: CurrentValueSubject<Bool, Never>
    private let isDisabledSubject: CurrentValueSubject<Bool, Never>
    private let oddsChangeEventSubject: PassthroughSubject<GomaUI.OutcomeItemOddsChangeEvent, Never>
    
    private var cancellables = Set<AnyCancellable>()
    
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
    
    
    // MARK: - Initialization
    init(
        outcomeId: String,
        initialOutcomeData: GomaUI.OutcomeItemData
    ) {
        self.outcomeId = outcomeId
        self.titleSubject = CurrentValueSubject(initialOutcomeData.title)
        self.valueSubject = CurrentValueSubject(initialOutcomeData.value)
        self.isSelectedSubject = CurrentValueSubject(initialOutcomeData.isSelected)
        self.isDisabledSubject = CurrentValueSubject(initialOutcomeData.isDisabled)
        self.oddsChangeEventSubject = PassthroughSubject()
        self.displayStateSubject = CurrentValueSubject(initialOutcomeData.displayState)
        
        print("[OutcomeItemViewModel] 🟢 INIT - outcomeId: \(outcomeId), title: \(initialOutcomeData.title)")
        setupOutcomeSubscription()
    }
    
    // MARK: - Public Methods
    public func toggleSelection() -> Bool {
        let newIsSelected = !isSelectedSubject.value
        isSelectedSubject.send(newIsSelected)
        return newIsSelected
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
        servicesProvider.subscribeToEventOnListsOutcomeUpdates(withId: outcomeId)
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { [weak self] completion in
                    if case .failure(let error) = completion {
                        print("Outcome subscription failed for \(self?.outcomeId ?? "unknown"): \(error)")
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
            print("[OutcomeItemViewModel] Odds changed for outcomeId: \(newTitle) - from: \(currentValue) to: \(formattedOdds)")
            updateOddsValue(formattedOdds)
        }
        
        if currentTitle != newTitle {
            print("[OutcomeItemViewModel] Title changed for outcomeId: \(newTitle) - from: \(currentValue) to: \(formattedOdds)")
            titleSubject.send(newTitle)
        }
        
        if currentIsDisabled != newIsDisabled {
            print("[OutcomeItemViewModel] isDisabled changed for outcomeId: \(newTitle) - from: \(currentValue) to: \(formattedOdds)")
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
