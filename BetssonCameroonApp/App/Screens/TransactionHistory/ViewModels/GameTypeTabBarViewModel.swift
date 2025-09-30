//
//  GameTypeTabBarViewModel.swift
//  BetssonCameroonApp
//
//  Created by Game Type Sub-Filter Feature on 30/09/2025.
//

import Foundation
import Combine
import GomaUI

/// Production implementation of MarketGroupSelectorTabViewModelProtocol for Transaction History game type filtering.
/// Manages All/Sportsbook/Casino tab selection for games category.
/// Based on MyBetsTabBarViewModel pattern.
final class GameTypeTabBarViewModel: MarketGroupSelectorTabViewModelProtocol {

    // MARK: - Private Properties

    private let tabDataSubject: CurrentValueSubject<MarketGroupSelectorTabData, Never>
    private let selectionEventSubject = PassthroughSubject<MarketGroupSelectionEvent, Never>()
    private var cancellables = Set<AnyCancellable>()

    // MARK: - Initialization

    init(selectedGameType: GameTransactionType = .all) {
        // Create fixed tabs for All, Sportsbook, and Casino
        let tabs = [
            MarketGroupTabItemData(
                id: GameTransactionType.all.rawValue,
                title: GameTransactionType.all.displayName,
                visualState: selectedGameType == .all ? .selected : .idle,
                prefixIconTypeName: nil,  // No icons for game type tabs
                suffixIconTypeName: nil,
                badgeCount: nil
            ),
            MarketGroupTabItemData(
                id: GameTransactionType.sportsbook.rawValue,
                title: GameTransactionType.sportsbook.displayName,
                visualState: selectedGameType == .sportsbook ? .selected : .idle,
                prefixIconTypeName: nil,
                suffixIconTypeName: nil,
                badgeCount: nil
            ),
            MarketGroupTabItemData(
                id: GameTransactionType.casino.rawValue,
                title: GameTransactionType.casino.displayName,
                visualState: selectedGameType == .casino ? .selected : .idle,
                prefixIconTypeName: nil,
                suffixIconTypeName: nil,
                badgeCount: nil
            )
        ]

        let tabData = MarketGroupSelectorTabData(
            id: "gameTypeTabs",
            marketGroups: tabs,
            selectedMarketGroupId: selectedGameType.rawValue
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
        // Validate the ID corresponds to a GameTransactionType
        guard GameTransactionType(rawValue: id) != nil else {
            print("⚠️ GameTypeTabBarViewModel: Invalid game type ID: \(id)")
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
                prefixIconTypeName: tab.prefixIconTypeName,
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

        print("🎯 GameTypeTabBarViewModel: Selected game type \(id)")
    }

    func updateMarketGroups(_ marketGroups: [MarketGroupTabItemData]) {
        // Not needed for game types - fixed set of tabs
        print("⚠️ GameTypeTabBarViewModel: updateMarketGroups not supported - tabs are fixed")
    }

    func addMarketGroup(_ marketGroup: MarketGroupTabItemData) {
        // Not needed for game types - fixed set of tabs
        print("⚠️ GameTypeTabBarViewModel: addMarketGroup not supported - tabs are fixed")
    }

    func removeMarketGroup(id: String) {
        // Not needed for game types - fixed set of tabs
        print("⚠️ GameTypeTabBarViewModel: removeMarketGroup not supported - tabs are fixed")
    }

    func updateMarketGroup(_ marketGroup: MarketGroupTabItemData) {
        // Not needed for game types - fixed set of tabs
        print("⚠️ GameTypeTabBarViewModel: updateMarketGroup not supported - tabs are fixed")
    }

    func clearSelection() {
        let currentData = tabDataSubject.value

        // Update all tabs to idle state
        let updatedTabs = currentData.marketGroups.map { tab in
            MarketGroupTabItemData(
                id: tab.id,
                title: tab.title,
                visualState: .idle,
                prefixIconTypeName: tab.prefixIconTypeName,
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
        print("🎯 GameTypeTabBarViewModel: Cleared selection")
    }

    func selectFirstAvailableMarketGroup() {
        // Always select All as the default
        selectMarketGroup(id: GameTransactionType.all.rawValue)
    }

    // MARK: - Public Methods for Parent ViewModel

    /// Update the selected game type based on the parent ViewModel's state
    func updateSelectedGameType(_ gameType: GameTransactionType) {
        selectMarketGroup(id: gameType.rawValue)
    }
}