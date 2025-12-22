//
//  FilterPillViewModel.swift
//  BetssonCameroonApp
//

import Combine
import GomaUI

/// Production implementation of PillItemViewModelProtocol for the Filter button.
/// This is an action button that opens the filters screen - it never toggles selection state.
final class FilterPillViewModel: PillItemViewModelProtocol {

    // MARK: - Synchronous State Access
    var currentDisplayState: PillDisplayState {
        PillDisplayState(pillData: PillData(
            id: "filter",
            title: localized("filter"),
            leftIconName: "line.3.horizontal.decrease",
            showExpandIcon: true,
            isSelected: false,
            shouldApplyTintColor: true
        ))
    }

    var displayStatePublisher: AnyPublisher<PillDisplayState, Never> {
        Just(currentDisplayState).eraseToAnyPublisher()
    }

    // MARK: - Publishers (static, never change)
    var idPublisher: AnyPublisher<String, Never> {
        Just("filter").eraseToAnyPublisher()
    }

    var titlePublisher: AnyPublisher<String, Never> {
        Just("Filter").eraseToAnyPublisher()
    }

    var leftIconNamePublisher: AnyPublisher<String?, Never> {
        Just("line.3.horizontal.decrease").eraseToAnyPublisher()
    }

    var showExpandIconPublisher: AnyPublisher<Bool, Never> {
        Just(true).eraseToAnyPublisher()
    }

    var isSelectedPublisher: AnyPublisher<Bool, Never> {
        Just(false).eraseToAnyPublisher()
    }

    var shouldApplyTintColorPublisher: AnyPublisher<Bool, Never> {
        Just(true).eraseToAnyPublisher()
    }

    var isReadOnly: Bool { true }

    // MARK: - Actions (no-op for action button)
    func selectPill() { }
    func updateTitle(_ title: String) { }
    func updateLeftIcon(_ iconName: String?) { }
    func updateExpandIconVisibility(_ show: Bool) { }
}
