//
//  SportsSearchViewModel.swift
//  BetssonCameroonApp
//
//  Created by Andre on 27/01/2025.
//

import Foundation
import Combine
import GomaUI
import ServicesProvider

final class SportsSearchViewModel: SportsSearchViewModelProtocol {
    
    // MARK: - Properties
    
    // Matches and Market Groups state (mirrors NextUpEventsViewModel)
    private let allMatchesSubject = CurrentValueSubject<[Match], Never>([])
    var allMatchesPublisher: AnyPublisher<[Match], Never> {
        allMatchesSubject.eraseToAnyPublisher()
    }
    var allMatches: [Match] {
        get { allMatchesSubject.value }
        set { allMatchesSubject.send(newValue) }
    }
    
    private let marketGroupsSubject = CurrentValueSubject<[MarketGroupTabItemData], Never>([])
    var marketGroupsPublisher: AnyPublisher<[MarketGroupTabItemData], Never> {
        marketGroupsSubject.eraseToAnyPublisher()
    }
    var marketGroups: [MarketGroupTabItemData] {
        get { marketGroupsSubject.value }
        set { marketGroupsSubject.send(newValue) }
    }
    
    private let selectedMarketGroupIdSubject = CurrentValueSubject<String?, Never>(nil)
    var selectedMarketGroupIdPublisher: AnyPublisher<String?, Never> {
        selectedMarketGroupIdSubject.eraseToAnyPublisher()
    }
    var selectedMarketGroupId: String? {
        get { selectedMarketGroupIdSubject.value }
        set { selectedMarketGroupIdSubject.send(newValue) }
    }
    
    private let isLoadingSubject = CurrentValueSubject<Bool, Never>(false)
    var isLoadingPublisher: AnyPublisher<Bool, Never> {
        isLoadingSubject.eraseToAnyPublisher()
    }
    
    var isLoading: Bool {
        get { isLoadingSubject.value }
        set { isLoadingSubject.send(newValue) }
    }
    
    // MARK: - Current State Properties
    var currentSearchText: String {
        return _currentSearchText
    }
    
    private let mainMarketsSubject = CurrentValueSubject<[MainMarket]?, Never>(nil)
    var mainMarketsPublisher: AnyPublisher<[MainMarket]?, Never> {
        mainMarketsSubject.eraseToAnyPublisher()
    }
    var mainMarkets: [MainMarket]? {
        get { mainMarketsSubject.value }
        set { mainMarketsSubject.send(newValue) }
    }
    
    // Child view model for market group tabs
    let marketGroupSelectorViewModel: MarketGroupSelectorTabViewModel
    
    // Search header info view model
    let searchHeaderInfoViewModel: SearchHeaderInfoViewModelProtocol
    
    // Publishers
    var searchTextPublisher: AnyPublisher<String, Never> {
        searchTextSubject.eraseToAnyPublisher()
    }

    var searchFocusPublisher: AnyPublisher<Bool, Never> { searchComponentViewModel.isFocusedPublisher }
    
    var searchResultsPublisher: AnyPublisher<Int, Never> {
        searchResultsSubject.eraseToAnyPublisher()
    }
    
    var onSearchSubmitted: AnyPublisher<String, Never> {
        searchSubmittedSubject.eraseToAnyPublisher()
    }
    
    var recentSearchesPublisher: AnyPublisher<[String], Never> {
        recentSearchesSubject.eraseToAnyPublisher()
    }
    
    // Component View Models
    var searchViewModel: SearchViewModelProtocol {
        return searchComponentViewModel
    }
    
    // Subjects
    private let searchTextSubject = CurrentValueSubject<String, Never>("")
    private let searchResultsSubject = CurrentValueSubject<Int, Never>(0)
    private let searchSubmittedSubject = PassthroughSubject<String, Never>()
    private let recentSearchesSubject = CurrentValueSubject<[String], Never>([])
    
