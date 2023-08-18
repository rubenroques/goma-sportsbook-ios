//
//  MakeYourBetTableViewCell.swift
//  Sportsbook
//
//  Created by Ruben Roques on 02/06/2023.
//

import Foundation
import UIKit

class MakeYourBetTableViewCell: UITableViewCell {

    var didTapCellAction: (() -> Void) = { }

    private let cellHeight: CGFloat = 75.0

    private lazy var baseView: UIView = Self.createBaseView()
    private lazy var swipeImageView: UIImageView = Self.createImageView()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        self.setupSubviews()
        self.setupWithTheme()

        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(didTapCell))
        self.addGestureRecognizer(tapGesture)
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

//        self.baseView.layer.borderWidth = 1
//        self.baseView.layer.borderColor = UIColor.App.highlightSecondary.cgColor

        self.baseView.backgroundColor = .clear
        // self.titleLabel.textColor = UIColor.App.textPrimary
    }

    @objc func didTapCell() {
        self.didTapCellAction()
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

//    private static func createTitleLabel() -> UILabel {
//        let titleLabel = UILabel()
//        titleLabel.numberOfLines = 2
//        titleLabel.textAlignment = .center
//        titleLabel.text = "MAKE YOUR\n              OWN BET"
//        titleLabel.font = AppFont.with(type: .bold, size: 22)
//        titleLabel.translatesAutoresizingMaskIntoConstraints = false
//        return titleLabel
//    }
//
//    private static func createImageView() -> UIImageView {
//        let view = UIImageView()
//        view.image = UIImage(named: "hand_pointing_image")
//        view.translatesAutoresizingMaskIntoConstraints = false
//        view.contentMode = .scaleAspectFit
//        view.backgroundColor = .clear
//        return view
//    }

    private static func createImageView() -> UIImageView {
        let view = UIImageView()
        view.image = UIImage(named: "bet_swipe_banner_v2")
        view.translatesAutoresizingMaskIntoConstraints = false
        view.contentMode = .scaleAspectFit
        view.backgroundColor = .clear
        view.layer.cornerRadius = 6
        view.layer.masksToBounds = true
        return view
    }

    private func setupSubviews() {
        // Add subviews to self.view or each other
        self.contentView.addSubview(self.baseView)

        self.baseView.addSubview(self.swipeImageView)

        // Initialize constraints
        self.initConstraints()
    }

    private func initConstraints() {
        NSLayoutConstraint.activate([
            // self.baseView.heightAnchor.constraint(equalToConstant: self.cellHeight),
            self.baseView.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor),
            self.baseView.topAnchor.constraint(equalTo: self.contentView.topAnchor, constant: 16),
            self.baseView.centerXAnchor.constraint(equalTo: self.contentView.centerXAnchor),
            self.baseView.centerYAnchor.constraint(equalTo: self.contentView.centerYAnchor),

            // Apply the aspect ratio constraint here (1056:216 = 4.8888)
            self.swipeImageView.widthAnchor.constraint(equalTo: self.swipeImageView.heightAnchor, multiplier: 4.89),

            self.swipeImageView.topAnchor.constraint(equalTo: self.baseView.topAnchor),
            self.swipeImageView.centerXAnchor.constraint(equalTo: self.baseView.centerXAnchor),
            self.swipeImageView.leadingAnchor.constraint(equalTo: self.baseView.leadingAnchor, constant: 17),
            self.swipeImageView.centerYAnchor.constraint(equalTo: self.baseView.centerYAnchor),
        ])
    }

}
