import UIKit

struct AppFont {

    enum AppFontType: String {
        case thin = "Thin"
        case light = "Light"
        case regular = "Regular"
        case medium = "Medium"
        case bold = "Bold"
        case semibold = "Semibold"
        case heavy = "Heavy"

        private var familyName: String {
            "Gilroy"
        }

        fileprivate var fullFontName: String {
            return rawValue.isEmpty ? familyName : familyName + "-" + rawValue
        }

        fileprivate func instance(_ size: CGFloat = 17.0) -> UIFont {
            if let font = UIFont(name: fullFontName, size: size) {
                return font
            }
            fatalError("Font '\(fullFontName)' does not exist.")
        }

    }

    static func with(type: AppFontType = .regular, size: CGFloat = 17.0) -> UIFont {
        return type.instance(size)
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
