//
//  LanguageFlagImageResolver.swift
//  BetssonCameroonApp
//

import UIKit
import GomaUI

// MARK: - App Language Flag Image Resolver

struct AppLanguageFlagImageResolver: GomaUI.LanguageFlagImageResolver {

    // MARK: - Image Resolution

    func flagImage(for languageCode: String) -> UIImage? {
        let imageName: String

        switch languageCode.lowercased() {
        case "en":
            imageName = "flag_en"
        case "fr":
            imageName = "flag_fr"
        default:
            return fallbackFlagImage(for: languageCode)
        }

        return UIImage(named: imageName) ?? fallbackFlagImage(for: languageCode)
    }

    // MARK: - Fallback Images

    private func fallbackFlagImage(for languageCode: String) -> UIImage? {
        // Fallback to globe SF Symbol if flag image not found
        return UIImage(systemName: "globe")
    }
}
