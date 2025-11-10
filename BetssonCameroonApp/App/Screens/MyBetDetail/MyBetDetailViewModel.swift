//
//  MyBetDetailViewModel.swift
//  BetssonCameroonApp
//
//  Created on 01/09/2025.
//

import Foundation
import Combine
import ServicesProvider
import GomaUI

final class MyBetDetailViewModel: ObservableObject {
    
    // MARK: - Core Properties
    
    let bet: MyBet
    
    // MARK: - Authentication State (Clean MVVM Pattern)
    
    @Published var isAuthenticated: Bool = false
    
    // MARK: - Child ViewModels
    
    let multiWidgetToolbarViewModel: MultiWidgetToolbarViewModel
    let walletStatusViewModel: WalletStatusViewModel
    
    // GomaUI Component ViewModels
    private(set) var betDetailValuesSummaryViewModel: BetDetailValuesSummaryViewModel
    private(set) var betDetailResultSummaryViewModels: [BetDetailResultSummaryViewModel]
    
    // MARK: - Navigation Closure (following MatchDetailsTextualViewModel pattern)
    
    var onNavigateBack: (() -> Void) = { }
    
    // MARK: - Dependencies
    
    private let servicesProvider: ServicesProvider.Client
    private let userSessionStore: UserSessionStore
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Callbacks
    var onShareBookingCodeRequested: ((String) -> Void)?
    var onShareBookingCodeFailed: ((String) -> Void)?
    
    // MARK: - Initialization
    
    init(bet: MyBet, servicesProvider: ServicesProvider.Client, userSessionStore: UserSessionStore) {
        self.bet = bet
        self.servicesProvider = servicesProvider
        self.userSessionStore = userSessionStore
        self.multiWidgetToolbarViewModel = MultiWidgetToolbarViewModel()
        self.walletStatusViewModel = WalletStatusViewModel(userSessionStore: userSessionStore)
        
        // Initialize GomaUI Component ViewModels
        self.betDetailValuesSummaryViewModel = BetDetailValuesSummaryViewModel.create(from: bet)
        self.betDetailResultSummaryViewModels = bet.selections.map { selection in
            BetDetailResultSummaryViewModel.create(from: selection)
        }
        
        setupAuthenticationState()
        
        print("🎯 MyBetDetailViewModel: Initialized with bet ID: \(bet.identifier)")
    }
    
    // MARK: - Public Methods
    
    // No loading methods needed - all data is immediately available from the bet object
    
    func handleBackTap() {
        print("🔙 MyBetDetailViewModel: Back button tapped")
        onNavigateBack()
    }
    
    func handleShareTap() {
        // Build publishers for each selection that has an outcomeId
        let publishers: [AnyPublisher<(Int, MyBetSelection, OutcomeBettingOfferReference)?, Never>] = bet.selections.enumerated().compactMap { index, selection in
            guard let outcomeId = selection.outcomeId else {
                print("⚠️ MyBetDetailViewModel: Selection \(index + 1) has no outcomeId, skipping")
                return nil
            }
            return servicesProvider.getBettingOfferReference(forOutcomeId: outcomeId)
                .map { reference -> (Int, MyBetSelection, OutcomeBettingOfferReference)? in
                    print("✅ MyBetDetailViewModel: Retrieved betting offer reference for selection \(index + 1)")
                    return (index, selection, reference)
                }
                .catch { error -> Just<(Int, MyBetSelection, OutcomeBettingOfferReference)?> in
                    print("❌ MyBetDetailViewModel: Failed to get reference for selection \(index + 1): \(error.localizedDescription)")
                    return Just(nil)
                }
                .eraseToAnyPublisher()
        }
        
        guard !publishers.isEmpty else {
            print("⚠️ MyBetDetailViewModel: No selections with outcomeId found for sharing")
            return
        }
        
        Publishers.MergeMany(publishers)
            .collect()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] results in
                guard let self = self else { return }
                let successful: [(selectionIndex: Int, selection: MyBetSelection, reference: OutcomeBettingOfferReference)] = results.compactMap { $0 }
                
                // Next step: create booking code from the betting offer IDs
                let bettingOfferIds = Array(Set(successful.flatMap { $0.reference.bettingOfferIds }))
                let originalSelectionsLength = self.bet.selections.count
                guard !bettingOfferIds.isEmpty else {
                    self.onShareBookingCodeFailed?(localized("mybetdetail_share_no_selections"))
                    return
                }
                
                self.servicesProvider.createBookingCode(
                    bettingOfferIds: bettingOfferIds,
                    originalSelectionsLength: originalSelectionsLength
                )
                .receive(on: DispatchQueue.main)
                .sink(
                    receiveCompletion: { [weak self] completion in
                        if case .failure(let error) = completion {
                            self?.onShareBookingCodeFailed?(error.localizedDescription)
                        }
                    },
                    receiveValue: { [weak self] response in
                        self?.onShareBookingCodeRequested?(response.code)
                    }
                )
                .store(in: &self.cancellables)
            }
            .store(in: &cancellables)
    }
}

// MARK: - Computed Properties for UI Display

extension MyBetDetailViewModel {
    
    /// Returns a formatted ticket reference for display
    var displayBetId: String {
        return "Ticket #\(bet.displayTicketReference)"
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
    
    /// Returns a label for the bet selections section
    var selectionsLabel: String {
        if bet.selections.count > 1 {
            return "Multiple bet results"
        } else {
            return "Bet result"
        }
    }
}

// MARK: - Private Methods

extension MyBetDetailViewModel {
    
    private func setupAuthenticationState() {
        // Set up authentication state tracking (used by bet details and other features)
        userSessionStore.userProfilePublisher
            .map { $0 != nil }
            .receive(on: DispatchQueue.main)
            .assign(to: &$isAuthenticated)
    }
}
