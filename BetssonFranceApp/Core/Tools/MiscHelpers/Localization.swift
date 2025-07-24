//
//  Localization.swift
//  Betto
//
//  Created by Ruben Roques on 30/06/2021.
//

import Foundation

func localized(_ string: String) -> String {
    // First check if there's a client-specific override
    if let override = TargetVariables.localizationOverrides[string] {
        return override
    }
    // If no override, use the default localization
    return NSLocalizedString(string, bundle: Bundle.main, comment: "")
}
