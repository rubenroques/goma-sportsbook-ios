//
//  RecentSearchRowView.swift
//  Sportsbook
//
//  Created by André Lascas on 25/01/2022.
//

import UIKit

class RecentSearchRowView: NibView {

    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var clearButton: UIButton!

    // Variables
    var row: Int = 0
    var tappedClearButton: ((Int) -> Void)?

    override init(frame: CGRect) {
        super.init(frame: frame)

        self.commonInit()
        self.setupWithTheme()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)

        self.commonInit()
        self.setupWithTheme()
    }

    override func commonInit() {
        self.titleLabel.text = "Title"
        self.titleLabel.font = AppFont.with(type: .semibold, size: 14)

        self.clearButton.setTitle("", for: .normal)
        self.clearButton.setImage(UIImage(named: ""), for: .normal)
    }

    func setTitle(title: String) {
        self.titleLabel.text = title
    }

    func setRow(row: Int) {
        self.row = row
    }

    func setupWithTheme() {
        self.backgroundColor = .clear

        self.titleLabel.textColor = UIColor.App.textPrimary

        self.clearButton.backgroundColor = .clear
        self.clearButton.tintColor = UIColor.App.inputText
    }

    @IBAction private func didTapClearButton() {
        self.tappedClearButton?(self.row)
    }

    override var intrinsicContentSize: CGSize {
        return CGSize(width: self.frame.width, height: 50)
    }
}
