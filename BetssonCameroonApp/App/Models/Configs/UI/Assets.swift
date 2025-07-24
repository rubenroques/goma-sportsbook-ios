//
//  Assets.swift
//  BetssonCameroonApp
//
//  Created by Ruben Roques on 23/07/2025.
//

import Foundation

enum Assets {
    static func flagName(withCountryCode code: String) -> String {
        if code.isEmpty || code.lowercased() == "international" {
            return "country_flag_240"
        }
        return "country_flag_\(code.lowercased())"
    }
}
