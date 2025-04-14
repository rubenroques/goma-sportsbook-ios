//
//  ReceivedMessageTableViewCell.swift
//  Sportsbook
//
//  Created by André Lascas on 06/04/2022.
//

import UIKit
import Combine
class ReceivedMessageTableViewCell: UITableViewCell {

    // MARK: Private Properties
    private lazy var iconBaseView: UIView = Self.createIconBaseView()
    private lazy var iconImageView: UIImageView = Self.createIconImageView()
//    private lazy var messageContainerView: UIView = Self.createMessageContainerView()
    private lazy var messageContainerView: ChatBubbleView = Self.createMessageContainerView()

    private lazy var userStackView: UIStackView = Self.createUserStackView()
    private lazy var usernameLabel: UILabel = Self.createUsernameLabel()
    private lazy var userStateBaseView: UIView = Self.createUserStateBaseView()
    private lazy var userStateView: UIView = Self.createUserStateView()
    private lazy var messageLabel: UILabel = Self.createMessageLabel()
    private lazy var promptsStackView: UIStackView = Self.createPromptsStackView()
    private lazy var messageDateLabel: UILabel = Self.createMessageDateLabel()
//    private lazy var topBubbleTailView: UIView = Self.createTopBubbleTailView()
    
    // Constraints
    private lazy var messageDateToTextConstraint: NSLayoutConstraint = Self.createMessageDateToTextConstraint()
    private lazy var messageDateToPromptsConstraint: NSLayoutConstraint = Self.createMessageDateToPromptsConstraint()
//    private lazy var avatarCenterConstraint: NSLayoutConstraint = Self.createAvatarCenterConstraint()

    private var cancellables = Set<AnyCancellable>()

    private let dateFormatter = DateFormatter()

    // MARK: Public Properties
    var showUserState: Bool = false {
        didSet {
            self.userStateBaseView.isHidden = !showUserState
        }
    }
    
    var showPrompts: Bool = false {
        didSet {
            self.promptsStackView.isHidden = !showPrompts
            
            self.messageDateToTextConstraint.isActive = !showPrompts
            self.messageDateToPromptsConstraint.isActive = showPrompts
        }
    }
    
    var shouldSendPromptMessage: ((String) -> Void)?

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
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        self.iconBaseView.layer.cornerRadius = self.iconBaseView.frame.height / 2
        self.iconBaseView.clipsToBounds = true
        
        self.iconImageView.layer.cornerRadius = self.iconImageView.frame.height / 2

        self.userStateView.layer.cornerRadius = self.userStateView.frame.height / 2

//        self.setBubbleTailTriangle()

    }

    func setupWithTheme() {

        self.contentView.backgroundColor = UIColor.App.backgroundSecondary

        self.iconBaseView.backgroundColor = .clear
        self.iconBaseView.layer.borderColor = UIColor.App.highlightTertiary.cgColor
        
        self.iconImageView.backgroundColor = .clear

//        self.messageContainerView.backgroundColor = UIColor.App.backgroundTertiary

        self.userStackView.backgroundColor = .clear

        self.usernameLabel.textColor = UIColor.App.textPrimary

        self.userStateBaseView.backgroundColor = .clear

        self.userStateView.backgroundColor = UIColor.App.alertSuccess

        self.messageLabel.textColor = UIColor.App.textPrimary

        self.messageDateLabel.textColor = UIColor.App.textSecondary

//        self.topBubbleTailView.backgroundColor = .clear

    }

    // MARK: Functions

    func setupMessage(messageData: MessageData, username: String, avatarName: String? = nil, chatroomId: Int, isAssistantMessage: Bool = false) {
        self.messageLabel.text = messageData.text

        self.dateFormatter.dateFormat = "dd-MM-yyyy HH:mm"

        if let date = dateFormatter.date(from: messageData.date) {
            dateFormatter.dateFormat = "HH:mm"
            let timeString = dateFormatter.string(from: date)
            self.messageDateLabel.text = timeString
        }
        else {
            self.messageDateLabel.text = messageData.date
        }

        self.usernameLabel.text = username.isEmpty ? localized("username") : username
        
        if let avatarName {
            self.iconImageView.image = UIImage(named: avatarName)
        }
        
        self.promptsStackView.removeAllArrangedSubviews()
        
        if let messagePrompts = messageData.prompts {
            
            for messagePrompt in messagePrompts {
                let promptView = PromptView()
                promptView.configure(title: messagePrompt)
                
                promptView.tappedPrompt = { [weak self] text in
                    print("PROMPT TEXT: \(text)")
                    self?.shouldSendPromptMessage?(text)
                }
                
                self.promptsStackView.addArrangedSubview(promptView)
            }
            
            self.showPrompts = true
            
        }
        else {
            
            self.showPrompts = false

        }
        
        if isAssistantMessage {
            self.iconImageView.image = UIImage(named: "ai_assistant_icon")
//            self.avatarCenterConstraint.constant = 0
        }

        if let onlineUsersPublisher = Env.gomaSocialClient.onlineUsersPublisher() {

            onlineUsersPublisher
                .receive(on: DispatchQueue.main)
                .sink(receiveValue: { [weak self] onlineUsersResponse in
                    guard let self = self else {return}

                    if let onlineUsersChat = onlineUsersResponse[chatroomId], let messageUserId = messageData.userId {

                        if onlineUsersChat.users.contains(messageUserId) {
                            self.showUserState = true

                        }
                        else {
                            self.showUserState = false

                        }

                    }

                })
                .store(in: &cancellables)
        }
    }

    func isReversedCell(isReversed: Bool) {
        if isReversed {
            self.contentView.transform = CGAffineTransform(scaleX: 1, y: -1)
        }
    }

