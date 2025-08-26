
import Foundation
import Combine

/// Mock implementation of `WalletStatusViewModelProtocol` for testing
final public class MockWalletStatusViewModel: WalletStatusViewModelProtocol {
    
    // MARK: - Private Properties
    private let totalBalanceSubject: CurrentValueSubject<String, Never>
    private let currentBalanceSubject: CurrentValueSubject<String, Never>
    private let bonusBalanceSubject: CurrentValueSubject<String, Never>
    private let cashbackBalanceSubject: CurrentValueSubject<String, Never>
    private let withdrawableAmountSubject: CurrentValueSubject<String, Never>
    
    // Button view models
    private let _depositButtonViewModel: MockButtonViewModel
    private let _withdrawButtonViewModel: MockButtonViewModel
    
    // MARK: - Public Properties
    public var totalBalancePublisher: AnyPublisher<String, Never> {
        totalBalanceSubject.eraseToAnyPublisher()
    }
    
    public var currentBalancePublisher: AnyPublisher<String, Never> {
        currentBalanceSubject.eraseToAnyPublisher()
    }
    
    public var bonusBalancePublisher: AnyPublisher<String, Never> {
        bonusBalanceSubject.eraseToAnyPublisher()
    }
    
    public var cashbackBalancePublisher: AnyPublisher<String, Never> {
        cashbackBalanceSubject.eraseToAnyPublisher()
    }
    
    public var withdrawableAmountPublisher: AnyPublisher<String, Never> {
        withdrawableAmountSubject.eraseToAnyPublisher()
    }
    
    public var depositButtonViewModel: ButtonViewModelProtocol {
        _depositButtonViewModel
    }
    
    public var withdrawButtonViewModel: ButtonViewModelProtocol {
        _withdrawButtonViewModel
    }
    
    // MARK: - Initialization
    public init(
        totalBalance: String,
        currentBalance: String,
        bonusBalance: String,
        cashbackBalance: String,
        withdrawableAmount: String
    ) {
        self.totalBalanceSubject = CurrentValueSubject(totalBalance)
        self.currentBalanceSubject = CurrentValueSubject(currentBalance)
        self.bonusBalanceSubject = CurrentValueSubject(bonusBalance)
        self.cashbackBalanceSubject = CurrentValueSubject(cashbackBalance)
        self.withdrawableAmountSubject = CurrentValueSubject(withdrawableAmount)
        
        // Create button view models
        let depositButtonData = ButtonData(
            id: "deposit",
            title: "Deposit",
            style: .solidBackground,
            isEnabled: true
        )
        self._depositButtonViewModel = MockButtonViewModel(buttonData: depositButtonData)
        
        let withdrawButtonData = ButtonData(
            id: "withdraw",
            title: "Withdraw",
            style: .bordered,
            isEnabled: true
        )
        self._withdrawButtonViewModel = MockButtonViewModel(buttonData: withdrawButtonData)
    }
    
    public func setTotalBalance(amount: String) {
        self.totalBalanceSubject.send(amount)
    }
    
    public func setCurrentBalance(amount: String) {
        self.currentBalanceSubject.send(amount)
    }
    
    public func setBonusBalance(amount: String) {
        self.bonusBalanceSubject.send(amount)
    }
    
    public func setCashbackBalance(amount: String) {
        self.cashbackBalanceSubject.send(amount)
    }
    
    public func setWithdrawableBalance(amount: String) {
        self.withdrawableAmountSubject.send(amount)
    }
    
    // MARK: - Public Methods
    
    /// Simulates a balance update from the server
    public func simulateBalanceUpdate(
        total: String? = nil,
        current: String? = nil,
        bonus: String? = nil,
        cashback: String? = nil,
        withdrawable: String? = nil
    ) {
        if let total = total {
            totalBalanceSubject.send(total)
        }
        if let current = current {
            currentBalanceSubject.send(current)
        }
        if let bonus = bonus {
            bonusBalanceSubject.send(bonus)
        }
        if let cashback = cashback {
            cashbackBalanceSubject.send(cashback)
        }
        if let withdrawable = withdrawable {
            withdrawableAmountSubject.send(withdrawable)
        }
    }
    
    /// Simulates deposit completion
    public func simulateDepositComplete(amount: Double) {
        let currentTotal = parseAmount(totalBalanceSubject.value)
        let currentBalance = parseAmount(currentBalanceSubject.value)
        let currentWithdrawable = parseAmount(withdrawableAmountSubject.value)
        
        totalBalanceSubject.send(formatAmount(currentTotal + amount))
        currentBalanceSubject.send(formatAmount(currentBalance + amount))
        withdrawableAmountSubject.send(formatAmount(currentWithdrawable + amount))
    }
    
    /// Simulates withdrawal completion
    public func simulateWithdrawalComplete(amount: Double) {
        let currentTotal = parseAmount(totalBalanceSubject.value)
        let currentBalance = parseAmount(currentBalanceSubject.value)
        let currentWithdrawable = parseAmount(withdrawableAmountSubject.value)
        
        totalBalanceSubject.send(formatAmount(max(0, currentTotal - amount)))
        currentBalanceSubject.send(formatAmount(max(0, currentBalance - amount)))
        withdrawableAmountSubject.send(formatAmount(max(0, currentWithdrawable - amount)))
    }
    
    // MARK: - Private Methods
    private func parseAmount(_ string: String) -> Double {
        let cleanedString = string.replacingOccurrences(of: ",", with: "")
        return Double(cleanedString) ?? 0
    }
    
    private func formatAmount(_ amount: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.minimumFractionDigits = 2
        formatter.maximumFractionDigits = 2
        formatter.groupingSeparator = ","
        return formatter.string(from: NSNumber(value: amount)) ?? "0.00"
    }
}

// MARK: - Mock Factory
extension MockWalletStatusViewModel {
    
    /// Default mock matching the Figma design
    public static var defaultMock: MockWalletStatusViewModel {
        return MockWalletStatusViewModel(
            totalBalance: "2,000.01",
            currentBalance: "1,000.00",
            bonusBalance: "965.01",
            cashbackBalance: "35.00",
            withdrawableAmount: "1,000.00"
        )
    }
    
    /// Empty balance mock
    public static var emptyBalanceMock: MockWalletStatusViewModel {
        return MockWalletStatusViewModel(
            totalBalance: "0.00",
            currentBalance: "0.00",
            bonusBalance: "0.00",
            cashbackBalance: "0.00",
            withdrawableAmount: "0.00"
        )
    }
    
    /// High balance mock
    public static var highBalanceMock: MockWalletStatusViewModel {
        return MockWalletStatusViewModel(
            totalBalance: "15,750.50",
            currentBalance: "10,000.00",
            bonusBalance: "5,000.00",
            cashbackBalance: "750.50",
            withdrawableAmount: "10,000.00"
        )
    }
    
    /// Bonus-only mock
    public static var bonusOnlyMock: MockWalletStatusViewModel {
        return MockWalletStatusViewModel(
            totalBalance: "500.00",
            currentBalance: "0.00",
            bonusBalance: "500.00",
            cashbackBalance: "0.00",
            withdrawableAmount: "0.00"
        )
    }
}
