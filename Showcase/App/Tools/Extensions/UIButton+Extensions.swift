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
        underlineAttriString.addAttribute(NSAttributedString.Key.foregroundColor, value: UIColor.App.highlightPrimary, range: range1)
        underlineAttriString.addAttribute(NSAttributedString.Key.underlineStyle, value: NSUnderlineStyle.single.rawValue, range: range1)

        self.setAttributedTitle(underlineAttriString, for: .normal)
    }

//    func enableButton() {
//        self.isEnabled = true
//        self.backgroundColor = UIColor.App.buttonBackgroundPrimary
//    }
//
//    func disableButton() {
//        self.isEnabled = false
//        self.backgroundColor = UIColor.App.buttonDisablePrimary
//    }

    func setInsets(forContentPadding contentPadding: UIEdgeInsets, imageTitlePadding: CGFloat) {
        self.contentEdgeInsets = UIEdgeInsets(top: contentPadding.top, left: contentPadding.left, bottom: contentPadding.bottom, right: contentPadding.right + imageTitlePadding)
        self.titleEdgeInsets = UIEdgeInsets(top: 0, left: imageTitlePadding, bottom: 0,right: -imageTitlePadding)
    }

    func alignVertical(spacing: CGFloat = 6.0) {
            guard let imageSize = self.imageView?.image?.size,
                let text = self.titleLabel?.text,
                let font = self.titleLabel?.font
                else { return }
            self.titleEdgeInsets = UIEdgeInsets(top: 0.0, left: -imageSize.width, bottom: -(imageSize.height + spacing), right: 0.0)
            let labelString = NSString(string: text)
        let titleSize = labelString.size(withAttributes: [kCTFontAttributeName as NSAttributedString.Key: font])
            self.imageEdgeInsets = UIEdgeInsets(top: -(titleSize.height + spacing), left: 0.0, bottom: 0.0, right: -titleSize.width)
            let edgeOffset = abs(titleSize.height - imageSize.height) / 2.0;
            self.contentEdgeInsets = UIEdgeInsets(top: edgeOffset, left: 0.0, bottom: edgeOffset, right: 0.0)
        }
}
