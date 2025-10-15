import UIKit
import Combine
import SwiftUI

/// Generic action row view for tappable menu items, buttons, and actions
public final class ActionRowView: UIView {

    // MARK: Private properties
    private lazy var containerView: UIView = Self.createContainerView()
    private lazy var iconContainerView: UIView = Self.createIconContainerView()
    private lazy var iconImageView: UIImageView = Self.createIconImageView()
    private lazy var titleLabel: UILabel = Self.createTitleLabel()
    private lazy var valueLabel: UILabel = Self.createValueLabel()
    private lazy var trailingIconImageView: UIImageView = Self.createTrailingIconImageView()
    private lazy var leftStackView: UIStackView = Self.createLeftStackView()
    private lazy var rightStackView: UIStackView = Self.createRightStackView()
    private lazy var mainStackView: UIStackView = Self.createMainStackView()

    // MARK: - Properties
    private var rowItem: ActionRowItem?
    private var onTapCallback: ((ActionRowItem) -> Void)?
    private var tapGesture: UITapGestureRecognizer?

    /// Custom background color for the action row (overrides default styling)
    public var customBackgroundColor: UIColor?

    // MARK: - Lifetime and Cycle
    public override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
        setupWithTheme()
    }

    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
        setupWithTheme()
    }

    func commonInit() {
        setupSubviews()
    }

    override public func layoutSubviews() {
        super.layoutSubviews()
        containerView.layer.cornerRadius = 8
    }

    func setupWithTheme() {
        backgroundColor = .clear
        containerView.backgroundColor = StyleProvider.Color.backgroundSecondary
        titleLabel.textColor = StyleProvider.Color.textPrimary
        valueLabel.textColor = StyleProvider.Color.textPrimary
        iconImageView.tintColor = StyleProvider.Color.highlightPrimary
        trailingIconImageView.tintColor = StyleProvider.Color.highlightPrimary
    }

    // MARK: Functions
    public func configure(with item: ActionRowItem, onTap: @escaping (ActionRowItem) -> Void) {
        self.rowItem = item
        self.onTapCallback = onTap

        titleLabel.text = item.title

        // Configure subtitle
        if let subtitle = item.subtitle, !subtitle.isEmpty {
            valueLabel.text = subtitle
            valueLabel.isHidden = false
        } else {
            valueLabel.text = nil
            valueLabel.isHidden = true
        }

        // Configure left icon (hide if empty string)
        if item.icon.isEmpty {
            iconContainerView.isHidden = true
        } else {
            iconContainerView.isHidden = false
            if let systemImage = UIImage(systemName: item.icon) {
                iconImageView.image = systemImage
            } else if let bundleImage = UIImage(named: item.icon) {
                iconImageView.image = bundleImage
            }
        }

        // Configure background color (use custom if set, else default)
        if let customBgColor = customBackgroundColor {
            containerView.backgroundColor = customBgColor
            // Adjust text/icon colors for better contrast on colored backgrounds
            titleLabel.textColor = StyleProvider.Color.buttonTextPrimary
            valueLabel.textColor = StyleProvider.Color.buttonTextPrimary
            iconImageView.tintColor = StyleProvider.Color.allWhite
            trailingIconImageView.tintColor = StyleProvider.Color.allWhite
        } else {
            containerView.backgroundColor = StyleProvider.Color.backgroundSecondary
            titleLabel.textColor = StyleProvider.Color.textPrimary
            valueLabel.textColor = StyleProvider.Color.textPrimary
            iconImageView.tintColor = StyleProvider.Color.highlightPrimary
            trailingIconImageView.tintColor = StyleProvider.Color.highlightPrimary
        }

        // Configure trailing icon
        if let customTrailingIcon = item.trailingIcon {
            // Use custom trailing icon
            if let systemImage = UIImage(systemName: customTrailingIcon) {
                trailingIconImageView.image = systemImage
            } else if let bundleImage = UIImage(named: customTrailingIcon) {
                trailingIconImageView.image = bundleImage
            }
            trailingIconImageView.isHidden = false
        } else {
            // Default behavior based on type
            switch item.type {
            case .navigation:
                trailingIconImageView.image = UIImage(systemName: "chevron.right")
                trailingIconImageView.isHidden = false
            case .action:
                trailingIconImageView.isHidden = true
            }
        }

        // Configure tap interaction
        setupTapGesture(isTappable: item.isTappable)
        isUserInteractionEnabled = item.isTappable
    }

    private func setupTapGesture(isTappable: Bool) {
        // Remove existing tap gesture if any
        if let existingGesture = tapGesture {
            containerView.removeGestureRecognizer(existingGesture)
            tapGesture = nil
        }

        // Add new tap gesture only if tappable
        if isTappable {
            let gesture = UITapGestureRecognizer(target: self, action: #selector(handleTap))
            containerView.addGestureRecognizer(gesture)
            tapGesture = gesture
        }
    }
}

