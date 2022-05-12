//
//  Theme.swift
//  Sportsbook
//
//  Created by Ruben Roques on 29/07/2021.
//

import Foundation
import UIKit

enum Theme: Int, CaseIterable {
    case device
    case light
    case dark
}

extension Theme {
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
}
