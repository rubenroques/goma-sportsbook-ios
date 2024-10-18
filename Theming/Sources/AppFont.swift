import UIKit

public struct AppFont {

    public enum AppFontType: String {
        case thin
        case light
        case regular
        case medium
        case bold
        case semibold
        case heavy

        private var sizeName: String {
            switch self {
            case .thin: return "Thin" // Roboto-Thin
            case .light: return "Light" // Roboto-Light
            case .regular: return "Regular" // Roboto-Regular
            case .medium: return "Medium" // Roboto-Medium
            case .semibold: return "Bold" // Roboto not supported semi bold
            case .bold: return "Black" // Roboto-Bold
            case .heavy: return "Black" // Roboto-Black
            }
        }

        private var familyName: String {
            "Roboto"
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

    public static func with(type: AppFontType = .regular, size: CGFloat = 17.0) -> UIFont {
        return type.instance(size)
    }

}
