//
//  Localization.swift
//
//  Created by Ruben Roques on 30/06/2021.
//

import Foundation
import PhraseSDK

func localized(_ string: String) -> String {
    // 1. Try Phrase OTA translation first (uses localeOverride setting)
    let phraseValue = Phrase.shared.localizedString(forKey: string, value: nil, table: nil)
    if phraseValue != string {
        return phraseValue
    }

    // 2. Fallback: Use local .lproj bundle for selected language
    let languageCode = LanguageManager.shared.currentLanguageCode
    if let path = Bundle.main.path(forResource: languageCode, ofType: "lproj"),
       let bundle = Bundle(path: path) {
        return NSLocalizedString(string, bundle: bundle, comment: "")
    }

    // 3. Final fallback: main bundle (system language)
    return NSLocalizedString(string, bundle: Bundle.main, comment: "")
}
