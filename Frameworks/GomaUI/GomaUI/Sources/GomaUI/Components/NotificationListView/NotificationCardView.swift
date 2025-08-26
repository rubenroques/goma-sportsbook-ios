import Foundation
import UIKit
import Combine
import SwiftUI

/// Internal notification card view used by NotificationListView
final class NotificationCardView: UIView {
    
    // MARK: - Private Properties
    private lazy var backgroundContainerView: UIView = Self.createBackgroundContainerView()
    private lazy var containerView: UIView = Self.createContainerView()
    private lazy var mainStackView: UIStackView = Self.createMainStackView()
    private lazy var headerContainerView: UIView = Self.createHeaderContainerView()
    private lazy var timestampLabel: UILabel = Self.createTimestampLabel()
    private lazy var unreadIndicatorView: UIView = Self.createUnreadIndicatorView()
    private lazy var titleLabel: UILabel = Self.createTitleLabel()
    private lazy var descriptionLabel: UILabel = Self.createDescriptionLabel()
    private lazy var actionButton: UIButton = Self.createActionButton()
    
    private var cancellables = Set<AnyCancellable>()
    private var currentNotification: NotificationData?
    private var currentPosition: CardPosition = .middle
    
    // MARK: - Public Properties
    public var onActionTapped: ((NotificationData) -> Void)?
    
