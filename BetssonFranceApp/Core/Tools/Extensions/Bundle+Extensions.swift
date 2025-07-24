//
//  Bundle+Extensions.swift
//  Sportsbook
//
//  Created by Ruben Roques on 16/09/2021.
//

import Foundation

extension Bundle {
    var versionNumber: String? {
        return infoDictionary?["CFBundleShortVersionString"] as? String
    }
    var buildNumber: String? {
        return infoDictionary?["CFBundleVersion"] as? String
    }
}