    // Component View Models
    private let searchComponentViewModel: SearchViewModelProtocol
    
    // Dependencies
    private let userSessionStore: UserSessionStore
    private var cancellables = Set<AnyCancellable>()
    
    // Search state
    private var _currentSearchText: String = ""
    
    // Store MarketGroupCards view models by market type id
    private var marketGroupCardsViewModels: [String: MarketGroupCardsViewModel] = [:]
    
    // Recommended events storage (from RecSys)
    private let recommendedItemsSubject = CurrentValueSubject<[TallOddsMatchCardViewModelProtocol], Never>([])
    var recommendedEventsPublisher: AnyPublisher<[Event], Never> { Just([]).eraseToAnyPublisher() }
    var recommendedItemsPublisher: AnyPublisher<[TallOddsMatchCardViewModelProtocol], Never> { recommendedItemsSubject.eraseToAnyPublisher() }
    
    // MARK: - Initialization
    
    init(userSessionStore: UserSessionStore) {
        self.userSessionStore = userSessionStore
        self.marketGroupSelectorViewModel = MarketGroupSelectorTabViewModel()
        
        // Create the SearchView's view model
        self.searchComponentViewModel = MockSearchViewModel.default
        
        // Create the SearchHeaderInfoView's view model
        self.searchHeaderInfoViewModel = MockSearchHeaderInfoViewModel()
        
        setupBindings()
        setupSearchComponentBindings()
        setupMarketGroupBindings()
        loadRecentSearches()
        getRecommendedMatches()
    }
    
    func clearData() {
        allMatches = []
        mainMarkets = nil
        marketGroups = []
        selectedMarketGroupId = nil
        marketGroupCardsViewModels.removeAll()
        self.marketGroupSelectorViewModel.updateWithMatches([], mainMarkets: [])
        self.marketGroupSelectorViewModel.clearSelection()
    }
    
    // MARK: - SportsSearchViewModelProtocol
    
    func updateSearchText(_ text: String) {
        _currentSearchText = text
        searchTextSubject.send(text)
        performSearch(text)
    }
    
    func submitSearch() {
        guard !_currentSearchText.isEmpty else { return }
        
        searchSubmittedSubject.send(_currentSearchText)
        performSearch(_currentSearchText)
    }
    
    func clearSearch() {
        _currentSearchText = ""
        searchTextSubject.send("")
        searchResultsSubject.send(0)
        clearData()
    }
    
    func searchFromRecent(_ text: String) {
        self.searchComponentViewModel.updateText(text)
        self.updateSearchText(text)
    }
    
    // MARK: - Private Methods
    private func setupBindings() {
        
        // Search results
        searchResultsPublisher
            .sink { [weak self] results in
                if results == 0 {
                    self?.clearData()
                }
            }
            .store(in: &cancellables)
    }
    
    private func setupSearchComponentBindings() {
        // Connect SearchView's text changes to our search logic with debouncing
        searchComponentViewModel.textPublisher
            .debounce(for: .milliseconds(500), scheduler: DispatchQueue.main)
            .sink { [weak self] text in
                self?.updateSearchText(text)
            }
            .store(in: &cancellables)
        
        // Connect SearchView's clear action to our clear logic
        searchComponentViewModel.textPublisher
            .filter { $0.isEmpty }
            .sink { [weak self] _ in
                self?.clearSearch()
            }
            .store(in: &cancellables)

        // Focus changes observed at the controller level
    }
    
    private func setupMarketGroupBindings() {
        // Listen to market group selection changes from selector ViewModel
        marketGroupSelectorViewModel.selectionEventPublisher
            .sink { [weak self] selectionEvent in
                self?.selectedMarketGroupId = selectionEvent.selectedId
            }
            .store(in: &cancellables)
        
        // Listen to market groups updates from selector ViewModel
        marketGroupSelectorViewModel.marketGroupsPublisher
            .sink { [weak self] marketGroups in
                self?.updateMarketGroupViewModels(marketGroups: marketGroups)
            }
            .store(in: &cancellables)
    }
    