    // MARK: - Initialization
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }
    
    // MARK: - Setup
    private func setupView() {
        setupSubviews()
        setupActions()
        applyStyles()
    }
    
    private func setupSubviews() {
        addSubview(backgroundContainerView)
        backgroundContainerView.addSubview(containerView)
        containerView.addSubview(mainStackView)
        
        // Setup header container
        headerContainerView.addSubview(timestampLabel)
        headerContainerView.addSubview(unreadIndicatorView)
        
        // Add arranged subviews to stack
        mainStackView.addArrangedSubview(headerContainerView)
        mainStackView.addArrangedSubview(titleLabel)
        mainStackView.addArrangedSubview(descriptionLabel)
        mainStackView.addArrangedSubview(actionButton)
        
        // Configure custom spacing
        mainStackView.setCustomSpacing(3, after: headerContainerView)
        mainStackView.setCustomSpacing(3, after: titleLabel)
        mainStackView.setCustomSpacing(12, after: descriptionLabel)
        
        setupConstraints()
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            // Background Container View
            backgroundContainerView.leadingAnchor.constraint(equalTo: leadingAnchor),
            backgroundContainerView.trailingAnchor.constraint(equalTo: trailingAnchor),
            backgroundContainerView.topAnchor.constraint(equalTo: topAnchor),
            backgroundContainerView.bottomAnchor.constraint(equalTo: bottomAnchor),
            
            // Container View (with padding inside background)
            containerView.leadingAnchor.constraint(equalTo: backgroundContainerView.leadingAnchor, constant: 8),
            containerView.trailingAnchor.constraint(equalTo: backgroundContainerView.trailingAnchor, constant: -8),
            containerView.topAnchor.constraint(equalTo: backgroundContainerView.topAnchor, constant: 8),
            containerView.bottomAnchor.constraint(equalTo: backgroundContainerView.bottomAnchor, constant: -8),
            
            // Main Stack View
            mainStackView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
            mainStackView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -16),
            mainStackView.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 16),
            mainStackView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -16),
            
            // Header Container (fixed height)
            headerContainerView.heightAnchor.constraint(equalToConstant: 16),
            
            // Header subviews
            timestampLabel.leadingAnchor.constraint(equalTo: headerContainerView.leadingAnchor),
            timestampLabel.centerYAnchor.constraint(equalTo: headerContainerView.centerYAnchor),
            
            unreadIndicatorView.trailingAnchor.constraint(equalTo: headerContainerView.trailingAnchor),
            unreadIndicatorView.centerYAnchor.constraint(equalTo: headerContainerView.centerYAnchor),
            unreadIndicatorView.widthAnchor.constraint(equalToConstant: 8),
            unreadIndicatorView.heightAnchor.constraint(equalToConstant: 8),
            
            // Action Button (fixed height when visible)
            actionButton.heightAnchor.constraint(equalToConstant: 33)
        ])
    }
    
    private func setupActions() {
        actionButton.addTarget(self, action: #selector(actionButtonTapped), for: .touchUpInside)
    }
    
    private func applyStyles() {
        backgroundColor = .clear
        
        // Apply StyleProvider colors
        backgroundContainerView.backgroundColor = StyleProvider.Color.backgroundPrimary // Dark gray background
        containerView.backgroundColor = StyleProvider.Color.backgroundSecondary // White/light background
        timestampLabel.textColor = StyleProvider.Color.textPrimary
        titleLabel.textColor = StyleProvider.Color.textPrimary
        descriptionLabel.textColor = StyleProvider.Color.textPrimary
        unreadIndicatorView.backgroundColor = StyleProvider.Color.highlightPrimary
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        applyCornerRadius(for: currentPosition)
        
        // Container view always has all 4 corners rounded (like before)
        containerView.layer.cornerRadius = 8
        
        unreadIndicatorView.layer.cornerRadius = 4
        actionButton.layer.cornerRadius = 4
    }
    
    // MARK: - Actions
    @objc private func actionButtonTapped() {
        guard let notification = currentNotification else { return }
        onActionTapped?(notification)
    }
    
    // MARK: - Configuration
    public func configure(with notification: NotificationData, position: CardPosition, onActionTapped: @escaping (NotificationData) -> Void) {
        self.currentNotification = notification
        self.currentPosition = position
        self.onActionTapped = onActionTapped
        
        updateContent(notification)
        updateVisualState(notification)
        applyCornerRadius(for: position)
    }
    
    private func applyCornerRadius(for position: CardPosition) {
        let cornerRadius: CGFloat = 16
        
        // Apply position-based corners to backgroundContainerView
        switch position {
        case .single:
            // All corners rounded
            backgroundContainerView.layer.cornerRadius = cornerRadius
            backgroundContainerView.layer.maskedCorners = [
                .layerMinXMinYCorner, .layerMaxXMinYCorner,
                .layerMinXMaxYCorner, .layerMaxXMaxYCorner
            ]
        case .first:
            // Only top corners rounded
            backgroundContainerView.layer.cornerRadius = cornerRadius
            backgroundContainerView.layer.maskedCorners = [
                .layerMinXMinYCorner, .layerMaxXMinYCorner
            ]
        case .middle:
            // No corners rounded
            backgroundContainerView.layer.cornerRadius = 0
            backgroundContainerView.layer.maskedCorners = []
        case .last:
            // Only bottom corners rounded
            backgroundContainerView.layer.cornerRadius = cornerRadius
            backgroundContainerView.layer.maskedCorners = [
                .layerMinXMaxYCorner, .layerMaxXMaxYCorner
            ]
        }
        
        // Ensure backgroundContainerView clips to bounds for corner radius
        backgroundContainerView.layer.masksToBounds = true
    }
    
    private func updateContent(_ notification: NotificationData) {
        timestampLabel.text = formatTimestamp(notification.timestamp)
        titleLabel.text = notification.title
        descriptionLabel.text = notification.description
        
        // Configure action button - stack view automatically adjusts layout
        if let action = notification.action {
            actionButton.isHidden = false
            actionButton.setTitle(action.title, for: .normal)
            updateButtonStyle(action.style)
        } else {
            actionButton.isHidden = true
        }
    }
    
    private func updateVisualState(_ notification: NotificationData) {
        switch notification.state {
        case .unread:
            containerView.layer.borderWidth = 1
            containerView.layer.borderColor = StyleProvider.Color.highlightPrimary.cgColor
            unreadIndicatorView.isHidden = false
        case .read:
            containerView.layer.borderWidth = 1
            containerView.layer.borderColor = StyleProvider.Color.separatorLine.cgColor
            unreadIndicatorView.isHidden = true
        }
    }
    
    private func updateButtonStyle(_ style: NotificationActionStyle) {
        switch style {
        case .primary:
            actionButton.backgroundColor = StyleProvider.Color.buttonBackgroundPrimary
            actionButton.setTitleColor(StyleProvider.Color.backgroundSecondary, for: .normal)
        case .secondary:
            actionButton.backgroundColor = StyleProvider.Color.highlightPrimary
            actionButton.setTitleColor(StyleProvider.Color.buttonTextPrimary, for: .normal)
        }
    }
    
    private func formatTimestamp(_ date: Date) -> String {
        let now = Date()
        let calendar = Calendar.current
        
        if calendar.isDateInToday(date) {
            let formatter = DateFormatter()
            formatter.timeStyle = .short
            return "Today, \(formatter.string(from: date))"
        } else if calendar.isDateInYesterday(date) {
            let formatter = DateFormatter()
            formatter.timeStyle = .short
            return "Yesterday, \(formatter.string(from: date))"
        } else {
            let formatter = DateFormatter()
            formatter.dateStyle = .short
            formatter.timeStyle = .short
            return formatter.string(from: date)
        }
    }
}

