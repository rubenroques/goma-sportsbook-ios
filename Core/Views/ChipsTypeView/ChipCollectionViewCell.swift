//
//  ChipCollectionViewCell.swift
//  Sportsbook
//
//  Created by Ruben Roques on 23/01/2025.
//

import UIKit
import Combine
import SwiftUI

class ChipCollectionViewCell: UICollectionViewCell {

    static let cellHeight: CGFloat = 42

    private lazy var selectionHighlightView: UIView = Self.createSelectionHighlightView()
    private lazy var containerView: UIView = Self.createContainerView()
    private lazy var backgroundImageView: UIImageView = Self.createBackgroundImageView()
    private lazy var contentStackView: UIStackView = Self.createContentStackView()
    private lazy var iconImageView: UIImageView = Self.createIconImageView()
    private lazy var titleLabel: UILabel = Self.createTitleLabel()

    var selectedColor: UIColor = .white
    var normalColor: UIColor = .black
    var isCustomDesign: Bool = false
    var hasBackgroundStyle: Bool = false

    override var isSelected: Bool {
        didSet {
            self.drawSelectionState()
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)

        self.isSelected = false

        self.setupSubviews()
        self.setupWithTheme()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)

        self.setupWithTheme()
    }

    override func prepareForReuse() {
        super.prepareForReuse()

        self.titleLabel.text = ""
        self.isSelected = false
        self.isCustomDesign = false
        self.hasBackgroundStyle = false
        
        self.iconImageView.image = nil
        self.backgroundImageView.image = nil

        self.setupWithTheme()
        self.drawSelectionState()
    }

    func setupWithTheme() {
        self.normalColor = UIColor.App.pillBackground
        self.selectedColor = UIColor.App.highlightPrimary

        self.titleLabel.textColor = UIColor.App.textPrimary
        self.containerView.backgroundColor = hasBackgroundStyle ? UIColor.App.pillNavigation : .clear

        self.drawSelectionState()
    }

    private func drawSelectionState() {
        if self.isSelected {
            self.selectionHighlightView.backgroundColor = self.selectedColor
            self.containerView.backgroundColor = hasBackgroundStyle ? UIColor.App.pillNavigation : self.normalColor
        }
        else {
            self.selectionHighlightView.backgroundColor = self.normalColor
            self.containerView.backgroundColor = hasBackgroundStyle ? UIColor.App.pillNavigation : self.normalColor
        }
    }

    func setup(with type: ChipType) {
        switch type {
        case .textual(let title):
            self.hasBackgroundStyle = false
            self.titleLabel.text = title
            self.iconImageView.image = nil
            self.iconImageView.isHidden = true
            self.backgroundImageView.image = nil

        case .icon(let title, let iconName):
            self.hasBackgroundStyle = true
            self.titleLabel.text = title
            self.iconImageView.image = UIImage(named: iconName)
            self.iconImageView.isHidden = false
            self.backgroundImageView.image = nil

        case .backgroungImage(let title, let iconName, let imageName):
            self.hasBackgroundStyle = true
            self.titleLabel.text = title
            self.titleLabel.textColor = UIColor.App.buttonTextPrimary
            self.iconImageView.image = UIImage(named: iconName)
            self.iconImageView.isHidden = false
            self.backgroundImageView.image = UIImage(named: imageName)
        }

        if self.isCustomDesign {
            let text = type.title
            let attributedString = NSMutableAttributedString(string: text)
            let fullRange = (text as NSString).range(of: text)
            let range = (text as NSString).range(of: localized("mix_match_mix_string"))

            attributedString.addAttribute(.foregroundColor, value: UIColor.App.buttonTextPrimary, range: fullRange)
            attributedString.addAttribute(.font, value: AppFont.with(type: .semibold, size: 14), range: fullRange)

            attributedString.addAttribute(.foregroundColor, value: UIColor.App.highlightPrimary, range: range)

            self.titleLabel.attributedText = attributedString
        }

        self.drawSelectionState()
    }

    // Remove later
    func setSelectedType(_ bool: Bool) {

    }

    override var intrinsicContentSize: CGSize {
        return self.contentView.frame.size
    }

}

// MARK: - UI Creation
extension ChipCollectionViewCell {

    private static func createSelectionHighlightView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.cornerRadius = (Self.cellHeight - 2) / 2
        view.clipsToBounds = true
        return view
    }

    private static func createContainerView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.cornerRadius = (Self.cellHeight - 4) / 2
        view.clipsToBounds = true
        return view
    }

    private static func createBackgroundImageView() -> UIImageView {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        imageView.layer.cornerRadius = (Self.cellHeight - 4) / 2
        imageView.clipsToBounds = true
        return imageView
    }

    private static func createIconImageView() -> UIImageView {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFill
        return imageView
    }

    private static func createTitleLabel() -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = AppFont.with(type: .bold, size: 14)
        return label
    }

    private static func createContentStackView() -> UIStackView {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .horizontal
        stackView.alignment = .center
        stackView.spacing = 4
        return stackView
    }

    private func setupSubviews() {
        self.contentView.addSubview(self.selectionHighlightView)
        self.selectionHighlightView.addSubview(self.containerView)

        self.containerView.addSubview(self.backgroundImageView)
        self.containerView.addSubview(self.contentStackView)

        self.contentStackView.addArrangedSubview(self.iconImageView)
        self.contentStackView.addArrangedSubview(self.titleLabel)

        self.initConstraints()
    }

    private func initConstraints() {
        NSLayoutConstraint.activate([
            self.contentView.heightAnchor.constraint(equalToConstant: Self.cellHeight),

            self.selectionHighlightView.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor, constant: 1),
            self.selectionHighlightView.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor, constant: -1),
            self.selectionHighlightView.topAnchor.constraint(equalTo: self.contentView.topAnchor, constant: 1),
            self.selectionHighlightView.bottomAnchor.constraint(equalTo: self.contentView.bottomAnchor, constant: -1),

            self.containerView.leadingAnchor.constraint(equalTo: self.selectionHighlightView.leadingAnchor, constant: 2),
            self.containerView.trailingAnchor.constraint(equalTo: self.selectionHighlightView.trailingAnchor, constant: -2),
            self.containerView.topAnchor.constraint(equalTo: self.selectionHighlightView.topAnchor, constant: 2),
            self.containerView.bottomAnchor.constraint(equalTo: self.selectionHighlightView.bottomAnchor, constant: -2),

            self.backgroundImageView.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor),
            self.backgroundImageView.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor),
            self.backgroundImageView.topAnchor.constraint(equalTo: self.contentView.topAnchor),
            self.backgroundImageView.bottomAnchor.constraint(equalTo: self.contentView.bottomAnchor),

            self.contentStackView.leadingAnchor.constraint(equalTo: self.containerView.leadingAnchor, constant: 16),
            self.contentStackView.trailingAnchor.constraint(equalTo: self.containerView.trailingAnchor, constant: -16),
            self.contentStackView.centerYAnchor.constraint(equalTo: self.containerView.centerYAnchor),

            self.iconImageView.widthAnchor.constraint(equalToConstant: 25),
            self.iconImageView.heightAnchor.constraint(equalToConstant: 34)
        ])
    }
}
