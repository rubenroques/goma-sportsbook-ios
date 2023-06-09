//
//  MakeYourBetTableViewCell.swift
//  Sportsbook
//
//  Created by Ruben Roques on 02/06/2023.
//

import Foundation
import UIKit

class MakeYourBetTableViewCell: UITableViewCell {

    private let cellHeight: CGFloat = 75.0

    private lazy var baseView: UIView = Self.createBaseView()
    private lazy var titleLabel: UILabel = Self.createTitleLabel()
    private lazy var swipeImageView: UIImageView = Self.createImageView()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

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
        self.contentView.backgroundColor = .clear

        self.baseView.backgroundColor = UIColor.App.backgroundOdds
        self.titleLabel.textColor = UIColor.App.buttonTextPrimary
    }

}

extension MakeYourBetTableViewCell {

    private static func createBaseView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.cornerRadius = 8
        view.clipsToBounds = true
        return view
    }

    private static func createTitleLabel() -> UILabel {
        let titleLabel = UILabel()
        titleLabel.numberOfLines = 2
        titleLabel.textAlignment = .center
        titleLabel.text = "MAKE YOUR\n              OWN BET"
        titleLabel.font = AppFont.with(type: .bold, size: 22)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        return titleLabel
    }

    private static func createImageView() -> UIImageView {
        let view = UIImageView()
        view.image = UIImage(named: "hand_pointing_image")
        view.translatesAutoresizingMaskIntoConstraints = false
        view.contentMode = .scaleAspectFit
        view.backgroundColor = .clear
        return view
    }

    private func setupSubviews() {
        // Add subviews to self.view or each other
        self.contentView.addSubview(self.baseView)
        self.baseView.addSubview(self.titleLabel)
        self.baseView.addSubview(self.swipeImageView)

        // Initialize constraints
        self.initConstraints()
    }

    private func initConstraints() {
        NSLayoutConstraint.activate([
            self.baseView.heightAnchor.constraint(equalToConstant: self.cellHeight),

            self.baseView.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor, constant: 18),
            self.baseView.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor, constant: -18),
            self.baseView.topAnchor.constraint(equalTo: self.contentView.topAnchor, constant: 6),
            self.baseView.bottomAnchor.constraint(equalTo: self.contentView.bottomAnchor, constant: -16),

            self.swipeImageView.widthAnchor.constraint(equalTo: self.swipeImageView.heightAnchor),
            self.swipeImageView.topAnchor.constraint(equalTo: self.baseView.topAnchor),
            self.swipeImageView.bottomAnchor.constraint(equalTo: self.baseView.bottomAnchor, constant: 28),
            self.swipeImageView.trailingAnchor.constraint(equalTo: self.baseView.trailingAnchor, constant: -12),

            self.titleLabel.leadingAnchor.constraint(equalTo: self.baseView.leadingAnchor),
            self.titleLabel.trailingAnchor.constraint(equalTo: self.swipeImageView.leadingAnchor),
            self.titleLabel.centerYAnchor.constraint(equalTo: self.baseView.centerYAnchor),
        ])
    }

}
