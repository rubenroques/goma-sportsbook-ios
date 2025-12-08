//
//  MockLanguageSelectorFullScreenViewModel.swift
//  GomaPlatform
//

import Foundation
import Combine
import GomaUI

/// Mock ViewModel for previews and testing
public final class MockLanguageSelectorFullScreenViewModel: LanguageSelectorFullScreenViewModelProtocol {

    // MARK: - Publishers
    private let displayStateSubject: CurrentValueSubject<LanguageSelectorFullScreenDisplayState, Never>

    public var displayStatePublisher: AnyPublisher<LanguageSelectorFullScreenDisplayState, Never> {
        displayStateSubject.eraseToAnyPublisher()
    }

    public var currentDisplayState: LanguageSelectorFullScreenDisplayState {
        displayStateSubject.value
    }

    // MARK: - Language Selector ViewModel

    public let languageSelectorViewModel: LanguageSelectorViewModelProtocol

    // MARK: - Initialization

    public init(
        displayState: LanguageSelectorFullScreenDisplayState = .initial,
        languageSelectorViewModel: LanguageSelectorViewModelProtocol = MockLanguageSelectorViewModel.twoLanguagesMock
    ) {
        self.displayStateSubject = CurrentValueSubject(displayState)
        self.languageSelectorViewModel = languageSelectorViewModel
    }

    // MARK: - LanguageSelectorFullScreenViewModelProtocol

    public func didTapBack() {
        // Mock: no-op for previews
    }

    // MARK: - Static Mocks

    public static var defaultMock: MockLanguageSelectorFullScreenViewModel {
        MockLanguageSelectorFullScreenViewModel()
    }

    public static var loadingMock: MockLanguageSelectorFullScreenViewModel {
        MockLanguageSelectorFullScreenViewModel(
            displayState: LanguageSelectorFullScreenDisplayState(
                title: LocalizationProvider.string("change_language"),
                isLoading: true
            )
        )
    }
}
