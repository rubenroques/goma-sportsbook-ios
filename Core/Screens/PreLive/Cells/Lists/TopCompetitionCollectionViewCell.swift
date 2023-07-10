//
//  TopCompetitionCollectionViewCell.swift
//  Sportsbook
//
//  Created by André Lascas on 06/07/2023.
//

import UIKit

class TopCompetitionCollectionViewCell: UICollectionViewCell {

    private lazy var containerView: UIView = Self.createContainerView()
    private lazy var iconImageView: UIImageView = Self.createIconImageView()
    private lazy var titleLabel: UILabel = Self.createTitleLabel()

    var competition: Competition?

    var hasHighlight: Bool = false {
        didSet {
            if hasHighlight {
                self.containerView.backgroundColor = UIColor.App.backgroundBorder

                self.titleLabel.textColor = UIColor.App.textPrimary
            }
            else {
                self.containerView.backgroundColor = UIColor.App.pillNavigation

                self.titleLabel.textColor = UIColor.App.textSecondary
            }
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)

        self.setupSubviews()
        self.setupWithTheme()

        self.hasHighlight = false
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        self.containerView.layer.cornerRadius = self.containerView.frame.height / 2

        self.iconImageView.layer.cornerRadius = self.containerView.frame.height / 2

    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)

        self.setupWithTheme()
    }

    override func prepareForReuse() {
        super.prepareForReuse()

        self.hasHighlight = false

        self.setupWithTheme()

    }

    func setupWithTheme() {

        self.containerView.backgroundColor = UIColor.App.pillNavigation

        self.containerView.layer.borderColor = UIColor.App.buttonActiveHoverTertiary.cgColor

        self.containerView.layer.borderColor = UIColor.App.buttonActiveHoverTertiary.cgColor

        self.iconImageView.backgroundColor = .clear

        self.titleLabel.textColor = UIColor.App.textSecondary

    }

    func setupInfo(competition: Competition) {

        if let country = competition.venue?.isoCode {
            self.iconImageView.image = UIImage(named: Assets.flagName(withCountryCode: country))
        }
        else {
            self.iconImageView.image = UIImage(named: Assets.flagName(withCountryCode: ""))

        }

        self.titleLabel.text = competition.name

        self.competition = competition
    }

}

extension TopCompetitionCollectionViewCell {

    private static func createContainerView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.borderWidth = 1
        return view
    }

    private static func createIconImageView() -> UIImageView {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.image = UIImage(named: "country_flag_240")
        imageView.contentMode = .scaleAspectFit
        return imageView
    }

    private static func createTitleLabel() -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Title"
        label.font = AppFont.with(type: .bold, size: 14)
        label.textAlignment = .center
        return label
    }

    private func setupSubviews() {

        self.contentView.addSubview(self.containerView)

        self.containerView.addSubview(self.iconImageView)
        self.containerView.addSubview(self.titleLabel)

        self.initConstraints()

        self.containerView.setNeedsLayout()
        self.containerView.layoutIfNeeded()
    }

    private func initConstraints() {

        NSLayoutConstraint.activate([

            self.containerView.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor),
            self.containerView.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor),
            self.containerView.topAnchor.constraint(equalTo: self.contentView.topAnchor),
            self.containerView.bottomAnchor.constraint(equalTo: self.contentView.bottomAnchor),

            self.iconImageView.leadingAnchor.constraint(equalTo: self.containerView.leadingAnchor, constant: 8),
            self.iconImageView.widthAnchor.constraint(equalToConstant: 16),
            self.iconImageView.heightAnchor.constraint(equalTo: self.iconImageView.widthAnchor),
            self.iconImageView.topAnchor.constraint(equalTo: self.containerView.topAnchor, constant: 8),
            self.iconImageView.bottomAnchor.constraint(equalTo: self.containerView.bottomAnchor, constant: -8),

            self.titleLabel.leadingAnchor.constraint(equalTo: self.iconImageView.trailingAnchor, constant: 8),
            self.titleLabel.trailingAnchor.constraint(equalTo: self.containerView.trailingAnchor, constant: -8),
            self.titleLabel.centerYAnchor.constraint(equalTo: self.iconImageView.centerYAnchor),

        ])
    }
}
