//
//  MyBetsStatusBarViewModel.swift
//  BetssonCameroonApp
//
//  Created on 03/09/2025.
//

import Foundation
import Combine
import GomaUI

/// Production implementation of PillSelectorBarViewModelProtocol specifically for MyBets screen.
/// Manages status filter pills (Open/CashOut/Won/Settled) with automatic state synchronization.
final class MyBetsStatusBarViewModel: PillSelectorBarViewModelProtocol {
    
    // MARK: - Private Properties
    
    private let displayStateSubject: CurrentValueSubject<PillSelectorBarDisplayState, Never>
    private let selectionEventSubject = PassthroughSubject<PillSelectionEvent, Never>()
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Initialization
    
    init(selectedStatusType: MyBetStatusType = .open) {
        // Create fixed pills for all status types
        let pills = MyBetStatusType.allCases.map { statusType in
            PillData(
                id: statusType.pillId,
                title: statusType.title,
                leftIconName: nil,
                showExpandIcon: false,
                isSelected: statusType == selectedStatusType
            )
        }
        
        let barData = PillSelectorBarData(
            id: "myBetsStatusBar",
            pills: pills,
            selectedPillId: selectedStatusType.pillId,
            isScrollEnabled: true,
            allowsVisualStateChanges: true
        )
        
        let displayState = PillSelectorBarDisplayState(
            barData: barData,
            isVisible: true,
            isUserInteractionEnabled: true
        )
        
        self.displayStateSubject = CurrentValueSubject(displayState)
    }
    
    // MARK: - PillSelectorBarViewModelProtocol
    
    var displayStatePublisher: AnyPublisher<PillSelectorBarDisplayState, Never> {
        displayStateSubject.eraseToAnyPublisher()
    }
    
    var selectionEventPublisher: AnyPublisher<PillSelectionEvent, Never> {
        selectionEventSubject.eraseToAnyPublisher()
    }
    
    var currentSelectedPillId: String? {
        displayStateSubject.value.barData.selectedPillId
    }
    
    var currentPills: [PillData] {
        displayStateSubject.value.barData.pills
    }
    
    // MARK: - Actions
    
    func selectPill(id: String) {
        // Validate the ID corresponds to a MyBetStatusType
        guard MyBetStatusType(rawValue: id) != nil else {
            print("⚠️ MyBetsStatusBarViewModel: Invalid status ID: \(id)")
            return
        }
        
        let currentState = displayStateSubject.value
        let currentBarData = currentState.barData
        let previouslySelectedId = currentBarData.selectedPillId
        
        // Update pill selection states
        let updatedPills = currentBarData.pills.map { pill in
            PillData(
                id: pill.id,
                title: pill.title,
                leftIconName: pill.leftIconName,
                showExpandIcon: pill.showExpandIcon,
                isSelected: pill.id == id
            )
        }
        
        let updatedBarData = PillSelectorBarData(
            id: currentBarData.id,
            pills: updatedPills,
            selectedPillId: id,
            isScrollEnabled: currentBarData.isScrollEnabled,
            allowsVisualStateChanges: currentBarData.allowsVisualStateChanges
        )
        
        let updatedDisplayState = PillSelectorBarDisplayState(
            barData: updatedBarData,
            isVisible: currentState.isVisible,
            isUserInteractionEnabled: currentState.isUserInteractionEnabled
        )
        
        displayStateSubject.send(updatedDisplayState)
        
        // Send selection event
        let selectionEvent = PillSelectionEvent(
            selectedId: id,
            previouslySelectedId: previouslySelectedId
        )
        selectionEventSubject.send(selectionEvent)
        
        print("🎯 MyBetsStatusBarViewModel: Selected status \(id)")
    }
    
    func updatePills(_ pills: [PillData]) {
        // Not needed for MyBets - fixed set of status pills
    }
    
    func addPill(_ pill: PillData) {
        // Not needed for MyBets - fixed set of status pills
    }
    
    func removePill(id: String) {
        // Not needed for MyBets - fixed set of status pills
    }
    
    func updatePill(_ pill: PillData) {
        // Not needed for MyBets - fixed set of status pills
    }
    
    func clearSelection() {
        let currentState = displayStateSubject.value
        let currentBarData = currentState.barData
        
        // Update all pills to unselected state
        let updatedPills = currentBarData.pills.map { pill in
            PillData(
                id: pill.id,
                title: pill.title,
                leftIconName: pill.leftIconName,
                showExpandIcon: pill.showExpandIcon,
                isSelected: false
            )
        }
        
        let updatedBarData = PillSelectorBarData(
            id: currentBarData.id,
            pills: updatedPills,
            selectedPillId: nil,
            isScrollEnabled: currentBarData.isScrollEnabled,
            allowsVisualStateChanges: currentBarData.allowsVisualStateChanges
        )
        
        let updatedDisplayState = PillSelectorBarDisplayState(
            barData: updatedBarData,
            isVisible: currentState.isVisible,
            isUserInteractionEnabled: currentState.isUserInteractionEnabled
        )
        
        displayStateSubject.send(updatedDisplayState)
        print("🎯 MyBetsStatusBarViewModel: Cleared selection")
    }
    
    func selectFirstAvailablePill() {
        // Always select "Open" as the default
        selectPill(id: MyBetStatusType.open.pillId)
    }
    
    func setVisible(_ visible: Bool) {
        let currentState = displayStateSubject.value
        let updatedDisplayState = PillSelectorBarDisplayState(
            barData: currentState.barData,
            isVisible: visible,
            isUserInteractionEnabled: currentState.isUserInteractionEnabled
        )
        displayStateSubject.send(updatedDisplayState)
    }
    
    func setUserInteractionEnabled(_ enabled: Bool) {
        let currentState = displayStateSubject.value
        let updatedDisplayState = PillSelectorBarDisplayState(
            barData: currentState.barData,
            isVisible: currentState.isVisible,
            isUserInteractionEnabled: enabled
        )
        displayStateSubject.send(updatedDisplayState)
    }
    
    // MARK: - Public Methods for Parent ViewModel

    /// Update the selected status based on the parent ViewModel's state
    func updateSelectedStatus(_ statusType: MyBetStatusType) {
        selectPill(id: statusType.pillId)
    }
}
