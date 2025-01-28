//
//  InAppMessageTableViewCell.swift
//  Sportsbook
//
//  Created by André Lascas on 25/07/2022.
//

import UIKit
import Combine

class InAppMessageTableViewCell: UITableViewCell {

    // MARK: Private Properties
    private lazy var containerView: UIView = Self.createContainerView()
    private lazy var backgroundImageView: UIImageView = Self.createBackgroundImageView()
    private lazy var unreadIndicatorView: UIView = Self.createUnreadIndicatorView()
    private lazy var messageStackView: UIStackView = Self.createMessageStackView()
    private lazy var messageTypeLabel: UILabel = Self.createMessageTypeLabel()
    private lazy var messageTitleLabel: UILabel = Self.createMessageTitleLabel()
    private lazy var messageDescriptionLabel: UILabel = Self.createMessageDescriptionLabel()
    private lazy var logoImageView: UIImageView = Self.createLogoImageView()
    private lazy var gradientLayer: CAGradientLayer = Self.createGradientLayer()

    private var cardHeight: CGFloat = 88
    private var viewModel: InAppMessageCellViewModel?

    private var cancellables = Set<AnyCancellable>()

    // MARK: Public Properties
    var hasBackgroundImage: Bool = false {
        didSet {
            self.backgroundImageView.isHidden = !hasBackgroundImage

            if hasBackgroundImage {
                self.messageTitleLabel.textColor = UIColor.App.buttonTextPrimary

                self.messageDescriptionLabel.textColor = UIColor.App.buttonTextPrimary
            }
            else {
                self.messageTitleLabel.textColor = UIColor.App.textPrimary

                self.messageDescriptionLabel.textColor = UIColor.App.textPrimary
            }
        }
    }

    var unreadMessage: Bool = false {
        didSet {
            self.unreadIndicatorView.isHidden = !unreadMessage

            if !unreadMessage {
                self.containerView.layer.borderWidth = 1
                self.containerView.layer.borderColor =  UIColor.App.buttonBorderTertiary.cgColor
            }
            else {
                self.containerView.layer.borderWidth = 0
            }
        }
    }

    var hasLogoImage: Bool = false {
        didSet {
            self.logoImageView.isHidden = !hasLogoImage
        }
    }

    var hasDescriptionLabel: Bool = false {
        didSet {
            self.messageDescriptionLabel.isHidden = !hasDescriptionLabel
        }
    }

    var tappedContainer: (() -> Void)?

    static var normalDateFormatter: DateFormatter = {
        var dateFormatter = Date.buildFormatter(locale: Env.locale)
        return dateFormatter
    }()

    static var relativeDateFormatter: DateFormatter = {
        var dateFormatter = Date.buildFormatter(locale: Env.locale, hasRelativeDate: true)
        return dateFormatter
    }()

    // MARK: Lifetime and Cycle
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        self.setupSubviews()
        self.commonInit()
        self.setupWithTheme()

        self.setNeedsLayout()
        self.layoutIfNeeded()

    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func prepareForReuse() {
        super.prepareForReuse()

        self.hasBackgroundImage = false

        self.unreadMessage = false

        self.hasLogoImage = false

        self.hasDescriptionLabel = false
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        self.containerView.layer.cornerRadius = CornerRadius.view
        self.containerView.layer.masksToBounds = true

        self.logoImageView.layer.cornerRadius = self.logoImageView.frame.width/2

        self.gradientLayer.frame = CGRect(x: 0, y: 0, width: self.backgroundImageView.frame.width*0.7, height: self.cardHeight)
        self.backgroundImageView.layer.insertSublayer(self.gradientLayer, at: 0)

    }

