//
//  LanguageSelectorFullScreenViewModel.swift
//  BetssonCameroonApp
//

import Foundation
import Combine
import GomaUI

/// Production ViewModel for the full-screen language selector
final class LanguageSelectorFullScreenViewModel: LanguageSelectorFullScreenViewModelProtocol {

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

    // MARK: - Callbacks

    /// Called when the user wants to dismiss the screen
    var onDismiss: (() -> Void)?

    /// Called when a language is selected (for future language switching logic)
    var onLanguageSelected: ((LanguageModel) -> Void)?

    // MARK: - Private Properties

    private var cancellables = Set<AnyCancellable>()
    private let internalLanguageSelectorVM: LanguageSelectorViewModel

    // MARK: - Initialization

    init() {
        self.displayStateSubject = CurrentValueSubject(.initial)

        // Create internal language selector VM
        let langVM = LanguageSelectorViewModel()
        self.internalLanguageSelectorVM = langVM
        self.languageSelectorViewModel = langVM

        setupBindings()
    }

    // MARK: - Private Methods

    private func setupBindings() {
        // Forward language selection to callback
        internalLanguageSelectorVM.onLanguageSelected = { [weak self] language in
            self?.onLanguageSelected?(language)
        }
    }

    // MARK: - LanguageSelectorFullScreenViewModelProtocol

    func didTapBack() {
        onDismiss?()
    }
}
