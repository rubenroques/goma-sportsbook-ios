//
//  AdaptiveTabBarItemView.swift
//  Sportsbook
//
//  Created by Ruben Roques on 16/05/2025.
//

import UIKit
import SwiftUI

final public class AdaptiveTabBarItemView: UIView {
    // MARK: - UI Elements
    private lazy var iconImageView: UIImageView = Self.createIconImageView()
    private lazy var titleLabel: UILabel = Self.createTitleLabel()
    private lazy var containerStackView: UIStackView = Self.createContainerStackView()

    // MARK: - Properties
    public var onTap: (() -> Void)?
    private(set) var itemIdentifier: TabItemIdentifier? // To identify the item if needed by parent

    // MARK: - Initialization
    public override init(frame: CGRect) { // Made public override
        super.init(frame: frame)
        setupSubviews()
        setupGestures()
    }

    // Convenience initializer if created without a specific frame initially
    public convenience init() {
        self.init(frame: .zero)
    }

    @available(iOS, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Configuration
    public func configure(with displayData: TabItemDisplayData) {
        self.itemIdentifier = displayData.identifier
        
        let image = displayData.icon?.withRenderingMode(.alwaysTemplate)
        self.iconImageView.image = image
        
        self.titleLabel.text = displayData.title
        self.updateAppearance(isActive: displayData.isActive)
    }

    // MARK: - Private Methods
    private func setupSubviews() {
        self.translatesAutoresizingMaskIntoConstraints = false
        self.backgroundColor = UIColor.clear
        addSubview(self.containerStackView)
        
        self.containerStackView.addArrangedSubview(self.iconImageView)
        self.containerStackView.addArrangedSubview(self.titleLabel)
        
        initConstraints()
    }

    private func setupGestures() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        addGestureRecognizer(tapGesture)
        isUserInteractionEnabled = true
    }

    private func updateAppearance(isActive: Bool) {
        if isActive {
            self.titleLabel.textColor = StyleProvider.Color.highlightPrimary
            self.iconImageView.tintColor = StyleProvider.Color.highlightPrimary
            self.alpha = 1.0
        } else {
            self.titleLabel.textColor = StyleProvider.Color.iconSecondary
            self.iconImageView.tintColor = StyleProvider.Color.iconSecondary
            self.alpha = 1.0
        }
    }

    @objc private func handleTap() {
        onTap?()
    }
}

// MARK: - Factory Methods
private extension AdaptiveTabBarItemView {
    static func createContainerStackView() -> UIStackView {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.alignment = .center
        stackView.spacing = 2
        return stackView
    }

    static func createIconImageView() -> UIImageView {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        // Set a placeholder or default tint color if needed upon creation
        imageView.tintColor = StyleProvider.Color.highlightSecondary
        return imageView
    }

    static func createTitleLabel() -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = StyleProvider.fontWith(type: .semibold, size: 12.0)
        label.textAlignment = .center
        // Set a placeholder or default text color if needed upon creation
        label.textColor = StyleProvider.Color.highlightSecondary
        return label
    }
}

// MARK: - Constraints
private extension AdaptiveTabBarItemView {
    func initConstraints() {
        NSLayoutConstraint.activate([
            containerStackView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 5),
            containerStackView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -5),
            containerStackView.topAnchor.constraint(equalTo: topAnchor, constant: 5),
            containerStackView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -5),

            iconImageView.widthAnchor.constraint(equalToConstant: 30),
            iconImageView.heightAnchor.constraint(equalToConstant: 22),

            titleLabel.heightAnchor.constraint(equalToConstant: 19)
        ])
    }
}

// MockAdaptiveTabBarItem class (ViewModel for item) is no longer needed here.

#if DEBUG
import SwiftUI // Ensure SwiftUI is imported for Preview macros

@available(iOS 17.0, *)
#Preview("Adaptive Tab Bar Item States") {
    // Create TabItemDisplayData for active and inactive states
    let activeItemDisplayData = TabItemDisplayData(
        identifier: .sportsHome,
        title: "Active",
        icon: UIImage(systemName: "star.fill"),
        isActive: true,
        switchToTabBar: nil
    )

    let inactiveItemDisplayData = TabItemDisplayData(
        identifier: .casinoSlots,
        title: "Inactive",
        icon: UIImage(systemName: "circle"),
        isActive: false,
        switchToTabBar: nil
    )

    // VStack is the root for SwiftUI preview layout
    VStack(spacing: 20) {
        Text("Active Item View:")
        PreviewUIView { // Wrap the UIView for previewing
            let itemViewActive = AdaptiveTabBarItemView()
            itemViewActive.configure(with: activeItemDisplayData)
            return itemViewActive
        }
        .frame(width: 60, height: 52) // Adjusted width for better visual
        .border(Color.gray) // Added border for clarity

        Text("Inactive Item View:")
        PreviewUIView { // Wrap the UIView for previewing
            let itemViewInactive = AdaptiveTabBarItemView()
            itemViewInactive.configure(with: inactiveItemDisplayData)
            return itemViewInactive
        }
        .frame(width: 60, height: 52) // Adjusted width for better visual
        .border(Color.gray) // Added border for clarity
    }
    .padding() // Padding for the whole VStack container
}
#endif
