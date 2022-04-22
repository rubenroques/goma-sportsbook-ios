//
//  GroupUserManagementTableViewCell.swift
//  Sportsbook
//
//  Created by André Lascas on 22/04/2022.
//

import UIKit

class GroupUserManagementTableViewCell: UITableViewCell {

    // MARK: Private Properties
    private lazy var iconBaseView: UIView = Self.createIconBaseView()
    private lazy var iconImageView: UIImageView = Self.createIconImageView()
    private lazy var userInfoStackView: UIStackView = Self.createUserInfoStackView()
    private lazy var titleLabel: UILabel = Self.createTitleLabel()
    private lazy var userAdminBaseView: UIView = Self.createUserAdminBaseView()
    private lazy var userAdminInnerView: UIView = Self.createUserAdminInnerView()
    private lazy var userAdminLabel: UILabel = Self.createUserAdminLabel()
    private lazy var userStateBaseView: UIView = Self.createUserStateBaseView()
    private lazy var userStateView: UIView = Self.createUserStateView()
    private lazy var deleteButton: UIButton = Self.createDeleteButton()
    private lazy var separatorLineView: UIView = Self.createSeparatorLineView()

    var viewModel: GroupUserManagementCellViewModel?
    var didTapDeleteAction: (() -> Void)?
    // MARK: Public Properties

    var hasSeparatorLine: Bool = true {
        didSet {
            self.separatorLineView.isHidden = !hasSeparatorLine
        }
    }

    var isOnline: Bool = false {
        didSet {
            self.userStateBaseView.isHidden = !isOnline
        }
    }

    var isAdmin: Bool = false {
        didSet {
            self.userAdminBaseView.isHidden = !isAdmin
        }
    }

    // MARK: Lifetime and Cycle
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        self.setupSubviews()
        self.setupWithTheme()

        self.setNeedsLayout()
        self.layoutIfNeeded()

    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func prepareForReuse() {
        super.prepareForReuse()

        self.titleLabel.text = ""

        self.isOnline = false

        self.hasSeparatorLine = true
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        self.iconBaseView.layer.cornerRadius = self.iconBaseView.frame.height / 2

        self.iconImageView.layer.cornerRadius = self.iconImageView.frame.height / 2

        self.userStateView.layer.cornerRadius = self.userStateView.frame.height / 2
    }

    func setupWithTheme() {

        self.contentView.backgroundColor = UIColor.App.backgroundPrimary

        self.iconBaseView.backgroundColor = UIColor.App.backgroundTertiary

        self.iconImageView.backgroundColor = UIColor.App.backgroundTertiary

        self.userInfoStackView.backgroundColor = UIColor.App.backgroundPrimary

        self.titleLabel.textColor = UIColor.App.textPrimary

        self.userAdminBaseView.backgroundColor = UIColor.App.backgroundPrimary

        self.userAdminInnerView.backgroundColor = UIColor.App.backgroundOdds

        self.userAdminLabel.textColor = UIColor.App.textPrimary

        self.userStateBaseView.backgroundColor = UIColor.App.backgroundPrimary

        self.userStateView.backgroundColor = UIColor.App.alertSuccess

        self.deleteButton.backgroundColor = .clear

        self.separatorLineView.backgroundColor = UIColor.App.separatorLine

    }

    func configure(viewModel: GroupUserManagementCellViewModel) {
        self.viewModel = viewModel

        self.titleLabel.text = viewModel.username

        self.isOnline = viewModel.isOnline

        self.isAdmin = viewModel.isAdmin

    }

    // MARK: Actions
    @objc func didTapDeleteButton() {
        print("DELETE!")
        self.didTapDeleteAction?()
    }

}

extension GroupUserManagementTableViewCell {

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

    private static func createUserInfoStackView() -> UIStackView {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .horizontal
        stackView.spacing = 8
        stackView.distribution = .fill
        return stackView
    }

