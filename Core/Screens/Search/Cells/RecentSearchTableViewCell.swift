//
//  RecentSearchTableViewCell.swift
//  Sportsbook
//
//  Created by André Lascas on 25/01/2022.
//

import UIKit

class RecentSearchTableViewCell: UITableViewCell {

    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var clearButton: UIButton!
    @IBOutlet private weak var separatorLineView: UIView!

    // Variables
    var didTapCellAction: (() -> Void)?
    var didTapClearButtonAction: (() -> Void)?

    override func awakeFromNib() {
        super.awakeFromNib()

        self.commonInit()
        self.setupWithTheme()
    }

    override func prepareForReuse() {
        super.prepareForReuse()

        self.titleLabel.text = ""
        self.separatorLineView.isHidden = false
    }

    func commonInit() {
        self.titleLabel.text = "Title"
        self.titleLabel.font = AppFont.with(type: .semibold, size: 14)

        self.clearButton.setTitle("", for: .normal)
        self.clearButton.setImage(UIImage(named: "thin_close_cross_icon"), for: .normal)

        let tapCell = UITapGestureRecognizer(target: self, action: #selector(self.handleCellTap(_:)))
        self.addGestureRecognizer(tapCell)
    }

    func setTitle(title: String) {
        self.titleLabel.text = title
    }

    @objc func handleCellTap(_ sender: UITapGestureRecognizer? = nil) {
        didTapCellAction?()
    }

    func setupWithTheme() {
        self.backgroundColor = .clear

        self.titleLabel.textColor = UIColor.App.textPrimary

        self.clearButton.backgroundColor = .clear
        self.clearButton.tintColor = UIColor.App.textDisablePrimary

        self.separatorLineView.backgroundColor = UIColor.App.separatorLine
    }

    func hideSeparatorLineView() {
        self.separatorLineView.isHidden = true
    }

    @IBAction private func didTapClearButton() {
        self.didTapClearButtonAction?()
    }

    override var intrinsicContentSize: CGSize {
        return CGSize(width: self.frame.width, height: 50)
    }

}
