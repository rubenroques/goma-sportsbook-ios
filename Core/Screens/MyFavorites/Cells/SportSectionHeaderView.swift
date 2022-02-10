//
//  SportSectionHeaderView.swift
//  Sportsbook
//
//  Created by André Lascas on 10/02/2022.
//

import UIKit

class SportSectionHeaderView: UITableViewHeaderFooterView {

    lazy var titleLabel: UILabel = {
        var titleLabel = UILabel()
        titleLabel.numberOfLines = 1
        titleLabel.text = "Sport"
        titleLabel.font = AppFont.with(type: .bold, size: 16)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        return titleLabel
    }()

    lazy var sportIconImageView: UIImageView = {
        var sportIconImageView = UIImageView()
        sportIconImageView.contentMode = .scaleAspectFit
        sportIconImageView.layer.cornerRadius = sportIconImageView.frame.width/2
        sportIconImageView.image = UIImage(named: "sport_type_mono_icon_default")
        sportIconImageView.translatesAutoresizingMaskIntoConstraints = false
        return sportIconImageView
    }()

    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)

        self.setupSubviews()
        self.setupWithTheme()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func prepareForReuse() {
        super.prepareForReuse()
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        self.setupWithTheme()
    }

    func setupWithTheme() {
        self.backgroundColor = .clear
        self.backgroundView?.backgroundColor = .clear
        self.contentView.backgroundColor = UIColor.App.alertSuccess

        self.titleLabel.textColor = UIColor.App.textPrimary

    }

    func configureHeader(title: String, sportTypeId: String) {
        self.titleLabel.text = title

        self.sportIconImageView.image = UIImage(named: "sport_type_mono_icon_\(sportTypeId)")
    }

}

extension SportSectionHeaderView {

    private func setupSubviews() {
        // Add subviews to self.view or each other
        self.contentView.addSubview(self.sportIconImageView)
        self.contentView.addSubview(self.titleLabel)

        // Initialize constraints
        self.initConstraints()
    }

    private func initConstraints() {

        NSLayoutConstraint.activate([
            self.sportIconImageView.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor, constant: 16),
            self.sportIconImageView.centerYAnchor.constraint(equalTo: self.contentView.centerYAnchor),
            self.sportIconImageView.widthAnchor.constraint(equalToConstant: 15),
            self.sportIconImageView.heightAnchor.constraint(equalToConstant: 15),

            self.titleLabel.leadingAnchor.constraint(equalTo: self.sportIconImageView.trailingAnchor, constant: 10),
            self.titleLabel.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor),
            self.titleLabel.centerYAnchor.constraint(equalTo: self.contentView.centerYAnchor)
        ])
    }
}
