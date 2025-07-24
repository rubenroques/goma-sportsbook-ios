//
//  AppearanceMode.swift
//  BetssonCameroonApp
//
//  Created by Ruben Roques on 22/07/2025.
//

import Foundation
import UIKit

enum AppearanceMode: Int, CaseIterable {
    case light
    case device
    case dark
}

extension AppearanceMode {
    var userInterfaceStyle: UIUserInterfaceStyle {
        switch self {
        case .device:
            return .unspecified
        case .light:
            return .light
        case .dark:
            return .dark
        }
    }

    var themeId: Int {
        switch self {
        case .device:
            return 3
        case .light:
            return 2
        case .dark:
            return 1
        }
    }

    var isDarkMode: Bool {
        if UIScreen.main.traitCollection.userInterfaceStyle == .dark {
            return true
        }
        else {
            return false
        }
    }
}

extension AppearanceMode {
    
    var title: String {
        switch self {
        case .light: return localized("theme_short_light")
        case .device: return localized("theme_short_system")
        case .dark: return localized("theme_short_dark")
        }
    }
    
    var iconName: String {
        switch self {
        case .light: return "light_theme_icon"
        case .device: return "system_theme_icon"
        case .dark: return "dark_theme_icon"
        }
    }
}
