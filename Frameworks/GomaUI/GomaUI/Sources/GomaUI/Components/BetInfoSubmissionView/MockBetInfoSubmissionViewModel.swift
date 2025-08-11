import Foundation
import Combine
import UIKit

/// Mock implementation of BetInfoSubmissionViewModelProtocol for testing and previews
public final class MockBetInfoSubmissionViewModel: BetInfoSubmissionViewModelProtocol {
    
    // MARK: - Properties
    private let dataSubject: CurrentValueSubject<BetInfoSubmissionData, Never>
    
    // Child view models
    private let amountTextFieldViewModelInstance: BorderedTextFieldViewModelProtocol
    private let placeBetButtonViewModelInstance: ButtonViewModelProtocol
    
    public var dataPublisher: AnyPublisher<BetInfoSubmissionData, Never> {
        dataSubject.eraseToAnyPublisher()
    }
    
    public var currentData: BetInfoSubmissionData {
        dataSubject.value
    }
    
    public var amountTextFieldViewModel: BorderedTextFieldViewModelProtocol {
        amountTextFieldViewModelInstance
    }
    
    public var placeBetButtonViewModel: ButtonViewModelProtocol {
        placeBetButtonViewModelInstance
    }
    
    // MARK: - Initialization
    public init(potentialWinnings: String = "XAF 0.00", 
                winBonus: String = "-XAF 0.00", 
                payout: String = "XAF 0.00", 
                amount: String = "", 
                placeBetAmount: String = "XAF 0", 
                isEnabled: Bool = false) {
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
        self.amountTextFieldViewModelInstance = MockBorderedTextFieldViewModel(
            textFieldData: BorderedTextFieldData(
                id: "amount",
                text: amount,
                placeholder: "Amount",
                keyboardType: .numberPad
            )
        )
        
        self.placeBetButtonViewModelInstance = MockButtonViewModel(buttonData: ButtonData(
            id: "place_bet",
            title: "Place Bet \(placeBetAmount)",
            style: .solidBackground,
            isEnabled: isEnabled
        ))
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
        
        // Update amount text field
        if let mockAmountViewModel = amountTextFieldViewModelInstance as? MockBorderedTextFieldViewModel {
            mockAmountViewModel.updateText(amount)
        }
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
        
        // Update place bet button title
        if let mockButtonViewModel = placeBetButtonViewModelInstance as? MockButtonViewModel {
            mockButtonViewModel.updateTitle("Place Bet \(amount)")
        }
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
        
        // Update place bet button enabled state
        placeBetButtonViewModelInstance.setEnabled(isEnabled)
    }
    
    public func onQuickAddTapped(_ amount: Int) {
        // Mock implementation - in real app this would add the amount to current amount
        let newAmount = Double(amount)
        let amountString = String(format: "%.0f", newAmount)
        updateAmount(amountString)
        
        // Update the place bet button text and state since amount changed
        updatePlaceBetAmount("XAF \(amountString)")
        let isEnabled = !amountString.isEmpty
        setEnabled(isEnabled)
    }
    
    public func onPlaceBetTapped() {
        // Mock implementation - in real app this would handle placing the bet
        print("Place bet tapped with amount: \(currentData.placeBetAmount)")
    }
    
    public func onAmountChanged(_ amount: String) {
        updateAmount(amount)
        updatePlaceBetAmount("XAF \(amount.isEmpty ? "0" : amount)")
        
        // Enable/disable place bet button based on amount
        let isEnabled = !amount.isEmpty
        setEnabled(isEnabled)
    }
}

// MARK: - Factory Methods
public extension MockBetInfoSubmissionViewModel {
    
    /// Creates a mock view model with default values
    static func defaultMock() -> MockBetInfoSubmissionViewModel {
        return MockBetInfoSubmissionViewModel()
    }
    
    /// Creates a mock view model with sample data
    static func sampleMock() -> MockBetInfoSubmissionViewModel {
        return MockBetInfoSubmissionViewModel(
            potentialWinnings: "XAF 1,250.00",
            winBonus: "XAF 37.50",
            payout: "XAF 1,287.50",
            amount: "500",
            placeBetAmount: "XAF 500",
            isEnabled: true
        )
    }
    
    /// Creates a mock view model for disabled state
    static func disabledMock() -> MockBetInfoSubmissionViewModel {
        return MockBetInfoSubmissionViewModel(
            potentialWinnings: "XAF 0.00",
            winBonus: "-XAF 0.00",
            payout: "XAF 0.00",
            amount: "",
            placeBetAmount: "XAF 0",
            isEnabled: false
        )
    }
} 
