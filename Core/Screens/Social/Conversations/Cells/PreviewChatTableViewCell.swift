//
//  PreviewChatTableViewCell.swift
//  Sportsbook
//
//  Created by André Lascas on 28/04/2022.
//

import UIKit

class PreviewChatTableViewCell: UITableViewCell {

    private lazy var baseView: UIView = Self.createBaseView()
    private lazy var iconBaseView: UIView = Self.createIconBaseView()
    private lazy var iconInnerView: UIView = Self.createIconInnerView()
    private lazy var photoImageView: UIImageView = Self.createPhotoImageView()
    private lazy var initialLabel: UILabel = Self.createInitialLabel()
    private lazy var nameLineStackView: UIStackView = Self.createNameLineStackView()
    private lazy var nameLabel: UILabel = Self.createNameLabel()
    private lazy var numberMessagesLabel: UILabel = Self.createNumberMessagesLabel()
    private lazy var messageLineStackView: UIStackView = Self.createMessageLineStackView()
    private lazy var feedbackImageView: UIImageView = Self.createFeedbackImageView()
    private lazy var messageLabel: UILabel = Self.createMessageLabel()
    private lazy var dateLabel: UILabel = Self.createDateLabel()
    private lazy var separatorLineView: UIView = Self.createSeparatorLineView()

    private var viewModel: PreviewChatCellViewModel?

    var didTapConversationAction: ((ConversationData) -> Void)?
    var removeChatroomAction: ((Int) -> Void)?

    var isSeen: Bool = false {
        didSet {
            if isSeen {
                self.dateLabel.textColor = UIColor.App.textSecondary
            }
            else {
                self.dateLabel.textColor = UIColor.App.highlightPrimary
            }
            self.feedbackImageView.isHidden = !isSeen
            self.numberMessagesLabel.isHidden = isSeen
        }
    }

    var isOnline: Bool = false {
        didSet {
            if isOnline {
//                self.iconBaseView.backgroundColor = UIColor.App.highlightPrimary
                self.iconBaseView.layer.borderWidth = 2
                self.iconBaseView.layer.borderColor = UIColor.App.highlightPrimary.cgColor
            }
            else {
//                self.iconBaseView.backgroundColor = UIColor.App.backgroundSecondary
                self.iconBaseView.layer.borderWidth = 2
                self.iconBaseView.layer.borderColor = UIColor.App.backgroundOdds.cgColor
            }
        }
    }

    var isGroup: Bool = false {
        didSet {
            if isGroup {
                self.photoImageView.isHidden = true
                self.initialLabel.isHidden = false
            }
            else {
                self.photoImageView.isHidden = false
                self.initialLabel.isHidden = true
            }
        }
    }

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        self.setupSubviews()
        self.setupWithTheme()

        self.setNeedsLayout()
        self.layoutIfNeeded()

        let tapConversationGesture = UITapGestureRecognizer(target: self, action: #selector(didTapConversationView))
        self.addGestureRecognizer(tapConversationGesture)

        self.isSeen = false

        self.isGroup = true
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
    }

    func setupWithTheme() {
        self.backgroundView?.backgroundColor = UIColor.App.backgroundPrimary
        self.backgroundColor = UIColor.App.backgroundPrimary

        self.baseView.backgroundColor = UIColor.App.backgroundPrimary

        self.iconBaseView.backgroundColor = UIColor.App.backgroundPrimary

        self.iconInnerView.backgroundColor = UIColor.App.backgroundPrimary

        self.photoImageView.backgroundColor = UIColor.App.backgroundPrimary

        self.initialLabel.textColor = UIColor.App.textSecondary

        self.feedbackImageView.backgroundColor = UIColor.App.backgroundPrimary
        self.messageLineStackView.backgroundColor = UIColor.App.backgroundPrimary
        self.nameLineStackView.backgroundColor = UIColor.App.backgroundPrimary

        self.nameLabel.textColor = UIColor.App.textPrimary
        self.numberMessagesLabel.textColor = UIColor.App.highlightPrimary
        self.messageLabel.textColor = UIColor.App.textPrimary
        self.dateLabel.textColor = UIColor.App.textSecondary

        self.separatorLineView.backgroundColor = UIColor.App.separatorLine
    }

    func configure(withViewModel viewModel: PreviewChatCellViewModel) {
        self.viewModel = viewModel

        // TEST
        self.nameLabel.text = viewModel.cellData.name

        self.messageLabel.text = viewModel.cellData.lastMessage

        if viewModel.cellData.conversationType == .user {
            self.isGroup = false
        }
        else if viewModel.cellData.conversationType == .group {
            self.isGroup = true
            self.initialLabel.text = viewModel.getGroupInitials(text: viewModel.cellData.name)
        }

        self.dateLabel.text = viewModel.cellData.date

        self.isSeen = viewModel.cellData.isLastMessageSeen

        self.isOnline = false

    }

    @objc func didTapConversationView() {
        if let viewModel = self.viewModel {
            self.didTapConversationAction?(viewModel.cellData)
        }
    }

    @objc private func didLongPressConversationView() {

        guard
            let parentViewController = self.viewController,
            let chatroomId = self.viewModel?.cellData.id,
            let chatroomType = self.viewModel?.cellData.conversationType
        else {
            return
        }

        let actionSheetController: UIAlertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)

