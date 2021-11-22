//
//  EmailVerificationTableViewCell.swift
//  Sportsbook
//
//  Created by André Lascas on 16/11/2021.
//

import UIKit

class EmailVerificationTableViewCell: UITableViewCell {

    @IBOutlet private var activationAlertView: ActivationAlertView!
    // Variables
    var activationAlertViewLinkLabelAction: (() -> Void)?

    override func awakeFromNib() {
        super.awakeFromNib()

        self.activationAlertView.setText(title: localized("string_verify_email"), info: localized("string_app_full_potential"), linkText: localized("string_verify_my_account"))
        self.activationAlertView.layer.cornerRadius = CornerRadius.button
        self.activationAlertView.layer.masksToBounds = true
        self.activationAlertView.linkLabelAction = {
            self.activationAlertViewLinkLabelAction?()
        }
        self.setupWithTheme()
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)

        self.setupWithTheme()
    }

    func setupWithTheme() {
        self.contentView.backgroundColor = UIColor.App.contentBackground

    }

    override var intrinsicContentSize: CGSize {
        return CGSize(width: self.frame.width, height: 130)
    }
    
}
