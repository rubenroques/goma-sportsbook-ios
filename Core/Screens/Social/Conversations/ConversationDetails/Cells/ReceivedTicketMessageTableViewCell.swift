//
//  ReceivedTicketMessageTableViewCell.swift
//  Sportsbook
//
//  Created by Ruben Roques on 26/05/2022.
//

import UIKit
import Combine

class ReceivedTicketMessageTableViewCell: UITableViewCell {

    var didTapBetNowAction: ((BetSelectionCellViewModel) -> Void) = { _ in }

    // MARK: Private Properties
    private lazy var iconBaseView: UIView = Self.createIconBaseView()
    private lazy var iconImageView: UIImageView = Self.createIconImageView()
    private lazy var messageContainerView: UIView = Self.createMessageContainerView()
    private lazy var ticketBaseStackView: UIStackView = Self.createTicketBaseStackView()
    private lazy var userStackView: UIStackView = Self.createUserStackView()
    private lazy var usernameLabel: UILabel = Self.createUsernameLabel()
    private lazy var userStateBaseView: UIView = Self.createUserStateBaseView()
    private lazy var userStateView: UIView = Self.createUserStateView()
    private lazy var messageLabel: UILabel = Self.createMessageLabel()
    private lazy var messageDateLabel: UILabel = Self.createMessageDateLabel()
    private lazy var topBubbleTailView: UIView = Self.createTopBubbleTailView()

    private var ticketInMessageView: ChatTicketInMessageView?
    private var ticketStateInMessageView: ChatTicketStateInMessageView?

    private var cancellables = Set<AnyCancellable>()

    // MARK: Public Properties
    var showUserState: Bool = false {
        didSet {
            self.userStateBaseView.isHidden = !showUserState
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
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        self.iconBaseView.layer.cornerRadius = self.iconBaseView.frame.height / 2
        self.iconImageView.layer.cornerRadius = self.iconImageView.frame.height / 2

        self.userStateView.layer.cornerRadius = self.userStateView.frame.height / 2

        self.setBubbleTailTriangle()
    }

    func setupWithTheme() {

        self.contentView.backgroundColor = UIColor.App.backgroundPrimary

        self.iconBaseView.backgroundColor = UIColor.App.backgroundTertiary
        self.iconImageView.backgroundColor = UIColor.App.backgroundTertiary

        self.messageContainerView.backgroundColor = UIColor.App.backgroundTertiary

        self.userStackView.backgroundColor = .clear
        self.usernameLabel.textColor = UIColor.App.textPrimary
        self.userStateBaseView.backgroundColor = .clear
        self.userStateView.backgroundColor = UIColor.App.alertSuccess

        self.messageLabel.textColor = UIColor.App.textSecondary
        self.messageDateLabel.textColor = UIColor.App.textDisablePrimary

        self.topBubbleTailView.backgroundColor = .clear
        self.ticketBaseStackView.backgroundColor = .clear

        self.ticketInMessageView?.setupWithTheme()

    }

    // MARK: Functions
    func setupMessage(messageData: MessageData, username: String, chatroomId: Int) {
        self.messageLabel.text = messageData.text

        self.messageDateLabel.text = messageData.date

//        if messageData.type == .receivedOffline {
//            self.showUserState = false
//        }
//        else if messageData.type == .receivedOnline {
//            self.showUserState = true
//        }

        self.usernameLabel.text = username

        self.ticketBaseStackView.removeAllArrangedSubviews()
        if let attachment = messageData.attachment {
            let ticket = BetHistoryEntry(sharedBetTicket: attachment.content)
            let betSelectionCellViewModel = BetSelectionCellViewModel(ticket: ticket)

            if ticket.status == "OPEN" {
                self.ticketInMessageView = ChatTicketInMessageView(betSelectionCellViewModel: betSelectionCellViewModel,
                                                                   shouldShowButton: true)

                self.ticketInMessageView!.didTapBetNowAction = { [weak self] viewModel in
                    self?.didTapBetNowAction(viewModel)
                }

                self.ticketBaseStackView.addArrangedSubview(self.ticketInMessageView!)
            }
            else {
                self.ticketStateInMessageView = ChatTicketStateInMessageView(betSelectionCellViewModel: betSelectionCellViewModel)

                self.ticketBaseStackView.addArrangedSubview(self.ticketStateInMessageView!)
            }
        }

        self.ticketInMessageView?.cardBackgroundColor = UIColor.App.backgroundSecondary

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

    private func setBubbleTailTriangle() {
        let heightWidth = self.topBubbleTailView.frame.width
        let path = CGMutablePath()

        path.move(to: CGPoint(x: 0, y: 0))
        path.addLine(to: CGPoint(x: heightWidth/2, y: heightWidth/2))
        path.addLine(to: CGPoint(x: heightWidth, y: 0))
        path.addLine(to: CGPoint(x: 0, y: 0))

        let shape = CAShapeLayer()
        shape.path = path
        shape.fillColor = UIColor.App.backgroundTertiary.cgColor

        self.topBubbleTailView.layer.insertSublayer(shape, at: 0)
    }

}

extension ReceivedTicketMessageTableViewCell {

    private static func createIconBaseView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }

    private static func createIconImageView() -> UIImageView {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.image = UIImage(named: "my_account_profile_icon")
        imageView.contentMode = .scaleToFill
        return imageView
    }

    private static func createMessageContainerView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.cornerRadius = CornerRadius.view
        return view
    }

