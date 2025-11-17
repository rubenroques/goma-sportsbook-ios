//
//  WalletDetailViewModel.swift
//  BetssonCameroonApp
//
//  Created on 29/08/2025.
//

import Foundation
import Combine
import UIKit
import GomaUI

final class WalletDetailViewModel: WalletDetailViewModelProtocol {
    
    // MARK: - Private Properties
    
    private let userSessionStore: UserSessionStore
    private var cancellables = Set<AnyCancellable>()
    
    // Data state
    private let displayStateSubject = CurrentValueSubject<WalletDetailDisplayState, Never>(
        WalletDetailDisplayState(
            walletData: WalletDetailData(
                walletTitle: localized("mobile_wallet"),
                phoneNumber: "+237 XXX XXX XXX",
                totalBalance: "0.00 XAF",
                currentBalance: "0.00 XAF",
                bonusBalance: "0.00 XAF",
                cashbackBalance: "0.00 XAF",
                withdrawableAmount: "0.00 XAF"
            ),
            isLoading: true
        )
    )
    
    // Individual balance subjects
    private let totalBalanceSubject = CurrentValueSubject<String, Never>("0.00 XAF")
    private let currentBalanceSubject = CurrentValueSubject<String, Never>("0.00 XAF")
    private let bonusBalanceSubject = CurrentValueSubject<String, Never>("0.00 XAF")
    private let cashbackBalanceSubject = CurrentValueSubject<String, Never>("0.00 XAF")
    private let withdrawableAmountSubject = CurrentValueSubject<String, Never>("0.00 XAF")
    
    // Button ViewModels
    public let withdrawButtonViewModel: ButtonViewModelProtocol
    public let depositButtonViewModel: ButtonViewModelProtocol
    
    // Pending Withdraw Section
    public var pendingWithdrawSectionViewModel: CustomExpandableSectionViewModelProtocol?
    public var pendingWithdrawViewModels: [PendingWithdrawViewModelProtocol] = [] {
        didSet {
            pendingWithdrawViewModelsSubject.send(pendingWithdrawViewModels)
        }
    }
    private let pendingWithdrawViewModelsSubject = CurrentValueSubject<[PendingWithdrawViewModelProtocol], Never>([])
    
    // Action callbacks
    public var onWithdrawRequested: (() -> Void)?
    public var onDepositRequested: (() -> Void)?
    
    // MARK: - Initialization
    
    init(userSessionStore: UserSessionStore) {
        self.userSessionStore = userSessionStore
        
        // Create button ViewModels with StyleProvider colors and Figma font size (12px)
        self.withdrawButtonViewModel = MockButtonViewModel(
            buttonData: ButtonData(
                id: "withdraw",
                title: localized("withdraw"),
                style: .bordered,
                borderColor: StyleProvider.Color.allWhite,
                textColor: StyleProvider.Color.allWhite,
                fontSize: 12.0,
                fontType: .bold,
                isEnabled: true
            )
        )

        self.depositButtonViewModel = MockButtonViewModel(
            buttonData: ButtonData(
                id: "deposit",
                title: localized("deposit"),
                style: .solidBackground,
                backgroundColor: StyleProvider.Color.allWhite,
                textColor: StyleProvider.Color.highlightPrimary,
                fontSize: 12.0,
                fontType: .bold,
                isEnabled: true
            )
        )
        
        setupWalletDataBinding()
        setupButtonActions()
        
        // Trigger initial wallet refresh if user is logged in
        if userSessionStore.isUserLogged() {
            refreshWalletData()
        }
    }
    
    // MARK: - Protocol Publishers
    
    public var displayStatePublisher: AnyPublisher<WalletDetailDisplayState, Never> {
        displayStateSubject.eraseToAnyPublisher()
    }
    
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
    
    public var pendingWithdrawViewModelsPublisher: AnyPublisher<[PendingWithdrawViewModelProtocol], Never> {
        pendingWithdrawViewModelsSubject.eraseToAnyPublisher()
    }
    
    // MARK: - Protocol Actions
    
    public func performWithdraw() {
        onWithdrawRequested?()
    }
    
