//
//  LanguageSelectorFullScreenViewModel.swift
//  GomaPlatform
//

import Foundation
import Combine
import GomaUI

/// Production ViewModel for the full-screen language selector
public final class LanguageSelectorFullScreenViewModel: LanguageSelectorFullScreenViewModelProtocol {

    // MARK: - Publishers

    private let displayStateSubject: CurrentValueSubject<LanguageSelectorFullScreenDisplayState, Never>

    public var displayStatePublisher: AnyPublisher<LanguageSelectorFullScreenDisplayState, Never> {
        displayStateSubject.eraseToAnyPublisher()
    }

    public var currentDisplayState: LanguageSelectorFullScreenDisplayState {
        displayStateSubject.value
    }

    // MARK: - Language Selector ViewModel

    public private(set) var languageSelectorViewModel: LanguageSelectorViewModelProtocol

    // MARK: - Callbacks

    /// Called when the user wants to dismiss the screen
    public var onDismiss: (() -> Void)?

    /// Called when a language is selected (for future language switching logic)
    public var onLanguageSelected: ((LanguageModel) -> Void)?

    // MARK: - Private Properties

    private var cancellables = Set<AnyCancellable>()

    // MARK: - Initialization

    /// Creates a LanguageSelectorFullScreenViewModel with an injected language selector ViewModel.
    /// - Parameter languageSelectorViewModel: The language selector ViewModel (implements LanguageSelectorViewModelProtocol)
    public init(languageSelectorViewModel: LanguageSelectorViewModelProtocol) {
        self.displayStateSubject = CurrentValueSubject(.initial)
        self.languageSelectorViewModel = languageSelectorViewModel

        setupBindings()
    }

    // MARK: - Private Methods

    private func setupBindings() {
        // Forward language selection to callback via protocol (no downcasting needed)
        languageSelectorViewModel.onLanguageSelected = { [weak self] language in
            self?.onLanguageSelected?(language)
        }
    }

    // MARK: - LanguageSelectorFullScreenViewModelProtocol

    public func didTapBack() {
        onDismiss?()
    }
}
