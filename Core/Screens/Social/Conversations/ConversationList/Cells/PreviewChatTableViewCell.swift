//
//  PreviewChatTableViewCell.swift
//  Sportsbook
//
//  Created by André Lascas on 28/04/2022.
//

import UIKit
import Combine

class PreviewChatTableViewCell: UITableViewCell {

    private lazy var baseView: UIView = Self.createBaseView()
    private lazy var iconBaseView: UIView = Self.createIconBaseView()
    private lazy var iconInnerView: UIView = Self.createIconInnerView()
    private lazy var photoImageView: UIImageView = Self.createPhotoImageView()
    private lazy var initialLabel: UILabel = Self.createInitialLabel()
    private lazy var nameLineStackView: UIStackView = Self.createNameLineStackView()
    private lazy var nameLabel: UILabel = Self.createNameLabel()
    //private lazy var numberMessagesLabel: UILabel = Self.createNumberMessagesLabel()
    private lazy var userStateBaseView: UIView = Self.createUserStateBaseView()
    private lazy var userStateView: UIView = Self.createUserStateView()
    private lazy var messageLineStackView: UIStackView = Self.createMessageLineStackView()
    private lazy var feedbackImageView: UIImageView = Self.createFeedbackImageView()
    private lazy var messageLabel: UILabel = Self.createMessageLabel()
    private lazy var dateLabel: UILabel = Self.createDateLabel()
    private lazy var separatorLineView: UIView = Self.createSeparatorLineView()

    private var viewModel: PreviewChatCellViewModel?
    private var cancellables = Set<AnyCancellable>()
    
    private let dateFormatter = DateFormatter()

    var didTapConversationAction: ((ConversationData) -> Void)?
    var removeChatroomAction: ((Int) -> Void)?

    var isSeen: Bool = false {
        didSet {
            if isSeen {
                self.dateLabel.textColor = UIColor.App.textSecondary
                self.messageLabel.font = AppFont.with(type: .regular, size: 14)
            }
            else {
                self.dateLabel.textColor = UIColor.App.highlightPrimary
                self.messageLabel.font = AppFont.with(type: .bold, size: 14)
            }

//            if self.messageLabel.text != "" {
//                self.feedbackImageView.isHidden = !isSeen
//            }
//            else {
//                self.feedbackImageView.isHidden = true
//            }
            self.feedbackImageView.isHidden = true

        }
    }
    
    var isDefaultMessage: Bool = false {
        didSet {
            
            if isDefaultMessage {
                self.messageLabel.font = AppFont.with(type: .italic, size: 14)
            }
        }
    }

