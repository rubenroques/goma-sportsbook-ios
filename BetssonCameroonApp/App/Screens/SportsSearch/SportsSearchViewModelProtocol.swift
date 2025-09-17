//
//  SportsSearchViewModelProtocol.swift
//  BetssonCameroonApp
//
//  Created by Andre on 27/01/2025.
//

import Foundation
import Combine
import GomaUI
import ServicesProvider

protocol SportsSearchViewModelProtocol: AnyObject {
    
    // MARK: - Publishers
    var searchTextPublisher: AnyPublisher<String, Never> { get }
    var isLoadingPublisher: AnyPublisher<Bool, Never> { get }
    var searchResultsPublisher: AnyPublisher<Int, Never> { get }

    // Matches and Market Groups state
    var allMatchesPublisher: AnyPublisher<[Match], Never> { get }
    var marketGroupsPublisher: AnyPublisher<[MarketGroupTabItemData], Never> { get }
    var selectedMarketGroupIdPublisher: AnyPublisher<String?, Never> { get }
    var mainMarketsPublisher: AnyPublisher<[MainMarket]?, Never> { get }
    
    // MARK: - Current State Properties
    var currentSearchText: String { get }
    var isLoading: Bool { get }
    
    // MARK: - Component View Models
    var searchViewModel: SearchViewModelProtocol { get }
    var searchHeaderInfoViewModel: SearchHeaderInfoViewModelProtocol { get }
    var marketGroupSelectorViewModel: MarketGroupSelectorTabViewModel { get }
    
    // MARK: - Market Group Helpers
    func selectMarketGroup(id: String)
    func getMarketGroupCardsViewModel(for marketGroupId: String) -> MarketGroupCardsViewModel?
    func getAllMarketGroupCardsViewModels() -> [String: MarketGroupCardsViewModel]
    func getCurrentMarketGroups() -> [MarketGroupTabItemData]
    func getCurrentSelectedMarketGroupId() -> String?
    
    // MARK: - Actions
    var onSearchSubmitted: AnyPublisher<String, Never> { get }
    
    // MARK: - Input Methods
    func updateSearchText(_ text: String)
    func submitSearch()
    func clearSearch()
}

// MARK: - Search Result Model
struct SearchResult: Equatable, Hashable {
    let id: String
    let title: String
    let subtitle: String?
    let type: SearchResultType
    let imageUrl: String?
    
    enum SearchResultType: String, CaseIterable {
        case sport = "sport"
        case league = "league"
        case team = "team"
        case match = "match"
    }
}
