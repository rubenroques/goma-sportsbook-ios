import Foundation
import UIKit

extension UIButton {
    private func imageWithColor(_ color: UIColor) -> UIImage? {

        defer {
            UIGraphicsEndImageContext()
        }

        let rect = CGRect(x: 0, y: 0, width: 1, height: 1)
        UIGraphicsBeginImageContext(rect.size)
        if let context = UIGraphicsGetCurrentContext() {

            context.setFillColor(color.cgColor)
            context.fill(rect)
            if let image = UIGraphicsGetImageFromCurrentImageContext() {
                return image
            }
        }
        return nil
    }

    func setBackgroundColor(_ color: UIColor, for state: UIControl.State) {

        if let image = imageWithColor(color) {
            self.setBackgroundImage(image, for: state)
        }
    }

    func underlineButtonTitleLabel(title: String) {
        let text = title

        let underlineAttriString = NSMutableAttributedString(string: text)

        let range1 = (text as NSString).range(of: title)

        underlineAttriString.addAttribute(NSAttributedString.Key.font, value: AppFont.with(type: .regular, size: 16), range: range1)

        underlineAttriString.addAttribute(NSAttributedString.Key.foregroundColor, value: UIColor.App.buttonMain, range: range1)

        underlineAttriString.addAttribute(NSAttributedString.Key.underlineStyle, value: NSUnderlineStyle.single.rawValue, range: range1)

        self.setAttributedTitle(underlineAttriString, for: .normal)
    }

    func enableButton() {
        self.isEnabled = true
        self.backgroundColor = UIColor.App.buttonMain
    }

    func disableButton() {
        self.isEnabled = false
        self.backgroundColor = UIColor.App.backgroundDarkProfile
    }
}
