//
//  LocalizationProvider.swift
//  GomaUI
//
//  Created by Claude Code on 07/11/2025.
//

import Foundation

/// Provides localization for GomaUI's internal UI strings (buttons, placeholders, error messages).
/// Apps configure this at startup to integrate with their localization system.
///
/// **Usage in App:**
/// ```swift
/// // In AppDelegate or app initialization
/// LocalizationProvider.configure { key in
///     return localized(key)  // Your app's localization function
/// }
/// ```
///
/// **Usage in GomaUI Components:**
/// ```swift
/// // For hardcoded UI strings only
/// button.setTitle(LocalizationProvider.string("ok_button"), for: .normal)
/// label.text = LocalizationProvider.string("empty_state_message")
/// ```
///
/// **Important:** This is for GomaUI's internal UI strings only.
/// Content strings (like tab titles, user data) should be localized by the app
/// before passing to GomaUI components.
public final class LocalizationProvider {

    // MARK: - Private Properties

    /// The localization function provided by the app
    private static var localizer: ((String) -> String) = { key in
        return key  // Default: return key as-is (for standalone usage)
    }

    // MARK: - Public API

    /// Configure the localization function for GomaUI.
    /// Call this once at app startup.
    ///
    /// - Parameter localizer: A closure that takes a localization key and returns the localized string
    ///
    /// **Example:**
    /// ```swift
    /// LocalizationProvider.configure { key in
    ///     return NSLocalizedString(key, comment: "")
    /// }
    /// ```
    public static func configure(localizer: @escaping (String) -> String) {
        self.localizer = localizer
    }

    /// Localize a string key using the configured localizer.
    /// Used internally by GomaUI components for UI strings.
    ///
    /// - Parameter key: The localization key
    /// - Returns: The localized string, or the key itself if no localizer is configured
    public static func string(_ key: String) -> String {
        return localizer(key)
    }

    /// Reset to default (returns keys as-is).
    /// Useful for testing.
    public static func reset() {
        localizer = { key in key }
    }
}
