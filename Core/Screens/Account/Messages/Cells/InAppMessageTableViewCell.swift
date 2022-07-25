//
//  InAppMessageTableViewCell.swift
//  Sportsbook
//
//  Created by André Lascas on 25/07/2022.
//

import UIKit
import Combine

class InAppMessageTableViewCell: UITableViewCell {

    // MARK: Private Properties
    private lazy var containerView: UIView = Self.createContainerView()
    private lazy var backgroundImageView: UIImageView = Self.createBackgroundImageView()

    // MARK: Public Properties
    var hasBackgroundImage: Bool = false {
        didSet {
            self.backgroundImageView.isHidden = !hasBackgroundImage
        }
    }

    // MARK: Lifetime and Cycle
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        self.setupSubviews()
        self.setupWithTheme()

        self.setNeedsLayout()
        self.layoutIfNeeded()

        self.hasBackgroundImage = false
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func prepareForReuse() {
        super.prepareForReuse()

        self.hasBackgroundImage = false

    }

    override func layoutSubviews() {
        super.layoutSubviews()

        self.containerView.layer.cornerRadius = CornerRadius.view
    }

    func setupWithTheme() {

        self.contentView.backgroundColor = UIColor.App.backgroundPrimary

        self.containerView.backgroundColor = UIColor.App.alertSuccess

        self.backgroundImageView.backgroundColor = .clear

    }

    func configure(cardType: MessageCardType) {
        switch cardType {
        case .promo:
            self.backgroundImageView.image = UIImage(named: "mastercard_logo")
            self.hasBackgroundImage = true
        case .bettingNew:
            ()
        case .maintenance:
            ()
        }
    }

}

extension InAppMessageTableViewCell {

    private static func createContainerView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }

    private static func createBackgroundImageView() -> UIImageView {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        return imageView
    }

    private func setupSubviews() {

        self.contentView.addSubview(self.containerView)

        self.containerView.addSubview(self.backgroundImageView)

        self.initConstraints()

    }

    private func initConstraints() {

        NSLayoutConstraint.activate([
            self.containerView.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor, constant: 0),
            self.containerView.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor, constant: 0),
            self.containerView.topAnchor.constraint(equalTo: self.contentView.topAnchor, constant: 4),
            self.containerView.bottomAnchor.constraint(equalTo: self.contentView.bottomAnchor, constant: -4),
            self.containerView.heightAnchor.constraint(equalToConstant: 88),

            self.backgroundImageView.leadingAnchor.constraint(equalTo: self.containerView.leadingAnchor),
            self.backgroundImageView.trailingAnchor.constraint(equalTo: self.containerView.trailingAnchor),
            self.backgroundImageView
                .topAnchor.constraint(equalTo: self.containerView.topAnchor),
            self.backgroundImageView.bottomAnchor.constraint(equalTo: self.containerView.bottomAnchor)

        ])

    }
}

enum MessageCardType {
    case promo
    case bettingNew
    case maintenance
}
