//
//  TransactionTypePillSelectorViewModel.swift
//  BetssonCameroonApp
//
//  Created by Claude on 25/01/2025.
//

import Foundation
import Combine
import GomaUI

final class TransactionTypePillSelectorViewModel: PillSelectorBarViewModelProtocol {

    // MARK: - Published Properties

    @Published private var displayState: PillSelectorBarDisplayState

    // MARK: - Publishers

    var displayStatePublisher: AnyPublisher<PillSelectorBarDisplayState, Never> {
        $displayState.eraseToAnyPublisher()
    }

    private let selectionEventSubject = PassthroughSubject<PillSelectionEvent, Never>()
    var selectionEventPublisher: AnyPublisher<PillSelectionEvent, Never> {
        selectionEventSubject.eraseToAnyPublisher()
    }

    // MARK: - Properties

    var currentSelectedPillId: String? {
        displayState.barData.selectedPillId
    }

    var currentPills: [PillData] {
        displayState.barData.pills
    }

    // MARK: - Initialization

    init() {
        let pills = TransactionCategory.allCases.map { category in
            PillData(
                id: category.rawValue,
                title: category.displayName,
                isSelected: category == .all
            )
        }

        let barData = PillSelectorBarData(
            id: "transaction-type-selector",
            pills: pills,
            selectedPillId: TransactionCategory.all.rawValue,
            isScrollEnabled: false,
            allowsVisualStateChanges: true
        )

        self.displayState = PillSelectorBarDisplayState(
            barData: barData,
            isVisible: true,
            isUserInteractionEnabled: true
        )
    }

    // MARK: - Actions

    func selectPill(id: String) {
        let previouslySelectedId = currentSelectedPillId

        // Update pills with new selection
        let updatedPills = currentPills.map { pill in
            PillData(
                id: pill.id,
                title: pill.title,
                leftIconName: pill.leftIconName,
                showExpandIcon: pill.showExpandIcon,
                isSelected: pill.id == id
            )
        }

        let updatedBarData = PillSelectorBarData(
            id: displayState.barData.id,
            pills: updatedPills,
            selectedPillId: id,
            isScrollEnabled: displayState.barData.isScrollEnabled,
            allowsVisualStateChanges: displayState.barData.allowsVisualStateChanges
        )

        displayState = PillSelectorBarDisplayState(
            barData: updatedBarData,
            isVisible: displayState.isVisible,
            isUserInteractionEnabled: displayState.isUserInteractionEnabled
        )

        // Emit selection event
        let selectionEvent = PillSelectionEvent(
            selectedId: id,
            previouslySelectedId: previouslySelectedId
        )
        selectionEventSubject.send(selectionEvent)
    }

    func updatePills(_ pills: [PillData]) {
        let updatedBarData = PillSelectorBarData(
            id: displayState.barData.id,
            pills: pills,
            selectedPillId: displayState.barData.selectedPillId,
            isScrollEnabled: displayState.barData.isScrollEnabled,
            allowsVisualStateChanges: displayState.barData.allowsVisualStateChanges
        )

        displayState = PillSelectorBarDisplayState(
            barData: updatedBarData,
            isVisible: displayState.isVisible,
            isUserInteractionEnabled: displayState.isUserInteractionEnabled
        )
    }

    func addPill(_ pill: PillData) {
        var updatedPills = currentPills
        updatedPills.append(pill)
        updatePills(updatedPills)
    }

    func removePill(id: String) {
        let updatedPills = currentPills.filter { $0.id != id }
        updatePills(updatedPills)
    }

    func updatePill(_ pill: PillData) {
        let updatedPills = currentPills.map { currentPill in
            currentPill.id == pill.id ? pill : currentPill
        }
        updatePills(updatedPills)
    }

    func clearSelection() {
        let updatedPills = currentPills.map { pill in
            PillData(
                id: pill.id,
                title: pill.title,
                leftIconName: pill.leftIconName,
                showExpandIcon: pill.showExpandIcon,
                isSelected: false
            )
        }

        let updatedBarData = PillSelectorBarData(
            id: displayState.barData.id,
            pills: updatedPills,
            selectedPillId: nil,
            isScrollEnabled: displayState.barData.isScrollEnabled,
            allowsVisualStateChanges: displayState.barData.allowsVisualStateChanges
        )

        displayState = PillSelectorBarDisplayState(
            barData: updatedBarData,
            isVisible: displayState.isVisible,
            isUserInteractionEnabled: displayState.isUserInteractionEnabled
        )
    }

    func selectFirstAvailablePill() {
        guard let firstPill = currentPills.first else { return }
        selectPill(id: firstPill.id)
    }

    func setVisible(_ visible: Bool) {
        displayState = PillSelectorBarDisplayState(
            barData: displayState.barData,
            isVisible: visible,
            isUserInteractionEnabled: displayState.isUserInteractionEnabled
        )
    }

    func setUserInteractionEnabled(_ enabled: Bool) {
        displayState = PillSelectorBarDisplayState(
            barData: displayState.barData,
            isVisible: displayState.isVisible,
            isUserInteractionEnabled: enabled
        )
    }
}