    public func performDeposit() {
        onDepositRequested?()
    }
    
    public func refreshWalletData() {
        guard userSessionStore.isUserLogged() else {
            updateWalletData(wallet: nil, userProfile: nil)
            return
        }
        
        // Update loading state
        let currentData = displayStateSubject.value.walletData
        displayStateSubject.send(WalletDetailDisplayState(
            walletData: currentData,
            isLoading: true
        ))
        
        // Trigger wallet refresh from service
        userSessionStore.refreshUserWallet()
    }
    
    // MARK: - Private Methods
    
    private func setupWalletDataBinding() {
        // Subscribe to wallet updates from UserSessionStore
        userSessionStore.userWalletPublisher
            .combineLatest(userSessionStore.userProfilePublisher)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] wallet, userProfile in
                self?.updateWalletData(wallet: wallet, userProfile: userProfile)
            }
            .store(in: &cancellables)
    }
    
    private func setupButtonActions() {
        // Setup withdraw button action
        if let mockWithdrawVM = withdrawButtonViewModel as? MockButtonViewModel {
            mockWithdrawVM.onButtonTapped = { [weak self] in
                self?.performWithdraw()
            }
        }
        
        // Setup deposit button action  
        if let mockDepositVM = depositButtonViewModel as? MockButtonViewModel {
            mockDepositVM.onButtonTapped = { [weak self] in
                self?.performDeposit()
            }
        }
    }
    
    private func updateWalletData(wallet: UserWallet?, userProfile: UserProfile?) {
        let totalBalance = formatCurrency(wallet?.total ?? 0.0)
        let currentBalance = formatCurrency(wallet?.total ?? 0.0) // Same as total
        let bonusBalance = formatCurrency(wallet?.bonus ?? 0.0)
        let cashbackBalance = formatCurrency(0.0) // Not available in current system
        let withdrawableAmount = formatCurrency(wallet?.totalWithdrawable ?? 0.0)
        
        // Update individual publishers
        totalBalanceSubject.send(totalBalance)
        currentBalanceSubject.send(currentBalance)
        bonusBalanceSubject.send(bonusBalance)
        cashbackBalanceSubject.send(cashbackBalance)
        withdrawableAmountSubject.send(withdrawableAmount)
        
        // Update display state
        let walletData = WalletDetailData(
            walletTitle: localized("wallet"),
            phoneNumber: formatPhoneNumber(userProfile),
            totalBalance: totalBalance,
            currentBalance: currentBalance,
            bonusBalance: bonusBalance,
            cashbackBalance: cashbackBalance,
            withdrawableAmount: withdrawableAmount
        )
        
        displayStateSubject.send(WalletDetailDisplayState(
            walletData: walletData,
            isLoading: false
        ))
    }
    
    private func formatCurrency(_ amount: Double) -> String {
        return CurrencyHelper.formatAmount(amount)
    }
    
    private func formatPhoneNumber(_ userProfile: UserProfile?) -> String {
        guard let userProfile = userProfile else {
            return "+237 XXX XXX XXX"
        }
        
        // Try to build from country code + local number
        if let countryCode = userProfile.mobileCountryCode,
           let localNumber = userProfile.mobilePhone,
           !countryCode.isEmpty && !localNumber.isEmpty {
            // Format as "+237 123 456 789"
            let formattedLocal = formatLocalNumber(localNumber)
            return "\(countryCode) \(formattedLocal)"
        }
        
        // Fallback to full mobile phone if available
        if let mobilePhone = userProfile.mobileLocalNumber, !mobilePhone.isEmpty {
            return mobilePhone
        }
        
        // Final fallback
        return "+237 XXX XXX XXX"
    }
    
    private func formatLocalNumber(_ localNumber: String) -> String {
        // Format as "123 456 789" for readability
        let digits = localNumber.filter { $0.isNumber }
        if digits.count >= 9 {
            let first3 = String(digits.prefix(3))
            let middle3 = String(digits.dropFirst(3).prefix(3))
            let last3 = String(digits.dropFirst(6).prefix(3))
            return "\(first3) \(middle3) \(last3)"
        }
        return localNumber // Return as is if not enough digits
    }
}
