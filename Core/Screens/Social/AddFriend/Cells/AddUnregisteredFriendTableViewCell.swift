//
//  AddUnregisteredFriendTableViewCell.swift
//  Sportsbook
//
//  Created by André Lascas on 20/04/2022.
//

import UIKit

class AddUnregisteredFriendTableViewCell: UITableViewCell {

    // MARK: Private Properties
    private lazy var iconBaseView: UIView = Self.createIconBaseView()
    private lazy var iconImageView: UIImageView = Self.createIconImageView()
    private lazy var titleLabel: UILabel = Self.createTitleLabel()
    private lazy var inviteButton: UIButton = Self.createInviteButton()
    private lazy var separatorLineView: UIView = Self.createSeparatorLineView()

    var viewModel: AddUnregisteredFriendCellViewModel?
    var didTapInviteAction: ((String) -> Void)?

    // MARK: Public Properties

    var hasSeparatorLine: Bool = true {
        didSet {
            self.separatorLineView.isHidden = !hasSeparatorLine
        }
    }

    // MARK: Lifetime and Cycle
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        self.setupSubviews()
        self.setupWithTheme()

        self.setNeedsLayout()
        self.layoutIfNeeded()

        self.inviteButton.addTarget(self, action: #selector(didTapInviteButton), for: .primaryActionTriggered)

    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func prepareForReuse() {
        super.prepareForReuse()

        self.titleLabel.text = ""

        self.hasSeparatorLine = true
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        self.iconBaseView.layer.cornerRadius = self.iconBaseView.frame.height / 2
        self.iconImageView.layer.cornerRadius = self.iconImageView.frame.height / 2

    }

    func setupWithTheme() {

        self.contentView.backgroundColor = UIColor.App.backgroundPrimary

        self.iconBaseView.backgroundColor = UIColor.App.backgroundTertiary

        self.iconImageView.backgroundColor = UIColor.App.backgroundTertiary

        self.titleLabel.textColor = UIColor.App.textPrimary

        self.inviteButton.backgroundColor = UIColor.App.buttonBackgroundSecondary
        self.inviteButton.setTitleColor(UIColor.App.textPrimary, for: .normal)

        self.separatorLineView.backgroundColor = UIColor.App.separatorLine

    }

    func configure(viewModel: AddUnregisteredFriendCellViewModel) {
        self.viewModel = viewModel

        self.titleLabel.text = viewModel.username

    }

    // MARK: Actions
    @objc func didTapInviteButton() {
        if let phoneNumber = self.viewModel?.phones.first {
            self.didTapInviteAction?(phoneNumber)
        }
    }

}

extension AddUnregisteredFriendTableViewCell {

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
        label.text = "@User"
        label.font = AppFont.with(type: .bold, size: 14)
        label.numberOfLines = 0
        return label
    }

    private static func createInviteButton() -> UIButton {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle(localized("invite"), for: .normal)
        button.titleLabel?.font = AppFont.with(type: .bold, size: 14)
        button.layer.cornerRadius = CornerRadius.button
        button.titleEdgeInsets = UIEdgeInsets(top: 0.0, left: 5.0, bottom: 0.0, right: 5.0)
        button.setContentHuggingPriority(.required, for: .horizontal)
        return button
    }

    private static func createSeparatorLineView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }

    private func setupSubviews() {

        self.contentView.addSubview(self.iconBaseView)

        self.iconBaseView.addSubview(self.iconImageView)

        self.contentView.addSubview(self.titleLabel)

        self.contentView.addSubview(self.inviteButton)

        self.contentView.addSubview(self.separatorLineView)

        self.initConstraints()

    }

    private func initConstraints() {

        NSLayoutConstraint.activate([
            self.iconBaseView.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor, constant: 25),
            self.iconBaseView.widthAnchor.constraint(equalToConstant: 40),
            self.iconBaseView.heightAnchor.constraint(equalTo: self.iconBaseView.widthAnchor),
            self.iconBaseView.centerYAnchor.constraint(equalTo: self.contentView.centerYAnchor),

            self.iconImageView.widthAnchor.constraint(equalToConstant: 30),
            self.iconImageView.heightAnchor.constraint(equalTo: self.iconImageView.widthAnchor),
            self.iconImageView.centerXAnchor.constraint(equalTo: self.iconBaseView.centerXAnchor),
            self.iconImageView.centerYAnchor.constraint(equalTo: self.iconBaseView.centerYAnchor),

            self.titleLabel.leadingAnchor.constraint(equalTo: self.iconBaseView.trailingAnchor, constant: 10),
            self.titleLabel.centerYAnchor.constraint(equalTo: self.contentView.centerYAnchor),

            self.inviteButton.leadingAnchor.constraint(equalTo: self.titleLabel.trailingAnchor, constant: 8),
            self.inviteButton.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor, constant: -25),
            self.inviteButton.heightAnchor.constraint(equalToConstant: 40),
            self.inviteButton.widthAnchor.constraint(greaterThanOrEqualToConstant: 64),
            self.inviteButton.centerYAnchor.constraint(equalTo: self.contentView.centerYAnchor),

            self.separatorLineView.leadingAnchor.constraint(equalTo: self.iconBaseView.leadingAnchor),
            self.separatorLineView.trailingAnchor.constraint(equalTo: self.inviteButton.trailingAnchor),
            self.separatorLineView.bottomAnchor.constraint(equalTo: self.contentView.bottomAnchor),
            self.separatorLineView.heightAnchor.constraint(equalToConstant: 1)

        ])

    }
}
