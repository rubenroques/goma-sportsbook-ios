//
//  MessageDetailViewController.swift
//  Sportsbook
//
//  Created by André Lascas on 26/07/2022.
//

import UIKit
import Combine

class MessageDetailViewController: UIViewController {

    // MARK: Private Properties
    private lazy var topView: UIView = Self.createTopView()
    private lazy var backButton: UIButton = Self.createBackButton()
    private lazy var topTitleLabel: UILabel = Self.createTopTitleLabel()
    private lazy var headerView: UIView = Self.createHeaderView()
    private lazy var headerTitleLabel: UILabel = Self.createHeaderTitleLabel()
    private lazy var deleteButton: UIButton = Self.createDeleteButton()
    private lazy var headerSeparatorView: UIView = Self.createHeaderSeparatorView()

    private lazy var scrollView: UIScrollView = Self.createScrollView()
    private lazy var scrollContainerView: UIView = Self.createScrollContainerView()

    private lazy var messageHeaderStackView: UIStackView = Self.createMessageHeaderStackView()

    private lazy var regularMessageHeaderView: UIView = Self.createRegularMessageHeaderView()
    private lazy var regularMessageTitleLabel: UILabel = Self.createRegularMessageTitleLabel()
    private lazy var regularMessageStackView: UIStackView = Self.createRegularMessageStackView()
    private lazy var regularMessageSubtitleLabel: UILabel = Self.createRegularMessageSubtitleLabel()
    private lazy var regularMessageImageView: UIImageView = Self.createRegularMessageImageView()

    private lazy var promoMessageHeaderView: UIView = Self.createPromoMessageHeaderView()
    private lazy var promoMessageTitleLabel: UILabel = Self.createPromoMessageTitleLabel()
    private lazy var promoMessageSubtitleLabel: UILabel = Self.createPromoMessageSubtitleLabel()
    private lazy var promoMessageImageView: UIImageView = Self.createPromoMessageImageView()
    private lazy var promoGradientLayer: CAGradientLayer = Self.createGradientLayer()
    private lazy var promoFlagView: UIView = Self.createPromoFlagView()
    private lazy var promoFlagTitle: UILabel = Self.createPromoFlagTitle()
    private lazy var messageDescriptionLabel: UILabel = Self.createMessageDescriptionLabel()

    private lazy var messageImageViewFixedHeightConstraint: NSLayoutConstraint = Self.createMessageImageViewFixedHeightConstraint()
    private lazy var messageImageViewDynamicHeightConstraint: NSLayoutConstraint = Self.createMessageImageViewDynamicHeightConstraint()

    private var aspectRatio: CGFloat = 1.0

    private var viewModel: MessageDetailViewModel

    static var normalDateFormatter: DateFormatter = {
        var dateFormatter = Date.buildFormatter(locale: Env.locale)
        return dateFormatter
    }()

    static var relativeDateFormatter: DateFormatter = {
        var dateFormatter = Date.buildFormatter(locale: Env.locale, hasRelativeDate: true)
        return dateFormatter
    }()

    var isRegularHeader: Bool = true {
        didSet {
            self.regularMessageHeaderView.isHidden = !isRegularHeader
            self.promoMessageHeaderView.isHidden = isRegularHeader
        }
    }

    var shouldSetMessageRead: ((Int) -> Void)?

    // MARK: Lifetime and Cycle
    init(viewModel: MessageDetailViewModel) {

        self.viewModel = viewModel

        super.init(nibName: nil, bundle: nil)
    }

