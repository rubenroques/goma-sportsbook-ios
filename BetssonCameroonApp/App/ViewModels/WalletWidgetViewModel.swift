//
//  WalletWidgetViewModel.swift
//  BetssonCameroonApp
//
//  Created on 02/09/2025.
//

import Foundation
import Combine
import GomaUI

final class WalletWidgetViewModel: WalletWidgetViewModelProtocol {
    
    // MARK: - Properties
    
    private let displayStateSubject: CurrentValueSubject<WalletWidgetDisplayState, Never>
    var displayStatePublisher: AnyPublisher<WalletWidgetDisplayState, Never> {
        displayStateSubject.eraseToAnyPublisher()
    }
    
    // Dependencies
    private let userSessionStore: UserSessionStore
    private var cancellables = Set<AnyCancellable>()
    
    // Action callback
    var onDepositRequested: (() -> Void)?
    
    // Internal state
    private var walletData: WalletWidgetData {
        didSet {
            publishNewState()
        }
    }
    
    // MARK: - Initialization
    
    init(userSessionStore: UserSessionStore) {
        self.userSessionStore = userSessionStore
        
        // Initialize with default/loading state
        self.walletData = WalletWidgetData(
            id: .wallet,
            balance: "-.--",
            depositButtonTitle: localized("deposit").uppercased()
        )
        
        // Create initial display state
        let initialState = WalletWidgetDisplayState(walletData: walletData)
        self.displayStateSubject = CurrentValueSubject(initialState)
        
        // Setup wallet subscription
        setupWalletBinding()
    }
    
    // MARK: - WalletWidgetViewModelProtocol

    func deposit() {
        print("💳 WalletWidgetViewModel: Deposit button tapped")
        onDepositRequested?()
    }

    func updateBalance(_ balance: String) {
        walletData = WalletWidgetData(
            id: walletData.id,
            balance: balance,
            depositButtonTitle: walletData.depositButtonTitle
        )
        print("💰 WalletWidgetViewModel: Balance manually updated to: \(balance)")
    }

    // MARK: - Private Methods
    
    private func setupWalletBinding() {
        // Subscribe to wallet updates from UserSessionStore
        userSessionStore.userWalletPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] wallet in
                self?.updateWalletDisplay(wallet: wallet)
            }
            .store(in: &cancellables)
        
        print("💰 WalletWidgetViewModel: Wallet binding established")
    }
    
    private func updateWalletDisplay(wallet: UserWallet?) {
        let balanceString: String

        if let wallet = wallet {
            // Format the balance with currency
            balanceString = CurrencyHelper.formatAmount(wallet.total)
        } else {
            // No wallet data - show placeholder
            balanceString = "-.--"
        }

        // Update wallet data
        walletData = WalletWidgetData(
            id: walletData.id,
            balance: balanceString,
            depositButtonTitle: walletData.depositButtonTitle
        )

        print("💰 WalletWidgetViewModel: Balance updated to: \(balanceString)")
    }
    
    private func publishNewState() {
        let newState = WalletWidgetDisplayState(walletData: walletData)
        displayStateSubject.send(newState)
    }
}
