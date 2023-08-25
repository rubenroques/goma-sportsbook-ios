//
//  SuggestedCompetitionsView.swift
//  Sportsbook
//
//  Created by André Lascas on 25/08/2023.
//

import UIKit

class SuggestedCompetitionsView: UIView {

    // MARK: Private properties
    private lazy var containerView: UIView = Self.createContainerView()
    private lazy var iconImageView: UIImageView = Self.createIconImageView()
    private lazy var titleLabel: UILabel = Self.createTitleLabel()
    private lazy var subtitleLabel: UILabel = Self.createSubtitleLabel()

    // MARK: Lifetime and Cycle
    override init(frame: CGRect) {
        super.init(frame: frame)

        self.setupSubviews()
        self.commonInit()
        self.setupWithTheme()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)

        self.setupSubviews()
        self.commonInit()
        self.setupWithTheme()
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        self.containerView.layer.cornerRadius = CornerRadius.view

    }

    func commonInit() {

    }

    func setupWithTheme() {
        self.backgroundColor = .clear

        self.containerView.backgroundColor = UIColor.App.backgroundCards

        self.iconImageView.setTintColor(color: UIColor.App.buttonTextPrimary)
        self.iconImageView.setImageColor(color: UIColor.App.buttonTextPrimary)
        
        self.titleLabel.textColor = UIColor.App.textPrimary

        self.subtitleLabel.textColor = UIColor.App.textPrimary

    }

    func configure(title: String, subtitle: String, icon: String) {
        self.titleLabel.text = title

        self.subtitleLabel.text = subtitle

        self.iconImageView.image = UIImage(named: icon)
        self.iconImageView.setImageColor(color: UIColor.App.buttonTextPrimary)
    }
}

extension SuggestedCompetitionsView {

    private static func createContainerView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }

    private static func createIconImageView() -> UIImageView {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.image = UIImage(named: "unselected_favorite_icon")
        imageView.contentMode = .scaleAspectFit
        return imageView
    }

    private static func createTitleLabel() -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = localized("no_favorite_competitions")
        label.font = AppFont.with(type: .bold, size: 14)
        label.numberOfLines = 0
        return label
    }

    private static func createSubtitleLabel() -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = localized("add_some_favorites")
        label.font = AppFont.with(type: .bold, size: 14)
        label.numberOfLines = 0
        return label
    }

    private func setupSubviews() {
        self.addSubview(self.containerView)

        self.containerView.addSubview(self.iconImageView)
        self.containerView.addSubview(self.titleLabel)
        self.containerView.addSubview(self.subtitleLabel)

        self.initConstraints()

        self.containerView.setNeedsLayout()
        self.containerView.layoutIfNeeded()
    }

    private func initConstraints() {

        // Top bar
        NSLayoutConstraint.activate([
            self.containerView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            self.containerView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            self.containerView.topAnchor.constraint(equalTo: self.topAnchor),
            self.containerView.bottomAnchor.constraint(equalTo: self.bottomAnchor),

            self.iconImageView.leadingAnchor.constraint(equalTo: self.containerView.leadingAnchor, constant: 15),
            self.iconImageView.widthAnchor.constraint(equalToConstant: 20),
            self.iconImageView.heightAnchor.constraint(equalTo: self.iconImageView.widthAnchor),
            self.iconImageView.centerYAnchor.constraint(equalTo: self.containerView.centerYAnchor),

            self.titleLabel.leadingAnchor.constraint(equalTo: self.iconImageView.trailingAnchor, constant: 10),
            self.titleLabel.trailingAnchor.constraint(equalTo: self.containerView.trailingAnchor, constant: -15),
            self.titleLabel.topAnchor.constraint(equalTo: self.containerView.topAnchor, constant: 15),

            self.subtitleLabel.leadingAnchor.constraint(equalTo: self.titleLabel.leadingAnchor),
            self.subtitleLabel.trailingAnchor.constraint(equalTo: self.containerView.trailingAnchor, constant: -15),
            self.subtitleLabel.topAnchor.constraint(equalTo: self.titleLabel.bottomAnchor, constant: 4),
            self.subtitleLabel.bottomAnchor.constraint(equalTo: self.containerView.bottomAnchor, constant: -15)



        ])

    }

}
