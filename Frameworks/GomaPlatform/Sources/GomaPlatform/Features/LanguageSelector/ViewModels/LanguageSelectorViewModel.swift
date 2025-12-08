//
//  LanguageSelectorViewModel.swift
//  GomaPlatform
//

import Foundation
import Combine
import GomaUI

/// ViewModel for the language selector overlay, implementing GomaUI's LanguageSelectorViewModelProtocol.
/// Uses dependency injection for language management to enable platform-agnostic usage.
public final class LanguageSelectorViewModel: LanguageSelectorViewModelProtocol {

    // MARK: - Publishers

    @Published private var languages: [LanguageModel] = []
    @Published private var selectedLanguage: LanguageModel?
    private let languageChangedSubject = PassthroughSubject<LanguageModel, Never>()

    public var languagesPublisher: AnyPublisher<[LanguageModel], Never> {
        $languages.eraseToAnyPublisher()
    }

    public var selectedLanguagePublisher: AnyPublisher<LanguageModel?, Never> {
        $selectedLanguage.eraseToAnyPublisher()
    }

    public var languageChangedPublisher: AnyPublisher<LanguageModel, Never> {
        languageChangedSubject.eraseToAnyPublisher()
    }

    // MARK: - Callbacks

    /// Called when a language is selected - for future language switching logic
    public var onLanguageSelected: ((LanguageModel) -> Void)?

    // MARK: - Private Properties

    private let supportedLanguages: [LanguageModel]
    private let languageManager: LanguageManagerProtocol

    // MARK: - Initialization

    /// Creates a LanguageSelectorViewModel with injected dependencies.
    /// - Parameters:
    ///   - languageManager: The language manager protocol implementation for reading/setting language
    ///   - supportedLanguages: Array of languages supported by the client app
    public init(
        languageManager: LanguageManagerProtocol,
        supportedLanguages: [LanguageModel]
    ) {
        self.languageManager = languageManager
        self.supportedLanguages = supportedLanguages
    }

    // MARK: - LanguageSelectorViewModelProtocol

    public func selectLanguage(_ language: LanguageModel) {
        // Update selection state
        let updatedLanguages = languages.map { lang in
            lang.withSelection(lang.id == language.id)
        }

        languages = updatedLanguages
        selectedLanguage = language.withSelection(true)

        // Emit change event (triggers overlay dismiss)
        languageChangedSubject.send(language)

        // Notify callback
        onLanguageSelected?(language)

        // Trigger actual language change if different from current
        // This will post a notification that triggers app restart
        if language.id != languageManager.currentLanguageCode {
            languageManager.setLanguage(language.id)
        }
    }

    public func loadLanguages() {
        let currentLanguageCode = languageManager.currentLanguageCode

        // Set up languages with current selection
        languages = supportedLanguages.map { lang in
            lang.withSelection(lang.id == currentLanguageCode)
        }

        selectedLanguage = languages.first { $0.isSelected }
    }

    public func setLanguages(_ languages: [LanguageModel]) {
        self.languages = languages
    }

    public func setInitialSelection(_ language: LanguageModel) {
        selectedLanguage = language

        let updatedLanguages = languages.map { lang in
            lang.withSelection(lang.id == language.id)
        }
        languages = updatedLanguages
    }

    public func getCurrentSelection() -> LanguageModel? {
        return selectedLanguage
    }
}
