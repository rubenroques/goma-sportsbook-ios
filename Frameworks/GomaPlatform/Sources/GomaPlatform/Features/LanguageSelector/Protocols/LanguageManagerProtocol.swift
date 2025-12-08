//
//  LanguageManagerProtocol.swift
//  GomaPlatform
//

import Foundation

/// Protocol for managing app language preference.
/// Abstracts the language management implementation to enable dependency injection
/// and platform-agnostic screen components.
public protocol LanguageManagerProtocol {

    /// Current language code (e.g., "en", "fr")
    var currentLanguageCode: String { get }

    /// Set language preference and trigger app language change.
    /// - Parameter languageCode: The language code to set (e.g., "en", "fr")
    func setLanguage(_ languageCode: String)
}
