//
//  MyBetDetailViewModel.swift
//  BetssonCameroonApp
//
//  Created by Assistant on 01/09/2025.
//

import Foundation
import Combine
import ServicesProvider
import GomaUI

enum MyBetDetailDisplayState {
    case loading
    case loaded
    case error(String)
}

final class MyBetDetailViewModel {
    
    // MARK: - Core Properties
    
    let bet: MyBet
    @Published var displayState: MyBetDetailDisplayState = .loading
    
    // MARK: - Child ViewModels
    
    let multiWidgetToolbarViewModel: MultiWidgetToolbarViewModelProtocol
    let walletStatusViewModel: WalletStatusViewModelProtocol
    
    // MARK: - Navigation Closure (following MatchDetailsTextualViewModel pattern)
    
    var onNavigateBack: (() -> Void) = { }
    
    // MARK: - Dependencies
    
    private let servicesProvider: ServicesProvider.Client
    private let userSessionStore: UserSessionStore
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Initialization
    
    init(bet: MyBet, servicesProvider: ServicesProvider.Client, userSessionStore: UserSessionStore) {
        self.bet = bet
        self.servicesProvider = servicesProvider
        self.userSessionStore = userSessionStore
        self.multiWidgetToolbarViewModel = MockMultiWidgetToolbarViewModel.defaultMock
        self.walletStatusViewModel = MockWalletStatusViewModel.emptyBalanceMock
        
        setupAuthenticationBinding()
        setupWalletBinding()
        
        print("🎯 MyBetDetailViewModel: Initialized with bet ID: \(bet.identifier)")
    }
    
    // MARK: - Public Methods
    
    func loadBetDetails() {
        print("🔍 MyBetDetailViewModel: Loading bet details for bet: \(bet.identifier)")
        
        displayState = .loading
        
        // Simulate loading with a delay for now
        // In the future, this could fetch fresh bet data from the API
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
            guard let self = self else { return }
            
            // For now, just show loaded state since we already have the bet data
            self.displayState = .loaded
            print("✅ MyBetDetailViewModel: Bet details loaded successfully")
        }
    }
    
    func refreshBetDetails() {
        print("🔄 MyBetDetailViewModel: Refreshing bet details")
        loadBetDetails()
    }
    
    func handleBackTap() {
        print("🔙 MyBetDetailViewModel: Back button tapped")
        onNavigateBack()
    }
}

// MARK: - Computed Properties for UI Display

extension MyBetDetailViewModel {
    
    /// Returns a formatted bet identifier for display
    var displayBetId: String {
        return "Bet #\(bet.identifier)"
    }
    
    /// Returns a formatted bet type description
    var displayBetType: String {
        return bet.typeDescription
    }
    
    /// Returns a formatted stake amount
    var displayStake: String {
        return "\(bet.currency) \(String(format: "%.2f", bet.stake))"
    }
    
    /// Returns a formatted total odds
    var displayTotalOdds: String {
        return String(format: "%.2f", bet.totalOdd)
    }
    
    /// Returns a formatted potential return
    var displayPotentialReturn: String {
        if let potentialReturn = bet.potentialReturn {
            return "\(bet.currency) \(String(format: "%.2f", potentialReturn))"
        }
        return "N/A"
    }
    
    /// Returns a formatted actual return (for settled bets)
    var displayActualReturn: String {
        if let totalReturn = bet.totalReturn {
            return "\(bet.currency) \(String(format: "%.2f", totalReturn))"
        }
        return "N/A"
    }
    
    /// Returns a formatted bet status
    var displayBetStatus: String {
        return bet.state.displayName
    }
    
    /// Returns a formatted bet result
    var displayBetResult: String {
        return bet.result.displayName
    }
    
    /// Returns a formatted date
    var displayBetDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: bet.date)
    }
    
    /// Returns the number of selections
    var selectionCount: Int {
        return bet.selections.count
    }
    
    /// Returns whether the bet can be cashed out
    var canCashOut: Bool {
        return bet.canCashOut
    }
    
    /// Returns a profit/loss amount for settled bets
    var displayProfitLoss: String? {
        guard let profitLoss = bet.profitLoss else { return nil }
        let prefix = profitLoss >= 0 ? "+" : ""
        return "\(prefix)\(bet.currency) \(String(format: "%.2f", profitLoss))"
    }
}

// MARK: - Private Methods

extension MyBetDetailViewModel {
    
    private func setupAuthenticationBinding() {
        userSessionStore.userProfilePublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] userProfile in
                let isLoggedIn = userProfile != nil
                let layoutState: LayoutState = isLoggedIn ? .loggedIn : .loggedOut
                self?.multiWidgetToolbarViewModel.setLayoutState(layoutState)
                print("🔐 MyBetDetailViewModel: Authentication state changed - logged in: \(isLoggedIn)")
            }
            .store(in: &cancellables)
    }
    
    private func setupWalletBinding() {
        userSessionStore.userWalletPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] wallet in
                // Update toolbar wallet balance
                if let walletBalance = wallet?.total {
                    self?.multiWidgetToolbarViewModel.setWalletBalance(balance: walletBalance)
                }
                
                // Update wallet status view model
                self?.walletStatusViewModel.setTotalBalance(amount: CurrencyFormater.formatWalletAmount(wallet?.total ?? 0.0))
                self?.walletStatusViewModel.setBonusBalance(amount: CurrencyFormater.formatWalletAmount(wallet?.bonus ?? 0.0))
                self?.walletStatusViewModel.setCurrentBalance(amount: CurrencyFormater.formatWalletAmount(wallet?.total ?? 0.0))
                self?.walletStatusViewModel.setWithdrawableBalance(amount: CurrencyFormater.formatWalletAmount(wallet?.totalWithdrawable ?? 0.0))
                self?.walletStatusViewModel.setCashbackBalance(amount: CurrencyFormater.formatWalletAmount(0.0))
                
                print("💰 MyBetDetailViewModel: Wallet updated - total: \(wallet?.total ?? 0.0)")
            }
            .store(in: &cancellables)
    }
}