    @available(iOS, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        print("MessageDetailViewController deinit called")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.setupSubviews()
        self.setupWithTheme()

        self.backButton.addTarget(self, action: #selector(didTapBackButton), for: .primaryActionTriggered)

        self.deleteButton.addTarget(self, action: #selector(didTapDeleteButton), for: .primaryActionTriggered)

        self.bind(toViewModel: self.viewModel)

        self.viewModel.markReadMessage()

        // TEMP
        self.deleteButton.isHidden = true

    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        self.regularMessageImageView.layer.masksToBounds = true

        self.promoGradientLayer.frame = self.promoMessageImageView.bounds
        self.promoMessageImageView.layer.insertSublayer(self.promoGradientLayer, at: 0)

        // Flag shape
        let path = UIBezierPath()
        path.move(to: CGPoint(x: 0, y: 0))
        path.addLine(to: CGPoint(x: self.promoFlagView.frame.size.width, y: 0))
        path.addLine(to: CGPoint(x: self.promoFlagView.frame.size.width - 5, y: self.promoFlagView.frame.size.height/2))
        path.addLine(to: CGPoint(x: self.promoFlagView.frame.size.width, y: self.promoFlagView.frame.size.height))
        path.addLine(to: CGPoint(x: 0, y: self.promoFlagView.frame.size.height))
        path.addLine(to: CGPoint(x: 0, y: 0))
        path.close()
        path.stroke()
        // path.reversing()
        let shapeLayer = CAShapeLayer()
        shapeLayer.frame = self.promoFlagView.bounds
        shapeLayer.path = path.cgPath
        shapeLayer.fillColor = UIColor.App.alertSuccess.cgColor
        self.promoFlagView.layer.mask = shapeLayer
        self.promoFlagView.layer.masksToBounds = true
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(true)
        
        self.shouldSetMessageRead?(self.viewModel.inAppMessage.id)
    }

    // MARK: Layout and Theme
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)

        self.setupWithTheme()
    }

    func setupWithTheme() {
        self.view.backgroundColor = UIColor.App.backgroundPrimary

        self.topView.backgroundColor = UIColor.App.backgroundPrimary

        self.backButton.tintColor = UIColor.App.textPrimary

        self.topTitleLabel.textColor = UIColor.App.textPrimary

        self.headerView.backgroundColor = UIColor.App.backgroundPrimary

        self.headerTitleLabel.textColor = UIColor.App.textSecondary

        self.deleteButton.backgroundColor = .clear

        self.deleteButton.setTitleColor(UIColor.App.highlightSecondary, for: UIControl.State.normal)

        self.headerSeparatorView.backgroundColor = UIColor.App.separatorLine

        self.scrollView.backgroundColor = .clear

        self.scrollContainerView.backgroundColor = .clear

        self.regularMessageTitleLabel.textColor = UIColor.App.textPrimary

        self.regularMessageSubtitleLabel.textColor = UIColor.App.textSecondary

        self.regularMessageStackView.backgroundColor = .clear

        self.promoMessageTitleLabel.textColor = UIColor.App.textPrimary

        self.promoMessageSubtitleLabel.textColor = UIColor.App.textSecondary

        self.promoFlagView.backgroundColor = UIColor.App.bubblesPrimary

        self.promoFlagTitle.textColor = UIColor.App.buttonTextPrimary

        self.messageDescriptionLabel.textColor = UIColor.App.textPrimary
    }

    // MARK: Functions
    private func setupRegularHeaderInfo() {

        self.headerTitleLabel.text = self.viewModel.inAppMessage.subtype.capitalized

        self.regularMessageTitleLabel.text = self.viewModel.inAppMessage.title

        let messageDateString = self.viewModel.inAppMessage.createdAtDateString

        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"

        if let messageDate = dateFormatter.date(from: messageDateString) {

            let relativeFormatter = MessageDetailViewController.relativeDateFormatter
            let relativeDateString = relativeFormatter.string(from: messageDate)

            let nonRelativeFormatter = MessageDetailViewController.normalDateFormatter
            let normalDateString = nonRelativeFormatter.string(from: messageDate)

            if relativeDateString == normalDateString {
                self.regularMessageSubtitleLabel.text = "\(normalDateString)"
            }
            else {
                self.regularMessageSubtitleLabel.text = "\(relativeDateString)"
            }
        }

        if let imageUrlString = viewModel.inAppMessage.imageUrl {

            let backgroundImageUrl = URL(string: imageUrlString)
            self.regularMessageImageView.kf.setImage(with: backgroundImageUrl)

            if let messageBannerImage = self.regularMessageImageView.image {
                self.resizeBannerImageView(messageBanner: messageBannerImage)
            }
        }
        else {
            self.regularMessageImageView.isHidden = true
        }

        self.messageDescriptionLabel.text = self.viewModel.inAppMessage.text
//        let htmlDescription = self.viewModel.inAppMessage.text
//        let data = Data(htmlDescription.utf8)
//        if let attributedString = try? NSMutableAttributedString(data: data, options: [.documentType: NSAttributedString.DocumentType.html], documentAttributes: nil) {
//
//            let attributes: [NSAttributedString.Key: AnyObject] = [NSAttributedString.Key.foregroundColor: UIColor.App.textPrimary,
//             NSAttributedString.Key.backgroundColor: UIColor.App.backgroundPrimary,
//                                                                   NSAttributedString.Key.font: AppFont.with(type: .medium, size: 14)]
//
//            attributedString.addAttributes(attributes,
//                                           range: NSRange.init(location: 0, length: attributedString.length ))
//
//            self.messageDescriptionLabel.attributedText = attributedString
//        }
    }

