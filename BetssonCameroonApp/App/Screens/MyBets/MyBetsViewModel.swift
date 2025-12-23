//
//  MyBetsViewModel.swift
//  BetssonCameroonApp
//
//  Created on 28/08/2025.
//

import Foundation
import Combine
import UIKit
import GomaUI
import ServicesProvider

enum MyBetsState {
    case loading
    case loaded([TicketBetInfoViewModel])
    case error(String)
}

struct BetListData {
    let viewModels: [TicketBetInfoViewModel]
    let hasMore: Bool
    let currentPage: Int
    
    static let empty = BetListData(viewModels: [], hasMore: false, currentPage: 0)
}

struct SelectionReferenceResult {
    let selectionIndex: Int
    let selection: MyBetSelection
    let reference: OutcomeBettingOfferReference
}

struct RebetProcessingResult {
    let successfulResults: [SelectionReferenceResult]
    let hadFailures: Bool
    let totalAttempted: Int
}

final class MyBetsViewModel {
    
    // MARK: - Tab Management
    
    @Published var selectedTabType: MyBetsTabType = .sports
    
    // MARK: - Status Filter Management
    
    @Published var selectedStatusType: MyBetStatusType = .open
    
    // MARK: - Data State
    
    private let betsStateSubject = CurrentValueSubject<MyBetsState, Never>(.loading)
    
    // MARK: - Pagination State
    
    private var betListDataCache: [String: BetListData] = [:]
    private let itemsPerPage = 20
    
    // MARK: - Child ViewModels
    
