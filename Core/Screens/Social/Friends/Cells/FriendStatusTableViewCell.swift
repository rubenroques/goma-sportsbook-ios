//
//  FriendStatusTableViewCell.swift
//  Sportsbook
//
//  Created by André Lascas on 26/04/2022.
//

import UIKit
import Combine

class FriendStatusTableViewCell: UITableViewCell {

    // MARK: Private Properties
    private lazy var baseView: UIView = Self.createBaseView()
    private lazy var iconBaseView: UIView = Self.createIconBaseView()
    private lazy var iconInnerView: UIView = Self.createIconInnerView()
    private lazy var photoImageView: UIImageView = Self.createPhotoImageView()
    private lazy var nameLabel: UILabel = Self.createNameLabel()
    private lazy var statusView: UIView = Self.createStatusView()
    private lazy var notificationEnabledButton: UIButton = Self.createNotificationEnabledButton()
    private lazy var separatorLineView: UIView = Self.createSeparatorLineView()

    private var viewModel: FriendStatusCellViewModel?
    private var cancellables = Set<AnyCancellable>()

    // MARK: Public Properties
    var notificationsEnabled: Bool = true {
        didSet {
            if notificationsEnabled {
                self.notificationEnabledButton.setImage(UIImage(named: "notifications_status_icon"), for: UIControl.State.normal)
            }
            else {
                self.notificationEnabledButton.setImage(UIImage(named: "notifications_status_on_icon"), for: UIControl.State.normal)
            }
        }
    }

    var isOnline: Bool = false {
        didSet {
            if isOnline {
                self.iconBaseView.layer.borderWidth = 2
                self.iconBaseView.layer.borderColor = UIColor.App.highlightPrimary.cgColor
            }
            else {
                self.iconBaseView.layer.borderWidth = 2
                self.iconBaseView.layer.borderColor = UIColor.App.backgroundOdds.cgColor
            }
        }
    }

    var removeFriendAction: ((Int) -> Void)?

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
        self.viewModel = nil
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        self.iconBaseView.layer.cornerRadius = self.iconBaseView.frame.size.width / 2

        self.iconInnerView.layer.cornerRadius = self.iconInnerView.frame.size.width / 2

        self.photoImageView.layer.cornerRadius = self.photoImageView.frame.size.width / 2

        self.statusView.layer.cornerRadius = self.statusView.frame.size.width / 2
    }

    func setupWithTheme() {
        self.backgroundView?.backgroundColor = UIColor.App.backgroundPrimary
        self.backgroundColor = UIColor.App.backgroundPrimary

        self.iconBaseView.backgroundColor = UIColor.App.backgroundPrimary

        self.iconInnerView.backgroundColor = UIColor.App.backgroundPrimary

        self.photoImageView.backgroundColor = UIColor.App.backgroundSecondary

        self.nameLabel.textColor = UIColor.App.textPrimary
        self.statusView.backgroundColor = .systemGreen

        if let image = self.notificationEnabledButton.imageView?.image?.withRenderingMode(.alwaysTemplate) {
            self.notificationEnabledButton.setImage(image, for: .normal)
            self.notificationEnabledButton.tintColor = UIColor.App.highlightSecondary
        }

        self.separatorLineView.backgroundColor = UIColor.App.separatorLine
    }

    // MARK: Functions
    func configure(withViewModel viewModel: FriendStatusCellViewModel) {
        self.viewModel = viewModel

        self.nameLabel.text = viewModel.username

        self.notificationsEnabled = viewModel.notificationsEnabled

        self.isOnline = true

        self.notificationEnabledButton.isHidden = true
    }

    // MARK: Actions
    @objc private func didTapNotificationsEnabledButton() {

        if let viewModel = self.viewModel {
            viewModel.notificationsEnabled = !self.notificationsEnabled
            self.notificationsEnabled = viewModel.notificationsEnabled
        }
    }

    @objc private func didLongPressFriendView() {

        guard
            let parentViewController = self.viewController,
            let friendId = self.viewModel?.id
        else {
            return
        }

        let actionSheetController: UIAlertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)

        let removeFriendAction: UIAlertAction = UIAlertAction(title: "Remove friend", style: .default) { [weak self] _ -> Void in
            print("REMOVE FRIEND ID: \(friendId)")
            self?.removeFriendAction?(friendId)
        }
        actionSheetController.addAction(removeFriendAction)

        let cancelAction: UIAlertAction = UIAlertAction(title: localized("cancel"), style: .cancel) { _ -> Void in }
        actionSheetController.addAction(cancelAction)

        if let popoverController = actionSheetController.popoverPresentationController {
            popoverController.sourceView = parentViewController.view
            popoverController.sourceRect = CGRect(x: parentViewController.view.bounds.midX, y: parentViewController.view.bounds.midY, width: 0, height: 0)
            popoverController.permittedArrowDirections = []
        }

        parentViewController.present(actionSheetController, animated: true, completion: nil)
    }

}

extension FriendStatusTableViewCell {

