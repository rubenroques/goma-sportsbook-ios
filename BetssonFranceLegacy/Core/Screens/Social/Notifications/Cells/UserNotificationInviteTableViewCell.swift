//
//  UserNotificationInviteTableViewCell.swift
//  Sportsbook
//
//  Created by André Lascas on 30/09/2022.
//

import UIKit
class UserNotificationInviteCellViewModel {

    var friendRequest: FriendRequest

    init(friendRequest: FriendRequest) {
        self.friendRequest = friendRequest
    }

    func getFriendRequestName() -> String {
        return self.friendRequest.name
    }

    func getFriendRequestUsername() -> String {
        return self.friendRequest.username
    }

    func getFriendRequestId() -> Int {
        return self.friendRequest.id
    }
}

class UserNotificationInviteTableViewCell: UITableViewCell {

    // MARK: Private Properties
    private lazy var containerView: UIView = Self.createContainerView()
    private lazy var topInfoView: UIView = Self.createTopInfoView()
    private lazy var iconBaseView: UIView = Self.createIconBaseView()
    private lazy var iconImageView: UIImageView = Self.createIconImageView()
    private lazy var titleLabel: UILabel = Self.createTitleLabel()
    private lazy var acceptButton: UIButton = Self.createAcceptButton()
    private lazy var rejectButton: UIButton = Self.createRejectButton()
    private lazy var separatorLineView: UIView = Self.createSeparatorLineView()

    // MARK: Public Properties
    var viewModel: UserNotificationInviteCellViewModel?

    var tappedAcceptAction: ((Int) -> Void)?
    var tappedRejectAction: ((Int) -> Void)?

//    var isUnread: Bool = false {
//        didSet {
//            if isUnread {
//                self.iconBaseView.backgroundColor = UIColor.App.highlightPrimary
//            }
//            else {
//                self.iconBaseView.backgroundColor = UIColor.App.backgroundTertiary
//            }
//        }
//    }

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

        self.acceptButton.addTarget(self, action: #selector(didTapAcceptButton), for: .primaryActionTriggered)

        self.rejectButton.addTarget(self, action: #selector(didTapDeclineButton), for: .primaryActionTriggered)

    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func prepareForReuse() {
        super.prepareForReuse()

        self.titleLabel.text = ""

        self.hasSeparatorLine = false
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        self.containerView.layer.cornerRadius = CornerRadius.view
        self.containerView.layer.masksToBounds = true

        self.iconBaseView.layer.cornerRadius = self.iconBaseView.frame.height / 2
        self.iconBaseView.layer.masksToBounds = true

        self.iconImageView.layer.cornerRadius = self.iconImageView.frame.height / 2
        self.iconImageView.layer.masksToBounds = true

        self.acceptButton.layer.cornerRadius = CornerRadius.button

        self.rejectButton.layer.cornerRadius = CornerRadius.button

    }

    func setupWithTheme() {

        self.contentView.backgroundColor = UIColor.App.backgroundPrimary

        self.containerView.backgroundColor = UIColor.App.backgroundSecondary

        self.topInfoView.backgroundColor = .clear

        self.iconBaseView.backgroundColor = UIColor.App.backgroundTertiary

        self.iconImageView.backgroundColor = UIColor.App.backgroundTertiary

        self.titleLabel.textColor = UIColor.App.textPrimary

        self.separatorLineView.backgroundColor = UIColor.App.separatorLine

        self.acceptButton.backgroundColor = UIColor.App.alertSuccess
        self.acceptButton.setTitleColor(UIColor.App.buttonTextPrimary, for: .normal)

        self.rejectButton.backgroundColor = UIColor.App.alertError
        self.rejectButton.setTitleColor(UIColor.App.buttonTextPrimary, for: .normal)

    }

    func configure(viewModel: UserNotificationInviteCellViewModel) {
        self.viewModel = viewModel

        self.titleLabel.text = viewModel.getFriendRequestUsername()

        self.hasSeparatorLine = false
    }

    // MARK: Actions

    @objc func didTapAcceptButton() {
        print("TAPPED ACCEPT BUTTON")
        if let friendRequestId = self.viewModel?.getFriendRequestId() {
            self.tappedAcceptAction?(friendRequestId)

        }

    }

    @objc func didTapDeclineButton() {
        print("TAPPED REJECT BUTTON")
        if let friendRequestId = self.viewModel?.getFriendRequestId() {
            self.tappedRejectAction?(friendRequestId)

        }
    }

}

extension UserNotificationInviteTableViewCell {

    private static func createContainerView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }

    private static func createTopInfoView() -> UIView {
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
        label.text = "@User"
        label.font = AppFont.with(type: .bold, size: 14)
        label.numberOfLines = 0
        label.setContentHuggingPriority(.required, for: .horizontal)
        return label
    }

    private static func createAcceptButton() -> UIButton {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle(localized("accept"), for: .normal)
        button.titleLabel?.font = AppFont.with(type: .bold, size: 16)
        return button
    }

    private static func createRejectButton() -> UIButton {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle(localized("reject"), for: .normal)
        button.titleLabel?.font = AppFont.with(type: .bold, size: 16)
        return button
    }

    private static func createSeparatorLineView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }

