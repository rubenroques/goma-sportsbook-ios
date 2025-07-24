//
//  AppFont.swift
//  BetssonCameroonApp
//
//  Created by Ruben Roques on 22/07/2025.
//

import UIKit

struct AppFont {

    enum AppFontType: String {
        case thin
        case light
        case regular
        case medium
        case bold
        case semibold
        case heavy
        case italic

        private var sizeName: String {
            switch self {
            case .thin: return "Light" // Roboto-Thin
            case .light: return "Light" // Roboto-Light
            case .regular: return "Light" // Roboto-Regular
            case .medium: return "Regular" // Roboto-Medium
            case .semibold: return "Medium" // Roboto not supported semi bold
            case .bold: return "Bold" // Roboto-Bold
            case .heavy: return "Bold" // Roboto-Black
            case .italic: return "Italic"
            }
        }

        private var familyName: String {
            return "Ubuntu" // "Roboto"
        }

        fileprivate var fullFontName: String {
            return rawValue.isEmpty ? familyName : familyName + "-" + self.sizeName
        }

        fileprivate func instance(_ size: CGFloat = 17.0) -> UIFont {
            if let font = UIFont(name: fullFontName, size: size) {
                return font
            }
            fatalError("Font '\(fullFontName)' does not exist.")
        }

    }

    static func with(type: AppFontType = .regular, size: CGFloat = 17.0) -> UIFont {
        let adustedSize: CGFloat = size // adjust this setting to globally apply to all the fonts
        return type.instance(adustedSize)
    }

    static func printFonts() {
       for familyName in UIFont.familyNames {
           print("\n-- \(familyName)")
           for fontName in UIFont.fontNames(forFamilyName: familyName) {
               print(fontName)
           }
       }
   }
}

// MARK: - SwiftUI Font Extension
import GomaUI
extension AppFont.AppFontType {

    static func fontTypeFrom(styleProviderFontType fontType: StyleProvider.FontType) -> AppFont.AppFontType {
        switch fontType {
        case .thin:
            return Self.thin
        case .light:
            return Self.light
        case .regular:
            return Self.regular
        case .medium:
            return Self.medium
        case .bold:
            return Self.bold
        case .semibold:
            return Self.semibold
        case .heavy:
            return Self.heavy
        }
    }

}

// MARK: - SwiftUI Font Extension
import SwiftUI

extension Font {
    static func appFont(type: AppFont.AppFontType, size: CGFloat) -> Font {
        return Font(AppFont.with(type: type, size: size) as CTFont)
    }
}
