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
    }

    func setupCell() {

        self.containerView.layer.cornerRadius = CornerRadius.view

        self.titleLabel.text = "Cell"
        self.titleLabel.font = AppFont.with(type: .bold, size: 16)

        let tapCell = UITapGestureRecognizer(target: self, action: #selector(self.handleCellTap(_:)))
        self.addGestureRecognizer(tapCell)
    }

    func setupWithTheme() {

        self.backgroundColor = UIColor.App.backgroundPrimary

        self.contentView.backgroundColor = .clear

        self.containerView.backgroundColor = UIColor.App.backgroundSecondary

        self.titleLabel.textColor = UIColor.App.textPrimary
    }

    func setTitle(title: String) {
        self.titleLabel.text = title
    }

    @objc func handleCellTap(_ sender: UITapGestureRecognizer? = nil) {
        self.tappedCompetitionCellAction?()
    }

    override var intrinsicContentSize: CGSize {
        return CGSize(width: self.frame.width, height: 56)
    }

}
