//
//  EmptyCardTableViewCell.swift
//  Sportsbook
//
//  Created by André Lascas on 23/12/2021.
//

import UIKit

class EmptyCardTableViewCell: UITableViewCell {

    @IBOutlet private var containerView: UIView!
    @IBOutlet private var iconImageView: UIImageView!
    @IBOutlet private var descriptionLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()

        self.setup()

        self.setupWithTheme()
    }

    func setup() {
        self.iconImageView.image = UIImage(named: "warning_alert_icon")

        self.descriptionLabel.text = "Lorem ipsum"
        self.descriptionLabel.numberOfLines = 0
    }

    func setupWithTheme() {

        self.backgroundColor = .clear
        self.contentView.backgroundColor = .clear

        self.containerView.backgroundColor = UIColor.App.secondaryBackground
        self.containerView.layer.cornerRadius = CornerRadius.modal
        self.containerView.layer.masksToBounds = true

        self.iconImageView.backgroundColor = .clear
        self.iconImageView.tintColor = UIColor.App.headingMain

        self.descriptionLabel.textColor = UIColor.App.headingMain
        self.descriptionLabel.font = AppFont.with(type: .semibold, size: 14)
    }

    func setDescription(text: String) {
        self.descriptionLabel.text = text
    }

}
