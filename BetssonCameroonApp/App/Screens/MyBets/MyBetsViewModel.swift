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

final class MyBetsViewModel: MyBetsViewModelProtocol {
    
    // MARK: - Tab Management
    
    @Published var selectedTabType: MyBetsTabType = .sports
    
    // MARK: - Status Filter Management
    
    @Published var selectedStatusType: MyBetStatusType = .open
    
    // MARK: - Data State
    
    private let betsStateSubject = CurrentValueSubject<MyBetsState, Never>(.loading)
    private let isLoadingSubject = CurrentValueSubject<Bool, Never>(false)
    private let errorMessageSubject = CurrentValueSubject<String?, Never>(nil)
    private let ticketViewModelsSubject = CurrentValueSubject<[TicketBetInfoViewModelProtocol], Never>([])
    
    // MARK: - Pagination State
    
    private var betListDataCache: [String: BetListData] = [:]
    private let itemsPerPage = 20
    
    // MARK: - Child ViewModels
    
    lazy var marketGroupSelectorTabViewModel: MarketGroupSelectorTabViewModelProtocol = {
        let mock = MockMarketGroupSelectorTabViewModel(tabData: MarketGroupSelectorTabData(id: "myBets", marketGroups: []))
        
        // Configure tabs for Sports and Virtuals
        let tabs = [
            MarketGroupTabItemData(
                id: MyBetsTabType.sports.rawValue,
                title: MyBetsTabType.sports.title,
                visualState: .selected,
                iconTypeName: MyBetsTabType.sports.iconTypeName
            ),
            MarketGroupTabItemData(
                id: MyBetsTabType.virtuals.rawValue,
                title: MyBetsTabType.virtuals.title,
                visualState: .idle,
                iconTypeName: MyBetsTabType.virtuals.iconTypeName
            )
        ]
        
        mock.updateMarketGroups(tabs)
        mock.selectMarketGroup(id: MyBetsTabType.sports.rawValue)
        
        // Handle tab selection
        mock.selectionEventPublisher
            .sink { [weak self] event in
                if let tabType = MyBetsTabType(rawValue: event.selectedId) {
                    self?.selectTab(tabType)
                }
            }
            .store(in: &cancellables)
        
        return mock
    }()
    
