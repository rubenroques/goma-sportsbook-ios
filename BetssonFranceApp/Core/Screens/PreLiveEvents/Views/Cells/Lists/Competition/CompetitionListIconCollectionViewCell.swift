//
//  CompetitionListIconCollectionViewCell.swift
//  Sportsbook
//
//  Created by André Lascas on 27/06/2023.
//

import UIKit

class CompetitionListIconCollectionViewCell: UICollectionViewCell {

    private lazy var selectionHighlightView: UIView = Self.createSelectionHighlightView()
    private lazy var containerView: UIView = Self.createContainerView()
    private lazy var iconImageView: UIImageView = Self.createIconImageView()
    private lazy var titleLabel: UILabel = Self.createTitleLabel()

    var selectedColor: UIColor = .white
    var normalColor: UIColor = .black

    var selectedType: Bool = false

    override init(frame: CGRect) {
        super.init(frame: frame)

        self.setupSubviews()
        self.setupWithTheme()

    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        self.selectionHighlightView.layer.cornerRadius = self.selectionHighlightView.frame.height / 2
        
        self.containerView.layer.cornerRadius = self.containerView.frame.height / 2
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)

        self.setupWithTheme()
    }

    override func prepareForReuse() {
        super.prepareForReuse()

        self.setupWithTheme()
        self.setSelectedType(false)

    }

    func setupWithTheme() {

        self.normalColor = UIColor.App.pills

        self.selectedColor = UIColor.App.highlightPrimary

        self.selectionHighlightView.backgroundColor = UIColor.App.highlightPrimary

        self.containerView.backgroundColor = UIColor.App.navPills

        self.setupWithSelection(self.selectedType)

        self.iconImageView.backgroundColor = .clear
        self.iconImageView.setImageColor(color: UIColor.App.textPrimary)

        self.titleLabel.textColor = UIColor.App.textPrimary

    }

    func setupInfo(title: String, iconName: String) {
        self.titleLabel.text = title

        self.iconImageView.image = UIImage(named: iconName)
        self.iconImageView.setImageColor(color: UIColor.App.textPrimary)

    }

    func setSelectedType(_ selected: Bool) {
        self.selectedType = selected
        self.setupWithSelection(self.selectedType)
    }

    func setupWithSelection(_ selected: Bool) {
        if selected {
            self.selectionHighlightView.backgroundColor = self.selectedColor
        }
        else {
            self.selectionHighlightView.backgroundColor = self.normalColor
        }
    }
}

extension CompetitionListIconCollectionViewCell {

    private static func createSelectionHighlightView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }

    private static func createContainerView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }

    private static func createTitleLabel() -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Title"
        label.font = AppFont.with(type: .bold, size: 14)
        label.textAlignment = .center
        return label
    }

    private static func createIconImageView() -> UIImageView {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        imageView.image = UIImage(named: "filter_funnel_icon")
        return imageView
    }

    private func setupSubviews() {

        self.contentView.addSubview(self.selectionHighlightView)

        self.selectionHighlightView.addSubview(self.containerView)

        self.containerView.addSubview(self.iconImageView)
        self.containerView.addSubview(self.titleLabel)

        self.initConstraints()

        self.setNeedsLayout()
        self.layoutIfNeeded()

        self.containerView.setNeedsLayout()
        self.containerView.layoutIfNeeded()
    }

    private func initConstraints() {

        NSLayoutConstraint.activate([
            self.selectionHighlightView.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor, constant: 1),
            self.selectionHighlightView.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor, constant: -1),
            self.selectionHighlightView.topAnchor.constraint(equalTo: self.contentView.topAnchor, constant: 1),
            self.selectionHighlightView.bottomAnchor.constraint(equalTo: self.contentView.bottomAnchor, constant: -1),
            self.selectionHighlightView.heightAnchor.constraint(equalToConstant: 40),

            self.containerView.leadingAnchor.constraint(equalTo: self.selectionHighlightView.leadingAnchor, constant: 2),
            self.containerView.trailingAnchor.constraint(equalTo: self.selectionHighlightView.trailingAnchor, constant: -2),
            self.containerView.topAnchor.constraint(equalTo: self.selectionHighlightView.topAnchor, constant: 2),
            self.containerView.bottomAnchor.constraint(equalTo: self.selectionHighlightView.bottomAnchor, constant: -2),

            self.iconImageView.widthAnchor.constraint(equalToConstant: 16),
            self.iconImageView.heightAnchor.constraint(equalTo: self.iconImageView.widthAnchor),
            self.iconImageView.leadingAnchor.constraint(equalTo: self.containerView.leadingAnchor, constant: 16),
            self.iconImageView.centerYAnchor.constraint(equalTo: self.containerView.centerYAnchor),

            self.titleLabel.leadingAnchor.constraint(equalTo: self.iconImageView.trailingAnchor, constant: 8),
            self.titleLabel.trailingAnchor.constraint(equalTo: self.containerView.trailingAnchor, constant: -16),
            self.titleLabel.centerYAnchor.constraint(equalTo: self.containerView.centerYAnchor)

        ])
    }
}
