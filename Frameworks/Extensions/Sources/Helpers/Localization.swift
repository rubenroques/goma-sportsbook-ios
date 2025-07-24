//
//  Localization.swift
//  
//
//  Created by Ruben Roques on 16/01/2023.
//

import Foundation

public struct Localization {
    public static func localized(_ string: String) -> String {
        return NSLocalizedString(string, bundle: Bundle.main, comment: "")
    }
}
