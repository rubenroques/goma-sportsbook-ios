//
//  MockBetslipViewModel.swift
//  BetssonCameroonApp
//
//  Created by André Lascas on 14/08/2025.
//

import Foundation
import Combine
import GomaUI

public final class MockBetslipViewModel: BetslipViewModelProtocol {
    
    // MARK: - Properties
    private let dataSubject = CurrentValueSubject<BetslipData, Never>(BetslipData())
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Child View Models
    public var headerViewModel: BetslipHeaderViewModelProtocol
    public var betslipTypeSelectorViewModel: BetslipTypeSelectorViewModelProtocol
    public var sportsBetslipViewModel: SportsBetslipViewModelProtocol
    public var virtualBetslipViewModel: VirtualBetslipViewModelProtocol
    
    // MARK: - Callbacks
    public var onHeaderCloseTapped: (() -> Void)?
    public var onHeaderJoinNowTapped: (() -> Void)?
    public var onHeaderLogInTapped: (() -> Void)?
    public var onEmptyStateActionTapped: (() -> Void)?
    public var onPlaceBetTapped: ((BetPlacedState) -> Void)?
    
    // MARK: - Initialization
    public init() {
        // Initialize child view models
        self.headerViewModel = MockBetslipHeaderViewModel.notLoggedInMock()
        self.betslipTypeSelectorViewModel = MockBetslipTypeSelectorViewModel.defaultMock()
        self.sportsBetslipViewModel = MockSportsBetslipViewModel()
        self.virtualBetslipViewModel = MockVirtualBetslipViewModel()
        
        // Setup initial mock data
        setupMockData()
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
        currentData = BetslipData(isEnabled: isEnabled, tickets: currentData.tickets)
        dataSubject.send(currentData)
    }
    
    // MARK: - Private Methods
    private func setupMockData() {
        // Start with empty betslip for mock
        let initialData = BetslipData(isEnabled: true, tickets: [])
        dataSubject.send(initialData)
    }
    
    private func setupPublishers() {
        // Subscribe to user profile changes to update header state
        Env.userSessionStore.userProfilePublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] userProfile in
                if userProfile != nil {
                    self?.updateToLoggedInState()
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
        
        // Wire virtual betslip view model callbacks
        virtualBetslipViewModel.emptyStateViewModel.onActionButtonTapped = { [weak self] in
            self?.onEmptyStateActionTapped?()
        }
        
    }
    
    private func updateToLoggedInState() {
        let loggedInState = BetslipHeaderState.loggedIn(balance: "XAF 25,000")
        headerViewModel.updateState(loggedInState)
    }
    
    private func updateToLoggedOutState() {
        let notLoggedInState = BetslipHeaderState.notLoggedIn
        headerViewModel.updateState(notLoggedInState)
    }
} 
