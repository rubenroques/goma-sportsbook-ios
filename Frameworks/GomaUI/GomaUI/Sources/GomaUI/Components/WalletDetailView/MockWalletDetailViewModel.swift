
import Foundation
import Combine
import UIKit


/// Mock implementation of `WalletDetailViewModelProtocol` for testing and previews.
final public class MockWalletDetailViewModel: WalletDetailViewModelProtocol {
    
    // MARK: - Properties
    private let displayStateSubject: CurrentValueSubject<WalletDetailDisplayState, Never>
    private let totalBalanceSubject: CurrentValueSubject<String, Never>
    private let currentBalanceSubject: CurrentValueSubject<String, Never>
    private let bonusBalanceSubject: CurrentValueSubject<String, Never>
    private let cashbackBalanceSubject: CurrentValueSubject<String, Never>
    private let withdrawableAmountSubject: CurrentValueSubject<String, Never>
    
    // MARK: - Publishers
    public var displayStatePublisher: AnyPublisher<WalletDetailDisplayState, Never> {
        return displayStateSubject.eraseToAnyPublisher()
    }
    
    public var totalBalancePublisher: AnyPublisher<String, Never> {
        return totalBalanceSubject.eraseToAnyPublisher()
    }
    
    public var currentBalancePublisher: AnyPublisher<String, Never> {
        return currentBalanceSubject.eraseToAnyPublisher()
    }
    
    public var bonusBalancePublisher: AnyPublisher<String, Never> {
        return bonusBalanceSubject.eraseToAnyPublisher()
    }
    
    public var cashbackBalancePublisher: AnyPublisher<String, Never> {
        return cashbackBalanceSubject.eraseToAnyPublisher()
    }
    
    public var withdrawableAmountPublisher: AnyPublisher<String, Never> {
        return withdrawableAmountSubject.eraseToAnyPublisher()
    }
    
    // MARK: - Button ViewModels
    public let withdrawButtonViewModel: ButtonViewModelProtocol
    public let depositButtonViewModel: ButtonViewModelProtocol
    
    // MARK: - Pending Withdraw Section
    public var pendingWithdrawSectionViewModel: CustomExpandableSectionViewModelProtocol?
    public var pendingWithdrawViewModels: [PendingWithdrawViewModelProtocol] = [] {
        didSet {
            pendingWithdrawViewModelsSubject.send(pendingWithdrawViewModels)
        }
    }
    private let pendingWithdrawViewModelsSubject = CurrentValueSubject<[PendingWithdrawViewModelProtocol], Never>([])
    
    public var pendingWithdrawViewModelsPublisher: AnyPublisher<[PendingWithdrawViewModelProtocol], Never> {
        pendingWithdrawViewModelsSubject.eraseToAnyPublisher()
    }
    
    // MARK: - Internal State
    private var walletData: WalletDetailData
    
    // MARK: - Initialization
    public init(walletData: WalletDetailData) {
        self.walletData = walletData
        
        // Initialize subjects with wallet data
        self.totalBalanceSubject = CurrentValueSubject(walletData.totalBalance)
        self.currentBalanceSubject = CurrentValueSubject(walletData.currentBalance)
        self.bonusBalanceSubject = CurrentValueSubject(walletData.bonusBalance)
        self.cashbackBalanceSubject = CurrentValueSubject(walletData.cashbackBalance)
        self.withdrawableAmountSubject = CurrentValueSubject(walletData.withdrawableAmount)
        
        let initialState = WalletDetailDisplayState(walletData: walletData, isLoading: false)
        self.displayStateSubject = CurrentValueSubject(initialState)
        
        // Create button view models
        let withdrawButtonData = ButtonData(
            id: "withdraw_wallet",
            title: LocalizationProvider.string("withdraw"),
            style: .bordered,
            isEnabled: true
        )
        self.withdrawButtonViewModel = MockButtonViewModel(buttonData: withdrawButtonData)
        
        let depositButtonData = ButtonData(
            id: "deposit_wallet",
            title: LocalizationProvider.string("deposit_text"),
            style: .solidBackground,
            isEnabled: true
        )
        self.depositButtonViewModel = MockButtonViewModel(buttonData: depositButtonData)
    }
    
    // MARK: - Demo/Testing Support
    public var onWithdrawCallback: (() -> Void)?
    public var onDepositCallback: (() -> Void)?
    #if DEBUG
    public var onWithdrawLegacyCallback: (() -> Void)?
    public var onDepositLegacyCallback: (() -> Void)?
    #endif

    // MARK: - WalletDetailViewModelProtocol
    public func performWithdraw() {
        onWithdrawCallback?()
    }

    public func performDeposit() {
        onDepositCallback?()
    }

    #if DEBUG
    public func performWithdrawLegacy() {
        onWithdrawLegacyCallback?()
    }

    public func performDepositLegacy() {
        onDepositLegacyCallback?()
    }
    #endif
    
