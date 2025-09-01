//
//  ProfileWalletViewModel.swift
//  BetssonCameroonApp
//
//  Created by Claude on 29/08/2025.
//

import Foundation
import Combine
import GomaUI
import ServicesProvider

// MARK: - ProfileWallet Display State

struct ProfileWalletDisplayState: Equatable {
    let isLoading: Bool
    let error: String?
    
    init(isLoading: Bool = false, error: String? = nil) {
        self.isLoading = isLoading
        self.error = error
    }
}

// MARK: - ProfileWallet ViewModel

final class ProfileWalletViewModel: ObservableObject {
    
    // MARK: - Published Properties
    
    @Published var displayState = ProfileWalletDisplayState()
    
    // MARK: - Private Properties
    
    private let servicesProvider: ServicesProvider.Client
    private let userSessionStore: UserSessionStore
    private var cancellables = Set<AnyCancellable>()
    
    // Child ViewModels
    var walletDetailViewModel: WalletDetailViewModelProtocol
    var profileMenuListViewModel: ProfileMenuListViewModelProtocol
    var themeSwitcherViewModel: ThemeSwitcherViewModelProtocol
    
    // MARK: - Navigation Callbacks
    
    var onDismiss: (() -> Void)?
    var onDepositRequested: (() -> Void)?
    var onWithdrawRequested: (() -> Void)?
    var onMenuItemSelected: ((ProfileMenuItem) -> Void)?
    
    // MARK: - Initialization
    
    init(servicesProvider: ServicesProvider.Client, userSessionStore: UserSessionStore) {
        self.servicesProvider = servicesProvider
        self.userSessionStore = userSessionStore
        
        // Create child ViewModels
        let walletDetailVM = WalletDetailViewModel(userSessionStore: userSessionStore)
        self.walletDetailViewModel = walletDetailVM
        self.profileMenuListViewModel = ProfileMenuListViewModel()
        self.themeSwitcherViewModel = MockThemeSwitcherViewModel.defaultMock
        
        setupChildViewModelBindings()
        setupWalletDetailCallbacks(walletDetailVM)
        setupProfileMenuCallbacks()
        setupThemeSwitcherCallbacks()
    }
    
    // MARK: - Public Methods
    
    func loadData() {
        displayState = ProfileWalletDisplayState(isLoading: true)
        
        // Load wallet data
        walletDetailViewModel.refreshWalletData()
        
        // Load menu configuration
        profileMenuListViewModel.loadConfiguration(from: nil)
        
        // Simulate loading completion
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { [weak self] in
            self?.displayState = ProfileWalletDisplayState(isLoading: false)
        }
    }
    
    func refreshData() {
        loadData()
    }
    
    func didTapClose() {
        onDismiss?()
    }
    
    // MARK: - Private Methods
    
    private func setupChildViewModelBindings() {
        // Monitor child ViewModels for state changes if needed
        // For now, we'll let them handle their own state internally
    }
    
    private func setupWalletDetailCallbacks(_ walletDetailVM: WalletDetailViewModel) {
        // Setup deposit/withdraw callbacks
        walletDetailVM.onDepositRequested = { [weak self] in
            self?.onDepositRequested?()
        }
        
        walletDetailVM.onWithdrawRequested = { [weak self] in
            self?.onWithdrawRequested?()
        }
    }
    
    private func setupProfileMenuCallbacks() {
        // Set up callback for ProfileMenuListViewModel
        profileMenuListViewModel.onItemSelected = { [weak self] menuItem in
            self?.onMenuItemSelected?(menuItem)
        }
    }
    
    private func setupThemeSwitcherCallbacks() {
        // Monitor theme changes
        themeSwitcherViewModel.selectedThemePublisher
            .dropFirst() // Skip initial value
            .sink { [weak self] theme in
                self?.applyTheme(theme)
            }
            .store(in: &cancellables)
    }
    
    private func applyTheme(_ theme: ThemeMode) {
        // Apply theme to app-wide theme system
        switch theme {
        case .light:
            // Apply light theme
            print("ProfileWalletViewModel: Applying light theme")
        case .dark:
            // Apply dark theme
            print("ProfileWalletViewModel: Applying dark theme")
        case .system:
            // Follow system theme
            print("ProfileWalletViewModel: Following system theme")
        }
    }
}
