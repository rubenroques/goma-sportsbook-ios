//
//  Colors.swift
//  Sportsbook
//
//  Created by Ruben Roques on 29/07/2021.
//

import UIKit
import Combine

// MARK: - Migrated to Dynamic Theming System
// This file now serves as a compatibility layer to the dynamic theming system.
// New color additions should be made via the theming system in Core/Constants/Theme.
//
// To add a new color:
// 1. Define it in Figma design tokens
// 2. Run the Python generation script
// 3. The color will be automatically available via UIColor.App.newColorName

// Re-expose the UIColor.App extension from Core/Constants/Theme/Generated/ColorExtension.swift
extension UIColor {
    // This struct is actually defined in ColorExtension.swift
    // Keep this empty struct so the compiler can find the real one
    struct App { }
    
}
