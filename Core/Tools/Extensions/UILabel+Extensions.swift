import UIKit

extension UILabel {

}

extension UILabel {

   func setCharacterSpacing(characterSpacing: CGFloat = 0.0) {

        guard let labelText = text else { return }

        let attributedString: NSMutableAttributedString
        if let labelAttributedText = attributedText {
            attributedString = NSMutableAttributedString(attributedString: labelAttributedText)
        }
        else {
            attributedString = NSMutableAttributedString(string: labelText)
        }
        attributedString.addAttribute(.kern, value: characterSpacing, range: NSRange(location: 0, length: attributedString.length))
        attributedText = attributedString
    }

}

extension UILabel {

    func setLineSpacing(lineSpacing: CGFloat = 0.0, lineHeightMultiple: CGFloat = 0.0) {

        guard let labelText = self.text else { return }

        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = lineSpacing
        paragraphStyle.lineHeightMultiple = lineHeightMultiple

        let attributedString: NSMutableAttributedString
        if let labelattributedText = self.attributedText {
            attributedString = NSMutableAttributedString(attributedString: labelattributedText)
        }
        else {
            attributedString = NSMutableAttributedString(string: labelText)
        }
        attributedString.addAttribute(NSAttributedString.Key.paragraphStyle, value: paragraphStyle, range: NSRange(location: 0, length: attributedString.length))
        self.attributedText = attributedString
    }

    func highlightTextLabel(fullString: String, highlightString: String) {
            let accountText = fullString

            self.text = accountText
            self.font = AppFont.with(type: .semibold, size: 14.0)

            self.textColor =  UIColor.white

            let highlightAttriString = NSMutableAttributedString(string: accountText)
            let range1 = (accountText as NSString).range(of: highlightString)
            highlightAttriString.addAttribute(NSAttributedString.Key.font, value: AppFont.with(type: .semibold, size: 14), range: range1)
            highlightAttriString.addAttribute(NSAttributedString.Key.foregroundColor, value: UIColor.App.mainTint, range: range1)

            self.attributedText = highlightAttriString
            self.isUserInteractionEnabled = true
        }
}