    var isOnline: Bool = false {
        didSet {
            self.userStateBaseView.isHidden = !isOnline
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
    
    var hasSeparatorLine: Bool = true {
        didSet {
            self.separatorLineView.isHidden = !hasSeparatorLine
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
        
        self.hasSeparatorLine = true
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        self.iconBaseView.layer.cornerRadius = self.iconBaseView.frame.size.width / 2

        self.iconInnerView.layer.cornerRadius = self.iconInnerView.frame.size.width / 2
        self.iconInnerView.clipsToBounds = true

        self.photoImageView.layer.cornerRadius = self.photoImageView.frame.size.width / 2

        self.userStateView.layer.cornerRadius = self.userStateView.frame.height / 2

    }

    func setupWithTheme() {
        self.backgroundView?.backgroundColor = UIColor.App.backgroundSecondary
        self.backgroundColor = UIColor.App.backgroundSecondary

        self.baseView.backgroundColor = .clear

        self.iconBaseView.backgroundColor = .clear
        self.iconBaseView.layer.borderColor = UIColor.App.highlightTertiary.cgColor
        
        self.iconInnerView.backgroundColor = .clear

        self.photoImageView.backgroundColor = .clear

        self.initialLabel.textColor = UIColor.App.textSecondary

        self.feedbackImageView.backgroundColor = .clear
        self.messageLineStackView.backgroundColor = .clear
        self.nameLineStackView.backgroundColor = .clear

        self.nameLabel.textColor = UIColor.App.textPrimary

        self.userStateBaseView.backgroundColor = .clear

        self.userStateView.backgroundColor = UIColor.App.alertSuccess

        self.messageLabel.textColor = UIColor.App.textSecondary
        self.dateLabel.textColor = UIColor.App.textSecondary

        self.separatorLineView.backgroundColor = UIColor.App.separatorLineSecondary
    }

    func configure(withViewModel viewModel: PreviewChatCellViewModel) {
        self.viewModel = viewModel

        self.nameLabel.text = viewModel.cellData.name
        
        self.messageLabel.text = viewModel.cellData.lastMessage
        
        if let avatar = viewModel.cellData.avatar {
            self.photoImageView.image = UIImage(named: avatar)
        }

        if viewModel.cellData.conversationType == .user {
            self.isGroup = false
        }
        else if viewModel.cellData.conversationType == .group {
            self.isGroup = true
            self.initialLabel.text = viewModel.getGroupInitials(text: viewModel.cellData.name)
        }
        
        if let timestampInt = viewModel.cellData.timestamp {
            let date = Date(timeIntervalSince1970: TimeInterval(timestampInt))
            let calendar = Calendar.current

            let dateFormatter = DateFormatter()
            
            if calendar.isDateInToday(date) {
                dateFormatter.dateFormat = "HH:mm"
                self.dateLabel.text = dateFormatter.string(from: date)
                
            } else if calendar.isDateInYesterday(date) {
                self.dateLabel.text = "Yesterday"
                
            } else {
                dateFormatter.dateFormat = "dd/MM"
                self.dateLabel.text = dateFormatter.string(from: date)
            }
        } else {
            self.dateLabel.text = viewModel.cellData.date
        }

        self.isSeen = viewModel.cellData.isLastMessageSeen
        
        self.isDefaultMessage = viewModel.cellData.lastMessage.contains("Hello! I just added") ? true : false

        // self.isOnline = false

        viewModel.isOnlinePublisher
            .sink(receiveValue: { [weak self] isOnline in
                self?.isOnline = isOnline
            })
            .store(in: &cancellables)

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
        view.layer.borderWidth = 2
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
        photoImageView.image = UIImage(named: "empty_user_image")
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
        nameLabel.text = localized("username")
        nameLabel.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        return nameLabel
    }

    private static func createUserStateBaseView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.setContentHuggingPriority(.defaultLow, for: .horizontal)
        return view
    }

    private static func createUserStateView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
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
        feedbackImageView.image = UIImage(named: "seen_message_icon")?.withRenderingMode(.alwaysTemplate)
        feedbackImageView.setTintColor(color: UIColor.App.highlightTertiary)
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
        self.nameLineStackView.addArrangedSubview(self.userStateBaseView)

        self.userStateBaseView.addSubview(self.userStateView)

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

            self.iconBaseView.leadingAnchor.constraint(equalTo: self.baseView.leadingAnchor, constant: 25),
            self.iconBaseView.widthAnchor.constraint(equalToConstant: 40),
            self.iconBaseView.heightAnchor.constraint(equalTo: self.iconBaseView.widthAnchor),
            self.iconBaseView.centerYAnchor.constraint(equalTo: self.baseView.centerYAnchor),

            self.iconInnerView.widthAnchor.constraint(equalToConstant: 40),
            self.iconInnerView.heightAnchor.constraint(equalTo: self.iconInnerView.widthAnchor),
            self.iconInnerView.centerXAnchor.constraint(equalTo: self.iconBaseView.centerXAnchor),
            self.iconInnerView.centerYAnchor.constraint(equalTo: self.iconBaseView.centerYAnchor),

            self.photoImageView.widthAnchor.constraint(equalToConstant: 35),
            self.photoImageView.heightAnchor.constraint(equalTo: self.photoImageView.widthAnchor),
            self.photoImageView.centerXAnchor.constraint(equalTo: self.iconInnerView.centerXAnchor),
            self.photoImageView.centerYAnchor.constraint(equalTo: self.iconInnerView.centerYAnchor),

            self.initialLabel.centerXAnchor.constraint(equalTo: self.iconInnerView.centerXAnchor),
            self.initialLabel.centerYAnchor.constraint(equalTo: self.iconInnerView.centerYAnchor),

            self.nameLabel.widthAnchor.constraint(lessThanOrEqualToConstant: 200),

            self.nameLineStackView.leadingAnchor.constraint(equalTo: self.iconBaseView.trailingAnchor, constant: 12),
            self.nameLineStackView.topAnchor.constraint(equalTo: self.iconBaseView.topAnchor, constant: 2),

            self.userStateBaseView.widthAnchor.constraint(greaterThanOrEqualToConstant: 10),

            self.userStateView.widthAnchor.constraint(equalToConstant: 8),
            self.userStateView.heightAnchor.constraint(equalTo: self.userStateView.widthAnchor),
            self.userStateView.leadingAnchor.constraint(equalTo: self.userStateBaseView.leadingAnchor),
            self.userStateView.centerYAnchor.constraint(equalTo: self.userStateBaseView.centerYAnchor),

            self.dateLabel.leadingAnchor.constraint(equalTo: self.nameLineStackView.trailingAnchor, constant: 8),
            self.dateLabel.trailingAnchor.constraint(equalTo: self.baseView.trailingAnchor, constant: -25),
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