//    private func setBubbleTailTriangle() {
//        let viewWidth = self.topBubbleTailView.frame.width
//        let viewheight = self.topBubbleTailView.frame.height
//        let path = CGMutablePath()
//
//        path.move(to: CGPoint(x: 0, y: 0))
//        path.addLine(to: CGPoint(x: (viewWidth/2)-3, y: viewheight))
//        path.addLine(to: CGPoint(x: viewWidth, y: 0))
//        path.addLine(to: CGPoint(x: 0, y: 0))
//
//        let shape = CAShapeLayer()
//        shape.path = path
//        shape.fillColor = UIColor.App.backgroundTertiary.cgColor
//
//        self.topBubbleTailView.layer.insertSublayer(shape, at: 0)
//    }

}

extension ReceivedMessageTableViewCell {

    private static func createIconBaseView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.borderWidth = 1
        return view
    }

    private static func createIconImageView() -> UIImageView {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.image = UIImage(named: "empty_user_image")
        imageView.contentMode = .scaleToFill
        return imageView
    }

//    private static func createMessageContainerView() -> UIView {
//        let view = UIView()
//        view.translatesAutoresizingMaskIntoConstraints = false
//        view.layer.cornerRadius = CornerRadius.message
//        return view
//    }
    
    private static func createMessageContainerView() -> ChatBubbleView {
        let view = ChatBubbleView()
        view.backgroundColors = [UIColor.App.backgroundTertiary]
        view.useGradient = false
        view.isReceivedMessage = true
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }

    private static func createUserStackView() -> UIStackView {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .horizontal
        stackView.spacing = 8
        stackView.distribution = .fillProportionally
        return stackView
    }

    private static func createUsernameLabel() -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = localized("username")
        label.font = AppFont.with(type: .bold, size: 16)
        label.setContentHuggingPriority(.required, for: .horizontal)
        return label
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

    private static func createMessageLabel() -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Curabitur porttitor mi eget pharetra eleifend. Nam vel finibus nibh, nec ullamcorper elit."
        label.textAlignment = .left
        label.numberOfLines = 0
        label.font = AppFont.with(type: .regular, size: 16)
        return label
    }
    
    private static func createPromptsStackView() -> UIStackView {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.distribution = .equalSpacing
        stackView.spacing = 8
        return stackView
    }

    private static func createMessageDateLabel() -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "01/01/2022 12:59"
        label.textAlignment = .right
        label.font = AppFont.with(type: .medium, size: 12)
        return label
    }

    private static func createTopBubbleTailView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }
    
    // Constraints
    private static func createMessageDateToTextConstraint() -> NSLayoutConstraint {
        let constraint = NSLayoutConstraint()
        return constraint
    }
    
    private static func createMessageDateToPromptsConstraint() -> NSLayoutConstraint {
        let constraint = NSLayoutConstraint()
        return constraint
    }
    
    private static func createAvatarCenterConstraint() -> NSLayoutConstraint {
        let constraint = NSLayoutConstraint()
        return constraint
    }
    

    private func setupSubviews() {

        self.contentView.addSubview(self.iconBaseView)

        self.iconBaseView.addSubview(self.iconImageView)

        self.contentView.addSubview(self.messageContainerView)

        self.messageContainerView.addSubview(self.userStackView)

        self.userStackView.addArrangedSubview(self.usernameLabel)
        self.userStackView.addArrangedSubview(self.userStateBaseView)

        self.userStateBaseView.addSubview(self.userStateView)

        self.messageContainerView.addSubview(self.messageLabel)
        
        self.messageContainerView.addSubview(self.promptsStackView)

        self.messageContainerView.addSubview(self.messageDateLabel)

//        self.contentView.addSubview(self.topBubbleTailView)
//
//        self.contentView.bringSubviewToFront(self.topBubbleTailView)

        self.initConstraints()

        self.showUserState = true

    }

    private func initConstraints() {

        NSLayoutConstraint.activate([
            self.iconBaseView.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor, constant: 16),
            self.iconBaseView.topAnchor.constraint(equalTo: self.contentView.topAnchor, constant: 16),
            self.iconBaseView.widthAnchor.constraint(equalToConstant: 28),
            self.iconBaseView.heightAnchor.constraint(equalTo: self.iconBaseView.widthAnchor),

            self.iconImageView.leadingAnchor.constraint(equalTo: self.iconBaseView.leadingAnchor),
            self.iconImageView.trailingAnchor.constraint(equalTo: self.iconBaseView.trailingAnchor),
            self.iconImageView.topAnchor.constraint(equalTo: self.iconBaseView.topAnchor),
            self.iconImageView.bottomAnchor.constraint(equalTo: self.iconBaseView.bottomAnchor),

            self.messageContainerView.leadingAnchor.constraint(equalTo: self.iconBaseView.trailingAnchor, constant: 10),
            self.messageContainerView.trailingAnchor.constraint(greaterThanOrEqualTo: self.contentView.trailingAnchor, constant: -60),
            self.messageContainerView.topAnchor.constraint(equalTo: self.contentView.topAnchor, constant: 16),
            self.messageContainerView.bottomAnchor.constraint(equalTo: self.contentView.bottomAnchor, constant: -16)
        ])

        NSLayoutConstraint.activate([
            self.userStackView.leadingAnchor.constraint(equalTo: self.messageContainerView.leadingAnchor, constant: 25),
            self.userStackView.trailingAnchor.constraint(equalTo: self.messageContainerView.trailingAnchor, constant: -15),
            self.userStackView.topAnchor.constraint(equalTo: self.messageContainerView.topAnchor, constant: 5),
            self.userStackView.heightAnchor.constraint(equalToConstant: 20),

            self.userStateBaseView.topAnchor.constraint(equalTo: self.userStackView.topAnchor),
//            self.userStateBaseView.bottomAnchor.constraint(equalTo: self.userStackView.bottomAnchor),
            self.userStateBaseView.widthAnchor.constraint(greaterThanOrEqualToConstant: 10),

            self.userStateView.widthAnchor.constraint(equalToConstant: 8),
            self.userStateView.heightAnchor.constraint(equalTo: self.userStateView.widthAnchor),
            self.userStateView.leadingAnchor.constraint(equalTo: self.userStateBaseView.leadingAnchor),
            self.userStateView.centerYAnchor.constraint(equalTo: self.userStateBaseView.centerYAnchor)
        ])

        NSLayoutConstraint.activate([
            self.messageLabel.leadingAnchor.constraint(equalTo: self.messageContainerView.leadingAnchor, constant: 25),
            self.messageLabel.trailingAnchor.constraint(equalTo: self.messageContainerView.trailingAnchor, constant: -15),
            self.messageLabel.topAnchor.constraint(equalTo: self.userStackView.bottomAnchor, constant: 8),
            
            self.promptsStackView.leadingAnchor.constraint(equalTo: self.messageContainerView.leadingAnchor, constant: 25),
            self.promptsStackView.trailingAnchor.constraint(equalTo: self.messageContainerView.trailingAnchor, constant: -15),
            self.promptsStackView.topAnchor.constraint(equalTo: self.messageLabel.bottomAnchor, constant: 4),

            self.messageDateLabel.leadingAnchor.constraint(equalTo: self.messageContainerView.leadingAnchor, constant: 25),
            self.messageDateLabel.trailingAnchor.constraint(equalTo: self.messageContainerView.trailingAnchor, constant: -15),
//            self.messageDateLabel.topAnchor.constraint(equalTo: self.promptsStackView.bottomAnchor, constant: 4),
            self.messageDateLabel.bottomAnchor.constraint(equalTo: self.messageContainerView.bottomAnchor, constant: -10)
        ])

//        NSLayoutConstraint.activate([
//            self.topBubbleTailView.leadingAnchor.constraint(equalTo: self.messageContainerView.leadingAnchor, constant: -6),
//            self.topBubbleTailView.topAnchor.constraint(equalTo: self.messageContainerView.topAnchor),
//            self.topBubbleTailView.widthAnchor.constraint(equalToConstant: 20),
//            self.topBubbleTailView.heightAnchor.constraint(equalToConstant: 18)
//        ])
        
        self.messageDateToTextConstraint =                         self.messageDateLabel.topAnchor.constraint(equalTo: self.messageLabel.bottomAnchor, constant: 8)
        
        self.messageDateToTextConstraint.isActive = true
        
        self.messageDateToPromptsConstraint =                         self.messageDateLabel.topAnchor.constraint(equalTo: self.promptsStackView.bottomAnchor, constant: 8)
        
        self.messageDateToPromptsConstraint.isActive = false
        
//        self.avatarCenterConstraint = self.iconImageView.topAnchor.constraint(equalTo: self.iconBaseView.topAnchor, constant: 3)
//        self.avatarCenterConstraint.isActive = true

    }
}
