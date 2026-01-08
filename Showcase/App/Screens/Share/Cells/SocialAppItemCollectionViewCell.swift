//
//  SocialAppItemCollectionViewCell.swift
//  Sportsbook
//
//  Created by André Lascas on 04/07/2022.
//

import UIKit

struct SocialAppItemCellViewModel {

    private var socialApp: SocialApp

    init(socialApp: SocialApp) {
        self.socialApp = socialApp
    }

    func getSocialAppId() -> String {
        return self.socialApp.id ?? ""
    }

    func getSocialAppName() -> String {
        return self.socialApp.name
    }

    func getSocialAppIconName() -> String {
        return self.socialApp.iconName ?? ""
    }

}

class SocialAppItemCollectionViewCell: UICollectionViewCell {

    // MARK: Private properties
    private lazy var containerView: UIView = Self.createContainerView()
    private lazy var iconBaseView: UIView = Self.createIconBaseView()
    private lazy var iconImageView: UIImageView = Self.createIconImageView()
    private lazy var titleLabel: UILabel = Self.createTitleLabel()
    private lazy var itemDisabledView: UIView = Self.createItemDisabledView()
    private var viewModel: SocialAppItemCellViewModel?

    // MARK: Public Properties
    var shouldShowSocialShare: (() -> Void)?

    var isItemDisabled: Bool = false {
        didSet {
            self.itemDisabledView.isHidden = !isItemDisabled
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)

        self.setupSubviews()
        self.setupWithTheme()

        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(didTapItem))
        self.contentView.addGestureRecognizer(tapGesture)

    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func prepareForReuse() {
        super.prepareForReuse()

        self.viewModel = nil

        self.isItemDisabled = false

    }

    override func layoutSubviews() {
        super.layoutSubviews()

        self.iconBaseView.layer.cornerRadius = self.iconBaseView.frame.height / 2
        self.iconBaseView.layer.masksToBounds = true

        self.iconImageView.layer.cornerRadius = self.iconImageView.frame.height / 2
        self.iconImageView.layer.masksToBounds = true

    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)

        self.setupWithTheme()
    }

    func setupWithTheme() {
        self.backgroundView?.backgroundColor = .clear
        self.backgroundColor = .clear
        self.contentView.backgroundColor = .clear

        self.iconBaseView.backgroundColor = UIColor.App.backgroundPrimary

        self.iconImageView.backgroundColor = .clear

        self.titleLabel.textColor = UIColor.App.textPrimary

        self.itemDisabledView.backgroundColor = UIColor.App.backgroundPrimary.withAlphaComponent(0.7)
    }

    // MARK: Functions

    func configure(withViewModel viewModel: SocialAppItemCellViewModel) {

        self.viewModel = viewModel

        self.titleLabel.text = viewModel.getSocialAppName()

        self.iconImageView.image = UIImage(named: viewModel.getSocialAppIconName())
    }

    // MARK: Actions
    @objc func didTapItem() {
        if let viewModel = self.viewModel {
            print("TAPPED SOCIAL APP: \(viewModel.getSocialAppName())")
            self.shouldShowSocialShare?()
        }

    }
}

extension SocialAppItemCollectionViewCell {

    private static func createContainerView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }

    private static func createIconBaseView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }

    private static func createIconImageView() -> UIImageView {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.image = UIImage(named: "my_account_profile_icon")
        imageView.contentMode = .scaleAspectFit
        return imageView
    }

    private static func createTitleLabel() -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 1
        label.textAlignment = .center
        label.text = "Social App"
        label.font = AppFont.with(type: .semibold, size: 14)
        return label
    }

    private static func createItemDisabledView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }

    private func setupSubviews() {

        self.contentView.addSubview(self.containerView)

        self.containerView.addSubview(self.iconBaseView)

        self.iconBaseView.addSubview(self.iconImageView)

        self.containerView.addSubview(self.titleLabel)

        self.containerView.addSubview(self.itemDisabledView)

        self.initConstraints()

        self.containerView.layoutIfNeeded()
        self.containerView.layoutSubviews()
    }

    private func initConstraints() {

        NSLayoutConstraint.activate([
            self.containerView.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor),
            self.containerView.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor),
            self.containerView.topAnchor.constraint(equalTo: self.contentView.topAnchor),
            self.containerView.bottomAnchor.constraint(equalTo: self.contentView.bottomAnchor),

            self.iconBaseView.topAnchor.constraint(equalTo: self.containerView.topAnchor, constant: 8),
            self.iconBaseView.heightAnchor.constraint(equalToConstant: 50),
            self.iconBaseView.widthAnchor.constraint(equalTo: self.iconBaseView.heightAnchor),
            self.iconBaseView.centerXAnchor.constraint(equalTo: self.containerView.centerXAnchor),

            self.iconImageView.centerXAnchor.constraint(equalTo: self.iconBaseView.centerXAnchor),
            self.iconImageView.centerYAnchor.constraint(equalTo: self.iconBaseView.centerYAnchor),
            self.iconImageView.widthAnchor.constraint(equalTo: self.iconBaseView.widthAnchor),
            self.iconImageView.heightAnchor.constraint(equalTo: self.iconImageView.widthAnchor),

            self.titleLabel.leadingAnchor.constraint(equalTo: self.containerView.leadingAnchor, constant: 8),
            self.titleLabel.trailingAnchor.constraint(equalTo: self.containerView.trailingAnchor, constant: -8),
            self.titleLabel.topAnchor.constraint(equalTo: self.iconBaseView.bottomAnchor, constant: 8),

            self.itemDisabledView.leadingAnchor.constraint(equalTo: self.containerView.leadingAnchor),
            self.itemDisabledView.trailingAnchor.constraint(equalTo: self.containerView.trailingAnchor),
            self.itemDisabledView.topAnchor.constraint(equalTo: self.containerView.topAnchor),
            self.itemDisabledView.bottomAnchor.constraint(equalTo: self.containerView.bottomAnchor)

        ])
    }
}