    private static func createTicketBaseStackView() -> UIStackView {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.spacing = 0
        stackView.distribution = .fill
        return stackView
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
        label.text = "Username"
        label.font = AppFont.with(type: .semibold, size: 16)
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
        label.font = AppFont.with(type: .medium, size: 16)
        return label
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

    private func setupSubviews() {

        self.contentView.addSubview(self.iconBaseView)

        self.iconBaseView.addSubview(self.iconImageView)

        self.contentView.addSubview(self.messageContainerView)

        self.messageContainerView.addSubview(self.userStackView)

        self.userStackView.addArrangedSubview(self.usernameLabel)
        self.userStackView.addArrangedSubview(self.userStateBaseView)

        self.userStateBaseView.addSubview(self.userStateView)

        self.messageContainerView.addSubview(self.messageLabel)

        self.messageContainerView.addSubview(self.ticketBaseStackView)

        self.messageContainerView.addSubview(self.messageDateLabel)

        self.contentView.addSubview(self.topBubbleTailView)

        self.contentView.bringSubviewToFront(self.topBubbleTailView)

        self.initConstraints()

        self.showUserState = true

    }

    private func initConstraints() {

        NSLayoutConstraint.activate([
            self.iconBaseView.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor, constant: 16),
            self.iconBaseView.topAnchor.constraint(equalTo: self.contentView.topAnchor, constant: 16),
            self.iconBaseView.widthAnchor.constraint(equalToConstant: 24),
            self.iconBaseView.heightAnchor.constraint(equalTo: self.iconBaseView.widthAnchor),

            self.iconImageView.leadingAnchor.constraint(equalTo: self.iconBaseView.leadingAnchor, constant: 3),
            self.iconImageView.trailingAnchor.constraint(equalTo: self.iconBaseView.trailingAnchor, constant: -3),
            self.iconImageView.topAnchor.constraint(equalTo: self.iconBaseView.topAnchor, constant: 3),
            self.iconImageView.bottomAnchor.constraint(equalTo: self.iconBaseView.bottomAnchor, constant: -3),

            self.messageContainerView.leadingAnchor.constraint(equalTo: self.iconBaseView.trailingAnchor, constant: 10),
            self.messageContainerView.trailingAnchor.constraint(greaterThanOrEqualTo: self.contentView.trailingAnchor, constant: -60),
            self.messageContainerView.topAnchor.constraint(equalTo: self.contentView.topAnchor, constant: 16),
            self.messageContainerView.bottomAnchor.constraint(equalTo: self.contentView.bottomAnchor, constant: -16)
        ])

        NSLayoutConstraint.activate([
            self.userStackView.leadingAnchor.constraint(equalTo: self.messageContainerView.leadingAnchor, constant: 15),
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
            self.messageLabel.leadingAnchor.constraint(equalTo: self.messageContainerView.leadingAnchor, constant: 15),
            self.messageLabel.trailingAnchor.constraint(equalTo: self.messageContainerView.trailingAnchor, constant: -15),
            self.messageLabel.topAnchor.constraint(equalTo: self.userStackView.bottomAnchor, constant: 8),

            self.ticketBaseStackView.leadingAnchor.constraint(equalTo: self.messageContainerView.leadingAnchor),
            self.ticketBaseStackView.trailingAnchor.constraint(equalTo: self.messageContainerView.trailingAnchor),
            self.ticketBaseStackView.topAnchor.constraint(equalTo: self.messageLabel.bottomAnchor, constant: 8),

            self.messageDateLabel.leadingAnchor.constraint(equalTo: self.messageContainerView.leadingAnchor, constant: 15),
            self.messageDateLabel.trailingAnchor.constraint(equalTo: self.messageContainerView.trailingAnchor, constant: -15),
            self.messageDateLabel.topAnchor.constraint(equalTo: self.ticketBaseStackView.bottomAnchor, constant: 8),
            self.messageDateLabel.bottomAnchor.constraint(equalTo: self.messageContainerView.bottomAnchor, constant: -10)
        ])

        NSLayoutConstraint.activate([
            self.topBubbleTailView.leadingAnchor.constraint(equalTo: self.messageContainerView.leadingAnchor, constant: -5),
            self.topBubbleTailView.topAnchor.constraint(equalTo: self.messageContainerView.topAnchor),
            self.topBubbleTailView.widthAnchor.constraint(equalToConstant: 10),
            self.topBubbleTailView.heightAnchor.constraint(equalTo: self.topBubbleTailView.widthAnchor)
        ])
    }
}