    private func setupPromoHeaderInfo() {

        self.headerTitleLabel.text = self.viewModel.inAppMessage.subtype.capitalized

        self.promoMessageTitleLabel.text = self.viewModel.inAppMessage.title

        let messageDateString = self.viewModel.inAppMessage.createdAtDateString

        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"

        if let messageDate = dateFormatter.date(from: messageDateString) {

            let relativeFormatter = MessageDetailViewController.relativeDateFormatter
            let relativeDateString = relativeFormatter.string(from: messageDate)

            let nonRelativeFormatter = MessageDetailViewController.normalDateFormatter
            let normalDateString = nonRelativeFormatter.string(from: messageDate)

            if relativeDateString == normalDateString {
                self.promoMessageSubtitleLabel.text = "\(normalDateString)"
            }
            else {
                self.promoMessageSubtitleLabel.text = "\(relativeDateString)"
            }
        }

        if let imageUrlString = viewModel.inAppMessage.imageUrl {

            let backgroundImageUrl = URL(string: imageUrlString)
            self.promoMessageImageView.kf.setImage(with: backgroundImageUrl)

        }

        self.messageDescriptionLabel.text = self.viewModel.inAppMessage.text
//        let htmlDescription = self.viewModel.inAppMessage.text
//        let data = Data(htmlDescription.utf8)
//        if let attributedString = try? NSMutableAttributedString(data: data, options: [.documentType: NSAttributedString.DocumentType.html], documentAttributes: nil) {
//
//            let attributes: [NSAttributedString.Key: AnyObject] = [NSAttributedString.Key.foregroundColor: UIColor.App.textPrimary,
//             NSAttributedString.Key.backgroundColor: UIColor.App.backgroundPrimary,
//                                                                   NSAttributedString.Key.font: AppFont.with(type: .medium, size: 14)]
//
//            attributedString.addAttributes(attributes,
//                                           range: NSRange.init(location: 0, length: attributedString.length ))
//
//            self.messageDescriptionLabel.attributedText = attributedString
//        }
    }

    private func resizeBannerImageView(messageBanner: UIImage) {

        self.aspectRatio = messageBanner.size.width/messageBanner.size.height

        self.messageImageViewFixedHeightConstraint.isActive = false

        self.messageImageViewDynamicHeightConstraint =
        NSLayoutConstraint(item: self.regularMessageImageView,
                           attribute: .height,
                           relatedBy: .equal,
                           toItem: self.regularMessageImageView,
                           attribute: .width,
                           multiplier: 1/self.aspectRatio,
                           constant: 0)

        self.messageImageViewDynamicHeightConstraint.isActive = true
    }

    // MARK: Binding
    private func bind(toViewModel viewModel: MessageDetailViewModel) {

        let messageType = viewModel.getMessageType()

        if messageType == .promo {
            self.setupPromoHeaderInfo()
            self.isRegularHeader = false
        }
        else {
            self.setupRegularHeaderInfo()
            self.isRegularHeader = true
        }

    }

    // MARK: Actions
    @objc private func didTapBackButton() {
        self.navigationController?.popViewController(animated: true)
    }

    @objc private func didTapDeleteButton() {
        // NOTE: Implement when backend has endpoint
    }
}

//
// MARK: Subviews initialization and setup
//
extension MessageDetailViewController {

