//
//  SentMessageTableViewCell.swift
//  Sportsbook
//
//  Created by André Lascas on 07/04/2022.
//

import UIKit

class SentMessageTableViewCell: UITableViewCell {

    // MARK: Private Properties
    private lazy var messageContainerView: UIView = Self.createMessageContainerView()
    private lazy var messageLabel: UILabel = Self.createMessageLabel()
    private lazy var dateStackView: UIStackView = Self.createDateStackView()
    private lazy var messageDateLabel: UILabel = Self.createMessageDateLabel()
    private lazy var messageStateBaseView: UIView = Self.createMessageStateBaseView()
    private lazy var messageStateImageView: UIImageView = Self.createMessageStateImageView()
    private lazy var topBubbleTailView: UIView = Self.createTopBubbleTailView()

    // MARK: Public Properties
    var isMessageSeen: Bool = false {
        didSet {
            if isMessageSeen {
                self.messageStateImageView.image = UIImage(named: "seen_message_icon")
            }
            else {
                self.messageStateImageView.image = UIImage(named: "sent_message_icon")
            }
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

        self.messageContainerView.layer.borderWidth = 1
        self.messageContainerView.layer.borderColor = UIColor.App.backgroundTertiary.cgColor

        self.setBubbleTailTriangle()

    }

    func setupWithTheme() {

        self.contentView.backgroundColor = UIColor.App.backgroundPrimary

        self.messageContainerView.backgroundColor = UIColor.App.backgroundPrimary

        self.messageLabel.textColor = UIColor.App.textSecondary

        self.dateStackView.backgroundColor = .clear

        self.messageDateLabel.textColor = UIColor.App.textDisablePrimary

        self.messageStateBaseView.backgroundColor = .clear

        self.topBubbleTailView.backgroundColor = .clear
    }

    // MARK: Functions

    func setupMessage(messageData: MessageData) {
        self.messageLabel.text = messageData.text

        self.messageDateLabel.text = messageData.date

        if messageData.type == .sentNotSeen {
            self.isMessageSeen = false
        }
        else if messageData.type == .sentSeen {
            self.isMessageSeen = true
        }

    }

    func isReversedCell(isReversed: Bool) {
        if isReversed {
            self.contentView.transform = CGAffineTransform(scaleX: 1, y: -1)
        }
    }

    private func setBubbleTailTriangle() {
        let heightWidth = self.topBubbleTailView.frame.width - 1
        let path = CGMutablePath()

        path.move(to: CGPoint(x: 0, y: 0))
        path.addLine(to: CGPoint(x: heightWidth, y: 0))
        path.addLine(to: CGPoint(x: heightWidth/2, y: heightWidth/2))
        // No need for \ triangle line to stroke
        // path.addLine(to: CGPoint(x: 0, y: 0))

        let shape = CAShapeLayer()
        shape.path = path
        shape.fillColor = UIColor.App.backgroundPrimary.cgColor
        shape.strokeColor = UIColor.App.backgroundTertiary.cgColor

        self.topBubbleTailView.layer.insertSublayer(shape, at: 0)
    }

}

extension SentMessageTableViewCell {

    private static func createMessageContainerView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.cornerRadius = CornerRadius.view
        return view
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
        label.font = AppFont.with(type: .medium, size: 16)
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
        imageView.image = UIImage(named: "sent_message_icon")
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

        self.messageContainerView.addSubview(self.dateStackView)

        self.dateStackView.addArrangedSubview(self.messageDateLabel)
        self.dateStackView.addArrangedSubview(self.messageStateBaseView)

        self.messageStateBaseView.addSubview(self.messageStateImageView)

        self.contentView.addSubview(self.topBubbleTailView)

        self.contentView.bringSubviewToFront(self.topBubbleTailView)

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

            self.dateStackView.leadingAnchor.constraint(equalTo: self.messageContainerView.leadingAnchor, constant: 15),
            self.dateStackView.trailingAnchor.constraint(equalTo: self.messageContainerView.trailingAnchor, constant: -15),
            self.dateStackView.topAnchor.constraint(equalTo: self.messageLabel.bottomAnchor, constant: 8),
            self.dateStackView.bottomAnchor.constraint(equalTo: self.messageContainerView.bottomAnchor, constant: -10),
            self.dateStackView.heightAnchor.constraint(equalToConstant: 25),

            self.messageStateBaseView.widthAnchor.constraint(greaterThanOrEqualToConstant: 10),

            self.messageStateImageView.widthAnchor.constraint(equalToConstant: 15),
            self.messageStateImageView.centerYAnchor.constraint(equalTo: self.messageStateBaseView.centerYAnchor),
            self.messageStateImageView.trailingAnchor.constraint(equalTo: self.messageStateBaseView.trailingAnchor)

        ])

        NSLayoutConstraint.activate([
            self.topBubbleTailView.trailingAnchor.constraint(equalTo: self.messageContainerView.trailingAnchor, constant: 5),
            self.topBubbleTailView.topAnchor.constraint(equalTo: self.messageContainerView.topAnchor, constant: 0.5),
            self.topBubbleTailView.widthAnchor.constraint(equalToConstant: 10),
            self.topBubbleTailView.heightAnchor.constraint(equalTo: self.topBubbleTailView.widthAnchor)
        ])
    }
}
