//
//  RecentSearchUITableViewHeaderFooterView.swift
//  Sportsbook
//
//  Created by André Lascas on 25/01/2022.
//

import UIKit

class RecentSearchUITableViewHeaderFooterView: UITableViewHeaderFooterView {

    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var clearAllButton: UIButton!

    // Variables
    var clearAllAction: (() -> Void)?

    override func awakeFromNib() {
        super.awakeFromNib()

        self.setup()
        self.setupWithTheme()
        
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)

        self.setupWithTheme()
    }

    func setup() {
        self.titleLabel.text = localized("recent_searches")
        self.titleLabel.font = AppFont.with(type: .bold, size: 16)

        self.clearAllButton.setTitle(localized("clear_all"), for: .normal)
        self.clearAllButton.titleLabel?.font = AppFont.with(type: .medium, size: 12)
    }

    func setupWithTheme() {

        self.titleLabel.textColor = UIColor.App.headingMain

        self.clearAllButton.backgroundColor = .clear
        self.clearAllButton.tintColor = UIColor.App.headingMain
    }

    @IBAction private func didTapClearAllButton() {
        self.clearAllAction?()
    }

}
