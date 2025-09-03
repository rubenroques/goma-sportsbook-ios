//
//  MyBetsViewModel.swift
//  BetssonCameroonApp
//
//  Created by Assistant on 28/08/2025.
//

import Foundation
import Combine
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
        
        // Listen to tab changes - skip initial value to prevent duplicate API call
        selectedTabTypePublisher
            .dropFirst()  // Skip the initial value
            .removeDuplicates()
            .sink { [weak self] tabType in
                print("📡 MyBetsViewModel: Tab publisher fired with: \(tabType.title)")
                self?.onTabOrStatusChanged()
            }
            .store(in: &cancellables)
        
        // Listen to status changes - skip initial value to prevent duplicate API call
        selectedStatusTypePublisher
            .dropFirst()  // Skip the initial value
            .removeDuplicates()
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
                        let errorMessage = "Failed to load bets: \(error.localizedDescription)"
                        print("❌ MyBetsViewModel: \(errorMessage)")
                        self?.betsStateSubject.send(.error(errorMessage))
                    }
                },
                receiveValue: { [weak self] bettingHistory in
                    self?.handleBetsResponse(bettingHistory, cacheKey: cacheKey)
                }
            )
    }
    
    func loadMoreBets() {
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
                        let errorMessage = "Failed to load more bets: \(error.localizedDescription)"
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
            // For now, get open bets and filter for cashout-eligible ones
            // TODO: Implement proper cashout filtering when API supports it
            serviceProviderPublisher = servicesProvider.getOpenBetsHistory(pageIndex: pageIndex, startDate: startDate, endDate: endDate)
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
        let viewModels = bets.map { bet in
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
            
            return viewModel
        }
        
        print("✅ MyBetsViewModel: Created \(viewModels.count) ticket view models")
        return viewModels
    }
    
    // MARK: - Navigation Closures
    
    var onNavigateToBetDetail: ((MyBet) -> Void)?
    
    // MARK: - Action Handlers
    
    private func handleNavigationTap(_ bet: MyBet) {
        print("🎯 MyBetsViewModel: Navigation tapped for bet: \(bet.identifier)")
        onNavigateToBetDetail?(bet)
    }
    
    private func handleRebetTap(_ bet: MyBet) {
        print("🔄 MyBetsViewModel: Rebet tapped for bet: \(bet.identifier)")
        // TODO: Create new bet ticket from selections
        // This would involve converting MyBetSelections back to BetTicketSelections
        // and adding them to the betslip
    }
    
    private func handleCashoutTap(_ bet: MyBet) {
        print("💰 MyBetsViewModel: Cashout tapped for bet: \(bet.identifier)")
        // TODO: Handle cashout flow
        // This would typically refresh the bet list to reflect the cashed out state
        refreshBets()
    }
}
