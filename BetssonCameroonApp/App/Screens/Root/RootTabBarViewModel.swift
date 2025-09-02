//
//  ScreenType.swift
//  Sportsbook
//
//  Created by Ruben Roques on 13/06/2025.
//

import UIKit
import Combine
import LocalAuthentication
import ServicesProvider
import GomaUI

class RootTabBarViewModel: ObservableObject {

    var multiWidgetToolbarViewModel: MultiWidgetToolbarViewModel
    var adaptiveTabBarViewModel: AdaptiveTabBarViewModelProtocol
    var floatingOverlayViewModel: FloatingOverlayViewModelProtocol
    var betslipFloatingViewModel: BetslipFloatingViewModelProtocol
    var walletStatusViewModel: WalletStatusViewModelProtocol

    private let userSessionStore: UserSessionStore
    private var cancellables = Set<AnyCancellable>()
    private var lastActiveTabBarID: TabBarIdentifier?
    
    // MARK: - Navigation Callbacks
    var onBetslipRequested: (() -> Void)?
    
    // MARK: - Authentication Publishers
    
    /// Publisher that emits user profile changes (for UI updates)
    var userProfilePublisher: AnyPublisher<UserProfile?, Never> {
        return userSessionStore.userProfilePublisher.eraseToAnyPublisher()
    }
    
    /// Publisher that emits loading session state
    var isLoadingUserSessionPublisher: AnyPublisher<Bool, Never> {
        return userSessionStore.isLoadingUserSessionPublisher.eraseToAnyPublisher()
    }
    
    /// Publisher that emits whether authentication should be shown
    var shouldShowAuthenticationPublisher: AnyPublisher<Bool, Never> {
        return userSessionStore.isLoadingUserSessionPublisher
            .map { !$0 } // Show authentication UI when NOT loading
            .eraseToAnyPublisher()
    }

    init(userSessionStore: UserSessionStore,
         multiWidgetToolbarViewModel: MultiWidgetToolbarViewModel? = nil,
         adaptiveTabBarViewModel: AdaptiveTabBarViewModelProtocol = MockAdaptiveTabBarViewModel.defaultMock,
         floatingOverlayViewModel: FloatingOverlayViewModelProtocol = MockFloatingOverlayViewModel(),
         betslipFloatingViewModel: BetslipFloatingViewModelProtocol = MockBetslipFloatingViewModel(state: .noTickets))
    {
        self.userSessionStore = userSessionStore
        // Use provided view model or create new instance
        self.multiWidgetToolbarViewModel = multiWidgetToolbarViewModel ?? MultiWidgetToolbarViewModel()
        self.adaptiveTabBarViewModel = adaptiveTabBarViewModel
        self.floatingOverlayViewModel = floatingOverlayViewModel
        self.betslipFloatingViewModel = betslipFloatingViewModel
        self.walletStatusViewModel = MockWalletStatusViewModel.emptyBalanceMock
        
        setupTabBarBinding()
        setupBetslipBinding()
        setupMultiWidgetToolbarBinding()
        setupWalletStatusBinding()
    }
    
    func logoutUser() {
        userSessionStore.logout()
    }
    
    // MARK: - Authentication Business Logic
    
    /// Returns true if user authentication is required
    func shouldAuthenticateUser() -> Bool {
        return userSessionStore.shouldAuthenticateUser
    }
    
    /// Returns true if biometric authentication should be requested
    func shouldRequestBiometrics() -> Bool {
        return userSessionStore.shouldRequestBiometrics()
    }
    
    /// Returns true if user is logged in
    func isUserLogged() -> Bool {
        return userSessionStore.isUserLogged()
    }
    
    /// Unlocks app with authenticated user
    func unlockAppWithUser() {
        userSessionStore.startUserSession()
    }
    
    /// Unlocks app in anonymous mode
    func unlockAppAnonymous() {
        userSessionStore.logout()
    }
    
    /// Triggers biometric authentication check on app foreground
    func handleAppWillEnterForeground() -> Bool {
        return userSessionStore.shouldRequestBiometrics()
    }

    // MARK: - Private Methods
    private func setupBetslipBinding() {
        // Setup betslip callback
        betslipFloatingViewModel.onBetslipTapped = { [weak self] in
            self?.onBetslipRequested?()
        }
        
        // Subscribe to betslip manager tickets to update floating view state
        Env.betslipManager.bettingTicketsPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] tickets in
                self?.updateBetslipFloatingState(tickets: tickets)
            }
            .store(in: &cancellables)
    }
    
    private func updateBetslipFloatingState(tickets: [BettingTicket]) {
        if tickets.isEmpty {
            betslipFloatingViewModel.updateState(.noTickets)
        } else {
            // Calculate total odds and other betslip data
            let selectionCount = tickets.count
            let totalOdds = calculateTotalOdds(from: tickets)
            let totalEligibleCount = 0
            
            betslipFloatingViewModel.updateState(.withTickets(
                selectionCount: selectionCount,
                odds: String(format: "%.2f", totalOdds),
                winBoostPercentage: nil, // TODO: Implement win boost calculation
                totalEligibleCount: totalEligibleCount
            ))
        }
    }
    
    private func calculateTotalOdds(from tickets: [BettingTicket]) -> Double {
        return tickets.reduce(1.0) { total, ticket in
            total * ticket.decimalOdd
        }
    }
    
    private func setupTabBarBinding() {
        // Listen to tab bar active bar id changes
        adaptiveTabBarViewModel.displayStatePublisher
            .sink { [weak self] displayState in
                if self?.lastActiveTabBarID != nil && self?.lastActiveTabBarID != displayState.activeTabBarID {
                    switch displayState.activeTabBarID {
                    case .home:
                        // Switched to Sportsbook
                        self?.floatingOverlayViewModel.show(mode: .sportsbook, duration: 3.0)
                    case .casino:
                        // Switched to Casino
                        self?.floatingOverlayViewModel.show(mode: .casino, duration: 3.0)
                    }
                }
                self?.lastActiveTabBarID = displayState.activeTabBarID
            }
            .store(in: &cancellables)

    }
    
    private func setupMultiWidgetToolbarBinding() {
        
        userSessionStore.userWalletPublisher
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] wallet in
                
                if let walletBalance = wallet?.total {
                    self?.multiWidgetToolbarViewModel.setWalletBalance(balance: walletBalance)
                }
            })
            .store(in: &cancellables)
    }
    
    private func setupWalletStatusBinding() {
        
        userSessionStore.userWalletPublisher
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] wallet in
                
                self?.walletStatusViewModel.setTotalBalance(amount: CurrencyFormater.formatWalletAmount(wallet?.total ?? 0.0))
                self?.walletStatusViewModel.setBonusBalance(amount: CurrencyFormater.formatWalletAmount(wallet?.bonus ?? 0.0))
                self?.walletStatusViewModel.setCurrentBalance(amount: CurrencyFormater.formatWalletAmount(wallet?.total ?? 0.0))
                self?.walletStatusViewModel.setWithdrawableBalance(amount: CurrencyFormater.formatWalletAmount(wallet?.totalWithdrawable ?? 0.0))
                self?.walletStatusViewModel.setCashbackBalance(amount: CurrencyFormater.formatWalletAmount(0.0))

            })
            .store(in: &cancellables)
    }

}
