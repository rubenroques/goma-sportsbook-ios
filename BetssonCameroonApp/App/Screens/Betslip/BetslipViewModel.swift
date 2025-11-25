//
//  BetslipViewModel.swift
//  BetssonCameroonApp
//
//  Created by André Lascas on 14/08/2025.
//

import Foundation
import Combine
import GomaUI

public final class BetslipViewModel: BetslipViewModelProtocol {
    
    // MARK: - Properties
    private let dataSubject = CurrentValueSubject<BetslipData, Never>(BetslipData())
    private var cancellables = Set<AnyCancellable>()
    private var environment: Environment
    
    // MARK: - Configuration
    private let betslipConfiguration: BetslipConfiguration = {
        return BetslipConfiguration(
            config: BetslipConfigMetadata(
                name: "standard-betslip-container",
                version: "1.0.0",
                defaultLanguage: "en",
                id: "standard-betslip-container"
            ),
            settings: [
                BetslipSetting(
                    id: "allow_no_odds_change",
                    label: "allow_no_odds_change",
                    value: "none",
                    default: true
                ),
                BetslipSetting(
                    id: "allow_higher_odds",
                    label: "allow_higher_odds",
                    value: "higher",
                    default: false
                )
            ],
            tabs: [
                BetslipTab(
                    id: "sports-betslip",
                    label: "sports",
                    component: "betslip",
                    icon: "sports",
                    default: true,
                    betslipId: "sports-betslip"
                )
                // Uncomment to enable virtual betslip:
                // BetslipTab(
                //     id: "virtuals-betslip",
                //     label: "virtuals",
                //     component: "betslip",
                //     icon: "virtuals",
                //     default: false,
                //     betslipId: "virtuals-betslip"
                // )
            ]
        )
    }()
    
    // MARK: - Child View Models
    public var headerViewModel: BetslipHeaderViewModelProtocol
    public var betslipTypeSelectorViewModel: BetslipTypeSelectorViewModelProtocol
    public var sportsBetslipViewModel: SportsBetslipViewModelProtocol
    public var virtualBetslipViewModel: VirtualBetslipViewModelProtocol

    // MARK: - Configuration
    public var shouldShowTypeSelector: Bool {
        betslipConfiguration.shouldShowTypeSelector
    }

    // MARK: - Callbacks
    public var onHeaderCloseTapped: (() -> Void)?
    public var onHeaderJoinNowTapped: (() -> Void)?
    public var onHeaderLogInTapped: (() -> Void)?
    public var onEmptyStateActionTapped: (() -> Void)?
    public var onPlaceBetTapped: ((BetPlacedState) -> Void)?
    
    // MARK: - Initialization
    init(environment: Environment) {
        self.environment = environment
        // Initialize child view models
        self.headerViewModel = MockBetslipHeaderViewModel.notLoggedInMock()
        self.betslipTypeSelectorViewModel = MockBetslipTypeSelectorViewModel.defaultMock()
        self.sportsBetslipViewModel = SportsBetslipViewModel(environment: environment)
        self.virtualBetslipViewModel = VirtualBetslipViewModel(environment: environment)
        
        // Setup initial data
        setupInitialData()
        setupPublishers()
    }
    
    // MARK: - Publishers
    public var dataPublisher: AnyPublisher<BetslipData, Never> {
        return dataSubject.eraseToAnyPublisher()
    }
    
    public var currentData: BetslipData {
        return dataSubject.value
    }
    
    // MARK: - Public Methods
    public func setEnabled(_ isEnabled: Bool) {
        var currentData = dataSubject.value
        currentData = BetslipData(
            isEnabled: isEnabled,
            tickets: currentData.tickets
        )
        dataSubject.send(currentData)
    }
    
    // MARK: - Private Methods
    private func setupInitialData() {
        // Start with empty betslip
        let initialData = BetslipData(
            isEnabled: true,
            tickets: []
        )
        dataSubject.send(initialData)
    }
    
    private func setupPublishers() {
        
        Publishers.CombineLatest(Env.userSessionStore.userProfilePublisher, Env.userSessionStore.userWalletPublisher)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] userProfile, userWallet in
                if userProfile != nil,
                   let userWallet {
                    self?.updateToLoggedInState(userWallet: userWallet)
                } else {
                    self?.updateToLoggedOutState()
                }
            }
            .store(in: &cancellables)
        
        // Setup header callbacks for coordinator communication
        setupHeaderCallbacks()
    }
    
    private func setupHeaderCallbacks() {
        // Wire header view model callbacks to our callbacks
        headerViewModel.onCloseTapped = { [weak self] in
            self?.onHeaderCloseTapped?()
        }
        
        headerViewModel.onJoinNowTapped = { [weak self] in
            self?.onHeaderJoinNowTapped?()
        }
        
        headerViewModel.onLogInTapped = { [weak self] in
            self?.onHeaderLogInTapped?()
        }
        
        // Setup child view model callbacks
        setupChildViewModelCallbacks()
    }
    
    private func setupChildViewModelCallbacks() {
        // Wire sports betslip view model callbacks
        sportsBetslipViewModel.emptyStateViewModel.onActionButtonTapped = { [weak self] in
            self?.onEmptyStateActionTapped?()
        }
        
//        sportsBetslipViewModel.betInfoSubmissionViewModel.onPlaceBetTapped = { [weak self] in
//            self?.onPlaceBetTapped?()
//        }
        
        sportsBetslipViewModel.showPlacedBetState = { [weak self] placedBetState in
            self?.onPlaceBetTapped?(placedBetState)
        }
        
        sportsBetslipViewModel.showLoginScreen = { [weak self] in
            self?.onHeaderLogInTapped?()
        }
        
        // Wire virtual betslip view model callbacks
        virtualBetslipViewModel.emptyStateViewModel.onActionButtonTapped = { [weak self] in
            self?.onEmptyStateActionTapped?()
        }
        
//        virtualBetslipViewModel.betInfoSubmissionViewModel.onPlaceBetTapped = { [weak self] in
//            self?.onPlaceBetTapped?()
//        }
    }
    
    private func updateToLoggedInState(userWallet: UserWallet) {
        let walletBalance = CurrencyHelper.formatAmountWithCurrency(userWallet.total, currency: userWallet.currency)
        let loggedInState = BetslipHeaderState.loggedIn(balance: walletBalance)
        headerViewModel.updateState(loggedInState)
    }
    
    private func updateToLoggedOutState() {
        let notLoggedInState = BetslipHeaderState.notLoggedIn
        headerViewModel.updateState(notLoggedInState)
    }
    
}
