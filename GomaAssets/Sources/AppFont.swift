import UIKit

public struct AppFont {

    public enum Weight: String {
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

    public static func with(type: AppFont.Weight = .regular, size: CGFloat = 17.0) -> UIFont {
        return UIFont.systemFont(ofSize: size) // type.instance(size)
    }

}
