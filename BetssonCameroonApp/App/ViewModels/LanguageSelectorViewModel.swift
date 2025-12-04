//
//  LanguageSelectorViewModel.swift
//  BetssonCameroonApp
//

import Foundation
import Combine
import GomaUI

/// ViewModel for the language selector overlay, implementing GomaUI's LanguageSelectorViewModelProtocol
final class LanguageSelectorViewModel: LanguageSelectorViewModelProtocol {

    // MARK: - Publishers

    @Published private var languages: [LanguageModel] = []
    @Published private var selectedLanguage: LanguageModel?
    private let languageChangedSubject = PassthroughSubject<LanguageModel, Never>()

    var languagesPublisher: AnyPublisher<[LanguageModel], Never> {
        $languages.eraseToAnyPublisher()
    }

    var selectedLanguagePublisher: AnyPublisher<LanguageModel?, Never> {
        $selectedLanguage.eraseToAnyPublisher()
    }

    var languageChangedPublisher: AnyPublisher<LanguageModel, Never> {
        languageChangedSubject.eraseToAnyPublisher()
    }

    // MARK: - Callbacks

    /// Called when a language is selected - for future language switching logic
    var onLanguageSelected: ((LanguageModel) -> Void)?

    // MARK: - Private Properties

    private let supportedLanguages: [LanguageModel]

    // MARK: - Initialization

    init() {
        // Define supported languages for Betsson Cameroon (EN/FR)
        // Flag images are resolved via LanguageFlagImageResolver based on language id
        // Language names are localized so they display correctly in the current app language
        self.supportedLanguages = [
            LanguageModel(
                id: "en",
                name: localized("language_english"),
                languageCode: "en",
                englishName: "English"
            ),
            LanguageModel(
                id: "fr",
                name: localized("language_french"),
                languageCode: "fr",
                englishName: "French"
            )
        ]
    }

    // MARK: - LanguageSelectorViewModelProtocol

    func selectLanguage(_ language: LanguageModel) {
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
        if language.id != LanguageManager.shared.currentLanguageCode {
            LanguageManager.shared.setLanguage(language.id)
        }
    }

    func loadLanguages() {
        let currentLanguageCode = LanguageManager.shared.currentLanguageCode

        // Set up languages with current selection
        languages = supportedLanguages.map { lang in
            lang.withSelection(lang.id == currentLanguageCode)
        }

        selectedLanguage = languages.first { $0.isSelected }
    }

    func setLanguages(_ languages: [LanguageModel]) {
        self.languages = languages
    }

    func setInitialSelection(_ language: LanguageModel) {
        selectedLanguage = language

        let updatedLanguages = languages.map { lang in
            lang.withSelection(lang.id == language.id)
        }
        languages = updatedLanguages
    }

    func getCurrentSelection() -> LanguageModel? {
        return selectedLanguage
    }
}
