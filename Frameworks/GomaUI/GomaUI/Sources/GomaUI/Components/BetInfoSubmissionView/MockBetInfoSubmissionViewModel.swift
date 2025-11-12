import Foundation
import UIKit
import Combine

/// Mock implementation of BetInfoSubmissionViewModelProtocol for testing and previews
public final class MockBetInfoSubmissionViewModel: BetInfoSubmissionViewModelProtocol {
    
    // MARK: - Properties
    private let dataSubject: CurrentValueSubject<BetInfoSubmissionData, Never>
    private let currency: String
    private var hasValidTickets: Bool = true
    
    // Child view models
    public var oddsRowViewModel: BetSummaryRowViewModelProtocol
    public var potentialWinningsRowViewModel: BetSummaryRowViewModelProtocol
    public var winBonusRowViewModel: BetSummaryRowViewModelProtocol
    public var payoutRowViewModel: BetSummaryRowViewModelProtocol
    public var amount100ButtonViewModel: QuickAddButtonViewModelProtocol
    public var amount250ButtonViewModel: QuickAddButtonViewModelProtocol
    public var amount500ButtonViewModel: QuickAddButtonViewModelProtocol
    public var amountTextFieldViewModel: BorderedTextFieldViewModelProtocol
    public var placeBetButtonViewModel: ButtonViewModelProtocol
    
    // Callback closures
    public var onPlaceBetTapped: (() -> Void)?
    public var onAmountReturnKeyTapped: (() -> Void)?
    public var amountChanged: (() -> Void)?
    
    public var dataPublisher: AnyPublisher<BetInfoSubmissionData, Never> {
        dataSubject.eraseToAnyPublisher()
    }
    
    public var currentData: BetInfoSubmissionData {
        dataSubject.value
    }
    
    // MARK: - Initialization
    public init(
        odds: String = "0.00",
        potentialWinnings: String = "0",
        winBonus: String = "0",
        payout: String = "0",
        amount: String = "",
        placeBetAmount: String = "0",
        isEnabled: Bool = true,
        currency: String = "XAF"
    ) {
        self.currency = currency
        
        // Format numeric values with the passed currency
        let defaultPotentialWinnings = "\(currency) \(potentialWinnings)"
        let defaultWinBonus = "\(currency) \(winBonus)"
        let defaultPayout = "\(currency) \(payout)"
        let defaultPlaceBetAmount = LocalizationProvider.string("place_bet_with_amount")
            .replacingOccurrences(of: "{currency}", with: currency)
            .replacingOccurrences(of: "{amount}", with: placeBetAmount)
        
        let initialData = BetInfoSubmissionData(
            odds: odds,
            potentialWinnings: defaultPotentialWinnings,
            winBonus: defaultWinBonus,
            payout: defaultPayout,
            amount: amount,
            placeBetAmount: defaultPlaceBetAmount,
            isEnabled: isEnabled,
            currency: currency
        )
        self.dataSubject = CurrentValueSubject(initialData)
        
        // Initialize child view models
        self.oddsRowViewModel = MockBetSummaryRowViewModel.oddsMock()
        self.potentialWinningsRowViewModel = MockBetSummaryRowViewModel.potentialWinningsMock()
        self.winBonusRowViewModel = MockBetSummaryRowViewModel.winBonusMock()
        self.payoutRowViewModel = MockBetSummaryRowViewModel.payoutMock()
        self.amount100ButtonViewModel = MockQuickAddButtonViewModel.amount100Mock()
        self.amount250ButtonViewModel = MockQuickAddButtonViewModel.amount250Mock()
        self.amount500ButtonViewModel = MockQuickAddButtonViewModel.amount500Mock()
        self.amountTextFieldViewModel = MockBorderedTextFieldViewModel(
            textFieldData: BorderedTextFieldData(
                id: "amount",
                text: "",
                placeholder: "Amount",
                visualState: .idle,
                keyboardType: .numbersAndPunctuation,
                returnKeyType: .go,
                textContentType: .flightNumber
            ))
        
        self.placeBetButtonViewModel = MockButtonViewModel(
            buttonData: ButtonData(
                id: "place_bet",
                title: LocalizationProvider.string("place_bet_with_amount")
                    .replacingOccurrences(of: "{currency}", with: currency)
                    .replacingOccurrences(of: "{amount}", with: "0"),
                style: .solidBackground,
                isEnabled: false
            ))
        
        // Wire up quick add button callbacks
        setupQuickAddButtonCallbacks()

        // Wire up text field return key to parent callback
        setupReturnKeyCallback()

        // Update child view models with initial state
        updateChildViewModels()

        self.updatePlaceBetButtonState()
    }
    