// MARK: - Static Factory Methods
extension NotificationCardView {
    
    private static func createBackgroundContainerView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.masksToBounds = true
        return view
    }
    
    private static func createContainerView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.masksToBounds = true
        return view
    }
    
    private static func createMainStackView() -> UIStackView {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.distribution = .fill
        stackView.alignment = .fill
        stackView.spacing = 0 // We use custom spacing
        return stackView
    }
    
    private static func createHeaderContainerView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }
    
    private static func createTimestampLabel() -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = StyleProvider.fontWith(type: .regular, size: 12)
        label.numberOfLines = 1
        return label
    }
    
    private static func createUnreadIndicatorView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.masksToBounds = true
        return view
    }
    
    private static func createTitleLabel() -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = StyleProvider.fontWith(type: .bold, size: 14)
        label.numberOfLines = 0
        return label
    }
    
    private static func createDescriptionLabel() -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = StyleProvider.fontWith(type: .regular, size: 12)
        label.numberOfLines = 0
        return label
    }
    
    private static func createActionButton() -> UIButton {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.titleLabel?.font = StyleProvider.fontWith(type: .bold, size: 12)
        button.layer.masksToBounds = true
        return button
    }
}

// MARK: - SwiftUI Preview Support
@available(iOS 17.0, *)
#Preview("Unread Notification") {
    PreviewUIViewController {
        let vc = UIViewController()
        let notification = NotificationData(
            id: "preview_1",
            timestamp: Calendar.current.date(byAdding: .hour, value: -2, to: Date()) ?? Date(),
            title: "Complete Onboarding",
            description: "You're almost there, Firstname. Complete your personal and account information, and start betting!",
            state: .unread
        )
        
        let cardView = NotificationCardView()
        cardView.configure(with: notification, position: .single) { _ in
            print("Action tapped!")
        }
        
        cardView.translatesAutoresizingMaskIntoConstraints = false
        vc.view.addSubview(cardView)
        
        NSLayoutConstraint.activate([
            cardView.leadingAnchor.constraint(equalTo: vc.view.leadingAnchor, constant: 16),
            cardView.trailingAnchor.constraint(equalTo: vc.view.trailingAnchor, constant: -16),
            cardView.topAnchor.constraint(equalTo: vc.view.safeAreaLayoutGuide.topAnchor, constant: 20),
            cardView.heightAnchor.constraint(greaterThanOrEqualToConstant: 100)
        ])
        
        vc.view.backgroundColor = .white
        return vc
    }
}

@available(iOS 17.0, *)
#Preview("Unread with Action Button") {
    PreviewUIViewController {
        let vc = UIViewController()
        let notification = NotificationData(
            id: "preview_2",
            timestamp: Calendar.current.date(byAdding: .minute, value: -30, to: Date()) ?? Date(),
            title: "Welcome Bonus Available",
            description: "Claim your €50 welcome bonus now! This offer is valid for the next 24 hours only.",
            state: .unread,
            action: NotificationAction(id: "claim", title: "Claim Bonus", style: .secondary)
        )
        
        let cardView = NotificationCardView()
        cardView.configure(with: notification, position: .first) { _ in
            print("Claim bonus tapped!")
        }
        
        cardView.translatesAutoresizingMaskIntoConstraints = false
        vc.view.addSubview(cardView)
        
        NSLayoutConstraint.activate([
            cardView.leadingAnchor.constraint(equalTo: vc.view.leadingAnchor, constant: 16),
            cardView.trailingAnchor.constraint(equalTo: vc.view.trailingAnchor, constant: -16),
            cardView.topAnchor.constraint(equalTo: vc.view.safeAreaLayoutGuide.topAnchor, constant: 20),
            cardView.heightAnchor.constraint(greaterThanOrEqualToConstant: 120)
        ])
        
        vc.view.backgroundColor = .white
        return vc
    }
}

