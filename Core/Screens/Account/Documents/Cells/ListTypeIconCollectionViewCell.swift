//
//  ListTypeIconCollectionViewCell.swift
//  Sportsbook
//
//  Created by André Lascas on 01/06/2023.
//

import UIKit

class ListTypeIconCollectionViewCell: UICollectionViewCell {

    private lazy var selectionHighlightView: UIView = Self.createSelectionHighlightView()
    private lazy var containerView: UIView = Self.createContainerView()
    private lazy var stackView: UIStackView = Self.createStackView()
    private lazy var titleLabel: UILabel = Self.createTitleLabel()
    private lazy var iconImageView: UIImageView = Self.createIconImageView()

    var selectedColor: UIColor = .white
    var normalColor: UIColor = .black

    var selectedType: Bool = false

    var hasIcon: Bool = false {
        didSet {
            self.iconImageView.isHidden = !hasIcon
        }
    }

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

        self.selectionHighlightView.layer.cornerRadius = self.selectionHighlightView.frame.size.height / 2
        self.containerView.layer.cornerRadius = self.containerView.frame.size.height / 2
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)

        self.setupWithTheme()
    }

    override func prepareForReuse() {
        super.prepareForReuse()

        self.setupWithTheme()
        self.setSelectedType(false)

        self.hasIcon = false
    }

    func setupWithTheme() {
        self.normalColor = UIColor.App.pillBackground
        self.selectedColor = UIColor.App.highlightPrimary
        self.selectionHighlightView.backgroundColor = UIColor.App.highlightPrimary
        self.containerView.backgroundColor = UIColor.App.pillBackground
        self.setupWithSelection(self.selectedType)

        self.titleLabel.textColor = UIColor.App.textPrimary

        self.stackView.backgroundColor = .clear

    }

    func setupInfo(title: String, iconName: String? = nil) {
        self.titleLabel.text = title

        if let iconName {
            self.iconImageView.image = UIImage(named: iconName)
            self.hasIcon = true
        }
        else {
            self.hasIcon = false
        }
    }

    func setSelectedType(_ selected: Bool) {
        self.selectedType = selected
        self.setupWithSelection(self.selectedType)
    }

    func setupWithSelection(_ selected: Bool) {
        if selected {
            self.selectionHighlightView.backgroundColor = self.selectedColor
            self.containerView.backgroundColor = self.normalColor
        }
        else {
            self.selectionHighlightView.backgroundColor = self.normalColor
            self.containerView.backgroundColor = self.normalColor
        }
    }
}

extension ListTypeIconCollectionViewCell {

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

    private static func createStackView() -> UIStackView {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .horizontal
        stackView.distribution = .equalSpacing
        stackView.spacing = 4
        return stackView
    }

    private static func createTitleLabel() -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Title"
        label.font = AppFont.with(type: .semibold, size: 14)
        label.textAlignment = .center
        return label
    }

    private static func createIconImageView() -> UIImageView {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        imageView.image = UIImage(named: "calendar_expired_icon")
        return imageView
    }

    private func setupSubviews() {

        self.contentView.addSubview(self.selectionHighlightView)

        self.selectionHighlightView.addSubview(self.containerView)

        self.containerView.addSubview(self.stackView)

        self.stackView.addArrangedSubview(self.titleLabel)
        self.stackView.addArrangedSubview(self.iconImageView)

        self.initConstraints()

        self.setNeedsLayout()
        self.layoutIfNeeded()
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

            self.stackView.leadingAnchor.constraint(equalTo: self.containerView.leadingAnchor, constant: 12),
            self.stackView.trailingAnchor.constraint(equalTo: self.containerView.trailingAnchor, constant: -12),
            self.stackView.centerYAnchor.constraint(equalTo: self.containerView.centerYAnchor),

            self.titleLabel.centerYAnchor.constraint(equalTo: self.stackView.centerYAnchor),

            self.iconImageView.widthAnchor.constraint(equalToConstant: 14),
            self.iconImageView.heightAnchor.constraint(equalTo: self.iconImageView.widthAnchor),
            self.iconImageView.centerYAnchor.constraint(equalTo: self.stackView.centerYAnchor)

        ])
    }
}
