//
//  LanguageFlagImageResolver.swift
//  GomaUI
//

import UIKit

/// Protocol for resolving flag images for language codes
/// Apps implement this to provide their own flag assets based on language ID
public protocol LanguageFlagImageResolver {
    /// Returns the flag image for a given language ID
    /// - Parameter languageId: The language identifier (e.g., "en", "fr")
    /// - Returns: The flag UIImage, or nil if not found
    func flagImage(for languageId: String) -> UIImage?
}

/// Default implementation that returns nil (no flags)
/// Apps should provide their own resolver with actual flag assets
public struct DefaultLanguageFlagImageResolver: LanguageFlagImageResolver {
    public init() {}

    public func flagImage(for languageId: String) -> UIImage? {
        // Default: return nil, fallback to globe icon will be used
        return nil
    }
}
