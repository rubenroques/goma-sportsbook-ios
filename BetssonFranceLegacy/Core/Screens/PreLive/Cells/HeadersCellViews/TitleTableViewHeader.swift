//
//  TitleTableViewHeader.swift
//  Sportsbook
//
//  Created by Ruben Roques on 01/10/2021.
//

import UIKit

class TitleTableViewHeader: UITableViewHeaderFooterView {

    @IBOutlet private weak var baseView: UIView!
    @IBOutlet private weak var sectionTitleLabel: UILabel!
    @IBOutlet private weak var searchIconBaseView: UIView!
    @IBOutlet private weak var searchIconImageView: UIImageView!

    var hasSearchIcon: Bool = false {
        didSet {
            self.searchIconBaseView.isHidden = !hasSearchIcon
        }
    }

    var shouldShowSearch: (() -> Void)?

    override func awakeFromNib() {
        super.awakeFromNib()
        self.setupWithTheme()

        // Setup fonts
        self.sectionTitleLabel.font = AppFont.with(type: .heavy, size: 16)
        
        self.hasSearchIcon = false

        let searchTapGesture = UITapGestureRecognizer(target: self, action: #selector(didTapSearchIcon))
        self.searchIconBaseView.addGestureRecognizer(searchTapGesture)
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        self.searchIconBaseView.layer.cornerRadius = self.searchIconBaseView.frame.size.width/2
    }

    override func prepareForReuse() {
        super.prepareForReuse()

        self.sectionTitleLabel.text = ""

        self.hasSearchIcon = false
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)

        self.setupWithTheme()
    }

    func setupWithTheme() {
        self.backgroundColor = .clear
        self.backgroundView?.backgroundColor = .clear

        self.sectionTitleLabel.textColor = UIColor.App.textPrimary

        self.searchIconBaseView.backgroundColor = UIColor.App.pillSettings

        self.searchIconImageView.backgroundColor = .clear
        self.searchIconImageView.setTintColor(color: UIColor.App.iconPrimary)
    }

    func configureWithTitle(_ title: String) {
        self.sectionTitleLabel.text = title
    }

    func setSearchIcon(hasSearch: Bool) {
        self.hasSearchIcon = hasSearch
    }

    @objc private func didTapSearchIcon() {
        self.shouldShowSearch?()
    }
}
