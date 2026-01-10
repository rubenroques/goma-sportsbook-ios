//
//  UserGodfatherView.swift
//  Sportsbook
//
//  Created by André Lascas on 14/07/2023.
//

import UIKit

class UserGodfatherView: UIView {

    // MARK: Private properties
    private lazy var containerView: UIView = Self.createContainerView()
    private lazy var iconBaseView: UIView = Self.createIconBaseView()
    private lazy var iconInnerView: UIView = Self.createIconInnerView()
    private lazy var iconImageView: UIImageView = Self.createIconImageView()
    private lazy var titleLabel: UILabel = Self.createTitleLabel()

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

        self.containerView.layer.cornerRadius = CornerRadius.squareView

        self.iconBaseView.layer.cornerRadius = self.iconBaseView.frame.height / 2

        self.iconInnerView.layer.cornerRadius = self.iconInnerView.frame.height / 2

    }

    func commonInit() {

    }

    func setupWithTheme() {
        self.backgroundColor = .clear

        self.containerView.backgroundColor = UIColor.App.backgroundPrimary
        self.containerView.layer.borderColor = UIColor.App.highlightPrimary.cgColor

        self.iconBaseView.backgroundColor = UIColor.App.textPrimary

        self.iconInnerView.backgroundColor = UIColor.App.backgroundPrimary

        self.iconImageView.backgroundColor = .clear

        self.titleLabel.textColor = UIColor.App.highlightPrimary

    }

    func configure(title: String, icon: String) {
        self.titleLabel.text = title

        self.iconImageView.image = UIImage(named: icon)
    }
}

extension UserGodfatherView {

    private static func createContainerView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.borderWidth = 1
        return view
    }

    private static func createIconBaseView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }

    private static func createIconInnerView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }

    private static func createIconImageView() -> UIImageView {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.image = UIImage(named: "avatar1")
        imageView.contentMode = .scaleAspectFit
        return imageView
    }

    private static func createTitleLabel() -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "User"
        label.font = AppFont.with(type: .bold, size: 16)
        label.numberOfLines = 0
        return label
    }

    private func setupSubviews() {
        self.addSubview(self.containerView)

        self.containerView.addSubview(self.iconBaseView)

        self.iconBaseView.addSubview(self.iconInnerView)
        self.iconBaseView.addSubview(self.iconImageView)

        self.containerView.addSubview(self.titleLabel)

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

            self.iconBaseView.leadingAnchor.constraint(equalTo: self.containerView.leadingAnchor, constant: 15),
            self.iconBaseView.widthAnchor.constraint(equalToConstant: 50),
            self.iconBaseView.heightAnchor.constraint(equalTo: self.iconBaseView.widthAnchor),
            self.iconBaseView.topAnchor.constraint(equalTo: self.containerView.topAnchor, constant: 10),
            self.iconBaseView.bottomAnchor.constraint(equalTo: self.containerView.bottomAnchor, constant: -10),

            self.iconInnerView.leadingAnchor.constraint(equalTo: self.iconBaseView.leadingAnchor, constant: 1),
            self.iconInnerView.trailingAnchor.constraint(equalTo: self.iconBaseView.trailingAnchor, constant: -1),
            self.iconInnerView.topAnchor.constraint(equalTo: self.iconBaseView.topAnchor, constant: 1),
            self.iconInnerView.bottomAnchor.constraint(equalTo: self.iconBaseView.bottomAnchor, constant: -1),

            self.iconImageView.leadingAnchor.constraint(equalTo: self.iconBaseView.leadingAnchor),
            self.iconImageView.trailingAnchor.constraint(equalTo: self.iconBaseView.trailingAnchor),
            self.iconImageView.topAnchor.constraint(equalTo: self.iconBaseView.topAnchor),
            self.iconImageView.bottomAnchor.constraint(equalTo: self.iconBaseView.bottomAnchor),

            self.titleLabel.leadingAnchor.constraint(equalTo: self.iconBaseView.trailingAnchor, constant: 10),
            self.titleLabel.trailingAnchor.constraint(equalTo: self.containerView.trailingAnchor, constant: -15),
            self.titleLabel.centerYAnchor.constraint(equalTo: self.iconBaseView.centerYAnchor)

        ])

    }

}