// MARK: - Subviews Initialization and Setup
extension ActionRowView {

    private static func createContainerView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }

    private static func createIconContainerView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }

    private static func createIconImageView() -> UIImageView {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        return imageView
    }

    private static func createTitleLabel() -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = StyleProvider.fontWith(type: .bold, size: 12)
        label.numberOfLines = 1
        return label
    }

    private static func createValueLabel() -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = StyleProvider.fontWith(type: .regular, size: 12)
        label.numberOfLines = 1
        label.textAlignment = .right
        return label
    }

    private static func createTrailingIconImageView() -> UIImageView {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        imageView.image = UIImage(systemName: "chevron.right")
        return imageView
    }

    private static func createLeftStackView() -> UIStackView {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .horizontal
        stackView.alignment = .center
        stackView.spacing = 4
        return stackView
    }

    private static func createRightStackView() -> UIStackView {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .horizontal
        stackView.alignment = .center
        stackView.spacing = 4
        return stackView
    }

    private static func createMainStackView() -> UIStackView {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .horizontal
        stackView.alignment = .center
        stackView.distribution = .fill
        return stackView
    }

    private func setupSubviews() {
        addSubview(containerView)
        containerView.addSubview(mainStackView)

        // Setup icon container
        iconContainerView.addSubview(iconImageView)

        // Setup left stack (icon + title)
        leftStackView.addArrangedSubview(iconContainerView)
        leftStackView.addArrangedSubview(titleLabel)

        // Setup right stack (value + trailing icon)
        rightStackView.addArrangedSubview(valueLabel)
        rightStackView.addArrangedSubview(trailingIconImageView)

        // Setup main stack
        mainStackView.addArrangedSubview(leftStackView)
        mainStackView.addArrangedSubview(rightStackView)

        // Set content priorities
        titleLabel.setContentHuggingPriority(.defaultLow, for: .horizontal)
        valueLabel.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        titleLabel.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        valueLabel.setContentCompressionResistancePriority(.defaultHigh, for: .horizontal)

        initConstraints()
    }

    private func initConstraints() {
        NSLayoutConstraint.activate([
            // Container
            containerView.leadingAnchor.constraint(equalTo: leadingAnchor),
            containerView.trailingAnchor.constraint(equalTo: trailingAnchor),
            containerView.topAnchor.constraint(equalTo: topAnchor),
            containerView.bottomAnchor.constraint(equalTo: bottomAnchor),
            containerView.heightAnchor.constraint(equalToConstant: 48),

            // Main stack
            mainStackView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 12),
            mainStackView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -12),
            mainStackView.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 9),
            mainStackView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -9),

            // Icon container
            iconContainerView.widthAnchor.constraint(equalToConstant: 22),
            iconContainerView.heightAnchor.constraint(equalToConstant: 22),

            // Icon image
            iconImageView.centerXAnchor.constraint(equalTo: iconContainerView.centerXAnchor),
            iconImageView.centerYAnchor.constraint(equalTo: iconContainerView.centerYAnchor),
            iconImageView.widthAnchor.constraint(lessThanOrEqualToConstant: 18),
            iconImageView.heightAnchor.constraint(lessThanOrEqualToConstant: 18),

            // Trailing icon
            trailingIconImageView.widthAnchor.constraint(equalToConstant: 18),
            trailingIconImageView.heightAnchor.constraint(equalToConstant: 18)
        ])
    }

    @objc private func handleTap() {
        guard let rowItem = rowItem, rowItem.isTappable else { return }

        // Add tap feedback
        UIView.animate(withDuration: 0.1, animations: {
            self.containerView.transform = CGAffineTransform(scaleX: 0.95, y: 0.95)
        }) { _ in
            UIView.animate(withDuration: 0.1) {
                self.containerView.transform = CGAffineTransform.identity
            }
        }

        onTapCallback?(rowItem)
    }
}

// MARK: - SwiftUI Preview
#if DEBUG

@available(iOS 17.0, *)
#Preview("Navigation Item") {
    PreviewUIViewController {
        let vc = UIViewController()
        let item = ActionRowItem(
            icon: "bell",
            title: "Notifications",
            type: .navigation,
            action: .notifications
        )
        let actionRow = ActionRowView()
        actionRow.configure(with: item) { item in
            print("Tapped: \(item.title)")
        }
        actionRow.translatesAutoresizingMaskIntoConstraints = false

        vc.view.backgroundColor = StyleProvider.Color.backgroundPrimary
        vc.view.addSubview(actionRow)

        NSLayoutConstraint.activate([
            actionRow.leadingAnchor.constraint(equalTo: vc.view.leadingAnchor, constant: 16),
            actionRow.trailingAnchor.constraint(equalTo: vc.view.trailingAnchor, constant: -16),
            actionRow.centerYAnchor.constraint(equalTo: vc.view.centerYAnchor)
        ])

        return vc
    }
}

