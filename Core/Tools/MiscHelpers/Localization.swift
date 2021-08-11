//
//  Localization.swift
//  Betto
//
//  Created by Ruben Roques on 30/06/2021.
//

import Foundation

func localized(_ string: String) -> String {
    return NSLocalizedString(string, bundle: Bundle.main, comment: "")
}
