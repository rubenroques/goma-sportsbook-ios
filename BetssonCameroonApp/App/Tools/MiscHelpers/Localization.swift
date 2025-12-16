//
//  Localization.swift
//
//  Created by Ruben Roques on 30/06/2021.
//

import Foundation

func localized(_ string: String) -> String {
    let languageCode = LanguageManager.shared.currentLanguageCode

    // Get the bundle for the selected language
    if let path = Bundle.main.path(forResource: languageCode, ofType: "lproj"),
       let bundle = Bundle(path: path) {
        return NSLocalizedString(string, bundle: bundle, comment: "")
    }

    // Fallback to main bundle (uses system default)
    return NSLocalizedString(string, bundle: Bundle.main, comment: "")
}