    private static func createBaseView() -> UIView {
        let baseView = UIView()
        baseView.translatesAutoresizingMaskIntoConstraints = false
        return baseView
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

    private static func createPhotoImageView() -> UIImageView {
        let photoImageView = UIImageView()
        photoImageView.translatesAutoresizingMaskIntoConstraints = false
        photoImageView.image = UIImage(named: "my_account_profile_icon")
        photoImageView.contentMode = .scaleAspectFit
        return photoImageView
    }

    private static func createNameLabel() -> UILabel {
        let nameLabel = UILabel()
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        nameLabel.font = AppFont.with(type: .bold, size: 14)
        nameLabel.text = "@NameSurname"
        return nameLabel
    }

    private static func createStatusView() -> UIView {
        let statusView = UIView()
        statusView.translatesAutoresizingMaskIntoConstraints = false
        return statusView
    }

    private static func createMessageLineStackView() -> UIStackView {
        let messageLineStackView = UIStackView()
        messageLineStackView.axis = .horizontal
        messageLineStackView.distribution = .fill
        messageLineStackView.spacing = 6
        messageLineStackView.translatesAutoresizingMaskIntoConstraints = false
        return messageLineStackView
    }

    private static func createNotificationEnabledButton() -> UIButton {
        let notificationEnabledButton = UIButton(type: .custom)
        notificationEnabledButton.setImage(UIImage(named: "notifications_status_on_icon"), for: .normal)
        notificationEnabledButton.translatesAutoresizingMaskIntoConstraints = false
        return notificationEnabledButton
    }

    private static func createSeparatorLineView() -> UIView {
        let headerSeparatorLine = UIView()
        headerSeparatorLine.translatesAutoresizingMaskIntoConstraints = false
        return headerSeparatorLine
    }

    private func setupSubviews() {

        self.contentView.addSubview(self.baseView)

        self.baseView.addSubview(self.iconBaseView)

        self.iconBaseView.addSubview(self.iconInnerView)

        self.iconInnerView.addSubview(self.photoImageView)

        self.baseView.addSubview(self.nameLabel)
        self.baseView.addSubview(self.statusView)
        self.baseView.addSubview(self.notificationEnabledButton)

        self.baseView.addSubview(self.separatorLineView)

        // Initialize constraints
        self.initConstraints()

        self.notificationEnabledButton.addTarget(self, action: #selector(didTapNotificationsEnabledButton), for: .primaryActionTriggered)

        let longPressGestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(didLongPressFriendView))
        self.baseView.addGestureRecognizer(longPressGestureRecognizer)
    }

    private func initConstraints() {
        NSLayoutConstraint.activate([
            self.baseView.heightAnchor.constraint(equalToConstant: 66),

            self.baseView.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor),
            self.baseView.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor),
            self.baseView.topAnchor.constraint(equalTo: self.contentView.topAnchor),
            self.baseView.bottomAnchor.constraint(equalTo: self.contentView.bottomAnchor),

            self.iconBaseView.leadingAnchor.constraint(equalTo: self.baseView.leadingAnchor, constant: 24),
            self.iconBaseView.widthAnchor.constraint(equalToConstant: 40),
            self.iconBaseView.heightAnchor.constraint(equalTo: self.iconBaseView.widthAnchor),
            self.iconBaseView.centerYAnchor.constraint(equalTo: self.baseView.centerYAnchor),

            self.iconInnerView.widthAnchor.constraint(equalToConstant: 37),
            self.iconInnerView.heightAnchor.constraint(equalTo: self.iconInnerView.widthAnchor),
            self.iconInnerView.centerXAnchor.constraint(equalTo: self.iconBaseView.centerXAnchor),
            self.iconInnerView.centerYAnchor.constraint(equalTo: self.iconBaseView.centerYAnchor),

            self.photoImageView.widthAnchor.constraint(equalToConstant: 25),
            self.photoImageView.heightAnchor.constraint(equalTo: self.photoImageView.widthAnchor),
            self.photoImageView.centerXAnchor.constraint(equalTo: self.iconInnerView.centerXAnchor),
            self.photoImageView.centerYAnchor.constraint(equalTo: self.iconInnerView.centerYAnchor),

            self.nameLabel.leadingAnchor.constraint(equalTo: self.photoImageView.trailingAnchor, constant: 12),
            self.nameLabel.centerYAnchor.constraint(equalTo: self.photoImageView.centerYAnchor),

            self.statusView.heightAnchor.constraint(equalTo: self.statusView.widthAnchor),
            self.statusView.heightAnchor.constraint(equalToConstant: 8),
            self.statusView.centerYAnchor.constraint(equalTo: self.nameLabel.centerYAnchor),
            self.statusView.leadingAnchor.constraint(equalTo: self.nameLabel.trailingAnchor, constant: 8),

            self.notificationEnabledButton.trailingAnchor.constraint(equalTo: self.baseView.trailingAnchor, constant: -23),
            self.notificationEnabledButton.centerYAnchor.constraint(equalTo: self.nameLabel.centerYAnchor),
            self.notificationEnabledButton.heightAnchor.constraint(equalTo: self.notificationEnabledButton.widthAnchor),
            self.notificationEnabledButton.heightAnchor.constraint(equalToConstant: 44),

            self.baseView.bottomAnchor.constraint(equalTo: self.separatorLineView.bottomAnchor, constant: 0),
            self.baseView.leadingAnchor.constraint(equalTo: self.separatorLineView.leadingAnchor, constant: -23),
            self.baseView.trailingAnchor.constraint(equalTo: self.separatorLineView.trailingAnchor, constant: 23),
            self.separatorLineView.heightAnchor.constraint(equalToConstant: 1),
        ])
    }

}