    private func setupSubviews() {

        self.contentView.addSubview(self.containerView)

        self.containerView.addSubview(self.topInfoView)

        self.topInfoView.addSubview(self.iconBaseView)

        self.iconBaseView.addSubview(self.iconImageView)

        self.topInfoView.addSubview(self.titleLabel)

        self.containerView.addSubview(self.acceptButton)

        self.containerView.addSubview(self.rejectButton)

        self.containerView.addSubview(self.separatorLineView)

        self.initConstraints()

        self.containerView.layoutSubviews()
        self.containerView.layoutIfNeeded()

    }

    private func initConstraints() {

        NSLayoutConstraint.activate([
            self.containerView.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor, constant: 15),
            self.containerView.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor, constant: -15),
            self.containerView.topAnchor.constraint(equalTo: self.contentView.topAnchor, constant: 5),
            self.containerView.bottomAnchor.constraint(equalTo: self.contentView.bottomAnchor, constant: -5),

            self.topInfoView.leadingAnchor.constraint(equalTo: self.containerView.leadingAnchor, constant: 20),
            self.topInfoView.trailingAnchor.constraint(equalTo: self.containerView.trailingAnchor, constant: -20),
            self.topInfoView.topAnchor.constraint(equalTo: self.containerView.topAnchor, constant: 5),
            self.topInfoView.heightAnchor.constraint(equalToConstant: 30),

            self.iconBaseView.leadingAnchor.constraint(equalTo: self.topInfoView.leadingAnchor),
            self.iconBaseView.widthAnchor.constraint(equalToConstant: 24),
            self.iconBaseView.heightAnchor.constraint(equalTo: self.iconBaseView.widthAnchor),
            self.iconBaseView.centerYAnchor.constraint(equalTo: self.topInfoView.centerYAnchor),

            self.iconImageView.widthAnchor.constraint(equalToConstant: 21),
            self.iconImageView.heightAnchor.constraint(equalTo: self.iconImageView.widthAnchor),
            self.iconImageView.centerXAnchor.constraint(equalTo: self.iconBaseView.centerXAnchor),
            self.iconImageView.centerYAnchor.constraint(equalTo: self.iconBaseView.centerYAnchor),

            self.titleLabel.leadingAnchor.constraint(equalTo: self.iconBaseView.trailingAnchor, constant: 8),
            self.titleLabel.trailingAnchor.constraint(equalTo: self.topInfoView.trailingAnchor),
            self.titleLabel.centerYAnchor.constraint(equalTo: self.topInfoView.centerYAnchor),

            self.acceptButton.topAnchor.constraint(equalTo: self.topInfoView.bottomAnchor, constant: 10),
//            self.acceptButton.widthAnchor.constraint(equalToConstant: 90),
            self.acceptButton.heightAnchor.constraint(equalToConstant: 33),
            self.acceptButton.leadingAnchor.constraint(equalTo: self.containerView.leadingAnchor, constant: 20),
            self.acceptButton.trailingAnchor.constraint(equalTo: self.containerView.centerXAnchor, constant: -15),
            self.acceptButton.bottomAnchor.constraint(equalTo: self.containerView.bottomAnchor, constant: -15),

            self.rejectButton.topAnchor.constraint(equalTo: self.topInfoView.bottomAnchor, constant: 10),
            self.rejectButton.trailingAnchor.constraint(equalTo: self.containerView.trailingAnchor, constant: -20),
//            self.rejectButton.widthAnchor.constraint(equalToConstant: 90),
            self.rejectButton.heightAnchor.constraint(equalToConstant: 33),
            self.rejectButton.leadingAnchor.constraint(equalTo: self.containerView.centerXAnchor, constant: 15),
            self.rejectButton.bottomAnchor.constraint(equalTo: self.containerView.bottomAnchor, constant: -15),

            self.separatorLineView.leadingAnchor.constraint(equalTo: self.iconBaseView.leadingAnchor),
            self.separatorLineView.trailingAnchor.constraint(equalTo: self.containerView.trailingAnchor, constant: -25),
            self.separatorLineView.bottomAnchor.constraint(equalTo: self.containerView.bottomAnchor),
            self.separatorLineView.heightAnchor.constraint(equalToConstant: 1)

        ])

    }
}
