//
//  IconTitleHeaderFooterView.swift
//  Sportsbook
//
//  Created by André Lascas on 26/02/2025.
//

import UIKit

class IconTitleHeaderFooterView: UITableViewHeaderFooterView {

    // MARK: Private Properties
    private lazy var iconImageView: UIImageView = Self.createIconImageView()
    private lazy var titleLabel: UILabel = Self.createTitleLabel()

    // MARK: - Lifetime and Cycle
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

    // MARK: - Layout and Theme
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        self.setupWithTheme()
    }

    func setupWithTheme() {
        self.contentView.backgroundColor = .clear

        self.iconImageView.backgroundColor = .clear
        
        self.titleLabel.textColor = UIColor.App.textPrimary

    }

    // MARK: Functions
    func configureHeader(iconName: String, title: String, backgroundColor: UIColor? = nil) {
        self.iconImageView.image = UIImage(named: iconName)
        
        self.titleLabel.text = title
        
        if let backgroundColor {
            self.contentView.backgroundColor = backgroundColor
        }
    }

}

extension IconTitleHeaderFooterView {
    
    private static func createIconImageView() -> UIImageView {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.image = nil
        imageView.contentMode = .scaleAspectFit
        return imageView
    }

    private static func createTitleLabel() -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 0
        label.text = "Title"
        label.font = AppFont.with(type: .bold, size: 16)
        label.textAlignment = .left
        return label
    }

    private func setupSubviews() {

        self.contentView.addSubview(self.iconImageView)
        self.contentView.addSubview(self.titleLabel)

        self.initConstraints()
    }

    private func initConstraints() {

        NSLayoutConstraint.activate([
            
            self.iconImageView.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor, constant: 16),
            self.iconImageView.topAnchor.constraint(equalTo: self.contentView.topAnchor, constant: 8),
            self.iconImageView.bottomAnchor.constraint(equalTo: self.contentView.bottomAnchor, constant: -8),
            self.iconImageView.widthAnchor.constraint(equalToConstant: 20),
            self.iconImageView.heightAnchor.constraint(equalToConstant: 25),
            
            self.titleLabel.leadingAnchor.constraint(equalTo: self.iconImageView.trailingAnchor, constant: 4),
            self.titleLabel.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor, constant: -16),
            self.titleLabel.centerYAnchor.constraint(equalTo: self.iconImageView.centerYAnchor)
        ])
    }
}
