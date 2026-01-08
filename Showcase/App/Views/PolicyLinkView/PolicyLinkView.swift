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

    private var termsText: String {
        var termsText = localized("signing_agree_terms_conditions")
        termsText = termsText.replacingOccurrences(of: "{terms_and_conditions}", with: localized("terms"))
        termsText = termsText.replacingOccurrences(of: "{privacy_policy}", with: localized("privacy_policy"))
        termsText = termsText.replacingOccurrences(of: "{sport_betting_rules}", with: localized("sport_betting_rules"))
        return termsText
    }

    override init(frame: CGRect) {
        super.init(frame: frame)

        self.setup()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)

        self.setup()
    }

    func setup() {

        self.backgroundColor = UIColor.App.backgroundPrimary

        termsLabel.text = self.termsText
        termsLabel.numberOfLines = 0
        termsLabel.font = AppFont.with(type: .semibold, size: 14.0)
        self.termsLabel.textColor =  UIColor.App.textPrimary

        let underlineAttriString = NSMutableAttributedString(string: termsText)

        let range1 = (termsText as NSString).range(of: localized("terms"))
        let range2 = (termsText as NSString).range(of: localized("privacy_policy"))
        let range3 = (termsText as NSString).range(of: localized("sport_betting_rules"))

        let paragraphStyle = NSMutableParagraphStyle()

        paragraphStyle.lineHeightMultiple = TextSpacing.subtitle
        paragraphStyle.lineSpacing = 2
        paragraphStyle.alignment = .center

        underlineAttriString.addAttribute(.font, value: AppFont.with(type: .semibold, size: 14), range: range1)
        underlineAttriString.addAttribute(.font, value: AppFont.with(type: .semibold, size: 14), range: range2)
        underlineAttriString.addAttribute(.font, value: AppFont.with(type: .semibold, size: 14), range: range3)
        underlineAttriString.addAttribute(.foregroundColor, value: UIColor.App.highlightPrimary, range: range1)
        underlineAttriString.addAttribute(.foregroundColor, value: UIColor.App.highlightPrimary, range: range2)
        underlineAttriString.addAttribute(.foregroundColor, value: UIColor.App.highlightPrimary, range: range3)
        underlineAttriString.addAttribute(.underlineStyle, value: NSUnderlineStyle.single.rawValue, range: range1)
        underlineAttriString.addAttribute(.underlineStyle, value: NSUnderlineStyle.single.rawValue, range: range2)
        underlineAttriString.addAttribute(.underlineStyle, value: NSUnderlineStyle.single.rawValue, range: range3)
        underlineAttriString.addAttribute(.paragraphStyle, value: paragraphStyle, range: NSRange(location: 0, length: underlineAttriString.length))

        termsLabel.attributedText = underlineAttriString
        termsLabel.isUserInteractionEnabled = true
        termsLabel.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(tapUnderlineLabel(gesture:))))
    }

    @IBAction private func tapUnderlineLabel(gesture: UITapGestureRecognizer) {
        let termsRange = (self.termsText as NSString).range(of: localized("terms"))
        let privacyRange = (self.termsText as NSString).range(of: localized("privacy_policy"))
        let eulaRange = (self.termsText as NSString).range(of: localized("sport_betting_rules"))

        if gesture.didTapAttributedTextInLabel(label: termsLabel, inRange: termsRange) {
            didTapTerms?()
        }
        else if gesture.didTapAttributedTextInLabel(label: termsLabel, inRange: privacyRange) {
            didTapPrivacy?()
        }
        else if gesture.didTapAttributedTextInLabel(label: termsLabel, inRange: eulaRange) {
            didTapEula?()
        }

    }

    override var intrinsicContentSize: CGSize {
        return CGSize(width: self.frame.width, height: termsLabel.frame.height)
    }

}