    private func getRecommendedMatches() {
        isLoadingSubject.send(true)
        
        let userId = userSessionStore.userProfilePublisher.value?.userIdentifier ?? ""
        
        Env.servicesProvider.getRecommendedMatch(userId: userId, isLive: false)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { [weak self] completion in
                if case .failure(let error) = completion {
                    print("RECOMMENDED ERROR: \(error)")
                    self?.isLoadingSubject.send(false)
                }
            }, receiveValue: { [weak self] events in
                guard let self = self else { return }
                // Step 1: Event -> Match
                let matches = ServiceProviderModelMapper.matches(fromEvents: events)
                // Step 2: Match -> TallOddsMatchData -> MockTallOddsMatchCardViewModel
                let items: [TallOddsMatchCardViewModelProtocol] = matches.map { match in
//                    let header = MatchHeaderData(
//                        id: match.id,
//                        competitionName: match.competitionName,
//                        matchTime: match.matchTime ?? "",
//                        isLive: match.status.isLive
//                    )
//                    let marketInfo = MarketInfoData(
//                        marketName: match.markets.first?.name ?? "",
//                        marketCount: match.markets.count,
//                        icons: []
//                    )
//                    let tallData = TallOddsMatchData(
//                        matchId: match.id,
//                        leagueInfo: header,
//                        homeParticipantName: match.homeParticipant.name,
//                        awayParticipantName: match.awayParticipant.name,
//                        marketInfo: marketInfo,
//                        outcomes: MarketGroupData(id: match.id, marketLines: [])
//                    )
                    let tallOddsMatchCardViewModel = TallOddsMatchCardViewModel.create(from: match, relevantMarkets: match.markets, marketTypeId: match.markets.first?.typeId ?? "", matchCardContext: .search)
                    return tallOddsMatchCardViewModel
                }
                self.recommendedItemsSubject.send(items)
                print("RECOMMENDED EVENTS STORED: \(events.map { $0.id })")
                self.isLoadingSubject.send(false)
            })
            .store(in: &cancellables)
    }
    
    private func performSearch(_ searchText: String) {
        guard !searchText.isEmpty else {
            searchResultsSubject.send(0)
            return
        }
                
        isLoadingSubject.send(true)
        updateSearchResultsState(isLoading: true, results: 0)
        
        Env.servicesProvider.getMultiSearchEvents(query: searchText, resultLimit: "5", page: "0")
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { [weak self] completion in
                switch completion {
                case .finished:
                    ()
                case .failure(let error):
                    print("SEARCH ERROR: \(error)")
                    self?.searchResultsSubject.send(0)
                    self?.updateSearchResultsState(isLoading: false, results: 0)
                }
                
                self?.isLoadingSubject.send(false)
            }, receiveValue: { [weak self] eventsGroup in
                // Map eventsGroup to matches and mainMarkets using ServiceProviderModelMapper
                let matches = ServiceProviderModelMapper.matches(fromEventsGroups: [eventsGroup])
                let mainMarkets = ServiceProviderModelMapper.mainMarkets(fromEventsGroups: [eventsGroup])
                self?.allMatches = matches
                self?.mainMarkets = mainMarkets
                // Update market group selector
                self?.marketGroupSelectorViewModel.updateWithMatches(matches, mainMarkets: mainMarkets)
                
                for (marketTypeName, viewModel) in self?.marketGroupCardsViewModels ?? [:] {
                    print("Updating matches for \(marketTypeName)")
                    viewModel.updateMatches(matches)
                }
                
                self?.searchResultsSubject.send(matches.count)
                self?.updateSearchResultsState(isLoading: false, results: matches.count)
                self?.addRecentSearch(searchText)
            })
            .store(in: &cancellables)
    }
    
    private func updateSearchResultsState(isLoading: Bool, results: Int) {
        
        // Get current search text from the view model
        let searchText = currentSearchText
        
        // Determine state based on loading status and results
        let state: SearchState
        if isLoading {
            state = .loading
        } else if results == 0 {
            state = .noResults
        } else {
            state = .results
        }
        
        let count = results > 0 ? results : nil
        
        // Update the view model with new data
        searchHeaderInfoViewModel.updateSearch(
            term: searchText,
            category: "Sports",
            state: state,
            count: count
        )
        
    }
    
    // MARK: - Market Group Helpers (mirroring NextUpEventsViewModel)
    func selectMarketGroup(id: String) {
        marketGroupSelectorViewModel.selectMarketGroup(id: id)
    }
    
    func getMarketGroupCardsViewModel(for marketGroupId: String) -> MarketGroupCardsViewModel? {
        return marketGroupCardsViewModels[marketGroupId]
    }
    
    func getAllMarketGroupCardsViewModels() -> [String: MarketGroupCardsViewModel] {
        return marketGroupCardsViewModels
    }
    
    func getCurrentMarketGroups() -> [MarketGroupTabItemData] {
        return marketGroupSelectorViewModel.currentMarketGroups
    }
    
    func getCurrentSelectedMarketGroupId() -> String? {
        return marketGroupSelectorViewModel.currentSelectedMarketGroupId
    }
    
    private func updateMarketGroupViewModels(marketGroups: [MarketGroupTabItemData]) {
        // Create ViewModels for new market groups
        for marketGroup in marketGroups {
            if marketGroupCardsViewModels[marketGroup.id] == nil {
                let marketGroupCardsViewModel = MarketGroupCardsViewModel(marketTypeId: marketGroup.id, matchCardContext: .search)
                marketGroupCardsViewModel.updateMatches(allMatches)
                marketGroupCardsViewModels[marketGroup.id] = marketGroupCardsViewModel
            }
        }
        
        // Remove ViewModels for market groups that no longer exist
        let currentMarketGroupIds = Set(marketGroups.map { $0.id })
        let viewModelsToRemove = marketGroupCardsViewModels.keys.filter { !currentMarketGroupIds.contains($0) }
        for idToRemove in viewModelsToRemove {
            marketGroupCardsViewModels.removeValue(forKey: idToRemove)
        }
        
        self.marketGroups = marketGroups
    }
    
    // MARK: - Recent Searches Management
    
    private func loadRecentSearches() {
        if let recentSearchesArray = UserDefaults.standard.array(forKey: "recentSearches") as? [String] {
            recentSearchesSubject.send(recentSearchesArray)
        }
    }
    
    func addRecentSearch(_ search: String) {
        guard !search.isEmpty else { return }
        
        var recentSearches = recentSearchesSubject.value
        
        // Remove if already exists to avoid duplicates
        recentSearches.removeAll { $0 == search }
        
        // Add to beginning (most recent first)
        recentSearches.insert(search, at: 0)
        
        // Limit to 20 recent searches
        if recentSearches.count > 20 {
            recentSearches = Array(recentSearches.prefix(20))
        }
        
        // Save to UserDefaults
        UserDefaults.standard.set(recentSearches, forKey: "recentSearches")
        
        // Update publisher
        recentSearchesSubject.send(recentSearches)
    }
    
    func removeRecentSearch(_ search: String) {
        var recentSearches = recentSearchesSubject.value
        recentSearches.removeAll { $0 == search }
        
        // Save to UserDefaults
        UserDefaults.standard.set(recentSearches, forKey: "recentSearches")
        
        // Update publisher
        recentSearchesSubject.send(recentSearches)
    }
    
    func clearAllRecentSearches() {
        UserDefaults.standard.removeObject(forKey: "recentSearches")
        recentSearchesSubject.send([])
    }
}
