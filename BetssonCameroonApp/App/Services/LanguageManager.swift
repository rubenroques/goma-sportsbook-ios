//
//  LanguageManager.swift
//  BetssonCameroonApp
//

import Foundation

/// Manages app language preference and triggers language change events
final class LanguageManager {

    // MARK: - Singleton

    // TODO: Remove this SINGLETON messy logic ASAP
    static let shared = LanguageManager()

    // MARK: - Constants

    private let userDefaultsKey = "app_selected_language"

    // MARK: - Initialization

    private init() {}

    // MARK: - Public Properties

    /// Current language code (checks user override first, then falls back to system language)
    var currentLanguageCode: String {
        if let override = UserDefaults.standard.string(forKey: userDefaultsKey) {
            return override
        }
        // Fall back to system language from bundle's preferred localizations
        // This respects the order in CFBundleDevelopmentRegion and available .lproj folders
        return Bundle.main.preferredLocalizations.first ?? "en"
    }

    /// Whether user has explicitly set a language preference
    var hasUserOverride: Bool {
        UserDefaults.standard.string(forKey: userDefaultsKey) != nil
    }

    /// Returns the locale string for Phrase SDK (e.g., "en-US", "fr-FR")
    var phraseLocaleString: String {
        switch currentLanguageCode {
        case "fr":
            return "fr-FR"
        default:
            return "en-US"
        }
    }

    // MARK: - Public Methods

    /// Set language preference and trigger app restart
    /// - Parameter languageCode: The language code to set (e.g., "en", "fr")
    func setLanguage(_ languageCode: String) {
        // Only proceed if language is actually changing
        guard languageCode != currentLanguageCode else {
            return
        }

        UserDefaults.standard.set(languageCode, forKey: userDefaultsKey)
        UserDefaults.standard.synchronize()

        // Post notification for app restart
        NotificationCenter.default.post(name: .languageDidChange, object: languageCode)
    }

    /// Clear user override and return to system language
    func clearOverride() {
        UserDefaults.standard.removeObject(forKey: userDefaultsKey)
        UserDefaults.standard.synchronize()
    }
}

// MARK: - Notification Names

extension Notification.Name {
    /// Posted when the user selects a different language. Object contains the new language code string.
    static let languageDidChange = Notification.Name("app.languageDidChange")
}

// MARK: - GomaPlatform Protocol Conformance

import GomaPlatform

extension LanguageManager: LanguageManagerProtocol {
    // Already implements required properties and methods:
    // - currentLanguageCode: String { get }
    // - setLanguage(_ languageCode: String)
}