@available(iOS 17.0, *)
#Preview("Read Notification") {
    PreviewUIViewController {
        let vc = UIViewController()
        let notification = NotificationData(
            id: "preview_3",
            timestamp: Calendar.current.date(byAdding: .day, value: -1, to: Date()) ?? Date(),
            title: "Account Verification Complete",
            description: "Your account has been successfully verified. You can now enjoy all features of our platform.",
            state: .read
        )
        
        let cardView = NotificationCardView()
        cardView.configure(with: notification, position: .middle) { _ in
            print("Action tapped!")
        }
        
        cardView.translatesAutoresizingMaskIntoConstraints = false
        vc.view.addSubview(cardView)
        
        NSLayoutConstraint.activate([
            cardView.leadingAnchor.constraint(equalTo: vc.view.leadingAnchor, constant: 16),
            cardView.trailingAnchor.constraint(equalTo: vc.view.trailingAnchor, constant: -16),
            cardView.topAnchor.constraint(equalTo: vc.view.safeAreaLayoutGuide.topAnchor, constant: 20),
            cardView.heightAnchor.constraint(greaterThanOrEqualToConstant: 100)
        ])
        
        vc.view.backgroundColor = .white
        return vc
    }
}

@available(iOS 17.0, *)
#Preview("Read with Primary Action") {
    PreviewUIViewController {
        let vc = UIViewController()
        let notification = NotificationData(
            id: "preview_4",
            timestamp: Calendar.current.date(byAdding: .day, value: -2, to: Date()) ?? Date(),
            title: "Payment Confirmation Required",
            description: "Please confirm your payment method to complete your recent deposit transaction.",
            state: .read,
            action: NotificationAction(id: "confirm", title: "Confirm Payment", style: .primary)
        )
        
        let cardView = NotificationCardView()
        cardView.configure(with: notification, position: .last) { _ in
            print("Confirm payment tapped!")
        }
        
        cardView.translatesAutoresizingMaskIntoConstraints = false
        vc.view.addSubview(cardView)
        
        NSLayoutConstraint.activate([
            cardView.leadingAnchor.constraint(equalTo: vc.view.leadingAnchor, constant: 16),
            cardView.trailingAnchor.constraint(equalTo: vc.view.trailingAnchor, constant: -16),
            cardView.topAnchor.constraint(equalTo: vc.view.safeAreaLayoutGuide.topAnchor, constant: 20),
            cardView.heightAnchor.constraint(greaterThanOrEqualToConstant: 120)
        ])
        
        vc.view.backgroundColor = .white
        return vc
    }
}

@available(iOS 17.0, *)
#Preview("Long Content") {
    PreviewUIViewController {
        let vc = UIViewController()
        let notification = NotificationData(
            id: "preview_5",
            timestamp: Calendar.current.date(byAdding: .hour, value: -4, to: Date()) ?? Date(),
            title: "Special Promotion: Double Your Winnings This Weekend",
            description: "Don't miss out on our exclusive weekend promotion! Double your winnings on all football matches this Saturday and Sunday. This offer is valid for both single bets and accumulators. Terms and conditions apply. Minimum bet amount is €10. Maximum bonus is €500 per customer.",
            state: .unread,
            action: NotificationAction(id: "learn_more", title: "Learn More", style: .secondary)
        )
        
        let cardView = NotificationCardView()
        cardView.configure(with: notification, position: .single) { _ in
            print("Learn more tapped!")
        }
        
        cardView.translatesAutoresizingMaskIntoConstraints = false
        vc.view.addSubview(cardView)
        
        NSLayoutConstraint.activate([
            cardView.leadingAnchor.constraint(equalTo: vc.view.leadingAnchor, constant: 16),
            cardView.trailingAnchor.constraint(equalTo: vc.view.trailingAnchor, constant: -16),
            cardView.topAnchor.constraint(equalTo: vc.view.safeAreaLayoutGuide.topAnchor, constant: 20),
            cardView.heightAnchor.constraint(greaterThanOrEqualToConstant: 150)
        ])
        
        vc.view.backgroundColor = .white
        return vc
    }
}