    private static func createTopView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }

    private static func createBackButton() -> UIButton {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("", for: .normal)
        button.setImage(UIImage(named: "arrow_back_icon"), for: .normal)
        return button
    }

    private static func createTopTitleLabel() -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = localized("message")
        label.font = AppFont.with(type: .bold, size: 18)
        label.textAlignment = .center
        return label
    }

    private static func createHeaderView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }

    private static func createHeaderTitleLabel() -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Header Title"
        label.font = AppFont.with(type: .semibold, size: 12)
        label.textAlignment = .left
        return label
    }

    private static func createDeleteButton() -> UIButton {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle(localized("delete"), for: .normal)
        button.titleLabel?.font = AppFont.with(type: .semibold, size: 12)
        return button
    }

    private static func createHeaderSeparatorView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }

    private static func createScrollView() -> UIScrollView {
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        return scrollView
    }

    private static func createScrollContainerView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }

    private static func createMessageHeaderStackView() -> UIStackView {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.spacing = 0
        stackView.distribution = .fill
        return stackView
    }

    private static func createRegularMessageHeaderView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }

    private static func createRegularMessageTitleLabel() -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Message Title"
        label.font = AppFont.with(type: .bold, size: 18)
        label.textAlignment = .left
        label.numberOfLines = 0
        label.setLineSpacing(lineSpacing: 3)
        return label
    }

    private static func createRegularMessageSubtitleLabel() -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Message Subtitle"
        label.font = AppFont.with(type: .semibold, size: 11)
        label.textAlignment = .left
        return label
    }

    private static func createRegularMessageImageView() -> UIImageView {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFill
        return imageView
    }

    private static func createRegularMessageStackView() -> UIStackView {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.spacing = 25
        stackView.distribution = .equalSpacing
        return stackView
    }

    private static func createPromoMessageHeaderView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }

    private static func createPromoMessageTitleLabel() -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Message Title"
        label.font = AppFont.with(type: .bold, size: 18)
        label.textAlignment = .left
        label.numberOfLines = 0
        label.setLineSpacing(lineSpacing: 3)
        return label
    }

    private static func createPromoMessageSubtitleLabel() -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Message Subtitle"
        label.font = AppFont.with(type: .semibold, size: 11)
        label.textAlignment = .left
        return label
    }

    private static func createPromoMessageImageView() -> UIImageView {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFill
        imageView.layer.masksToBounds = true
        return imageView
    }

    private static func createPromoFlagView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }

    private static func createPromoFlagTitle() -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "BONUS"
        label.font = AppFont.with(type: .bold, size: 10)
        label.textAlignment = .left
        return label
    }

    private static func createGradientLayer() -> CAGradientLayer {
        let gradient = CAGradientLayer()
        let startColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.8).cgColor
        let endColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0).cgColor
        gradient.startPoint = CGPoint(x: 0.0, y: 1.0)
        gradient.endPoint = CGPoint(x: 0.0, y: 0.0)
        gradient.colors = [startColor, endColor]
        return gradient
    }

    private static func createMessageDescriptionLabel() -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Description"
        label.font = AppFont.with(type: .medium, size: 15)
        label.textAlignment = .left
        label.numberOfLines = 0
        return label
    }

    private static func createMessageImageViewFixedHeightConstraint() -> NSLayoutConstraint {
        let constraint = NSLayoutConstraint()
        return constraint
    }

    private static func createMessageImageViewDynamicHeightConstraint() -> NSLayoutConstraint {
        let constraint = NSLayoutConstraint()
        return constraint
    }

    private static func createMessageDescriptionTopConstraint() -> NSLayoutConstraint {
        let constraint = NSLayoutConstraint()
        return constraint
    }

    private func setupSubviews() {
        self.view.addSubview(self.topView)

        self.topView.addSubview(self.backButton)
        self.topView.addSubview(self.topTitleLabel)
        self.topView.bringSubviewToFront(self.topTitleLabel)

        self.view.addSubview(self.headerView)

        self.headerView.addSubview(self.headerTitleLabel)
        self.headerView.addSubview(self.deleteButton)
        self.headerView.addSubview(self.headerSeparatorView)

        self.view.addSubview(self.scrollView)

        self.scrollView.addSubview(self.scrollContainerView)

        self.scrollContainerView.addSubview(self.messageHeaderStackView)

        self.messageHeaderStackView.addArrangedSubview(self.regularMessageHeaderView)
        self.messageHeaderStackView.addArrangedSubview(self.promoMessageHeaderView)

        self.regularMessageHeaderView.addSubview(self.regularMessageTitleLabel)
        self.regularMessageHeaderView.addSubview(self.regularMessageStackView)

        self.regularMessageStackView.addArrangedSubview(self.regularMessageSubtitleLabel)
        self.regularMessageStackView.addArrangedSubview(self.regularMessageImageView)

        self.promoMessageHeaderView.addSubview(self.promoMessageImageView)

        self.promoMessageImageView.addSubview(self.promoMessageTitleLabel)
        self.promoMessageHeaderView.addSubview(self.promoMessageSubtitleLabel)
        self.promoMessageImageView.addSubview(self.promoFlagView)

        self.promoFlagView.addSubview(self.promoFlagTitle)

        self.scrollContainerView.addSubview(self.messageDescriptionLabel)

        self.initConstraints()
    }

    private func initConstraints() {

        // Top bar
        NSLayoutConstraint.activate([
            self.topView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            self.topView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            self.topView.topAnchor.constraint(equalTo: self.view.topAnchor),
            self.topView.heightAnchor.constraint(equalToConstant: 44),

            self.backButton.leadingAnchor.constraint(equalTo: self.topView.leadingAnchor, constant: 0),
            self.backButton.centerYAnchor.constraint(equalTo: self.topView.centerYAnchor),
            self.backButton.heightAnchor.constraint(equalToConstant: 44),
            self.backButton.widthAnchor.constraint(equalToConstant: 40),

            self.topTitleLabel.leadingAnchor.constraint(equalTo: self.topView.leadingAnchor, constant: 20),
            self.topTitleLabel.trailingAnchor.constraint(equalTo: self.topView.trailingAnchor, constant: -20),
            self.topTitleLabel.centerYAnchor.constraint(equalTo: self.topView.centerYAnchor)
        ])

        // Header view
        NSLayoutConstraint.activate([
            self.headerView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 25),
            self.headerView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -25),
            self.headerView.topAnchor.constraint(equalTo: self.topView.bottomAnchor, constant: 5),

            self.headerTitleLabel.leadingAnchor.constraint(equalTo: self.headerView.leadingAnchor, constant: 14),
            self.headerTitleLabel.topAnchor.constraint(equalTo: self.headerView.topAnchor, constant: 5),

            self.deleteButton.trailingAnchor.constraint(equalTo: self.headerView.trailingAnchor),
            self.deleteButton.heightAnchor.constraint(equalToConstant: 40),
            self.deleteButton.centerYAnchor.constraint(equalTo: self.headerTitleLabel.centerYAnchor),

            self.headerSeparatorView.leadingAnchor.constraint(equalTo: self.headerView.leadingAnchor),
            self.headerSeparatorView.trailingAnchor.constraint(equalTo: self.headerView.trailingAnchor),
            self.headerSeparatorView.topAnchor.constraint(equalTo: self.headerTitleLabel.bottomAnchor, constant: 8),
            self.headerSeparatorView.bottomAnchor.constraint(equalTo: self.headerView.bottomAnchor),
            self.headerSeparatorView.heightAnchor.constraint(equalToConstant: 1)
        ])

        // Scroll view
        NSLayoutConstraint.activate([
            self.scrollView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            self.scrollView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            self.scrollView.topAnchor.constraint(equalTo: self.headerView.bottomAnchor, constant: 15),
            self.scrollView.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor),

            self.scrollContainerView.leadingAnchor.constraint(equalTo: self.scrollView.contentLayoutGuide.leadingAnchor),
            self.scrollContainerView.trailingAnchor.constraint(equalTo: self.scrollView.contentLayoutGuide.trailingAnchor),
            self.scrollContainerView.topAnchor.constraint(equalTo: self.scrollView.contentLayoutGuide.topAnchor),
            self.scrollContainerView.bottomAnchor.constraint(equalTo: self.scrollView.contentLayoutGuide.bottomAnchor),
            self.scrollContainerView.widthAnchor.constraint(equalTo: self.scrollView.frameLayoutGuide.widthAnchor),

            self.messageHeaderStackView.leadingAnchor.constraint(equalTo: self.scrollContainerView.leadingAnchor, constant: 25),
            self.messageHeaderStackView.trailingAnchor.constraint(equalTo: self.scrollContainerView.trailingAnchor, constant: -25),
            self.messageHeaderStackView.topAnchor.constraint(equalTo: self.scrollContainerView.topAnchor)
        ])

        // Regular header view
        NSLayoutConstraint.activate([
            self.regularMessageHeaderView.leadingAnchor.constraint(equalTo: self.messageHeaderStackView.leadingAnchor, constant: 15),
            self.regularMessageHeaderView.trailingAnchor.constraint(equalTo: self.messageHeaderStackView.trailingAnchor, constant: -15),

            self.regularMessageTitleLabel.leadingAnchor.constraint(equalTo: self.regularMessageHeaderView.leadingAnchor),
            self.regularMessageTitleLabel.trailingAnchor.constraint(equalTo: self.regularMessageHeaderView.trailingAnchor),
            self.regularMessageTitleLabel.topAnchor.constraint(equalTo: self.regularMessageHeaderView.topAnchor, constant: 10),

            self.regularMessageStackView.leadingAnchor.constraint(equalTo: self.regularMessageHeaderView.leadingAnchor),
            self.regularMessageStackView.trailingAnchor.constraint(equalTo: self.regularMessageHeaderView.trailingAnchor),
            self.regularMessageStackView.topAnchor.constraint(equalTo: self.regularMessageTitleLabel.bottomAnchor, constant: 20),
            self.regularMessageStackView.bottomAnchor.constraint(equalTo: self.regularMessageHeaderView.bottomAnchor, constant: -10)
        ])

        // Promo header view
        NSLayoutConstraint.activate([
            self.promoMessageHeaderView.leadingAnchor.constraint(equalTo: self.messageHeaderStackView.leadingAnchor),
            self.promoMessageHeaderView.trailingAnchor.constraint(equalTo: self.messageHeaderStackView.trailingAnchor),

            self.promoMessageImageView.leadingAnchor.constraint(equalTo: self.promoMessageHeaderView.leadingAnchor),
            self.promoMessageImageView.trailingAnchor.constraint(equalTo: self.promoMessageHeaderView.trailingAnchor),
            self.promoMessageImageView.topAnchor.constraint(equalTo: self.promoMessageHeaderView.topAnchor),
            self.promoMessageImageView.bottomAnchor.constraint(equalTo: self.promoMessageHeaderView.bottomAnchor),
            self.promoMessageImageView.heightAnchor.constraint(equalToConstant: 279),

            self.promoMessageTitleLabel.leadingAnchor.constraint(equalTo: self.promoMessageImageView.leadingAnchor, constant: 15),
            self.promoMessageTitleLabel.trailingAnchor.constraint(equalTo: self.promoMessageImageView.trailingAnchor, constant: -15),
            self.promoMessageTitleLabel.bottomAnchor.constraint(equalTo: self.promoMessageSubtitleLabel.topAnchor, constant: -7),

            self.promoMessageSubtitleLabel.leadingAnchor.constraint(equalTo: self.promoMessageImageView.leadingAnchor, constant: 15),
            self.promoMessageSubtitleLabel.trailingAnchor.constraint(equalTo: self.promoMessageImageView.trailingAnchor, constant: -15),
            self.promoMessageSubtitleLabel.bottomAnchor.constraint(equalTo: self.promoMessageHeaderView.bottomAnchor, constant: -20),

            self.promoFlagView.leadingAnchor.constraint(equalTo: self.promoMessageImageView.leadingAnchor),
            self.promoFlagView.bottomAnchor.constraint(equalTo: self.promoMessageTitleLabel.topAnchor, constant: -15),
            self.promoFlagView.widthAnchor.constraint(equalToConstant: 73),
            self.promoFlagView.heightAnchor.constraint(equalToConstant: 25),

            self.promoFlagTitle.leadingAnchor.constraint(equalTo: self.promoFlagView.leadingAnchor, constant: 15),
            self.promoFlagTitle.centerYAnchor.constraint(equalTo: self.promoFlagView.centerYAnchor)

        ])

        NSLayoutConstraint.activate([
            self.messageDescriptionLabel.leadingAnchor.constraint(equalTo: self.scrollContainerView.leadingAnchor, constant: 40),
            self.messageDescriptionLabel.trailingAnchor.constraint(equalTo: self.scrollContainerView.trailingAnchor, constant: -40),
            self.messageDescriptionLabel.topAnchor.constraint(equalTo: self.messageHeaderStackView.bottomAnchor, constant: 30),
            self.messageDescriptionLabel.bottomAnchor.constraint(equalTo: self.scrollContainerView.bottomAnchor, constant: -20)
        ])

        self.messageImageViewFixedHeightConstraint =
        NSLayoutConstraint(item: self.regularMessageImageView,
                           attribute: .height,
                           relatedBy: .equal,
                           toItem: nil,
                           attribute: .notAnAttribute,
                           multiplier: 1,
                           constant: 150)
        self.messageImageViewFixedHeightConstraint.isActive = true

        self.messageImageViewDynamicHeightConstraint =
        NSLayoutConstraint(item: self.regularMessageImageView,
                           attribute: .height,
                           relatedBy: .equal,
                           toItem: self.regularMessageImageView,
                           attribute: .width,
                           multiplier: 1/self.aspectRatio,
                           constant: 0)
        self.messageImageViewDynamicHeightConstraint.isActive = false

    }

}
