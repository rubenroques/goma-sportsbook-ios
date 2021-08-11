
import UIKit

struct AppFont {

    enum AppFontType: String {
        case light = "Light"
        case regular = ""
        case medium = "Medium"
        case bold = "Bold"


        private var familyName: String {
            "HelveticaNeue"
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

    static func with(type: AppFontType, size: CGFloat = 17.0) -> UIFont {
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