    lazy var myBetsTabBarViewModel: MyBetsTabBarViewModel = {
        let tabViewModel = MyBetsTabBarViewModel(selectedTabType: selectedTabType)

        // Handle tab selection
        tabViewModel.selectionEventPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] event in
                if let tabType = MyBetsTabType(rawValue: event.selectedId) {
                    self?.selectTab(tabType)
                }
            }
            .store(in: &cancellables)

        return tabViewModel
    }()
    
    lazy var myBetsStatusBarViewModel: MyBetsStatusBarViewModel = {
        let statusViewModel = MyBetsStatusBarViewModel(selectedStatusType: selectedStatusType)

        // Handle pill selection
        statusViewModel.selectionEventPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] event in
                if let statusType = MyBetStatusType(rawValue: event.selectedId) {
                    self?.selectStatus(statusType)
                }
            }
            .store(in: &cancellables)

        return statusViewModel
    }()
    
    // MARK: - Dependencies
    
    private let servicesProvider: ServicesProvider.Client
    
    // MARK: - Private Properties

    private var cancellables = Set<AnyCancellable>()
    private var currentBetsRequest: AnyCancellable?
    private let viewModelCache = TicketBetInfoViewModelCache(maxSize: 20)
    
    // MARK: - Publishers
    
    var betsStatePublisher: AnyPublisher<MyBetsState, Never> {
        betsStateSubject.eraseToAnyPublisher()
    }
    
    var selectedTabTypePublisher: AnyPublisher<MyBetsTabType, Never> {
        $selectedTabType.eraseToAnyPublisher()
    }
    
    var selectedStatusTypePublisher: AnyPublisher<MyBetStatusType, Never> {
        $selectedStatusType.eraseToAnyPublisher()
    }
    
    // MARK: - Initialization
    
    init(servicesProvider: ServicesProvider.Client) {
        print("🏁 MyBetsViewModel: INIT STARTED")
        self.servicesProvider = servicesProvider
        print("🏁 MyBetsViewModel: About to setup bindings")
        setupBindings()
        print("🏁 MyBetsViewModel: About to call loadBets from init")
        loadBets(forced: false)
    }
    
    // MARK: - Setup
    
    private func setupBindings() {
        print("📡 MyBetsViewModel: Setting up bindings")

        // Subscribe to user logout to clear cached data (SECURITY)
        // This prevents the next user from seeing the previous user's betting history
        Env.userSessionStore.userProfileStatusPublisher
            .removeDuplicates()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] status in
                guard let self = self else { return }
                switch status {
                case .anonymous:
                    // User logged out - clear data and show empty state
                    print("[SECURITY] MyBetsViewModel: User logged out, clearing cached bets and ViewModels")
                    self.betListDataCache.removeAll()
                    self.viewModelCache.invalidateAll()
                    self.betsStateSubject.send(.loaded([]))
                case .logged:
                    // User logged in - refresh data for new user
                    print("MyBetsViewModel: User logged in, refreshing bets")
                    self.loadBets(forced: true)
                }
            }
            .store(in: &cancellables)

        // Listen to tab changes - skip initial value to prevent duplicate API call
        selectedTabTypePublisher
            .dropFirst()  // Skip the initial value
            .removeDuplicates()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] tabType in
                print("📡 MyBetsViewModel: Tab publisher fired with: \(tabType.title)")
                self?.onTabOrStatusChanged()
            }
            .store(in: &cancellables)
        
        // Listen to status changes - skip initial value to prevent duplicate API call
        selectedStatusTypePublisher
            .dropFirst()  // Skip the initial value
            .removeDuplicates()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] statusType in
                print("📡 MyBetsViewModel: Status publisher fired with: \(statusType.title)")
                self?.onTabOrStatusChanged()
            }
            .store(in: &cancellables)
        
        print("📡 MyBetsViewModel: Bindings setup complete")
    }
    
    // MARK: - Actions
    
    func selectTab(_ tabType: MyBetsTabType) {
        selectedTabType = tabType
    }
    
    func selectStatus(_ statusType: MyBetStatusType) {
        selectedStatusType = statusType
    }
    
    func loadBets(forced: Bool = false) {
        // Check auth first - show empty state if not logged in (matches web behavior)
        guard Env.userSessionStore.isUserLogged() else {
            print("MyBetsViewModel: User not logged in - showing empty state")
            betsStateSubject.send(.loaded([]))
            return
        }

        let cacheKey = "\(selectedTabType.rawValue)_\(selectedStatusType.rawValue)"
        
        // Check cache first if not forced
        if !forced, let cachedData = betListDataCache[cacheKey], !cachedData.viewModels.isEmpty {
            print("📦 MyBetsViewModel: Using cached data for \(cacheKey)")
            betsStateSubject.send(.loaded(cachedData.viewModels))
            return
        }
        
        // Cancel any existing request
        currentBetsRequest?.cancel()
        
        // Set loading state
        betsStateSubject.send(.loading)
        
        print("[AUTH_LOGS] 🚀 MyBetsViewModel: Loading bets for tab=\(selectedTabType.title) status=\(selectedStatusType.title) - API CALL WILL BE MADE")
        
        // Handle virtual sports - not implemented yet
        if selectedTabType == .virtuals {
            betsStateSubject.send(.loaded([]))
            betListDataCache[cacheKey] = BetListData(viewModels: [], hasMore: false, currentPage: 0)
            print("⚠️ MyBetsViewModel: Virtual sports not implemented")
            return
        }
        
        // Get appropriate API call based on status
        let publisher = getPublisherForCurrentStatus()
        
        currentBetsRequest = publisher
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { [weak self] completion in
                    if case .failure(let error) = completion {
                        let errorMessage = localized("mybets_error_api_load")
                            .replacingOccurrences(of: "{error}", with: error.localizedDescription)
                        print("❌ MyBetsViewModel: \(errorMessage)")
                        self?.betsStateSubject.send(.error(errorMessage))
                    }
                },
                receiveValue: { [weak self] bettingHistory in
                    self?.handleBetsResponse(bettingHistory, cacheKey: cacheKey)
                    self?.myBetsStatusBarViewModel.updateCounter(bettingHistory.count)
                }
            )
    }
    
    func loadMoreBets() {
        // Don't try to load more if not logged in
        guard Env.userSessionStore.isUserLogged() else { return }

        let cacheKey = "\(selectedTabType.rawValue)_\(selectedStatusType.rawValue)"
        guard let currentData = betListDataCache[cacheKey], currentData.hasMore else {
            print("📄 MyBetsViewModel: No more bets to load")
            return
        }
        
        print("📄 MyBetsViewModel: Loading more bets (page \(currentData.currentPage + 1))")
        
        // Note: For load more, we keep the current state and append to it
        // The loading indicator will be handled by the table view's pull-to-refresh
        
        let publisher = getPublisherForCurrentStatus(pageIndex: currentData.currentPage + 1)
        
        currentBetsRequest = publisher
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { [weak self] completion in
                    if case .failure(let error) = completion {
                        let errorMessage = localized("mybets_error_api_load_more")
                            .replacingOccurrences(of: "{error}", with: error.localizedDescription)
                        print("❌ MyBetsViewModel: \(errorMessage)")
                        // For load more errors, we just log them and keep current state
                    }
                },
                receiveValue: { [weak self] bettingHistory in
                    self?.handleLoadMoreResponse(bettingHistory, cacheKey: cacheKey)
                }
            )
    }
    
    func refreshBets() {
        // Don't refresh if not logged in
        guard Env.userSessionStore.isUserLogged() else {
            betsStateSubject.send(.loaded([]))
            return
        }

        print("🔄 MyBetsViewModel: Refreshing bets")
        betListDataCache.removeAll()
        loadBets(forced: true)
    }
    
    // MARK: - Private Methods
    
    private func onTabOrStatusChanged() {
        print("⚡️ MyBetsViewModel: onTabOrStatusChanged() triggered - scheduling loadBets after 0.1s delay")
        // Small delay to prevent rapid API calls when switching tabs/status quickly
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { [weak self] in
            print("⚡️ MyBetsViewModel: Delay completed, calling loadBets from onTabOrStatusChanged")
            self?.loadBets(forced: false)
        }
    }
    
    private func getPublisherForCurrentStatus(pageIndex: Int = 0) -> AnyPublisher<MyBettingHistory, ServiceProviderError> {
        let startDate: String? = nil // Use default from API
        let endDate: String? = nil   // Use default from API
        
        let serviceProviderPublisher: AnyPublisher<ServicesProvider.BettingHistory, ServiceProviderError>
        
        switch selectedStatusType {
        case .open:
            serviceProviderPublisher = servicesProvider.getOpenBetsHistory(pageIndex: pageIndex, startDate: startDate, endDate: endDate)
        case .settled:
            serviceProviderPublisher = servicesProvider.getResolvedBetsHistory(pageIndex: pageIndex, startDate: startDate, endDate: endDate)
        case .won:
            serviceProviderPublisher = servicesProvider.getWonBetsHistory(pageIndex: pageIndex, startDate: startDate, endDate: endDate)
        case .cashOut:
            serviceProviderPublisher = servicesProvider.getCashedOutBetsHistory(pageIndex: pageIndex, startDate: startDate, endDate: endDate)
        }
        
        return serviceProviderPublisher
            .map { servicesProviderBettingHistory in
                ServiceProviderModelMapper.myBettingHistory(servicesProviderBettingHistory)
            }
            .eraseToAnyPublisher()
    }
    
    private func handleBetsResponse(_ bettingHistory: MyBettingHistory, cacheKey: String) {
        let bets = bettingHistory.bets
        let hasMore = bets.count >= itemsPerPage // Simple pagination logic
        
        print("✅ MyBetsViewModel: Loaded \(bets.count) bets")
        
        // Create ticket view models from bets
        let viewModels = createTicketViewModels(from: bets)
        
        // Cache the data
        betListDataCache[cacheKey] = BetListData(
            viewModels: viewModels,
            hasMore: hasMore,
            currentPage: 0
        )
        
        // Update state
        betsStateSubject.send(.loaded(viewModels))
    }
    
    private func handleLoadMoreResponse(_ bettingHistory: MyBettingHistory, cacheKey: String) {
        guard let currentData = betListDataCache[cacheKey] else { return }
        
        let newBets = bettingHistory.bets
        let newViewModels = createTicketViewModels(from: newBets)
        let combinedViewModels = currentData.viewModels + newViewModels
        let hasMore = newBets.count >= itemsPerPage
        
        print("✅ MyBetsViewModel: Loaded \(newBets.count) more bets (total: \(combinedViewModels.count))")
        
        // Update cache
        betListDataCache[cacheKey] = BetListData(
            viewModels: combinedViewModels,
            hasMore: hasMore,
            currentPage: currentData.currentPage + 1
        )
        
        // Update state
        betsStateSubject.send(.loaded(combinedViewModels))
    }
    
    // MARK: - Ticket View Models Creation

    private func createTicketViewModels(from bets: [MyBet]) -> [TicketBetInfoViewModel] {
        var cacheHits = 0
        var cacheMisses = 0

        let viewModels = bets.map { bet -> TicketBetInfoViewModel in
            // Check cache first
            if let cachedViewModel = viewModelCache.get(forBetId: bet.identifier) {
                cacheHits += 1
                // Update with fresh bet data (preserves SSE subscription)
                cachedViewModel.updateBetInfo(bet)
                return cachedViewModel
            }

            cacheMisses += 1

            // Create new ViewModel
            let viewModel = TicketBetInfoViewModel(myBet: bet, servicesProvider: servicesProvider)

            // Wire up actions
            viewModel.onNavigationTap = { [weak self] bet in
                self?.handleNavigationTap(bet)
            }

            viewModel.onRebetTap = { [weak self] bet in
                self?.handleRebetTap(bet)
            }

            viewModel.onCashoutTap = { [weak self] bet in
                self?.handleCashoutTap(bet)
            }

            // Wire cashout completion callback
            viewModel.onCashoutCompleted = { [weak self] betId, isFullCashout, error in
                self?.handleCashoutCompleted(betId: betId, isFullCashout: isFullCashout)
            }

            // Wire cashout error callback
            viewModel.onCashoutError = { [weak self] message, retryAction in
                self?.onShowCashoutError?(message, retryAction, {
                    // Cancel action - ViewModel handles state reset
                })
            }

            // Cache the new ViewModel
            viewModelCache.set(viewModel, forBetId: bet.identifier)

            return viewModel
        }

        print("✅ MyBetsViewModel: Created \(viewModels.count) ticket view models (cache hits: \(cacheHits), misses: \(cacheMisses))")
        return viewModels
    }
    
    // MARK: - Navigation Closures
    
    var onNavigateToBetDetail: ((MyBet) -> Void)?
    var onRequestRebetConfirmation: ((@escaping (Bool) -> Void) -> Void)?
    var onNavigateToBetslip: ((Int?, Int?) -> Void)? // (successCount?, failCount?) - nil if no partial failure
    var onShowRebetAllFailedError: (() -> Void)?
    var onShowCashoutError: ((String, @escaping () -> Void, @escaping () -> Void) -> Void)?
    
    // MARK: - Action Handlers
    
    private func handleNavigationTap(_ bet: MyBet) {
        print("🎯 MyBetsViewModel: Navigation tapped for bet: \(bet.identifier)")
        onNavigateToBetDetail?(bet)
    }
    
    private func handleRebetTap(_ bet: MyBet) {
        
        // Track total number of selections we're attempting to process
        let totalAttempted = bet.selections.count
        
        // Create publishers for each selection that has an outcomeId
        // Convert errors to nil so individual failures don't break the chain
        let publishers: [AnyPublisher<SelectionReferenceResult?, Never>] = bet.selections.enumerated().compactMap { index, selection in
            guard let outcomeId = selection.outcomeId else {
                print("⚠️ MyBetsViewModel: Selection \(index + 1) has no outcomeId, skipping")
                return nil
            }
            
            return servicesProvider.getBettingOfferReference(forOutcomeId: outcomeId)
                .map { reference -> SelectionReferenceResult? in
                    print("✅ MyBetsViewModel: Successfully retrieved reference for selection \(index + 1)")
                    return SelectionReferenceResult(
                        selectionIndex: index,
                        selection: selection,
                        reference: reference
                    )
                }
                .catch { error -> Just<SelectionReferenceResult?> in
                    print("❌ MyBetsViewModel: Failed to get reference for selection \(index + 1): \(error.localizedDescription)")
                    return Just(nil)
                }
                .eraseToAnyPublisher()
        }
        
        guard !publishers.isEmpty else {
            print("⚠️ MyBetsViewModel: No valid selections with outcomeId found")
            return
        }
                
        // Combine all publishers and wait for all to complete
        Publishers.MergeMany(publishers)
            .collect()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] optionalResults in
                // Filter out nil results (failures) and keep successful ones
                let successfulResults = optionalResults.compactMap { $0 }
                let hadFailures = successfulResults.count < optionalResults.count
                
                print("📊 MyBetsViewModel: Rebet processing complete")
                print("   - Total selections attempted: \(totalAttempted)")
                print("   - Successful retrievals: \(successfulResults.count)")
                print("   - Failed retrievals: \(optionalResults.count - successfulResults.count)")
                
                let processingResult = RebetProcessingResult(
                    successfulResults: successfulResults,
                    hadFailures: hadFailures,
                    totalAttempted: totalAttempted
                )
                
                self?.processBettingOfferReferences(processingResult: processingResult, originalBet: bet)
            }
            .store(in: &cancellables)
    }
    
    private func processBettingOfferReferences(processingResult: RebetProcessingResult, originalBet: MyBet) {
        
        // Check if we have any successful results
        guard !processingResult.successfulResults.isEmpty else {
            print("❌ MyBetsViewModel: All selections failed to retrieve betting offer references")
            onShowRebetAllFailedError?()
            return
        }
        
        // Create updated selections with new betting offer IDs
        // Only keep selections that were successfully updated
        var successfullyUpdatedSelections: [MyBetSelection] = []
        
        for result in processingResult.successfulResults {
            let reference = result.reference
            let index = result.selectionIndex
            
            // Update the selection with the new betting offer ID
            if let newBettingOfferId = reference.bettingOfferIds.first {
                let originalSelection = originalBet.selections[index]
                
                // Create updated selection with new identifier
                let updatedSelection = MyBetSelection(
                    identifier: newBettingOfferId,  // Update with betting offer ID
                    state: originalSelection.state,
                    result: originalSelection.result,
                    globalState: originalSelection.globalState,
                    eventName: originalSelection.eventName,
                    homeTeamName: originalSelection.homeTeamName,
                    awayTeamName: originalSelection.awayTeamName,
                    eventDate: originalSelection.eventDate,
                    tournamentName: originalSelection.tournamentName,
                    sport: originalSelection.sport,
                    marketName: originalSelection.marketName,
                    outcomeName: originalSelection.outcomeName,
                    odd: originalSelection.odd,
                    marketId: originalSelection.marketId,
                    marketTypeId: originalSelection.marketTypeId,
                    outcomeId: originalSelection.outcomeId,
                    homeResult: originalSelection.homeResult,
                    awayResult: originalSelection.awayResult,
                    eventId: originalSelection.eventId,
                    country: originalSelection.country
                )
                
                successfullyUpdatedSelections.append(updatedSelection)
                
                print("✅ Updated identifier: \(originalSelection.identifier) → \(newBettingOfferId)")
            } else {
                print("⚠️ No betting offer ID found in response for selection \(index + 1) - skipping")
            }
        }
        
        // Create BettingTickets ONLY from successfully updated selections
        let bettingTickets: [BettingTicket] = successfullyUpdatedSelections.compactMap { selection in
            guard let outcomeId = selection.outcomeId,
                  let marketId = selection.marketId else {
                return nil
            }
            
            // Create betting ticket
            let ticket = BettingTicket(
                id: selection.identifier,
                outcomeId: outcomeId,
                marketId: marketId,
                matchId: selection.eventId,
                marketTypeId: nil,
                isAvailable: true,
                matchDescription: selection.eventName,
                marketDescription: selection.marketName,
                outcomeDescription: selection.outcomeName,
                homeParticipantName: selection.homeTeamName,
                awayParticipantName: selection.awayTeamName,
                sport: selection.sport,
                sportIdCode: selection.sport?.id,
                venue: nil,  // Not available in MyBetSelection
                competition: selection.tournamentName,
                date: selection.eventDate,
                odd: selection.odd,
                isFromBetBuilderMarket: nil
            )
            
            return ticket
        }
        
        // Determine if there were failures (including selections without betting offer IDs)
        let actualSuccessCount = successfullyUpdatedSelections.count
        let actualFailCount = processingResult.totalAttempted - actualSuccessCount
        let hadFailures = actualFailCount > 0
        
        // Request confirmation from view controller
        onRequestRebetConfirmation? { [weak self] shouldProceed in
            if shouldProceed {
                
                self?.addTicketsToBetslip(bettingTickets)
                
                if hadFailures {
                    self?.onNavigateToBetslip?(actualSuccessCount, actualFailCount)
                } else {
                    self?.onNavigateToBetslip?(nil, nil)
                }
            }
        }
    }
    
    
    private func addTicketsToBetslip(_ bettingTickets: [BettingTicket]) {
        
        Env.betslipManager.clearAllBettingTickets()
        
        // Add all tickets to betslip
        for ticket in bettingTickets {
            Env.betslipManager.addBettingTicket(ticket)
        }
        
    }
    
    private func handleCashoutTap(_ bet: MyBet) {
        print("💰 MyBetsViewModel: Cashout tapped for bet: \(bet.identifier)")
        // Cashout execution is now handled by TicketBetInfoViewModel's state machine
        // This callback is kept for legacy compatibility but the actual execution
        // flows through onCashoutCompleted and onCashoutError
    }

    private func handleCashoutCompleted(betId: String, isFullCashout: Bool) {
        if isFullCashout {
            // Full cashout: Remove bet from list
            print("✅ MyBetsViewModel: Full cashout completed for bet: \(betId)")
            viewModelCache.invalidate(forBetId: betId)

            // Filter bet from current list
            let cacheKey = "\(selectedTabType.rawValue)_\(selectedStatusType.rawValue)"
            if let currentData = betListDataCache[cacheKey] {
                let filteredViewModels = currentData.viewModels.filter { $0.currentBetInfo.id != betId }
                let updatedData = BetListData(
                    viewModels: filteredViewModels,
                    hasMore: currentData.hasMore,
                    currentPage: currentData.currentPage
                )
                betListDataCache[cacheKey] = updatedData
                betsStateSubject.send(.loaded(filteredViewModels))
            } else {
                // Fallback: refresh bets
                refreshBets()
            }
        } else {
            // Partial cashout: Reload bets to get updated data
            print("✅ MyBetsViewModel: Partial cashout completed for bet: \(betId)")
            loadBets(forced: true)
        }
    }
}