    private func commonInit() {
        self.hasBackgroundImage = false

        self.unreadMessage = false

        self.hasLogoImage = false

        self.hasDescriptionLabel = false

        let containerGesture = UITapGestureRecognizer(target: self, action: #selector(didTapContainer))
        self.containerView.addGestureRecognizer(containerGesture)

    }

    private func setupWithTheme() {

        self.contentView.backgroundColor = UIColor.App.backgroundPrimary

        self.containerView.backgroundColor = UIColor.App.backgroundSecondary

        self.backgroundImageView.backgroundColor = .clear

        self.unreadIndicatorView.backgroundColor = UIColor.App.highlightPrimary

        self.messageStackView.backgroundColor = .clear

        self.messageTypeLabel.textColor = UIColor.App.textSecondary

        self.messageTitleLabel.textColor = UIColor.App.textPrimary

        self.messageDescriptionLabel.textColor = UIColor.App.textPrimary

        self.logoImageView.backgroundColor = .clear
    }

    func setupPublishers() {

        if let viewModel = self.viewModel {

            viewModel.unreadMessagePublisher
                .receive(on: DispatchQueue.main)
                .sink(receiveValue: { [weak self] unreadMessage in
                    self?.unreadMessage = unreadMessage
                })
                .store(in: &cancellables)
        }
    }

    func configure(viewModel: InAppMessageCellViewModel) {

        self.viewModel = viewModel

        let messageDateString = viewModel.inAppMessage.createdAtDateString

        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"

        if let messageDate = dateFormatter.date(from: messageDateString) {

            let relativeFormatter = InAppMessageTableViewCell.relativeDateFormatter
            let relativeDateString = relativeFormatter.string(from: messageDate)

            let nonRelativeFormatter = InAppMessageTableViewCell.normalDateFormatter
            let normalDateString = nonRelativeFormatter.string(from: messageDate)

            if relativeDateString == normalDateString {
                self.messageTypeLabel.text = "\(viewModel.inAppMessage.subtype.capitalized) | \(normalDateString)"
            }
            else {
                self.messageTypeLabel.text = "\(viewModel.inAppMessage.subtype.capitalized) | \(relativeDateString)"
            }
        }

        self.messageTitleLabel.text = viewModel.inAppMessage.title

        if viewModel.inAppMessage.subtype == MessageCardType.promo.identifier {
            if let imageUrlString = viewModel.inAppMessage.imageUrl {
                let backgroundImageUrl = URL(string: imageUrlString)
                self.backgroundImageView.kf.setImage(with: backgroundImageUrl)
                self.hasBackgroundImage = true
            }

        }
        else if viewModel.inAppMessage.subtype == MessageCardType.news.identifier {

            if let imageUrlString = viewModel.inAppMessage.imageUrl {

                let backgroundImageUrl = URL(string: imageUrlString)
                self.backgroundImageView.kf.setImage(with: backgroundImageUrl)
                self.hasBackgroundImage = true

                // self.logoImageView.image = UIImage(named: "brand_icon_variation_1")
                self.hasLogoImage = false
            }
        }
        else if viewModel.inAppMessage.subtype == MessageCardType.information.identifier {

//            let htmlDescription = viewModel.inAppMessage.text
//            let data = Data(htmlDescription.utf8)
//
//            if let attributedString = try? NSMutableAttributedString(data: data, options: [.documentType: NSAttributedString.DocumentType.html], documentAttributes: nil) {
//
//                let attributes: [NSAttributedString.Key: AnyObject] = [NSAttributedString.Key.foregroundColor: UIColor.App.textPrimary,
//                 NSAttributedString.Key.backgroundColor: UIColor.App.backgroundSecondary,
//                                                                       NSAttributedString.Key.font: AppFont.with(type: .medium, size: 14)]
//
//                attributedString.addAttributes(attributes,
//                                               range: NSRange.init(location: 0, length: attributedString.length ))
//
//                self.messageDescriptionLabel.attributedText = attributedString
//            }

            self.messageDescriptionLabel.text = viewModel.inAppMessage.text
            
            self.hasDescriptionLabel = true
        }

        self.setupPublishers()

    }

    // MARK: Action
    @objc func didTapContainer() {
        if let viewModel = self.viewModel {
            self.tappedContainer?()
        }
    }

}

extension InAppMessageTableViewCell {

    private static func createContainerView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }

    private static func createBackgroundImageView() -> UIImageView {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFill
        return imageView
    }

