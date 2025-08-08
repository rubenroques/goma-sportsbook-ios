import Foundation
import Combine
import UIKit

/// Mock implementation of BetInfoSubmissionViewModelProtocol for testing and previews
public final class MockBetInfoSubmissionViewModel: BetInfoSubmissionViewModelProtocol {
    
    // MARK: - Properties
    private let dataSubject: CurrentValueSubject<BetInfoSubmissionData, Never>
    
    public var dataPublisher: AnyPublisher<BetInfoSubmissionData, Never> {
        dataSubject.eraseToAnyPublisher()
    }
    
    public var currentData: BetInfoSubmissionData {
        dataSubject.value
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
    }
    
    public func onQuickAddTapped(_ amount: Int) {
        // Mock implementation - in real app this would add the amount to current amount
        let currentAmount = Double(currentData.amount) ?? 0.0
        let newAmount = currentAmount + Double(amount)
        updateAmount(String(format: "%.0f", newAmount))
    }
    
    public func onPlaceBetTapped() {
        // Mock implementation - in real app this would handle placing the bet
        print("Place bet tapped with amount: \(currentData.placeBetAmount)")
    }
    
    public func onAmountChanged(_ amount: String) {
        updateAmount(amount)
        updatePlaceBetAmount("XAF \(amount.isEmpty ? "0" : amount)")
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