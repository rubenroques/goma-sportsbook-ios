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

    func addLineHeight(to label: UILabel, lineHeight: CGFloat) {
        guard let labelText = label.text else {
            return
        }

        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = lineHeight - label.font.lineHeight
        paragraphStyle.alignment = label.textAlignment

        let attributedString = NSMutableAttributedString(string: labelText)
        attributedString.addAttribute(.paragraphStyle, value: paragraphStyle, range: NSMakeRange(0, attributedString.length))

        label.attributedText = attributedString
    }

}
