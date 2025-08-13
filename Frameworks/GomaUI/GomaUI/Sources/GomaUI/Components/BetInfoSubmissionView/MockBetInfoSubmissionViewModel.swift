import Foundation
import UIKit
import Combine

/// Mock implementation of BetInfoSubmissionViewModelProtocol for testing and previews
public final class MockBetInfoSubmissionViewModel: BetInfoSubmissionViewModelProtocol {
    
    // MARK: - Properties
    private let dataSubject: CurrentValueSubject<BetInfoSubmissionData, Never>
    
    // Child view models
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
    
    public var dataPublisher: AnyPublisher<BetInfoSubmissionData, Never> {
        dataSubject.eraseToAnyPublisher()
    }
    
    public var currentData: BetInfoSubmissionData {
        dataSubject.value
    }
    
    // MARK: - Initialization
    public init(
        potentialWinnings: String = "XAF 0",
        winBonus: String = "XAF 0",
        payout: String = "XAF 0",
        amount: String = "",
        placeBetAmount: String = "Place Bet XAF 0",
        isEnabled: Bool = true
    ) {
        let initialData = BetInfoSubmissionData(
            potentialWinnings: potentialWinnings,
            winBonus: winBonus,
            payout: payout,
            amount: amount,
            placeBetAmount: placeBetAmount,
            isEnabled: isEnabled
        )
        self.dataSubject = CurrentValueSubject(initialData)
        
        // Initialize child view models
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
                keyboardType: .decimalPad,
                textContentType: .flightNumber
            ))
        self.placeBetButtonViewModel = MockButtonViewModel(
            buttonData: ButtonData(
                id: "place_bet",
                title: "Place Bet XAF 0",
                style: .solidBackground,
                isEnabled: false
            ))
        
        // Wire up quick add button callbacks
        setupQuickAddButtonCallbacks()
        
        // Update child view models with initial state
        updateChildViewModels()
    }
    
    // MARK: - Protocol Methods
    public func updatePotentialWinnings(_ amount: String) {
        let newData = BetInfoSubmissionData(
            potentialWinnings: amount,
            winBonus: currentData.winBonus,
            payout: currentData.payout,
            amount: currentData.amount,
            placeBetAmount: currentData.placeBetAmount,
            isEnabled: currentData.isEnabled
        )
        dataSubject.send(newData)
        
        // Update child view models
        potentialWinningsRowViewModel.updateValue(amount)
    }
    
    public func updateWinBonus(_ amount: String) {
        let newData = BetInfoSubmissionData(
            potentialWinnings: currentData.potentialWinnings,
            winBonus: amount,
            payout: currentData.payout,
            amount: currentData.amount,
            placeBetAmount: currentData.placeBetAmount,
            isEnabled: currentData.isEnabled
        )
        dataSubject.send(newData)
        
        // Update child view models
        winBonusRowViewModel.updateValue(amount)
    }
    
    public func updatePayout(_ amount: String) {
        let newData = BetInfoSubmissionData(
            potentialWinnings: currentData.potentialWinnings,
            winBonus: currentData.winBonus,
            payout: amount,
            amount: currentData.amount,
            placeBetAmount: currentData.placeBetAmount,
            isEnabled: currentData.isEnabled
        )
        dataSubject.send(newData)
        
        // Update child view models
        payoutRowViewModel.updateValue(amount)
    }
    
    public func updateAmount(_ amount: String) {
        let newData = BetInfoSubmissionData(
            potentialWinnings: currentData.potentialWinnings,
            winBonus: currentData.winBonus,
            payout: currentData.payout,
            amount: amount,
            placeBetAmount: currentData.placeBetAmount,
            isEnabled: currentData.isEnabled
        )
        dataSubject.send(newData)
        
        // Update child view models
        amountTextFieldViewModel.updateText(amount)
        updatePlaceBetButtonState()
    }
    
    public func updatePlaceBetAmount(_ amount: String) {
        let newData = BetInfoSubmissionData(
            potentialWinnings: currentData.potentialWinnings,
            winBonus: currentData.winBonus,
            payout: currentData.payout,
            amount: currentData.amount,
            placeBetAmount: amount,
            isEnabled: currentData.isEnabled
        )
        dataSubject.send(newData)
        
        // Update child view models
        placeBetButtonViewModel.updateTitle(amount)
    }
    
    public func setEnabled(_ isEnabled: Bool) {
        let newData = BetInfoSubmissionData(
            potentialWinnings: currentData.potentialWinnings,
            winBonus: currentData.winBonus,
            payout: currentData.payout,
            amount: currentData.amount,
            placeBetAmount: currentData.placeBetAmount,
            isEnabled: isEnabled
        )
        dataSubject.send(newData)
        
        // Update child view models
        potentialWinningsRowViewModel.setEnabled(isEnabled)
        winBonusRowViewModel.setEnabled(isEnabled)
        payoutRowViewModel.setEnabled(isEnabled)
        amount100ButtonViewModel.setEnabled(isEnabled)
        amount250ButtonViewModel.setEnabled(isEnabled)
        amount500ButtonViewModel.setEnabled(isEnabled)
        amountTextFieldViewModel.setEnabled(isEnabled)
        placeBetButtonViewModel.setEnabled(isEnabled)
    }
    
    public func onQuickAddTapped(_ amount: Int) {
        let amountString = String(amount)
        updateAmount(amountString)
        updatePlaceBetAmount("Place Bet XAF \(amountString)")
        
        // Update child view models
        amountTextFieldViewModel.updateText(amountString)
        placeBetButtonViewModel.updateTitle("Place Bet XAF \(amountString)")
        placeBetButtonViewModel.setEnabled(true)
    }
    
    public func onAmountChanged(_ amount: String) {
        updateAmount(amount)
        updatePlaceBetButtonState()
        placeBetButtonViewModel.updateTitle("Place Bet XAF \(amount)")
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
    
    private func updateChildViewModels() {
        potentialWinningsRowViewModel.updateValue(currentData.potentialWinnings)
        winBonusRowViewModel.updateValue(currentData.winBonus)
        payoutRowViewModel.updateValue(currentData.payout)
        amountTextFieldViewModel.updateText(currentData.amount)
        placeBetButtonViewModel.updateTitle(currentData.placeBetAmount)
        placeBetButtonViewModel.setEnabled(currentData.isEnabled)
    }
    
    private func updatePlaceBetButtonState() {
        let isEnabled = !currentData.amount.isEmpty
        placeBetButtonViewModel.setEnabled(isEnabled)
    }
}

// MARK: - Factory Methods
public extension MockBetInfoSubmissionViewModel {
    
    /// Creates a mock view model for default state
    static func defaultMock() -> MockBetInfoSubmissionViewModel {
        MockBetInfoSubmissionViewModel()
    }
    
    /// Creates a mock view model with specific amounts
    static func withAmountsMock(
        potentialWinnings: String = "XAF 50,000",
        winBonus: String = "XAF 5,000",
        payout: String = "XAF 55,000",
        amount: String = "10,000"
    ) -> MockBetInfoSubmissionViewModel {
        MockBetInfoSubmissionViewModel(
            potentialWinnings: potentialWinnings,
            winBonus: winBonus,
            payout: payout,
            amount: amount,
            placeBetAmount: "Place Bet XAF \(amount)"
        )
    }
    
    /// Creates a mock view model for disabled state
    static func disabledMock() -> MockBetInfoSubmissionViewModel {
        MockBetInfoSubmissionViewModel(isEnabled: false)
    }
} 
