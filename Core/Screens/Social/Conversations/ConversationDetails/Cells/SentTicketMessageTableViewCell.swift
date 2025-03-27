//
//  SentTicketMessageTableViewCell.swift
//  Sportsbook
//
//  Created by Ruben Roques on 26/05/2022.
//

import UIKit

class SentTicketMessageTableViewCell: UITableViewCell {

    var didTapBetNowAction: ((BetSelectionCellViewModel) -> Void) = { _ in }

    // MARK: Private Properties
//    private lazy var messageContainerView: UIView = Self.createMessageContainerView()
    private lazy var messageContainerView: ChatBubbleView = Self.createMessageContainerView()

    private lazy var messageLabel: UILabel = Self.createMessageLabel()
    private lazy var ticketBaseStackView: UIStackView = Self.createTicketBaseStackView()
    private lazy var dateStackView: UIStackView = Self.createDateStackView()
    private lazy var messageDateLabel: UILabel = Self.createMessageDateLabel()
    private lazy var messageStateBaseView: UIView = Self.createMessageStateBaseView()
    private lazy var messageStateImageView: UIImageView = Self.createMessageStateImageView()
//    private lazy var topBubbleTailView: UIView = Self.createTopBubbleTailView()

    private var ticketInMessageView: ChatTicketInMessageView?
    private var ticketStateInMessageView: ChatTicketStateInMessageView?
    
    private let dateFormatter = DateFormatter()

    // MARK: Public Properties
    var isMessageSeen: Bool = false {
        didSet {
            if isMessageSeen {
                self.messageStateImageView.image = UIImage(named: "seen_message_icon")?.withRenderingMode(.alwaysTemplate)
            }
            else {
                self.messageStateImageView.image = UIImage(named: "sent_message_icon")?.withRenderingMode(.alwaysTemplate)
            }
            
            self.messageStateImageView.setTintColor(color: UIColor.App.highlightTertiary)

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

        self.ticketBaseStackView.removeAllArrangedSubviews()
        self.ticketInMessageView = nil

        self.setupWithTheme()
    }

    override func layoutSubviews() {
        super.layoutSubviews()

//        self.messageContainerView.layer.borderWidth = 1
//        self.messageContainerView.layer.borderColor = UIColor.App.backgroundBorder.cgColor

//        self.setBubbleTailTriangle()
        
    }

    func setupWithTheme() {

        self.contentView.backgroundColor = UIColor.App.backgroundSecondary

        self.messageContainerView.backgroundColor = UIColor.App.backgroundSecondary

        self.messageLabel.textColor = UIColor.App.buttonTextSecondary

        self.dateStackView.backgroundColor = .clear

        self.messageDateLabel.textColor = UIColor.App.textSecondary

        self.messageStateBaseView.backgroundColor = .clear

//        self.topBubbleTailView.backgroundColor = .clear

        self.ticketBaseStackView.backgroundColor = .clear

        self.ticketInMessageView?.setupWithTheme()

    }

    // MARK: Functions

    func setupMessage(messageData: MessageData) {
        self.messageLabel.text = messageData.text

        if messageData.text.isEmpty {
            self.messageLabel.text = localized("chat_empty_shared_ticket_self")
        }
        
        self.dateFormatter.dateFormat = "dd-MM-yyyy HH:mm"

        if let date = dateFormatter.date(from: messageData.date) {
            dateFormatter.dateFormat = "HH:mm"
            let timeString = dateFormatter.string(from: date)
            self.messageDateLabel.text = timeString
        }
        else {
            self.messageDateLabel.text = messageData.date
        }

        if messageData.type == .sentNotSeen {
            self.isMessageSeen = false
        }
        else if messageData.type == .sentSeen {
            self.isMessageSeen = true
        }

        self.ticketBaseStackView.removeAllArrangedSubviews()
        if let attachment = messageData.attachment {
            let ticket = BetHistoryEntry(sharedBetTicket: attachment.content)
            let betSelectionCellViewModel = BetSelectionCellViewModel(ticket: ticket)
            
            let ticketStatus = ticket.status?.lowercased()

            if ticketStatus == "open" || ticketStatus == "pending"  {
                self.ticketInMessageView = ChatTicketInMessageView(betSelectionCellViewModel: betSelectionCellViewModel,
                                                                   shouldShowButton: true)

                self.ticketInMessageView!.didTapBetNowAction = { [weak self] viewModel in
                    self?.didTapBetNowAction(viewModel)
                }
                self.ticketBaseStackView.addArrangedSubview(self.ticketInMessageView!)
            }
            else {
                self.ticketStateInMessageView = ChatTicketStateInMessageView(betSelectionCellViewModel: betSelectionCellViewModel)

                self.ticketBaseStackView.addArrangedSubview(self.ticketStateInMessageView!)
            }

        }

        self.ticketInMessageView?.cardBackgroundColor = UIColor.App.backgroundPrimary
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
//        path.addLine(to: CGPoint(x: viewWidth, y: 0))
//        path.addLine(to: CGPoint(x: (viewWidth/2)+3, y: viewheight))
//        // No need for \ triangle line to stroke
//        // path.addLine(to: CGPoint(x: 0, y: 0))
//
//        let shape = CAShapeLayer()
//        shape.path = path
//        shape.fillColor = UIColor.App.backgroundSecondary.cgColor
//        shape.strokeColor = UIColor.App.backgroundBorder.cgColor
//
//        self.topBubbleTailView.layer.insertSublayer(shape, at: 0)
//    }

}

extension SentTicketMessageTableViewCell {

//    private static func createMessageContainerView() -> UIView {
//        let view = UIView()
//        view.translatesAutoresizingMaskIntoConstraints = false
//        view.layer.cornerRadius = CornerRadius.message
//        return view
//    }
    
    private static func createMessageContainerView() -> ChatBubbleView {
        let view = ChatBubbleView()
        view.backgroundColors = [UIColor.App.messageGradient1, UIColor.App.messageGradient2]
        view.useGradient = true
        view.translatesAutoresizingMaskIntoConstraints = false
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

    private static func createDateStackView() -> UIStackView {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .horizontal
        stackView.spacing = 8
        stackView.distribution = .fillProportionally
        stackView.semanticContentAttribute = .forceRightToLeft
        return stackView
    }

    private static func createMessageLabel() -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Lorem ipsum dolor sit amet, consectetur adipiscing elit"
        label.textAlignment = .left
        label.numberOfLines = 0
        label.font = AppFont.with(type: .regular, size: 16)
        return label
    }

    private static func createMessageDateLabel() -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "01/01/2022 12:59"
        label.textAlignment = .right
        label.font = AppFont.with(type: .medium, size: 12)
        label.setContentHuggingPriority(.required, for: .horizontal)
        return label
    }

    private static func createMessageStateBaseView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.setContentHuggingPriority(.defaultLow, for: .horizontal)
        return view
    }

