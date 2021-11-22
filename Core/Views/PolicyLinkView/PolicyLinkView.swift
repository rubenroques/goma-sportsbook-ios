//
//  PolicyLinkView.swift
//  Sportsbook
//
//  Created by André Lascas on 22/11/2021.
//

import UIKit

class PolicyLinkView: NibView {

    @IBOutlet private var termsLabel: UILabel!

    // Variables
        var didTapTerms: (() -> Void)?
        var didTapPrivacy: (() -> Void)?
        var didTapEula: (() -> Void)?

        override init(frame: CGRect) {
            super.init(frame: frame)

            self.setup()
        }

        required init?(coder aDecoder: NSCoder) {
            super.init(coder: aDecoder)

            self.setup()
        }

        func setup() {

            self.backgroundColor = UIColor.App.mainBackground

            let termsText = localized("string_agree_terms_conditions")

            termsLabel.text = termsText
            termsLabel.numberOfLines = 0
            termsLabel.font = AppFont.with(type: .semibold, size: 14.0)
            self.termsLabel.textColor =  UIColor.App.headingMain

            let underlineAttriString = NSMutableAttributedString(string: termsText)

            let range1 = (termsText as NSString).range(of: localized("string_terms"))
            let range2 = (termsText as NSString).range(of: localized("string_privacy_policy"))
            let range3 = (termsText as NSString).range(of: localized("string_eula"))

            let paragraphStyle = NSMutableParagraphStyle()

            paragraphStyle.lineHeightMultiple = TextSpacing.subtitle
            paragraphStyle.alignment = .center

            underlineAttriString.addAttribute(.font, value: AppFont.with(type: .regular, size: 14), range: range1)
            underlineAttriString.addAttribute(.font, value: AppFont.with(type: .regular, size: 14), range: range2)
            underlineAttriString.addAttribute(.font, value: AppFont.with(type: .regular, size: 14), range: range3)
            underlineAttriString.addAttribute(.foregroundColor, value: UIColor.App.mainTint, range: range1)
            underlineAttriString.addAttribute(.foregroundColor, value: UIColor.App.mainTint, range: range2)
            underlineAttriString.addAttribute(.foregroundColor, value: UIColor.App.mainTint, range: range3)
            underlineAttriString.addAttribute(.underlineStyle, value: NSUnderlineStyle.single.rawValue, range: range1)
            underlineAttriString.addAttribute(.underlineStyle, value: NSUnderlineStyle.single.rawValue, range: range2)
            underlineAttriString.addAttribute(.underlineStyle, value: NSUnderlineStyle.single.rawValue, range: range3)
            underlineAttriString.addAttribute(.paragraphStyle, value: paragraphStyle, range: NSMakeRange(0, underlineAttriString.length))

            termsLabel.attributedText = underlineAttriString
            termsLabel.isUserInteractionEnabled = true
            termsLabel.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(tapUnderlineLabel(gesture:))))
        }

    @IBAction private func tapUnderlineLabel(gesture: UITapGestureRecognizer) {
            let text = localized("string_agree_terms_conditions")

            let termsRange = (text as NSString).range(of: localized("string_terms"))
            let privacyRange = (text as NSString).range(of: localized("string_privacy_policy"))
            let eulaRange = (text as NSString).range(of: localized("string_eula"))

            if gesture.didTapAttributedTextInLabel(label: termsLabel, inRange: termsRange) {
                didTapTerms?()
            } else if gesture.didTapAttributedTextInLabel(label: termsLabel, inRange: privacyRange) {
                didTapPrivacy?()
            } else if gesture.didTapAttributedTextInLabel(label: termsLabel, inRange: eulaRange) {
                didTapEula?()
            }
        }

        override var intrinsicContentSize: CGSize {
            return CGSize(width: self.frame.width, height: termsLabel.frame.height)
        }

}
