import Foundation
import Combine

/// Mock implementation of LanguageSelectorViewModelProtocol for testing and previews
public final class MockLanguageSelectorViewModel: LanguageSelectorViewModelProtocol {
    
    // MARK: - Publishers
    @Published private var languages: [LanguageModel] = []
    @Published private var selectedLanguage: LanguageModel? = nil
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
    
    // MARK: - Properties

    /// Callback closure invoked when a language is selected (protocol requirement)
    public var onLanguageSelected: ((LanguageModel) -> Void)?
    private var initialLanguages: [LanguageModel]
    
    // MARK: - Initialization
    public init(
        languages: [LanguageModel] = LanguageModel.commonLanguages,
        initialSelection: LanguageModel? = nil,
        onLanguageSelected: ((LanguageModel) -> Void)? = nil
    ) {
        self.initialLanguages = languages
        self.onLanguageSelected = onLanguageSelected

        // Set up initial state
        setupInitialState(initialSelection: initialSelection)
    }
    
    // MARK: - LanguageSelectorViewModelProtocol
    public func selectLanguage(_ language: LanguageModel) {
        print("🌐 Mock: Language selected: \(language.displayName)")
        
        // Update language list to reflect new selection
        let updatedLanguages = languages.map { lang in
            lang.withSelection(lang.id == language.id)
        }
        
        languages = updatedLanguages
        selectedLanguage = language.withSelection(true)
        
        // Emit language change
        languageChangedSubject.send(language)
        
        // Simulate language switching feedback
        switch language.id {
        case "en":
            print("🇺🇸 Mock: Interface will be displayed in English")
        case "fr":
            print("🇫🇷 Mock: L'interface sera affichée en français")
        case "es":
            print("🇪🇸 Mock: La interfaz se mostrará en español")
        case "de":
            print("🇩🇪 Mock: Die Benutzeroberfläche wird auf Deutsch angezeigt")
        case "it":
            print("🇮🇹 Mock: L'interfaccia sarà visualizzata in italiano")
        case "pt":
            print("🇵🇹 Mock: A interface será exibida em português")
        default:
            print("🌍 Mock: Interface language changed to \(language.displayName)")
        }
        
        onLanguageSelected?(language)
    }
    
    public func loadLanguages() {
        print("📚 Mock: Loading languages...")
        
        // Simulate async loading with a small delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.languages = self.initialLanguages
            print("✅ Mock: Loaded \(self.languages.count) languages")
        }
    }
    
    public func setLanguages(_ languages: [LanguageModel]) {
        self.initialLanguages = languages
        self.languages = languages
        print("📝 Mock: Updated language list with \(languages.count) languages")
    }
    
    public func setInitialSelection(_ language: LanguageModel) {
        selectedLanguage = language
        
        // Update languages to reflect selection
        let updatedLanguages = languages.map { lang in
            lang.withSelection(lang.id == language.id)
        }
        languages = updatedLanguages
        
        print("🎯 Mock: Set initial selection to \(language.displayName)")
    }
    
    public func getCurrentSelection() -> LanguageModel? {
        return selectedLanguage
    }
    
    // MARK: - Private Methods
    private func setupInitialState(initialSelection: LanguageModel?) {
        let selectionId = initialSelection?.id ?? "en" // Default to English
        
        languages = initialLanguages.map { lang in
            lang.withSelection(lang.id == selectionId)
        }
        
        selectedLanguage = languages.first { $0.isSelected }
    }
}

// MARK: - Static Factory Methods
extension MockLanguageSelectorViewModel {
    
    /// Default mock instance with common languages and English selected
    public static var defaultMock: MockLanguageSelectorViewModel {
        MockLanguageSelectorViewModel(
            languages: [
                LanguageModel.english.withSelection(true),
                LanguageModel.french,
                LanguageModel.spanish,
                LanguageModel.german
            ],
            initialSelection: LanguageModel.english
        ) { language in
            print("🎯 Default Mock: Selected \(language.displayName)")
        }
    }
    
    /// Mock with just two languages (like Figma design)
    public static var twoLanguagesMock: MockLanguageSelectorViewModel {
        MockLanguageSelectorViewModel(
            languages: [
                LanguageModel.english.withSelection(true),
                LanguageModel.french
            ],
            initialSelection: LanguageModel.english
        ) { language in
            print("🎯 Two Languages Mock: Selected \(language.displayName)")
        }
    }
    
    /// Mock with many languages for scrolling test
    public static var manyLanguagesMock: MockLanguageSelectorViewModel {
        MockLanguageSelectorViewModel(
            languages: LanguageModel.commonLanguages,
            initialSelection: LanguageModel.french
        ) { language in
            print("🎯 Many Languages Mock: Selected \(language.displayName)")
        }
    }
    
    /// Mock with French initially selected
    public static var frenchSelectedMock: MockLanguageSelectorViewModel {
        MockLanguageSelectorViewModel(
            languages: [
                LanguageModel.english,
                LanguageModel.french.withSelection(true),
                LanguageModel.spanish
            ],
            initialSelection: LanguageModel.french
        ) { language in
            print("🎯 French Selected Mock: Selected \(language.displayName)")
        }
    }
    
    /// Mock with custom callback for demo interaction
    public static func customCallbackMock(
        languages: [LanguageModel] = LanguageModel.commonLanguages,
        initialSelection: LanguageModel? = nil,
        onLanguageSelected: @escaping (LanguageModel) -> Void
    ) -> MockLanguageSelectorViewModel {
        MockLanguageSelectorViewModel(
            languages: languages,
            initialSelection: initialSelection ?? LanguageModel.english,
            onLanguageSelected: onLanguageSelected
        )
    }
    
    /// Interactive mock for demo with comprehensive feedback
    public static var interactiveMock: MockLanguageSelectorViewModel {
        MockLanguageSelectorViewModel(
            languages: [
                LanguageModel.english.withSelection(true),
                LanguageModel.french,
                LanguageModel.portuguese,
                LanguageModel.german,
                LanguageModel.italian
            ],
            initialSelection: LanguageModel.english
        ) { language in
            print("🎯 Interactive Mock: Selected \(language.displayName)")
            
            // Additional interactive feedback
            print("🔄 Mock: App language is being changed...")
            print("📱 Mock: UI will refresh with new language")
            print("💾 Mock: Language preference saved")
        }
    }
    
    /// Mock for testing empty state
    public static var emptyMock: MockLanguageSelectorViewModel {
        MockLanguageSelectorViewModel(
            languages: [],
            initialSelection: nil
        ) { language in
            print("🎯 Empty Mock: Selected \(language.displayName)")
        }
    }
    
    /// Mock for testing single language
    public static var singleLanguageMock: MockLanguageSelectorViewModel {
        MockLanguageSelectorViewModel(
            languages: [LanguageModel.english.withSelection(true)],
            initialSelection: LanguageModel.english
        ) { language in
            print("🎯 Single Language Mock: Selected \(language.displayName)")
        }
    }
}
