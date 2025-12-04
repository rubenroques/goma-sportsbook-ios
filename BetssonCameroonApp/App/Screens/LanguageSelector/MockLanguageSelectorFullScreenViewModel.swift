//
//  MockLanguageSelectorFullScreenViewModel.swift
//  BetssonCameroonApp
//

import Foundation
import Combine
import GomaUI

/// Mock ViewModel for previews and testing
final class MockLanguageSelectorFullScreenViewModel: LanguageSelectorFullScreenViewModelProtocol {

    // MARK: - Publishers

    private let displayStateSubject: CurrentValueSubject<LanguageSelectorFullScreenDisplayState, Never>

    var displayStatePublisher: AnyPublisher<LanguageSelectorFullScreenDisplayState, Never> {
        displayStateSubject.eraseToAnyPublisher()
    }

    var currentDisplayState: LanguageSelectorFullScreenDisplayState {
        displayStateSubject.value
    }

    // MARK: - Language Selector ViewModel

    let languageSelectorViewModel: LanguageSelectorViewModelProtocol

    // MARK: - Initialization

    init(displayState: LanguageSelectorFullScreenDisplayState = .initial,
         languageSelectorViewModel: LanguageSelectorViewModelProtocol = MockLanguageSelectorViewModel.twoLanguagesMock) {
        self.displayStateSubject = CurrentValueSubject(displayState)
        self.languageSelectorViewModel = languageSelectorViewModel
    }

    // MARK: - LanguageSelectorFullScreenViewModelProtocol

    func didTapBack() {
        // Mock: just log
    }

    // MARK: - Static Mocks

    static var defaultMock: MockLanguageSelectorFullScreenViewModel {
        MockLanguageSelectorFullScreenViewModel()
    }

    static var loadingMock: MockLanguageSelectorFullScreenViewModel {
        MockLanguageSelectorFullScreenViewModel(
            displayState: LanguageSelectorFullScreenDisplayState(
                title: localized("change_language"),
                isLoading: true
            )
        )
    }
}
