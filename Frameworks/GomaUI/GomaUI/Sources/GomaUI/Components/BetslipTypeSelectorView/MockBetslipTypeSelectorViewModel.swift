//
//  MockBetslipTypeSelectorViewModel.swift
//  GomaUI
//
//  Created by André Lascas on 14/08/2025.
//

import Combine
import UIKit

public final class MockBetslipTypeSelectorViewModel: BetslipTypeSelectorViewModelProtocol {
    
    // MARK: - Publishers
    private var tabsSubject = CurrentValueSubject<[BetslipTypeTabData], Never>([])
    private let selectedTabIdSubject = CurrentValueSubject<String?, Never>(nil)
    private let selectionEventSubject = PassthroughSubject<BetslipTypeSelectionEvent, Never>()
    
    public var tabsPublisher: AnyPublisher<[BetslipTypeTabData], Never> {
        tabsSubject.eraseToAnyPublisher()
    }
    
    public var selectedTabIdPublisher: AnyPublisher<String?, Never> {
        selectedTabIdSubject.eraseToAnyPublisher()
    }
    
    public var selectionEventPublisher: AnyPublisher<BetslipTypeSelectionEvent, Never> {
        selectionEventSubject.eraseToAnyPublisher()
    }
    
    // MARK: - Current State
    public var currentSelectedTabId: String? {
        selectedTabIdSubject.value
    }
    
    public var currentTabs: [BetslipTypeTabData] {
        tabsSubject.value
    }
    
    // MARK: - Initialization
    public init() {
        setupDefaultTabs()
    }
    
    // MARK: - Actions
    public func selectTab(id: String) {
        let previouslySelectedId = selectedTabIdSubject.value
        
        // Update selection
        selectedTabIdSubject.send(id)
        
        // Update tabs selection state
        var updatedTabs = tabsSubject.value
        for i in 0..<updatedTabs.count {
            updatedTabs[i].isSelected = (updatedTabs[i].id == id)
        }
        tabsSubject.send(updatedTabs)
        
        // Send selection event
        let event = BetslipTypeSelectionEvent(selectedId: id, previouslySelectedId: previouslySelectedId)
        selectionEventSubject.send(event)
    }
    
    public func updateTabs(_ tabs: [BetslipTypeTabData]) {
        tabsSubject.send(tabs)
    }
    
    public func clearSelection() {
        selectedTabIdSubject.send(nil)
        
        var updatedTabs = tabsSubject.value
        for i in 0..<updatedTabs.count {
            updatedTabs[i].isSelected = false
        }
        tabsSubject.send(updatedTabs)
    }
    
    public func selectFirstAvailableTab() {
        guard let firstTab = tabsSubject.value.first else { return }
        selectTab(id: firstTab.id)
    }
    
    // MARK: - Private Methods
    private func setupDefaultTabs() {
        let defaultTabs = [
            BetslipTypeTabData(id: "sports", title: "Sports", icon: "sport_betslip_icon", isSelected: true),
            BetslipTypeTabData(id: "virtuals", title: "Virtuals", icon: "virtual_betslip_icon", isSelected: false)
        ]
        
        tabsSubject.send(defaultTabs)
        selectedTabIdSubject.send("sports")
    }
    
    // MARK: - Mock Factory Methods
    public static func defaultMock() -> MockBetslipTypeSelectorViewModel {
        return MockBetslipTypeSelectorViewModel()
    }
    
    public static func sportsSelectedMock() -> MockBetslipTypeSelectorViewModel {
        let mock = MockBetslipTypeSelectorViewModel()
        mock.selectTab(id: "sports")
        return mock
    }
    
    public static func virtualsSelectedMock() -> MockBetslipTypeSelectorViewModel {
        let mock = MockBetslipTypeSelectorViewModel()
        mock.selectTab(id: "virtuals")
        return mock
    }
} 