@available(iOS 17.0, *)
#Preview("Custom Background (Green)") {
    PreviewUIViewController {
        let vc = UIViewController()
        let item = ActionRowItem(
            icon: "checkmark.circle.fill",
            title: "Bet Placed",
            type: .action,
            action: .custom,
            isTappable: false
        )
        let actionRow = ActionRowView()
        actionRow.customBackgroundColor = StyleProvider.Color.alertSuccess
        actionRow.configure(with: item) { item in
            print("Tapped: \(item.title)")
        }
        actionRow.translatesAutoresizingMaskIntoConstraints = false

        vc.view.backgroundColor = StyleProvider.Color.backgroundPrimary
        vc.view.addSubview(actionRow)

        NSLayoutConstraint.activate([
            actionRow.leadingAnchor.constraint(equalTo: vc.view.leadingAnchor, constant: 16),
            actionRow.trailingAnchor.constraint(equalTo: vc.view.trailingAnchor, constant: -16),
            actionRow.centerYAnchor.constraint(equalTo: vc.view.centerYAnchor)
        ])

        return vc
    }
}

@available(iOS 17.0, *)
#Preview("Custom Trailing Icon (Share)") {
    PreviewUIViewController {
        let vc = UIViewController()
        let item = ActionRowItem(
            icon: "",
            title: "Share your Betslip",
            type: .action,
            action: .custom,
            trailingIcon: "square.and.arrow.up"
        )
        let actionRow = ActionRowView()
        actionRow.configure(with: item) { item in
            print("Tapped: \(item.title)")
        }
        actionRow.translatesAutoresizingMaskIntoConstraints = false

        vc.view.backgroundColor = StyleProvider.Color.backgroundPrimary
        vc.view.addSubview(actionRow)

        NSLayoutConstraint.activate([
            actionRow.leadingAnchor.constraint(equalTo: vc.view.leadingAnchor, constant: 16),
            actionRow.trailingAnchor.constraint(equalTo: vc.view.trailingAnchor, constant: -16),
            actionRow.centerYAnchor.constraint(equalTo: vc.view.centerYAnchor)
        ])

        return vc
    }
}

@available(iOS 17.0, *)
#Preview("All States") {
    PreviewUIViewController {
        let vc = UIViewController()
        vc.view.backgroundColor = StyleProvider.Color.backgroundPrimary

        // Green "Bet Placed" - non-tappable
        let betPlaced = ActionRowItem(
            icon: "checkmark.circle.fill",
            title: "Bet Placed",
            type: .action,
            action: .custom,
            isTappable: false
        )
        let betPlacedRow = ActionRowView()
        betPlacedRow.customBackgroundColor = StyleProvider.Color.alertSuccess
        betPlacedRow.configure(with: betPlaced) { _ in }
        betPlacedRow.translatesAutoresizingMaskIntoConstraints = false

        // "Open Details" - chevron
        let openDetails = ActionRowItem(
            icon: "",
            title: "Open Betslip Details",
            type: .navigation,
            action: .custom,
            trailingIcon: "chevron.right"
        )
        let openDetailsRow = ActionRowView()
        openDetailsRow.configure(with: openDetails) { item in
            print("Tapped: \(item.title)")
        }
        openDetailsRow.translatesAutoresizingMaskIntoConstraints = false

        // "Share" - share icon
        let share = ActionRowItem(
            icon: "",
            title: "Share your Betslip",
            type: .action,
            action: .custom,
            trailingIcon: "square.and.arrow.up"
        )
        let shareRow = ActionRowView()
        shareRow.configure(with: share) { item in
            print("Tapped: \(item.title)")
        }
        shareRow.translatesAutoresizingMaskIntoConstraints = false

        vc.view.addSubview(betPlacedRow)
        vc.view.addSubview(openDetailsRow)
        vc.view.addSubview(shareRow)

        NSLayoutConstraint.activate([
            // Bet Placed
            betPlacedRow.leadingAnchor.constraint(equalTo: vc.view.leadingAnchor, constant: 16),
            betPlacedRow.trailingAnchor.constraint(equalTo: vc.view.trailingAnchor, constant: -16),
            betPlacedRow.topAnchor.constraint(equalTo: vc.view.safeAreaLayoutGuide.topAnchor, constant: 20),

            // Open Details
            openDetailsRow.leadingAnchor.constraint(equalTo: vc.view.leadingAnchor, constant: 16),
            openDetailsRow.trailingAnchor.constraint(equalTo: vc.view.trailingAnchor, constant: -16),
            openDetailsRow.topAnchor.constraint(equalTo: betPlacedRow.bottomAnchor, constant: 12),

            // Share
            shareRow.leadingAnchor.constraint(equalTo: vc.view.leadingAnchor, constant: 16),
            shareRow.trailingAnchor.constraint(equalTo: vc.view.trailingAnchor, constant: -16),
            shareRow.topAnchor.constraint(equalTo: openDetailsRow.bottomAnchor, constant: 12)
        ])

        return vc
    }
}

#endif
