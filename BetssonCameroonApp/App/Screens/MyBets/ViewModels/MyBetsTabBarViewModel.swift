//
//  MyBetsTabBarViewModel.swift
//  BetssonCameroonApp
//
//  Created by Assistant on 03/09/2025.
//

import Foundation
import Combine
import GomaUI

/// Production implementation of MarketGroupSelectorTabViewModelProtocol specifically for MyBets screen.
/// Manages Sports/Virtuals tab selection with automatic state synchronization.
final class MyBetsTabBarViewModel: MarketGroupSelectorTabViewModelProtocol {
    
    // MARK: - Private Properties
    
    private let tabDataSubject: CurrentValueSubject<MarketGroupSelectorTabData, Never>
    private let selectionEventSubject = PassthroughSubject<MarketGroupSelectionEvent, Never>()
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Initialization
    
    init(selectedTabType: MyBetsTabType = .sports) {
        // Create fixed tabs for Sports and Virtuals
        let tabs = [
            MarketGroupTabItemData(
                id: MyBetsTabType.sports.rawValue,
                title: MyBetsTabType.sports.title,
                visualState: selectedTabType == .sports ? .selected : .idle,
                prefixIconTypeName: MyBetsTabType.sports.iconTypeName
            ),
            MarketGroupTabItemData(
                id: MyBetsTabType.virtuals.rawValue,
                title: MyBetsTabType.virtuals.title,
                visualState: selectedTabType == .virtuals ? .selected : .idle,
                prefixIconTypeName: MyBetsTabType.virtuals.iconTypeName
            )
        ]
        
        let tabData = MarketGroupSelectorTabData(
            id: "myBetsTabs",
            marketGroups: tabs,
            selectedMarketGroupId: selectedTabType.rawValue
        )
        
        self.tabDataSubject = CurrentValueSubject(tabData)
    }
    
    // MARK: - MarketGroupSelectorTabViewModelProtocol
    
    var marketGroupsPublisher: AnyPublisher<[MarketGroupTabItemData], Never> {
        tabDataSubject
            .map(\.marketGroups)
            .removeDuplicates()
            .eraseToAnyPublisher()
    }
    
    var selectedMarketGroupIdPublisher: AnyPublisher<String?, Never> {
        tabDataSubject
            .map(\.selectedMarketGroupId)
            .removeDuplicates()
            .eraseToAnyPublisher()
    }
    
    var selectionEventPublisher: AnyPublisher<MarketGroupSelectionEvent, Never> {
        selectionEventSubject.eraseToAnyPublisher()
    }
    
    var currentSelectedMarketGroupId: String? {
        tabDataSubject.value.selectedMarketGroupId
    }
    
    var currentMarketGroups: [MarketGroupTabItemData] {
        tabDataSubject.value.marketGroups
    }
    
    // MARK: - Actions
    
    func selectMarketGroup(id: String) {
        // Validate the ID corresponds to a MyBetsTabType
        guard MyBetsTabType(rawValue: id) != nil else {
            print("⚠️ MyBetsTabBarViewModel: Invalid tab ID: \(id)")
            return
        }
        
        let currentData = tabDataSubject.value
        let previouslySelectedId = currentData.selectedMarketGroupId
        
        // Update visual states - selected tab gets .selected, others get .idle
        let updatedTabs = currentData.marketGroups.map { tab in
            MarketGroupTabItemData(
                id: tab.id,
                title: tab.title,
                visualState: tab.id == id ? .selected : .idle,
                suffixIconTypeName: tab.suffixIconTypeName,
                badgeCount: tab.badgeCount
            )
        }
        
        let updatedData = MarketGroupSelectorTabData(
            id: currentData.id,
            marketGroups: updatedTabs,
            selectedMarketGroupId: id
        )
        
        tabDataSubject.send(updatedData)
        
        // Send selection event
        let selectionEvent = MarketGroupSelectionEvent(
            selectedId: id,
            previouslySelectedId: previouslySelectedId
        )
        selectionEventSubject.send(selectionEvent)
        
        print("🎯 MyBetsTabBarViewModel: Selected tab \(id)")
    }
    
    func updateMarketGroups(_ marketGroups: [MarketGroupTabItemData]) {
        // Not needed for MyBets - fixed set of tabs
        print("⚠️ MyBetsTabBarViewModel: updateMarketGroups not supported - tabs are fixed")
    }
    
    func addMarketGroup(_ marketGroup: MarketGroupTabItemData) {
        // Not needed for MyBets - fixed set of tabs
        print("⚠️ MyBetsTabBarViewModel: addMarketGroup not supported - tabs are fixed")
    }
    
    func removeMarketGroup(id: String) {
        // Not needed for MyBets - fixed set of tabs
        print("⚠️ MyBetsTabBarViewModel: removeMarketGroup not supported - tabs are fixed")
    }
    
    func updateMarketGroup(_ marketGroup: MarketGroupTabItemData) {
        // Not needed for MyBets - fixed set of tabs
        print("⚠️ MyBetsTabBarViewModel: updateMarketGroup not supported - tabs are fixed")
    }
    
    func clearSelection() {
        let currentData = tabDataSubject.value
        
        // Update all tabs to idle state
        let updatedTabs = currentData.marketGroups.map { tab in
            MarketGroupTabItemData(
                id: tab.id,
                title: tab.title,
                visualState: .idle,
                suffixIconTypeName: tab.suffixIconTypeName,
                badgeCount: tab.badgeCount
            )
        }
        
        let updatedData = MarketGroupSelectorTabData(
            id: currentData.id,
            marketGroups: updatedTabs,
            selectedMarketGroupId: nil
        )
        
        tabDataSubject.send(updatedData)
        print("🎯 MyBetsTabBarViewModel: Cleared selection")
    }
    
    func selectFirstAvailableMarketGroup() {
        // Always select Sports as the default
        selectMarketGroup(id: MyBetsTabType.sports.rawValue)
    }
    
    // MARK: - Public Methods for Parent ViewModel
    
    /// Update the selected tab based on the parent ViewModel's state
    func updateSelectedTab(_ tabType: MyBetsTabType) {
        selectMarketGroup(id: tabType.rawValue)
    }
}