    // MARK: - Protocol Methods
    public func updatePotentialWinnings(_ amount: String) {
        let newData = BetInfoSubmissionData(
            odds: currentData.odds,
            potentialWinnings: amount,
            winBonus: currentData.winBonus,
            payout: currentData.payout,
            amount: currentData.amount,
            placeBetAmount: currentData.placeBetAmount,
            isEnabled: currentData.isEnabled,
            currency: currentData.currency
        )
        dataSubject.send(newData)
        
        // Update child view models
        potentialWinningsRowViewModel.updateValue(amount)
    }
    
    public func updateWinBonus(_ amount: String) {
        let newData = BetInfoSubmissionData(
            odds: currentData.odds,
            potentialWinnings: currentData.potentialWinnings,
            winBonus: amount,
            payout: currentData.payout,
            amount: currentData.amount,
            placeBetAmount: currentData.placeBetAmount,
            isEnabled: currentData.isEnabled,
            currency: currentData.currency
        )
        dataSubject.send(newData)
        
        // Update child view models
        winBonusRowViewModel.updateValue(amount)
    }
    
    public func updatePayout(_ amount: String) {
        let newData = BetInfoSubmissionData(
            odds: currentData.odds,
            potentialWinnings: currentData.potentialWinnings,
            winBonus: currentData.winBonus,
            payout: amount,
            amount: currentData.amount,
            placeBetAmount: currentData.placeBetAmount,
            isEnabled: currentData.isEnabled,
            currency: currentData.currency
        )
        dataSubject.send(newData)
        
        // Update child view models
        payoutRowViewModel.updateValue(amount)
    }
    
    public func updateAmount(_ amount: String) {
        let newData = BetInfoSubmissionData(
            odds: currentData.odds,
            potentialWinnings: currentData.potentialWinnings,
            winBonus: currentData.winBonus,
            payout: currentData.payout,
            amount: amount,
            placeBetAmount: currentData.placeBetAmount,
            isEnabled: currentData.isEnabled,
            currency: currentData.currency
        )
        dataSubject.send(newData)
        
        // Update child view models
        amountTextFieldViewModel.updateText(amount)
        updatePlaceBetButtonState()
    }
    
    public func updatePlaceBetAmount(_ amount: String) {
        let newData = BetInfoSubmissionData(
            odds: currentData.odds,
            potentialWinnings: currentData.potentialWinnings,
            winBonus: currentData.winBonus,
            payout: currentData.payout,
            amount: currentData.amount,
            placeBetAmount: amount,
            isEnabled: currentData.isEnabled,
            currency: currentData.currency
        )
        dataSubject.send(newData)
        
        // Update child view models
        placeBetButtonViewModel.updateTitle(amount)
    }
    
    public func setEnabled(_ isEnabled: Bool) {
        let newData = BetInfoSubmissionData(
            odds: currentData.odds,
            potentialWinnings: currentData.potentialWinnings,
            winBonus: currentData.winBonus,
            payout: currentData.payout,
            amount: currentData.amount,
            placeBetAmount: currentData.placeBetAmount,
            isEnabled: isEnabled,
            currency: currentData.currency
        )
        dataSubject.send(newData)
        
        // Update child view models
        oddsRowViewModel.setEnabled(isEnabled)
        potentialWinningsRowViewModel.setEnabled(isEnabled)
        winBonusRowViewModel.setEnabled(isEnabled)
        payoutRowViewModel.setEnabled(isEnabled)
        amount100ButtonViewModel.setEnabled(isEnabled)
        amount250ButtonViewModel.setEnabled(isEnabled)
        amount500ButtonViewModel.setEnabled(isEnabled)
        amountTextFieldViewModel.setEnabled(isEnabled)
        placeBetButtonViewModel.setEnabled(isEnabled)
    }
    
    public func updateHasValidTickets(_ hasValidTickets: Bool) {
        self.hasValidTickets = hasValidTickets
        updatePlaceBetButtonState()
    }
    
