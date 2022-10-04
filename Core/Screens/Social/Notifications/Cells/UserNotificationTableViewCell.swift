//
//  UserNotificationTableViewCell.swift
//  Sportsbook
//
//  Created by André Lascas on 30/09/2022.
//

import UIKit

class UserNotificationCellViewModel {

    var notification: ChatNotification

    init(notification: ChatNotification) {
        self.notification = notification
    }

    func getNotificationTitle() -> String {
        return self.notification.title
    }

    func getNotificationText() -> String {
        return self.notification.text
    }

    func getNotificationReadState() -> Int {
        return self.notification.notificationUsers[safe: 0]?.read ?? -1
    }
}

class UserNotificationTableViewCell: UITableViewCell {

    // MARK: Private Properties
    private lazy var containerView: UIView = Self.createContainerView()
    private lazy var iconBaseView: UIView = Self.createIconBaseView()
    private lazy var iconImageView: UIImageView = Self.createIconImageView()
    private lazy var titleLabel: UILabel = Self.createTitleLabel()
    private lazy var separatorLineView: UIView = Self.createSeparatorLineView()

    // MARK: Public Properties
    var viewModel: UserNotificationCellViewModel?

    var isUnread: Bool = false {
        didSet {
            if isUnread {
                self.iconBaseView.backgroundColor = UIColor.App.highlightPrimary
            }
            else {
                self.iconBaseView.backgroundColor = UIColor.App.backgroundTertiary
            }
        }
    }

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

    }

    func setupWithTheme() {

        self.contentView.backgroundColor = UIColor.App.backgroundPrimary

        self.containerView.backgroundColor = UIColor.App.backgroundSecondary

        self.iconBaseView.backgroundColor = UIColor.App.backgroundTertiary

        self.iconImageView.backgroundColor = UIColor.App.backgroundTertiary

        self.titleLabel.textColor = UIColor.App.textPrimary

        self.separatorLineView.backgroundColor = UIColor.App.separatorLine

    }

    func configure(viewModel: UserNotificationCellViewModel) {
        self.viewModel = viewModel

        self.titleLabel.text = viewModel.getNotificationText()

        let notificationReadState = viewModel.getNotificationReadState()

        if notificationReadState == 0 {
            self.isUnread = true
        }
        else {
            self.isUnread = false
        }

        self.hasSeparatorLine = false
    }

}

extension UserNotificationTableViewCell {

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
        label.text = "@User"
        label.font = AppFont.with(type: .bold, size: 14)
        label.numberOfLines = 0
        label.setContentHuggingPriority(.required, for: .horizontal)
        return label
    }

    private static func createSeparatorLineView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }

    private func setupSubviews() {

        self.contentView.addSubview(self.containerView)

        self.containerView.addSubview(self.iconBaseView)

        self.iconBaseView.addSubview(self.iconImageView)

        self.containerView.addSubview(self.titleLabel)

        self.containerView.addSubview(self.separatorLineView)

        self.initConstraints()

        self.containerView.layoutIfNeeded()
        self.containerView.layoutSubviews()

    }

    private func initConstraints() {

        NSLayoutConstraint.activate([
            self.containerView.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor, constant: 15),
            self.containerView.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor, constant: -15),
            self.containerView.topAnchor.constraint(equalTo: self.contentView.topAnchor, constant: 5),
            self.containerView.bottomAnchor.constraint(equalTo: self.contentView.bottomAnchor, constant: -5),
            self.containerView.heightAnchor.constraint(equalToConstant: 35),

            self.iconBaseView.leadingAnchor.constraint(equalTo: self.containerView.leadingAnchor, constant: 20),
//            self.iconBaseView.topAnchor.constraint(equalTo: self.containerView.topAnchor, constant: 15),
//            self.iconBaseView.bottomAnchor.constraint(equalTo: self.containerView.bottomAnchor, constant: -15),
            self.iconBaseView.widthAnchor.constraint(equalToConstant: 24),
            self.iconBaseView.heightAnchor.constraint(equalTo: self.iconBaseView.widthAnchor),
            self.iconBaseView.centerYAnchor.constraint(equalTo: self.containerView.centerYAnchor),

            self.iconImageView.widthAnchor.constraint(equalToConstant: 21),
            self.iconImageView.heightAnchor.constraint(equalTo: self.iconImageView.widthAnchor),
            self.iconImageView.centerXAnchor.constraint(equalTo: self.iconBaseView.centerXAnchor),
            self.iconImageView.centerYAnchor.constraint(equalTo: self.iconBaseView.centerYAnchor),

            self.titleLabel.leadingAnchor.constraint(equalTo: self.iconBaseView.trailingAnchor, constant: 8),
            self.titleLabel.trailingAnchor.constraint(equalTo: self.containerView.trailingAnchor, constant: -25),
            self.titleLabel.centerYAnchor.constraint(equalTo: self.contentView.centerYAnchor),

            self.separatorLineView.leadingAnchor.constraint(equalTo: self.iconBaseView.leadingAnchor),
            self.separatorLineView.trailingAnchor.constraint(equalTo: self.containerView.trailingAnchor, constant: -25),
            self.separatorLineView.bottomAnchor.constraint(equalTo: self.containerView.bottomAnchor),
            self.separatorLineView.heightAnchor.constraint(equalToConstant: 1)

        ])

    }
}