    lazy var pillSelectorBarViewModel: PillSelectorBarViewModelProtocol = {
        // Configure pills for bet statuses
        let pills = MyBetStatusType.allCases.map { statusType in
            PillData(
                id: statusType.pillId,
                title: statusType.title,
                leftIconName: nil,
                showExpandIcon: false,
                isSelected: statusType == .open
            )
        }
        
        let barData = PillSelectorBarData(
            id: "betStatus",
            pills: pills,
            selectedPillId: MyBetStatusType.open.pillId
        )
        
        let mock = MockPillSelectorBarViewModel(barData: barData)
        
        // Handle pill selection
        mock.selectionEventPublisher
            .sink { [weak self] event in
                if let statusType = MyBetStatusType(rawValue: event.selectedId) {
                    self?.selectStatus(statusType)
                }
            }
            .store(in: &cancellables)
        
        return mock
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
    
    var isLoadingPublisher: AnyPublisher<Bool, Never> {
        isLoadingSubject.eraseToAnyPublisher()
    }
    
    var errorMessagePublisher: AnyPublisher<String?, Never> {
        errorMessageSubject.eraseToAnyPublisher()
    }
    
    var selectedTabTypePublisher: AnyPublisher<MyBetsTabType, Never> {
        $selectedTabType.eraseToAnyPublisher()
    }
    
    var selectedStatusTypePublisher: AnyPublisher<MyBetStatusType, Never> {
        $selectedStatusType.eraseToAnyPublisher()
    }
    
    var ticketBetInfoViewModelsPublisher: AnyPublisher<[TicketBetInfoViewModelProtocol], Never> {
        ticketViewModelsSubject.eraseToAnyPublisher()
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
        print("🎯 MyBetsViewModel: selectTab() called with: \(tabType.title) (caller: \(Thread.callStackSymbols[1]))")
        selectedTabType = tabType
    }
    
    func selectStatus(_ statusType: MyBetStatusType) {
        print("🎯 MyBetsViewModel: selectStatus() called with: \(statusType.title) (caller: \(Thread.callStackSymbols[1]))")
        selectedStatusType = statusType
    }
    
    func loadBets(forced: Bool = false) {
        print("🔍 MyBetsViewModel: loadBets() called (forced=\(forced)) - STACK TRACE:")
        Thread.callStackSymbols.prefix(5).forEach { print("   \($0)") }
        
        let cacheKey = "\(selectedTabType.rawValue)_\(selectedStatusType.rawValue)"
        
        // Check cache first if not forced
        if !forced, let cachedData = betListDataCache[cacheKey], !cachedData.bets.isEmpty {
            print("📦 MyBetsViewModel: Using cached data for \(cacheKey)")
            betsStateSubject.send(.loaded(cachedData.bets))
            return
        }
        
        // Cancel any existing request
        currentBetsRequest?.cancel()
        
        // Set loading state
        isLoadingSubject.send(true)
        betsStateSubject.send(.loading)
        errorMessageSubject.send(nil)
        
        print("[AUTH_LOGS] 🚀 MyBetsViewModel: Loading bets for tab=\(selectedTabType.title) status=\(selectedStatusType.title) - API CALL WILL BE MADE")
        
        // Handle virtual sports - not implemented yet
        if selectedTabType == .virtuals {
            isLoadingSubject.send(false)
            betsStateSubject.send(.loaded([]))
            betListDataCache[cacheKey] = BetListData(bets: [], hasMore: false, currentPage: 0)
            print("⚠️ MyBetsViewModel: Virtual sports not implemented")
            return
        }
        
        // Get appropriate API call based on status
        let publisher = getPublisherForCurrentStatus()
        
        currentBetsRequest = publisher
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { [weak self] completion in
                    self?.isLoadingSubject.send(false)
                    
                    if case .failure(let error) = completion {
                        let errorMessage = "Failed to load bets: \(error.localizedDescription)"
                        print("❌ MyBetsViewModel: \(errorMessage)")
                        self?.betsStateSubject.send(.error(errorMessage))
                        self?.errorMessageSubject.send(errorMessage)
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
        
        // Set loading for additional content
        isLoadingSubject.send(true)
        
        let publisher = getPublisherForCurrentStatus(pageIndex: currentData.currentPage + 1)
        
        currentBetsRequest = publisher
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { [weak self] completion in
                    self?.isLoadingSubject.send(false)
                    
                    if case .failure(let error) = completion {
                        let errorMessage = "Failed to load more bets: \(error.localizedDescription)"
                        print("❌ MyBetsViewModel: \(errorMessage)")
                        self?.errorMessageSubject.send(errorMessage)
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
        
        // Cache the data
        betListDataCache[cacheKey] = BetListData(
            bets: bets,
            hasMore: hasMore,
            currentPage: 0
        )
        
        // Create ticket view models from bets
        createTicketViewModels(from: bets)
        
        // Update state
        betsStateSubject.send(.loaded(bets))
        isLoadingSubject.send(false)
    }
    
    private func handleLoadMoreResponse(_ bettingHistory: MyBettingHistory, cacheKey: String) {
        guard let currentData = betListDataCache[cacheKey] else { return }
        
        let newBets = bettingHistory.bets
        let combinedBets = currentData.bets + newBets
        let hasMore = newBets.count >= itemsPerPage
        
        print("✅ MyBetsViewModel: Loaded \(newBets.count) more bets (total: \(combinedBets.count))")
        
        // Update cache
        betListDataCache[cacheKey] = BetListData(
            bets: combinedBets,
            hasMore: hasMore,
            currentPage: currentData.currentPage + 1
        )
        
        // Create ticket view models from combined bets
        createTicketViewModels(from: combinedBets)
        
        // Update state
        betsStateSubject.send(.loaded(combinedBets))
        isLoadingSubject.send(false)
    }
    
    // MARK: - Ticket View Models Creation
    
    private func createTicketViewModels(from bets: [MyBet]) {
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
            
            return viewModel as TicketBetInfoViewModelProtocol
        }
        
        ticketViewModelsSubject.send(viewModels)
        print("✅ MyBetsViewModel: Created \(viewModels.count) ticket view models")
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
