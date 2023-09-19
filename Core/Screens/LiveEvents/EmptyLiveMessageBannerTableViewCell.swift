//
//  EmptyLiveMessageBannerTableViewCell.swift
//  Sportsbook
//
//  Created by Ruben Roques on 05/09/2023.
//

import Foundation
import UIKit


class EmptyLiveMessageBannerTableViewCell: UITableViewCell {

    private lazy var baseView: UIView = Self.createBaseView()
    private lazy var gradientBorderView: GradientBorderView = Self.createGradientBorderView()
    private lazy var liveImageView: UIImageView = Self.createLiveImageView()
    private lazy var labelsStackView: UIStackView = Self.createLabelsStackView()
    private lazy var titleLabel: UILabel = Self.createTitleLabel()
    private lazy var subtitleLabel: UILabel = Self.createSubtitleLabel()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        self.setupSubviews()
        self.setupWithTheme()
    }

    @available(iOS, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func prepareForReuse() {
        super.prepareForReuse()
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)

        self.setupWithTheme()
    }

    override func layoutSubviews() {
        super.layoutSubviews()
    }

    private func setupWithTheme() {
        self.backgroundColor = .clear
        self.contentView.backgroundColor = .clear
        self.backgroundView?.backgroundColor = .clear

        self.baseView.backgroundColor = UIColor.App.backgroundCards
        self.titleLabel.textColor = UIColor.App.highlightPrimary
        self.subtitleLabel.textColor = UIColor.App.textPrimary
    }

}

extension EmptyLiveMessageBannerTableViewCell {

    private static func createBaseView() -> UIView {
        let baseView  = UIView()
        baseView.clipsToBounds = true
        baseView.layer.cornerRadius = 9
        baseView.translatesAutoresizingMaskIntoConstraints = false
        return baseView
    }

    private static func createGradientBorderView() -> GradientBorderView {
        let gradientBorderView = GradientBorderView()
        gradientBorderView.translatesAutoresizingMaskIntoConstraints = false
        gradientBorderView.gradientBorderWidth = 1
        gradientBorderView.gradientCornerRadius = 9
        return gradientBorderView
    }

    private static func createLiveImageView() -> UIImageView {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.image = UIImage(named: "tabbar_live_icon")
        imageView.contentMode = .scaleAspectFill
        return imageView
    }

    private static func createLabelsStackView() -> UIStackView {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.spacing = 4
        stackView.distribution = .fillEqually
        return stackView
    }

    private static func createTitleLabel() -> UILabel {
        let label  = UILabel()
        label.font = AppFont.with(type: .bold, size: 14)
        label.numberOfLines = 2
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = localized("no_live_matches_happening")
        return label
    }

    private static func createSubtitleLabel() -> UILabel {
        let label  = UILabel()
        label.font = AppFont.with(type: .bold, size: 12)
        label.numberOfLines = 2
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = localized("no_live_matches_happening_subtitle")
        return label
    }

    private func setupSubviews() {
        self.contentView.addSubview(self.baseView)

        self.baseView.addSubview(self.gradientBorderView)
        self.baseView.addSubview(self.liveImageView)

        self.baseView.addSubview(self.labelsStackView)

        self.labelsStackView.addArrangedSubview(self.titleLabel)
        self.labelsStackView.addArrangedSubview(self.subtitleLabel)

        self.initConstraints()
    }

    private func initConstraints() {

        NSLayoutConstraint.activate([
            self.baseView.leadingAnchor.constraint(equalTo: self.gradientBorderView.leadingAnchor),
            self.baseView.trailingAnchor.constraint(equalTo: self.gradientBorderView.trailingAnchor),
            self.baseView.topAnchor.constraint(equalTo: self.gradientBorderView.topAnchor),
            self.baseView.bottomAnchor.constraint(equalTo: self.gradientBorderView.bottomAnchor),
        ])

        NSLayoutConstraint.activate([
            self.baseView.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor, constant: 16),
            self.baseView.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor, constant: -18),
            self.baseView.topAnchor.constraint(equalTo: self.contentView.topAnchor, constant: 22),
            self.baseView.bottomAnchor.constraint(equalTo: self.contentView.bottomAnchor, constant: -4),

            self.liveImageView.widthAnchor.constraint(equalTo: self.liveImageView.heightAnchor),
            self.liveImageView.widthAnchor.constraint(equalToConstant: 21),
            self.liveImageView.leadingAnchor.constraint(equalTo: self.baseView.leadingAnchor, constant: 18),
            self.liveImageView.centerYAnchor.constraint(equalTo: self.baseView.centerYAnchor),

            self.liveImageView.topAnchor.constraint(greaterThanOrEqualTo: self.baseView.topAnchor, constant: 12),

            self.labelsStackView.leadingAnchor.constraint(equalTo: self.liveImageView.trailingAnchor, constant: 16),
            self.labelsStackView.topAnchor.constraint(equalTo: self.baseView.topAnchor, constant: 20),
            self.labelsStackView.bottomAnchor.constraint(equalTo: self.baseView.bottomAnchor, constant: -20),
            self.labelsStackView.trailingAnchor.constraint(equalTo: self.baseView.trailingAnchor, constant: -14),
        ])

    }

}