    private static func createUnreadIndicatorView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.masksToBounds = true
        return view
    }

    private static func createMessageStackView() -> UIStackView {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.spacing = 4
        stackView.axis = .vertical
        stackView.distribution = .equalSpacing
        return stackView
    }

    private static func createMessageTypeLabel() -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Message Type"
        label.font = AppFont.with(type: .medium, size: 11)
        label.textAlignment = .left
        return label
    }

    private static func createMessageTitleLabel() -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Message TItle"
        label.font = AppFont.with(type: .bold, size: 14)
        label.textAlignment = .left
        label.numberOfLines = 2
        label.setLineSpacing(lineSpacing: 3)
        return label
    }

    private static func createMessageDescriptionLabel() -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Message Description"
        label.font = AppFont.with(type: .medium, size: 12)
        label.textAlignment = .left
        return label
    }

    private static func createLogoImageView() -> UIImageView {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.image = UIImage(named: "brand_icon_variation_new")
        imageView.contentMode = .scaleAspectFit
        return imageView
    }

    private static func createGradientLayer() -> CAGradientLayer {
        let gradient = CAGradientLayer()
        let startColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.8).cgColor
        let endColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0).cgColor
        gradient.startPoint = CGPoint(x: 0.0, y: 0.5)
        gradient.endPoint = CGPoint(x: 1.0, y: 0.5)
        gradient.colors = [startColor, endColor]
        return gradient
    }

    private func setupSubviews() {

        self.contentView.addSubview(self.containerView)

        self.containerView.addSubview(self.backgroundImageView)

        self.containerView.addSubview(self.unreadIndicatorView)

        self.containerView.addSubview(self.messageStackView)

        self.messageStackView.addArrangedSubview(self.messageTypeLabel)
        self.messageStackView.addArrangedSubview(self.messageTitleLabel)
        self.messageStackView.addArrangedSubview(self.messageDescriptionLabel)

        self.containerView.addSubview(self.logoImageView)

        self.initConstraints()

    }

    private func initConstraints() {

        NSLayoutConstraint.activate([
            self.containerView.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor, constant: 0),
            self.containerView.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor, constant: 0),
            self.containerView.topAnchor.constraint(equalTo: self.contentView.topAnchor, constant: 4),
            self.containerView.bottomAnchor.constraint(equalTo: self.contentView.bottomAnchor, constant: -4),
            self.containerView.heightAnchor.constraint(equalToConstant: self.cardHeight),

            self.backgroundImageView.leadingAnchor.constraint(equalTo: self.containerView.leadingAnchor),
            self.backgroundImageView.trailingAnchor.constraint(equalTo: self.containerView.trailingAnchor),
            self.backgroundImageView
                .topAnchor.constraint(equalTo: self.containerView.topAnchor),
            self.backgroundImageView.bottomAnchor.constraint(equalTo: self.containerView.bottomAnchor),

            self.unreadIndicatorView.leadingAnchor.constraint(equalTo: self.containerView.leadingAnchor),
            self.unreadIndicatorView.topAnchor.constraint(equalTo: self.containerView.topAnchor),
            self.unreadIndicatorView.bottomAnchor.constraint(equalTo: self.containerView.bottomAnchor),
            self.unreadIndicatorView.widthAnchor.constraint(equalToConstant: 4)

        ])

        // Content
        NSLayoutConstraint.activate([
            self.messageStackView.leadingAnchor.constraint(equalTo: self.containerView.leadingAnchor, constant: 20),
            self.messageStackView.trailingAnchor.constraint(equalTo: self.containerView.trailingAnchor, constant: -110),
            self.messageStackView.topAnchor.constraint(equalTo: self.containerView.topAnchor, constant: 15),
            self.messageStackView.bottomAnchor.constraint(equalTo: self.containerView.bottomAnchor, constant: -15),

            self.logoImageView.trailingAnchor.constraint(equalTo: self.containerView.trailingAnchor, constant: -23),
            self.logoImageView.centerYAnchor.constraint(equalTo: self.containerView.centerYAnchor),
            self.logoImageView.widthAnchor.constraint(equalToConstant: 65),
            self.logoImageView.heightAnchor.constraint(equalTo: self.logoImageView.widthAnchor)
        ])

    }
}

enum MessageCardType {
    case promo
    case news
    case information

    var identifier: String {
        switch self {
        case .promo:
            return "promo"
        case .news:
            return "news"
        case .information:
            return "information"
        }
    }
}