    public func refreshWalletData() {
        print("🔄 Refreshing wallet data...")
        let newState = WalletDetailDisplayState(walletData: walletData, isLoading: true)
        displayStateSubject.send(newState)
        
        // Simulate network delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            guard let self = self else { return }
            let refreshedState = WalletDetailDisplayState(walletData: self.walletData, isLoading: false)
            self.displayStateSubject.send(refreshedState)
        }
    }
    
    // MARK: - Test Helper Methods
    public func simulateBalanceUpdate(
        total: String? = nil,
        current: String? = nil,
        bonus: String? = nil,
        cashback: String? = nil,
        withdrawable: String? = nil
    ) {
        if let total = total {
            self.walletData = WalletDetailData(
                walletTitle: walletData.walletTitle,
                phoneNumber: walletData.phoneNumber,
                totalBalance: total,
                currentBalance: walletData.currentBalance,
                bonusBalance: walletData.bonusBalance,
                cashbackBalance: walletData.cashbackBalance,
                withdrawableAmount: walletData.withdrawableAmount
            )
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
        
        // Update display state
        let newState = WalletDetailDisplayState(walletData: walletData, isLoading: false)
        displayStateSubject.send(newState)
    }
    
    public func simulateLoadingState() {
        let loadingState = WalletDetailDisplayState(walletData: walletData, isLoading: true)
        displayStateSubject.send(loadingState)
    }
    
    public func simulateDepositComplete(amount: Double) {
        let currentTotal = Double(walletData.totalBalance.replacingOccurrences(of: ",", with: "")) ?? 0.0
        let currentBalance = Double(walletData.currentBalance.replacingOccurrences(of: ",", with: "")) ?? 0.0
        let currentWithdrawable = Double(walletData.withdrawableAmount.replacingOccurrences(of: ",", with: "")) ?? 0.0
        
        let newTotal = currentTotal + amount
        let newCurrent = currentBalance + amount
        let newWithdrawable = currentWithdrawable + amount
        
        simulateBalanceUpdate(
            total: String(format: "%.2f", newTotal),
            current: String(format: "%.2f", newCurrent),
            withdrawable: String(format: "%.2f", newWithdrawable)
        )
    }
    
    public func simulateWithdrawalComplete(amount: Double) {
        let currentTotal = Double(walletData.totalBalance.replacingOccurrences(of: ",", with: "")) ?? 0.0
        let currentBalance = Double(walletData.currentBalance.replacingOccurrences(of: ",", with: "")) ?? 0.0
        let currentWithdrawable = Double(walletData.withdrawableAmount.replacingOccurrences(of: ",", with: "")) ?? 0.0
        
        let newTotal = max(0, currentTotal - amount)
        let newCurrent = max(0, currentBalance - amount)
        let newWithdrawable = max(0, currentWithdrawable - amount)
        
        simulateBalanceUpdate(
            total: String(format: "%.2f", newTotal),
            current: String(format: "%.2f", newCurrent),
            withdrawable: String(format: "%.2f", newWithdrawable)
        )
    }
}

// MARK: - Mock Factory
extension MockWalletDetailViewModel {
    
    /// Default mock matching Figma design
    public static var defaultMock: MockWalletDetailViewModel {
        let walletData = WalletDetailData(
            walletTitle: "Wallet",
            phoneNumber: "+234 737 456789",
            totalBalance: "2,000.00",
            currentBalance: "1,000.24",
            bonusBalance: "1,000.24",
            cashbackBalance: "0.00",
            withdrawableAmount: "1,000.24"
        )
        
        return MockWalletDetailViewModel(walletData: walletData)
    }
    
    /// Empty wallet mock
    public static var emptyBalanceMock: MockWalletDetailViewModel {
        let walletData = WalletDetailData(
            walletTitle: "Wallet",
            phoneNumber: "+234 737 456789",
            totalBalance: "0.00",
            currentBalance: "0.00",
            bonusBalance: "0.00",
            cashbackBalance: "0.00",
            withdrawableAmount: "0.00"
        )
        
        return MockWalletDetailViewModel(walletData: walletData)
    }
    
    /// High balance mock
    public static var highBalanceMock: MockWalletDetailViewModel {
        let walletData = WalletDetailData(
            walletTitle: "Wallet",
            phoneNumber: "+234 737 456789",
            totalBalance: "150,000.50",
            currentBalance: "75,250.25",
            bonusBalance: "50,000.00",
            cashbackBalance: "5,750.25",
            withdrawableAmount: "80,000.50"
        )
        
        return MockWalletDetailViewModel(walletData: walletData)
    }
    
    /// Bonus-only mock (no withdrawable)
    public static var bonusOnlyMock: MockWalletDetailViewModel {
        let walletData = WalletDetailData(
            walletTitle: "Wallet",
            phoneNumber: "+234 737 456789",
            totalBalance: "500.00",
            currentBalance: "0.00",
            bonusBalance: "500.00",
            cashbackBalance: "0.00",
            withdrawableAmount: "0.00"
        )
        
        return MockWalletDetailViewModel(walletData: walletData)
    }
    
    /// Cashback focus mock
    public static var cashbackFocusMock: MockWalletDetailViewModel {
        let walletData = WalletDetailData(
            walletTitle: "Wallet",
            phoneNumber: "+234 737 456789",
            totalBalance: "1,250.75",
            currentBalance: "500.00",
            bonusBalance: "250.00",
            cashbackBalance: "500.75",
            withdrawableAmount: "1,000.75"
        )
        
        return MockWalletDetailViewModel(walletData: walletData)
    }
}