@available(iOS 17.0, *)
#Preview("Today Timestamp") {
    PreviewUIViewController {
        let vc = UIViewController()
        let notification = NotificationData(
            id: "preview_6",
            timestamp: Calendar.current.date(byAdding: .minute, value: -15, to: Date()) ?? Date(),
            title: "Bet Placed Successfully",
            description: "Your bet on Manchester United vs Liverpool has been placed successfully. Good luck!",
            state: .unread
        )
        
        let cardView = NotificationCardView()
        cardView.configure(with: notification, position: .first) { _ in
            print("Action tapped!")
        }
        
        cardView.translatesAutoresizingMaskIntoConstraints = false
        vc.view.addSubview(cardView)
        
        NSLayoutConstraint.activate([
            cardView.leadingAnchor.constraint(equalTo: vc.view.leadingAnchor, constant: 16),
            cardView.trailingAnchor.constraint(equalTo: vc.view.trailingAnchor, constant: -16),
            cardView.topAnchor.constraint(equalTo: vc.view.safeAreaLayoutGuide.topAnchor, constant: 20),
            cardView.heightAnchor.constraint(greaterThanOrEqualToConstant: 100)
        ])
        
        vc.view.backgroundColor = .white
        return vc
    }
}

@available(iOS 17.0, *)
#Preview("All States Side by Side") {
    PreviewUIViewController {
        let vc = UIViewController()
        let scrollView = UIScrollView()
        let stackView = UIStackView()
        
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.spacing = 16
        stackView.alignment = .fill
        stackView.layoutMargins = UIEdgeInsets(top: 20, left: 16, bottom: 20, right: 16)
        stackView.isLayoutMarginsRelativeArrangement = true
        
        // Different notification states
        let notifications = [
            NotificationData(id: "1", timestamp: Date(), title: "Unread", description: "This is an unread notification", state: .unread),
            NotificationData(id: "2", timestamp: Calendar.current.date(byAdding: .hour, value: -1, to: Date()) ?? Date(), title: "Unread with Action", description: "This notification has an action button", state: .unread, action: NotificationAction(id: "action", title: "Do Something", style: .primary)),
            NotificationData(id: "3", timestamp: Calendar.current.date(byAdding: .day, value: -1, to: Date()) ?? Date(), title: "Read", description: "This is a read notification", state: .read),
            NotificationData(id: "4", timestamp: Calendar.current.date(byAdding: .day, value: -2, to: Date()) ?? Date(), title: "Read with Secondary Action", description: "This has a secondary style action", state: .read, action: NotificationAction(id: "secondary", title: "Learn More", style: .secondary))
        ]
        
        for (index, notification) in notifications.enumerated() {
            let cardView = NotificationCardView()
            let position: CardPosition = {
                if notifications.count == 1 {
                    return .single
                } else if index == 0 {
                    return .first
                } else if index == notifications.count - 1 {
                    return .last
                } else {
                    return .middle
                }
            }()
            cardView.configure(with: notification, position: position) { notification in
                print("Action tapped for: \(notification.title)")
            }
            stackView.addArrangedSubview(cardView)
        }
        
        vc.view.addSubview(scrollView)
        scrollView.addSubview(stackView)
        
        NSLayoutConstraint.activate([
            scrollView.leadingAnchor.constraint(equalTo: vc.view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: vc.view.trailingAnchor),
            scrollView.topAnchor.constraint(equalTo: vc.view.safeAreaLayoutGuide.topAnchor),
            scrollView.bottomAnchor.constraint(equalTo: vc.view.safeAreaLayoutGuide.bottomAnchor),
            
            stackView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            stackView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            stackView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            stackView.widthAnchor.constraint(equalTo: scrollView.widthAnchor)
        ])
        
        vc.view.backgroundColor = .white
        return vc
    }
}
