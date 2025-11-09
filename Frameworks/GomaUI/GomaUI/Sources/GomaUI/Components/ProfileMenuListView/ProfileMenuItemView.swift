import UIKit
import Combine
import SwiftUI


/// Individual menu item view for profile menu
public final class ProfileMenuItemView: UIView {
    
    // MARK: Private properties
    private lazy var containerView: UIView = Self.createContainerView()
    private lazy var iconContainerView: UIView = Self.createIconContainerView()
    private lazy var iconImageView: UIImageView = Self.createIconImageView()
    private lazy var titleLabel: UILabel = Self.createTitleLabel()
    private lazy var valueLabel: UILabel = Self.createValueLabel()
    private lazy var chevronImageView: UIImageView = Self.createChevronImageView()
    private lazy var leftStackView: UIStackView = Self.createLeftStackView()
    private lazy var rightStackView: UIStackView = Self.createRightStackView()
    private lazy var mainStackView: UIStackView = Self.createMainStackView()
    
    // MARK: - Properties
    private var menuItem: ProfileMenuItem?
    private var onTapCallback: ((ProfileMenuItem) -> Void)?
    
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
        setupActions()
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
        chevronImageView.tintColor = StyleProvider.Color.highlightPrimary
    }
    
    // MARK: Functions
    public func configure(with item: ProfileMenuItem, onTap: @escaping (ProfileMenuItem) -> Void) {
        self.menuItem = item
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
        
        // Configure icon
        if let systemImage = UIImage(systemName: item.icon) {
            iconImageView.image = systemImage
        } else if let bundleImage = UIImage(named: item.icon) {
            iconImageView.image = bundleImage
        }
        
        // Configure based on item type
        switch item.type {
        case .navigation:
            chevronImageView.isHidden = false
            
        case .action:
            chevronImageView.isHidden = true
        }
        
        // Update interaction state
        isUserInteractionEnabled = true
    }
}

// MARK: - Subviews Initialization and Setup
extension ProfileMenuItemView {
    
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
    
    private static func createChevronImageView() -> UIImageView {
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
        
        // Setup right stack (value + chevron)
        rightStackView.addArrangedSubview(valueLabel)
        rightStackView.addArrangedSubview(chevronImageView)
        
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
            
            // Chevron
            chevronImageView.widthAnchor.constraint(equalToConstant: 18),
            chevronImageView.heightAnchor.constraint(equalToConstant: 18)
        ])
    }
    
    private func setupActions() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        containerView.addGestureRecognizer(tapGesture)
    }
    
    @objc private func handleTap() {
        guard let menuItem = menuItem else { return }
        
        // Add tap feedback
        UIView.animate(withDuration: 0.1, animations: {
            self.containerView.transform = CGAffineTransform(scaleX: 0.95, y: 0.95)
        }) { _ in
            UIView.animate(withDuration: 0.1) {
                self.containerView.transform = CGAffineTransform.identity
            }
        }
        
        onTapCallback?(menuItem)
    }
}

// MARK: - Data Models
public enum ProfileMenuItemType: String, Codable, Equatable {
    case navigation
    case action
}

public enum ProfileMenuAction: String, Codable {
    case notifications
    case transactionHistory
    case changeLanguage
    case responsibleGaming
    case helpCenter
    case changePassword
    case logout
    case promotions
}

public struct ProfileMenuItem: Codable, Identifiable {
    public let id: String
    public let icon: String
    public let title: String
    public let subtitle: String?
    public let type: ProfileMenuItemType
    public let action: ProfileMenuAction
    
    public init(id: String, icon: String, title: String, subtitle: String? = nil, type: ProfileMenuItemType, action: ProfileMenuAction) {
        self.id = id
        self.icon = icon
        self.title = title
        self.subtitle = subtitle
        self.type = type
        self.action = action
    }
}

// MARK: - SwiftUI Preview
#if DEBUG

@available(iOS 17.0, *)
#Preview("Navigation Item") {
    PreviewUIViewController {
        let vc = UIViewController()
        let item = ProfileMenuItem(
            id: "notifications",
            icon: "bell",
            title: LocalizationProvider.string("notifications"),
            type: .navigation,
            action: .notifications
        )
        let menuItemView = ProfileMenuItemView()
        menuItemView.configure(with: item) { item in
            print("Tapped: \(item.title)")
        }
        menuItemView.translatesAutoresizingMaskIntoConstraints = false
        
        vc.view.backgroundColor = StyleProvider.Color.backgroundPrimary
        vc.view.addSubview(menuItemView)
        
        NSLayoutConstraint.activate([
            menuItemView.leadingAnchor.constraint(equalTo: vc.view.leadingAnchor, constant: 16),
            menuItemView.trailingAnchor.constraint(equalTo: vc.view.trailingAnchor, constant: -16),
            menuItemView.centerYAnchor.constraint(equalTo: vc.view.centerYAnchor)
        ])
        
        return vc
    }
}

@available(iOS 17.0, *)
#Preview("Selection Item") {
    PreviewUIViewController {
        let vc = UIViewController()
        let item = ProfileMenuItem(
            id: "language",
            icon: "globe",
            title: LocalizationProvider.string("change_language"),
            type: .navigation,
            action: .changeLanguage
        )
        let menuItemView = ProfileMenuItemView()
        menuItemView.configure(with: item) { item in
            print("Tapped: \(item.title)")
        }
        menuItemView.translatesAutoresizingMaskIntoConstraints = false
        
        vc.view.backgroundColor = StyleProvider.Color.backgroundPrimary
        vc.view.addSubview(menuItemView)
        
        NSLayoutConstraint.activate([
            menuItemView.leadingAnchor.constraint(equalTo: vc.view.leadingAnchor, constant: 16),
            menuItemView.trailingAnchor.constraint(equalTo: vc.view.trailingAnchor, constant: -16),
            menuItemView.centerYAnchor.constraint(equalTo: vc.view.centerYAnchor)
        ])
        
        return vc
    }
}

@available(iOS 17.0, *)
#Preview("Action Item") {
    PreviewUIViewController {
        let vc = UIViewController()
        let item = ProfileMenuItem(
            id: "logout",
            icon: "rectangle.portrait.and.arrow.right",
            title: LocalizationProvider.string("logout"),
            type: .action,
            action: .logout
        )
        let menuItemView = ProfileMenuItemView()
        menuItemView.configure(with: item) { item in
            print("Tapped: \(item.title)")
        }
        menuItemView.translatesAutoresizingMaskIntoConstraints = false
        
        vc.view.backgroundColor = StyleProvider.Color.backgroundPrimary
        vc.view.addSubview(menuItemView)
        
        NSLayoutConstraint.activate([
            menuItemView.leadingAnchor.constraint(equalTo: vc.view.leadingAnchor, constant: 16),
            menuItemView.trailingAnchor.constraint(equalTo: vc.view.trailingAnchor, constant: -16),
            menuItemView.centerYAnchor.constraint(equalTo: vc.view.centerYAnchor)
        ])
        
        return vc
    }
}

#endif
