//
//  ActivationAlertCollectionViewCell.swift
//  Sportsbook
//
//  Created by André Lascas on 17/11/2021.
//

import UIKit

class ActivationAlertCollectionViewCell: UICollectionViewCell {

    @IBOutlet private var containerView: UIView!
    @IBOutlet private var titleLabel: UILabel!
    @IBOutlet private var descriptionLabel: UILabel!
    @IBOutlet private var linkLabel: UILabel!

    enum AlertType {
        case email
        case profile
    }
    // Variables

    var linkLabelAction: (() -> Void)?

    override func awakeFromNib() {
        super.awakeFromNib()

        containerView.layer.cornerRadius = CornerRadius.button
        containerView.layer.masksToBounds = true

        titleLabel.text = ""

        descriptionLabel.text = ""
        descriptionLabel.numberOfLines = 0

        linkLabel.text = "Click here"
        let labelTap = UITapGestureRecognizer(target: self, action: #selector(self.labelTapped(_:)))
        self.linkLabel.isUserInteractionEnabled = true
        self.linkLabel.addGestureRecognizer(labelTap)

        setupWithTheme()
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)

        self.setupWithTheme()
    }

    override func prepareForReuse() {
        super.prepareForReuse()

        titleLabel.text = localized("empty_value")
        descriptionLabel.text = localized("empty_value")
        linkLabel.text = localized("empty_value")
    }

    func setupWithTheme() {

        containerView.backgroundColor = UIColor.App.backgroundTertiary
        containerView.layer.borderWidth = 1
        containerView.layer.borderColor = UIColor.App.iconSecondary.cgColor

        titleLabel.textColor = UIColor.App.textPrimary
        titleLabel.font = AppFont.with(type: .bold, size: 16)

        descriptionLabel.textColor = UIColor.App.textPrimary
        descriptionLabel.font = AppFont.with(type: .semibold, size: 13)

        linkLabel.textColor = UIColor.App.highlightPrimary
        linkLabel.font = AppFont.with(type: .semibold, size: 14)
    }

    func setText(title: String, info: String, linkText: String) {
        self.titleLabel.text = title
        self.descriptionLabel.text = info
        self.linkLabel.text = linkText
    }

    @objc func labelTapped(_ sender: UITapGestureRecognizer) {
        self.linkLabelAction?()
    }

}
