//
//  SportsbookSupportedLanguage.swift
//  BetssonCameroonApp
//
//  Created by Ruben Roques on 23/07/2025.
//

import Foundation

enum SportsbookSupportedLanguage: String, CaseIterable {
    case english = "en"
    case french = "fr"

    var languageCode: String {
        return self.rawValue
    }
}