    public func onQuickAddTapped(_ amount: Int) {
        // Get the current amount and add the new amount
        let currentAmountString = currentData.amount
        let currentAmount = Double(currentAmountString) ?? 0.0
        let newTotalAmount = currentAmount + Double(amount)
        let newTotalAmountString = String(format: "%.0f", newTotalAmount)
        
        updateAmount(newTotalAmountString)
        updatePlaceBetAmount(LocalizationProvider.string("place_bet_with_amount")
            .replacingOccurrences(of: "{currency}", with: currency)
            .replacingOccurrences(of: "{amount}", with: newTotalAmountString))

        // Update child view models
        amountTextFieldViewModel.updateText(newTotalAmountString)
        placeBetButtonViewModel.updateTitle(LocalizationProvider.string("place_bet_with_amount")
            .replacingOccurrences(of: "{currency}", with: currency)
            .replacingOccurrences(of: "{amount}", with: newTotalAmountString))
        placeBetButtonViewModel.setEnabled(true)
    }
    
    public func onAmountChanged(_ amount: String) {
        updateAmount(amount)
        updatePlaceBetButtonState()
        amountChanged?()
        placeBetButtonViewModel.updateTitle(LocalizationProvider.string("place_bet_with_amount")
            .replacingOccurrences(of: "{currency}", with: currency)
            .replacingOccurrences(of: "{amount}", with: amount))
    }
    
    // MARK: - Private Methods
    private func setupQuickAddButtonCallbacks() {
        // Wire quick add button callbacks to our onQuickAddTapped method
        amount100ButtonViewModel.onButtonTapped = { [weak self] in
            self?.onQuickAddTapped(100)
        }

        amount250ButtonViewModel.onButtonTapped = { [weak self] in
            self?.onQuickAddTapped(250)
        }

        amount500ButtonViewModel.onButtonTapped = { [weak self] in
            self?.onQuickAddTapped(500)
        }
    }

    private func setupReturnKeyCallback() {
        // Wire the text field's return key callback to trigger the parent callback
        if let mockViewModel = amountTextFieldViewModel as? MockBorderedTextFieldViewModel {
            mockViewModel.onReturnKeyTappedCallback = { [weak self] in
                self?.onAmountReturnKeyTapped?()
            }
        }
    }
    
    private func updateChildViewModels() {
        oddsRowViewModel.updateValue(currentData.odds)
        potentialWinningsRowViewModel.updateValue(currentData.potentialWinnings)
        winBonusRowViewModel.updateValue(currentData.winBonus)
        payoutRowViewModel.updateValue(currentData.payout)
        amountTextFieldViewModel.updateText(currentData.amount)
        placeBetButtonViewModel.updateTitle(currentData.placeBetAmount)
        placeBetButtonViewModel.setEnabled(currentData.isEnabled)
    }

    public func updateOdds(_ odds: String) {
        let newData = BetInfoSubmissionData(
            odds: odds,
            potentialWinnings: currentData.potentialWinnings,
            winBonus: currentData.winBonus,
            payout: currentData.payout,
            amount: currentData.amount,
            placeBetAmount: currentData.placeBetAmount,
            isEnabled: currentData.isEnabled,
            currency: currentData.currency
        )
        dataSubject.send(newData)
        oddsRowViewModel.updateValue(odds)
    }
    
    private func updatePlaceBetButtonState() {
        // Button is only enabled if we have an amount AND all tickets are valid
        let isEnabled = !currentData.amount.isEmpty && hasValidTickets
        placeBetButtonViewModel.setEnabled(isEnabled)
    }
}

// MARK: - Factory Methods
public extension MockBetInfoSubmissionViewModel {
    
    /// Creates a mock view model for default state
    static func defaultMock(currency: String = "XAF") -> MockBetInfoSubmissionViewModel {
        MockBetInfoSubmissionViewModel(currency: currency)
    }
    
    /// Creates a mock view model with specific amounts
    static func withAmountsMock(
        potentialWinnings: String = "50,000",
        winBonus: String = "5,000",
        payout: String = "55,000",
        amount: String = "10,000",
        currency: String = "XAF"
    ) -> MockBetInfoSubmissionViewModel {
        return MockBetInfoSubmissionViewModel(
            potentialWinnings: potentialWinnings,
            winBonus: winBonus,
            payout: payout,
            amount: amount,
            placeBetAmount: amount,
            currency: currency
        )
    }
    
    /// Creates a mock view model for disabled state
    static func disabledMock(currency: String = "XAF") -> MockBetInfoSubmissionViewModel {
        MockBetInfoSubmissionViewModel(isEnabled: false, currency: currency)
    }
} 
