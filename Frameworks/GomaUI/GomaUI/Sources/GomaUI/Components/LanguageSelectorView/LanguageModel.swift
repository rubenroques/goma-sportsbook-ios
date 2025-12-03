import Foundation

/// Data model representing a selectable language option
public struct LanguageModel: Identifiable, Equatable, Codable {

    /// Unique identifier for the language (typically language code like "en", "fr")
    public let id: String

    /// Display name of the language in its native form
    public let name: String

    /// Flag representation - deprecated, use LanguageFlagImageResolver instead
    /// Kept for backwards compatibility, will be ignored when imageResolver is provided
    @available(*, deprecated, message: "Use LanguageFlagImageResolver based on language id instead")
    public let flagIcon: String

    /// Current selection state of this language
    public let isSelected: Bool

    /// Language code for programmatic use (e.g., "en-US", "fr-FR")
    public let languageCode: String?

    /// Optional display name in English for fallback
    public let englishName: String?

    // MARK: - Initialization
    public init(
        id: String,
        name: String,
        flagIcon: String = "",
        isSelected: Bool = false,
        languageCode: String? = nil,
        englishName: String? = nil
    ) {
        self.id = id
        self.name = name
        self.flagIcon = flagIcon
        self.isSelected = isSelected
        self.languageCode = languageCode ?? id
        self.englishName = englishName
    }
    
    // MARK: - Convenience Methods
    
    /// Creates a copy of this language model with updated selection state
    /// - Parameter selected: New selection state
    /// - Returns: New LanguageModel instance with updated selection
    public func withSelection(_ selected: Bool) -> LanguageModel {
        LanguageModel(
            id: id,
            name: name,
            flagIcon: flagIcon,
            isSelected: selected,
            languageCode: languageCode,
            englishName: englishName
        )
    }
    
    /// Display name to show in UI, with fallback to English name if available
    public var displayName: String {
        return name.isEmpty ? (englishName ?? id) : name
    }
}

// MARK: - Predefined Languages
extension LanguageModel {

    /// English language model
    public static let english = LanguageModel(
        id: "en",
        name: "English",
        languageCode: "en-US",
        englishName: "English"
    )

    /// French language model
    public static let french = LanguageModel(
        id: "fr",
        name: "Français",
        languageCode: "fr-FR",
        englishName: "French"
    )

    /// Spanish language model
    public static let spanish = LanguageModel(
        id: "es",
        name: "Español",
        languageCode: "es-ES",
        englishName: "Spanish"
    )

    /// German language model
    public static let german = LanguageModel(
        id: "de",
        name: "Deutsch",
        languageCode: "de-DE",
        englishName: "German"
    )

    /// Italian language model
    public static let italian = LanguageModel(
        id: "it",
        name: "Italiano",
        languageCode: "it-IT",
        englishName: "Italian"
    )

    /// Portuguese language model
    public static let portuguese = LanguageModel(
        id: "pt",
        name: "Português",
        languageCode: "pt-PT",
        englishName: "Portuguese"
    )

    /// Common languages collection
    public static let commonLanguages: [LanguageModel] = [
        .english,
        .french,
        .spanish,
        .german,
        .italian,
        .portuguese
    ]
}
