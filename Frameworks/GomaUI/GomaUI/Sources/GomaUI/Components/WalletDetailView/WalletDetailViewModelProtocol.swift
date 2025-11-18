import GomaUI

import Foundation
import Combine

// MARK: - Data Models

/// Data model for wallet detail information
public struct WalletDetailData: Equatable, Hashable {
    public let walletTitle: String
    public let phoneNumber: String
    public let totalBalance: String
    public let currentBalance: String
    public let bonusBalance: String
    public let cashbackBalance: String
    public let withdrawableAmount: String
    
    public init(
        walletTitle: String,
        phoneNumber: String,
        totalBalance: String,
        currentBalance: String,
        bonusBalance: String,
        cashbackBalance: String,
        withdrawableAmount: String
    ) {
        self.walletTitle = walletTitle
        self.phoneNumber = phoneNumber
        self.totalBalance = totalBalance
        self.currentBalance = currentBalance
        self.bonusBalance = bonusBalance
        self.cashbackBalance = cashbackBalance
        self.withdrawableAmount = withdrawableAmount
    }
}

/// Display state for the wallet detail component
public struct WalletDetailDisplayState: Equatable {
    public let walletData: WalletDetailData
    public let isLoading: Bool
    
    public init(
        walletData: WalletDetailData,
        isLoading: Bool = false
    ) {
        self.walletData = walletData
        self.isLoading = isLoading
    }
}

// MARK: - View Model Protocol

/// Protocol defining the data contract for WalletDetailView
public protocol WalletDetailViewModelProtocol {
    
    // MARK: - Display State Publisher
    /// Publisher for overall component state updates
    var displayStatePublisher: AnyPublisher<WalletDetailDisplayState, Never> { get }
    
    // MARK: - Individual Balance Publishers
    /// Publisher for total balance updates
    var totalBalancePublisher: AnyPublisher<String, Never> { get }
    
    /// Publisher for current balance updates
    var currentBalancePublisher: AnyPublisher<String, Never> { get }
    
    /// Publisher for bonus balance updates
    var bonusBalancePublisher: AnyPublisher<String, Never> { get }
    
    /// Publisher for cashback balance updates
    var cashbackBalancePublisher: AnyPublisher<String, Never> { get }
    
    /// Publisher for withdrawable amount updates
    var withdrawableAmountPublisher: AnyPublisher<String, Never> { get }
    
    // MARK: - Button View Models
    /// View model for the withdraw button
    var withdrawButtonViewModel: ButtonViewModelProtocol { get }
    
    /// View model for the deposit button
    var depositButtonViewModel: ButtonViewModelProtocol { get }
    
    // MARK: - Pending Withdraw Section
    /// View model for the pending withdraw expandable section (optional)
    var pendingWithdrawSectionViewModel: CustomExpandableSectionViewModelProtocol? { get set }
    
    /// View models for individual pending withdraw items
    var pendingWithdrawViewModels: [PendingWithdrawViewModelProtocol] { get set }
    
    /// Publisher for pending withdraw view models updates
    var pendingWithdrawViewModelsPublisher: AnyPublisher<[PendingWithdrawViewModelProtocol], Never> { get }
    
    // MARK: - Actions
    /// Trigger withdraw action
    func performWithdraw()
    
    /// Trigger deposit action
    func performDeposit()
    
    /// Refresh wallet data
    func refreshWalletData()
}