    private static func createMessageStateImageView() -> UIImageView {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.image = UIImage(named: "sent_message_icon")?.withRenderingMode(.alwaysTemplate)
        imageView.setTintColor(color: UIColor.App.highlightTertiary)
        imageView.contentMode = .scaleAspectFit
        return imageView
    }

    private static func createTopBubbleTailView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }

    private func setupSubviews() {

        self.contentView.addSubview(self.messageContainerView)

        self.messageContainerView.addSubview(self.messageLabel)

        self.messageContainerView.addSubview(self.ticketBaseStackView)

        self.messageContainerView.addSubview(self.dateStackView)

        self.dateStackView.addArrangedSubview(self.messageDateLabel)
        self.dateStackView.addArrangedSubview(self.messageStateBaseView)

        self.messageStateBaseView.addSubview(self.messageStateImageView)

//        self.contentView.addSubview(self.topBubbleTailView)
//
//        self.contentView.bringSubviewToFront(self.topBubbleTailView)
        
        self.contentView

        self.initConstraints()

        self.isMessageSeen = false

    }

    private func initConstraints() {

        NSLayoutConstraint.activate([

            self.messageContainerView.leadingAnchor.constraint(lessThanOrEqualTo: self.contentView.leadingAnchor, constant: 60),
            self.messageContainerView.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor, constant: -20),
            self.messageContainerView.topAnchor.constraint(equalTo: self.contentView.topAnchor, constant: 16),
            self.messageContainerView.bottomAnchor.constraint(equalTo: self.contentView.bottomAnchor, constant: -16)
        ])

        NSLayoutConstraint.activate([

            self.messageLabel.leadingAnchor.constraint(equalTo: self.messageContainerView.leadingAnchor, constant: 15),
            self.messageLabel.trailingAnchor.constraint(equalTo: self.messageContainerView.trailingAnchor, constant: -30),
            self.messageLabel.topAnchor.constraint(equalTo: self.messageContainerView.topAnchor, constant: 10),

            self.ticketBaseStackView.leadingAnchor.constraint(equalTo: self.messageContainerView.leadingAnchor),
            self.ticketBaseStackView.trailingAnchor.constraint(equalTo: self.messageContainerView.trailingAnchor, constant: -10),
            self.ticketBaseStackView.topAnchor.constraint(equalTo: self.messageLabel.bottomAnchor, constant: 8),

            self.dateStackView.leadingAnchor.constraint(equalTo: self.messageContainerView.leadingAnchor, constant: 15),
            self.dateStackView.trailingAnchor.constraint(equalTo: self.messageContainerView.trailingAnchor, constant: -25),
            self.dateStackView.topAnchor.constraint(equalTo: self.ticketBaseStackView.bottomAnchor, constant: 8),
            self.dateStackView.bottomAnchor.constraint(equalTo: self.messageContainerView.bottomAnchor, constant: -10),
            self.dateStackView.heightAnchor.constraint(equalToConstant: 25),

            self.messageStateBaseView.widthAnchor.constraint(greaterThanOrEqualToConstant: 10),

            self.messageStateImageView.widthAnchor.constraint(equalToConstant: 15),
            self.messageStateImageView.centerYAnchor.constraint(equalTo: self.messageStateBaseView.centerYAnchor),
            self.messageStateImageView.trailingAnchor.constraint(equalTo: self.messageStateBaseView.trailingAnchor)
        ])

//        NSLayoutConstraint.activate([
//            self.topBubbleTailView.trailingAnchor.constraint(equalTo: self.messageContainerView.trailingAnchor, constant: 6),
//            self.topBubbleTailView.topAnchor.constraint(equalTo: self.messageContainerView.topAnchor, constant: 0.65),
//            self.topBubbleTailView.widthAnchor.constraint(equalToConstant: 20),
//            self.topBubbleTailView.heightAnchor.constraint(equalToConstant: 18)
//        ])
    }
}
