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

    // Variables
    var didTapCellAction: (() -> Void)?

    override func awakeFromNib() {
        super.awakeFromNib()

        self.commonInit()
        self.setupWithTheme()
    }

    // Variables
    var row: Int = 0
    var tappedClearButton: ((Int) -> Void)?

    func commonInit() {
        self.titleLabel.text = "Title"
        self.titleLabel.font = AppFont.with(type: .semibold, size: 14)

        self.clearButton.setTitle("", for: .normal)
        self.clearButton.setImage(UIImage(named: ""), for: .normal)

        let tapCell = UITapGestureRecognizer(target: self, action: #selector(self.handleCellTap(_:)))
        self.addGestureRecognizer(tapCell)
    }

    func setTitle(title: String) {
        self.titleLabel.text = title
    }

    func setRow(row: Int) {
        self.row = row
    }

    @objc func handleCellTap(_ sender: UITapGestureRecognizer? = nil) {
        didTapCellAction?()
    }

    func setupWithTheme() {
        self.backgroundColor = .clear

        self.titleLabel.textColor = UIColor.App.headingMain

        self.clearButton.backgroundColor = .clear
        self.clearButton.tintColor = UIColor.App.headerTextField
    }

    @IBAction private func didTapClearButton() {
        self.tappedClearButton?(self.row)
    }

    override var intrinsicContentSize: CGSize {
        return CGSize(width: self.frame.width, height: 50)
    }

}