    private static func createTitleLabel() -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "@User"
        label.font = AppFont.with(type: .bold, size: 14)
        label.numberOfLines = 0
        label.setContentHuggingPriority(.required, for: .horizontal)
        label.setContentCompressionResistancePriority(.required, for: .horizontal)
        return label
    }

    private static func createUserAdminBaseView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.setContentHuggingPriority(.required, for: .horizontal)
        view.setContentCompressionResistancePriority(.required, for: .horizontal)
        return view
    }

    private static func createUserAdminInnerView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }

    private static func createUserAdminLabel() -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "ADM"
        label.font = AppFont.with(type: .bold, size: 8)
        return label
    }

    private static func createUserStateBaseView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.setContentHuggingPriority(.defaultLow, for: .horizontal)
        view.setContentCompressionResistancePriority(.defaultHigh, for: .horizontal)
        return view
    }

    private static func createUserStateView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }

    private static func createDeleteButton() -> UIButton {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setImage(UIImage(named: "trash_icon"), for: .normal)
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

        self.contentView.addSubview(self.userInfoStackView)

        self.userInfoStackView.addArrangedSubview(self.titleLabel)

        self.userInfoStackView.addArrangedSubview(self.userAdminBaseView)

        self.userAdminBaseView.addSubview(self.userAdminInnerView)

        self.userAdminInnerView.addSubview(self.userAdminLabel)

        self.userInfoStackView.addArrangedSubview(self.userStateBaseView)

        self.userStateBaseView.addSubview(self.userStateView)

        self.contentView.addSubview(self.deleteButton)

        self.contentView.addSubview(self.separatorLineView)

        self.initConstraints()

        self.deleteButton.addTarget(self, action: #selector(didTapDeleteButton), for: .primaryActionTriggered)

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

            self.deleteButton.leadingAnchor.constraint(equalTo: self.userInfoStackView.trailingAnchor, constant: 8),
            self.deleteButton.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor, constant: -25),
            self.deleteButton.widthAnchor.constraint(equalToConstant: 40),
            self.deleteButton.heightAnchor.constraint(equalTo: self.deleteButton.widthAnchor),
            self.deleteButton.centerYAnchor.constraint(equalTo: self.contentView.centerYAnchor),

            self.separatorLineView.leadingAnchor.constraint(equalTo: self.iconBaseView.leadingAnchor),
            self.separatorLineView.trailingAnchor.constraint(equalTo: self.deleteButton.trailingAnchor),
            self.separatorLineView.bottomAnchor.constraint(equalTo: self.contentView.bottomAnchor),
            self.separatorLineView.heightAnchor.constraint(equalToConstant: 1)

        ])

        // Stackview
        NSLayoutConstraint.activate([
            self.userInfoStackView.leadingAnchor.constraint(equalTo: self.iconBaseView.trailingAnchor, constant: 15),
            self.userInfoStackView.centerYAnchor.constraint(equalTo: self.contentView.centerYAnchor),
            self.userInfoStackView.heightAnchor.constraint(equalToConstant: 30),

            self.userAdminBaseView.widthAnchor.constraint(greaterThanOrEqualToConstant: 30),

            self.userAdminInnerView.widthAnchor.constraint(equalToConstant: 25),
            self.userAdminInnerView.heightAnchor.constraint(equalToConstant: 10),
            self.userAdminInnerView.centerYAnchor.constraint(equalTo: self.userAdminBaseView.centerYAnchor),
            self.userAdminInnerView.leadingAnchor.constraint(equalTo: self.userAdminBaseView.leadingAnchor),

            self.userAdminLabel.centerXAnchor.constraint(equalTo: self.userAdminInnerView.centerXAnchor),
            self.userAdminLabel.centerYAnchor.constraint(equalTo: self.userAdminInnerView.centerYAnchor),

            self.userStateBaseView.widthAnchor.constraint(greaterThanOrEqualToConstant: 10),

            self.userStateView.widthAnchor.constraint(equalToConstant: 8),
            self.userStateView.heightAnchor.constraint(equalTo: self.userStateView.widthAnchor),
            self.userStateView.leadingAnchor.constraint(equalTo: self.userStateBaseView.leadingAnchor),
            self.userStateView.centerYAnchor.constraint(equalTo: self.userStateBaseView.centerYAnchor)
        ])

    }
}
