//
//  ProfileWalletViewModel.swift
//  BetssonCameroonApp
//
//  Created on 29/08/2025.
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
    var onMenuItemSelected: ((ActionRowItem, String?) -> Void)?
    var showErrorAlert: ((String) -> Void)?
    
    var isActionLoadingPublisher: CurrentValueSubject<Bool, Never> = .init(false)
    
    // MARK: - Initialization
    
    init(servicesProvider: ServicesProvider.Client, userSessionStore: UserSessionStore) {
        self.servicesProvider = servicesProvider
        self.userSessionStore = userSessionStore
        
        // Create child ViewModels
        let walletDetailVM = WalletDetailViewModel(userSessionStore: userSessionStore)
        self.walletDetailViewModel = walletDetailVM
        self.profileMenuListViewModel = ProfileMenuListViewModel()
        self.themeSwitcherViewModel = ThemeSwitcherViewModel()
        
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

    func refreshLanguageDisplay() {
        let currentLanguageCode = localized("current_language_code")
        let displayName = ProfileMenuListViewModel.displayNameForLanguageCode(currentLanguageCode)
        profileMenuListViewModel.updateCurrentLanguage(displayName)
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
            if menuItem.action == .changePassword {
                self?.getChangePasswordToken(menuItem: menuItem)
            }
            else {
                self?.onMenuItemSelected?(menuItem, nil)
            }
        }
    }
    
    private func setupThemeSwitcherCallbacks() {
        // The ThemeSwitcherViewModel handles theme application directly
        // We can monitor theme changes here if needed for analytics or other purposes
        themeSwitcherViewModel.selectedThemePublisher
            .dropFirst() // Skip initial value
            .sink { theme in
                print("ProfileWalletViewModel: Theme changed to \(theme.rawValue)")
                // Add any additional handling here if needed (e.g., analytics)
            }
            .store(in: &cancellables)
    }
    
    private func getChangePasswordToken(menuItem: ActionRowItem) {
        self.isActionLoadingPublisher.send(true)
        
        let userMobilePrefix = userSessionStore.userProfilePublisher.value?.mobileCountryCode ?? ""
        let userMobilePhoneNumber = userSessionStore.userProfilePublisher.value?.mobilePhone ?? ""
        
        Env.servicesProvider
            .getResetPasswordTokenId(mobileNumber: userMobilePhoneNumber, mobilePrefix: userMobilePrefix)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { [weak self] completion in
                guard let self = self else { return }
                
                self.isActionLoadingPublisher.send(false)

                switch completion {
                case .finished:
                    break
                case .failure(let error):
                    self.showErrorAlert?("Can't proceed with change password at the moment. Please try again later")
                }
            }, receiveValue: { [weak self] response in
                guard let self = self else { return }
                self.onMenuItemSelected?(menuItem, response.tokenId)
            })
            .store(in: &cancellables)
    }
}