        // TEST
        if chatroomType == .group {

            let removeChatroomAction: UIAlertAction = UIAlertAction(title: "Remove chatroom", style: .default) { [weak self] _ -> Void in
                self?.removeChatroomAction?(chatroomId)
            }
            actionSheetController.addAction(removeChatroomAction)
        }

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

extension PreviewChatTableViewCell {

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

    private static func createInitialLabel() -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "G"
        label.font = AppFont.with(type: .bold, size: 18)
        label.textAlignment = .center
        return label
    }

    private static func createNameLineStackView() -> UIStackView {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .horizontal
        stackView.distribution = .fill
        stackView.spacing = 6
        return stackView
    }

    private static func createNameLabel() -> UILabel {
        let nameLabel = UILabel()
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        nameLabel.font = AppFont.with(type: .bold, size: 16)
        nameLabel.text = "Suspendisse potenti. Cras a suscipit mi. Nam et mi ac ipsum luctus maximus."
        nameLabel.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        return nameLabel
    }

    private static func createNumberMessagesLabel() -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = AppFont.with(type: .bold, size: 16)
        label.text = "(1)"
        label.textAlignment = .left
        label.setContentHuggingPriority(.defaultLow, for: .horizontal)
        return label
    }

    private static func createMessageLineStackView() -> UIStackView {
        let messageLineStackView = UIStackView()
        messageLineStackView.axis = .horizontal
        messageLineStackView.distribution = .fill
        messageLineStackView.spacing = 6
        messageLineStackView.translatesAutoresizingMaskIntoConstraints = false
        return messageLineStackView
    }

    private static func createFeedbackImageView() -> UIImageView {
        let feedbackImageView = UIImageView()
        feedbackImageView.translatesAutoresizingMaskIntoConstraints = false
        feedbackImageView.image = UIImage(named: "seen_message_icon")
        feedbackImageView.contentMode = .scaleAspectFit
        return feedbackImageView
    }

    private static func createMessageLabel() -> UILabel {
        let messageLabel = UILabel()
        messageLabel.font = AppFont.with(type: .regular, size: 14)
        messageLabel.translatesAutoresizingMaskIntoConstraints = false
        messageLabel.text = "Suspendisse potenti. Cras a suscipit mi. Nam et mi ac ipsum luctus maximus."
        return messageLabel
    }
    private static func createDateLabel() -> UILabel {
        let dateLabel = UILabel()
        dateLabel.font = AppFont.with(type: .semibold, size: 14)
        dateLabel.translatesAutoresizingMaskIntoConstraints = false
        dateLabel.text = "Yesterday"
        dateLabel.textAlignment = .right
        return dateLabel
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
        self.iconInnerView.addSubview(self.initialLabel)

        self.baseView.addSubview(self.nameLineStackView)

        self.nameLineStackView.addArrangedSubview(self.nameLabel)
        self.nameLineStackView.addArrangedSubview(self.numberMessagesLabel)

        self.messageLineStackView.addArrangedSubview(self.feedbackImageView)
        self.messageLineStackView.addArrangedSubview(self.messageLabel)
        self.baseView.addSubview(self.messageLineStackView)

        self.baseView.addSubview(self.dateLabel)
        self.baseView.addSubview(self.separatorLineView)

        // Initialize constraints
        self.initConstraints()

        let longPressGestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(didLongPressConversationView))
        self.baseView.addGestureRecognizer(longPressGestureRecognizer)
    }

    private func initConstraints() {
        NSLayoutConstraint.activate([
            self.baseView.heightAnchor.constraint(equalToConstant: 70),

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

            self.initialLabel.centerXAnchor.constraint(equalTo: self.iconInnerView.centerXAnchor),
            self.initialLabel.centerYAnchor.constraint(equalTo: self.iconInnerView.centerYAnchor),

            self.nameLabel.widthAnchor.constraint(lessThanOrEqualToConstant: 200),

            self.nameLineStackView.leadingAnchor.constraint(equalTo: self.iconBaseView.trailingAnchor, constant: 12),
            self.nameLineStackView.topAnchor.constraint(equalTo: self.iconBaseView.topAnchor, constant: 2),

            self.dateLabel.leadingAnchor.constraint(equalTo: self.nameLineStackView.trailingAnchor, constant: 8),
            self.dateLabel.trailingAnchor.constraint(equalTo: self.baseView.trailingAnchor, constant: -24),
            self.dateLabel.centerYAnchor.constraint(equalTo: self.nameLineStackView.centerYAnchor),

            self.feedbackImageView.widthAnchor.constraint(equalToConstant: 20),
            self.feedbackImageView.heightAnchor.constraint(equalTo: self.feedbackImageView.widthAnchor),

            self.messageLineStackView.leadingAnchor.constraint(equalTo: self.nameLineStackView.leadingAnchor),
            self.messageLineStackView.topAnchor.constraint(equalTo: self.nameLineStackView.bottomAnchor, constant: 4),
            self.messageLineStackView.trailingAnchor.constraint(equalTo: self.baseView.trailingAnchor, constant: -23),

            self.baseView.bottomAnchor.constraint(equalTo: self.separatorLineView.bottomAnchor, constant: 0),
            self.baseView.leadingAnchor.constraint(equalTo: self.separatorLineView.leadingAnchor, constant: -23),
            self.baseView.trailingAnchor.constraint(equalTo: self.separatorLineView.trailingAnchor, constant: 23),
            self.separatorLineView.heightAnchor.constraint(equalToConstant: 1),
        ])
    }

}
