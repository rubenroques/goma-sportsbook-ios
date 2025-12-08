//
//  AppSupportedLanguages.swift
//  BetssonCameroonApp
//
//  Client-specific supported languages configuration.
//

import Foundation
import GomaUI

/// Defines the languages supported by BetssonCameroon app.
/// Each client app can define their own supported languages.
enum AppSupportedLanguages {

    /// All languages supported by BetssonCameroon
    static var all: [LanguageModel] {
        [
            LanguageModel(
                id: "en",
                name: LocalizationProvider.string("language_english"),
                languageCode: "en",
                englishName: "English"
            ),
            LanguageModel(
                id: "fr",
                name: LocalizationProvider.string("language_french"),
                languageCode: "fr",
                englishName: "French"
            )
        ]
    }
}
