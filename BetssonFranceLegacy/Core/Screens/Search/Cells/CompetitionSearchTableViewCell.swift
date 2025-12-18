//
//  CompetitionSearchTableViewCell.swift
//  Sportsbook
//
//  Created by André Lascas on 24/01/2022.
//

import UIKit

class CompetitionSearchTableViewCell: UITableViewCell {

    @IBOutlet private weak var containerView: UIView!
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var flagImageView: UIImageView!

    // Variables
    var tappedCompetitionCellAction: (() -> Void)?

    override func awakeFromNib() {
        super.awakeFromNib()

        self.setupCell()
        self.setupWithTheme()
    }

    override func prepareForReuse() {
        super.prepareForReuse()

        self.titleLabel.text = ""
        self.flagImageView.image = nil
    }

    func setupCell() {

        self.containerView.layer.cornerRadius = CornerRadius.view

        self.titleLabel.text = "Cell"
        self.titleLabel.font = AppFont.with(type: .bold, size: 16)
        self.titleLabel.numberOfLines = 0

        self.flagImageView.backgroundColor = .clear
        self.flagImageView.contentMode = .scaleToFill
        self.flagImageView.layer.cornerRadius = self.flagImageView.frame.width/2

        let tapCell = UITapGestureRecognizer(target: self, action: #selector(self.handleCellTap(_:)))
        self.addGestureRecognizer(tapCell)
    }

    func setupWithTheme() {

        self.backgroundColor = UIColor.App.backgroundPrimary

        self.contentView.backgroundColor = .clear

        self.containerView.backgroundColor = UIColor.App.backgroundCards

        self.titleLabel.textColor = UIColor.App.textPrimary
    }

    func setCellValues(title: String, flagCode: String, flagId: String) {
        self.titleLabel.text = title

        if flagCode != "" {
        self.flagImageView.image = UIImage(named: Assets.flagName(withCountryCode: flagCode))
        }
        else {
            self.flagImageView.image = UIImage(named: Assets.flagName(withCountryCode: flagId))
        }
    }

    @objc func handleCellTap(_ sender: UITapGestureRecognizer? = nil) {
        self.tappedCompetitionCellAction?()
    }

    override var intrinsicContentSize: CGSize {
        return CGSize(width: self.frame.width, height: self.titleLabel.frame.height + 40)
    }

}
