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

#if DEBUG

@available(iOS 17.0, *)
#Preview("All States") {
    PreviewUIViewController {
        let vc = UIViewController()
        vc.view.backgroundColor = StyleProvider.Color.backgroundPrimary

        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.spacing = 8
        stackView.alignment = .fill
        stackView.distribution = .fillEqually
        stackView.translatesAutoresizingMaskIntoConstraints = false

        // Active with icon - star.fill
        let activeWithIconData = TabItemDisplayData(
            identifier: .sportsHome,
            title: "Sports",
            icon: UIImage(systemName: "star.fill"),
            isActive: true,
            switchToTabBar: nil
        )
        let activeWithIconView = AdaptiveTabBarItemView()
        activeWithIconView.configure(with: activeWithIconData)
        activeWithIconView.translatesAutoresizingMaskIntoConstraints = false

        // Inactive with icon - circle
        let inactiveWithIconData = TabItemDisplayData(
            identifier: .casinoSlots,
            title: "Casino",
            icon: UIImage(systemName: "circle"),
            isActive: false,
            switchToTabBar: nil
        )
        let inactiveWithIconView = AdaptiveTabBarItemView()
        inactiveWithIconView.configure(with: inactiveWithIconData)
        inactiveWithIconView.translatesAutoresizingMaskIntoConstraints = false

        inactiveWithIconView.layer.borderWidth = 1
        inactiveWithIconView.layer.borderColor = UIColor.red.cgColor
        
        // Active text-only
        let activeTextOnlyData = TabItemDisplayData(
            identifier: .myBets,
            title: "My Bets",
            icon: nil,
            isActive: true,
            switchToTabBar: nil
        )
        let activeTextOnlyView = AdaptiveTabBarItemView()
        activeTextOnlyView.configure(with: activeTextOnlyData)
        activeTextOnlyView.translatesAutoresizingMaskIntoConstraints = false

        // Inactive text-only
        let inactiveTextOnlyData = TabItemDisplayData(
            identifier: .profile,
            title: "Profile",
            icon: nil,
            isActive: false,
            switchToTabBar: nil
        )
        let inactiveTextOnlyView = AdaptiveTabBarItemView()
        inactiveTextOnlyView.configure(with: inactiveTextOnlyData)
        inactiveTextOnlyView.translatesAutoresizingMaskIntoConstraints = false

        // Long text case - test truncation
        let longTextData = TabItemDisplayData(
            identifier: .promotions,
            title: "Promotions",
            icon: UIImage(systemName: "gift.fill"),
            isActive: false,
            switchToTabBar: nil
        )
        let longTextView = AdaptiveTabBarItemView()
        longTextView.configure(with: longTextData)
        longTextView.translatesAutoresizingMaskIntoConstraints = false

        stackView.addArrangedSubview(activeWithIconView)
        stackView.addArrangedSubview(inactiveWithIconView)
        stackView.addArrangedSubview(activeTextOnlyView)
        stackView.addArrangedSubview(inactiveTextOnlyView)
        stackView.addArrangedSubview(longTextView)

        stackView.layer.borderWidth = 1
        stackView.layer.borderColor = UIColor.gray.cgColor
        
        vc.view.addSubview(stackView)

        NSLayoutConstraint.activate([
            stackView.centerXAnchor.constraint(equalTo: vc.view.centerXAnchor),
            stackView.centerYAnchor.constraint(equalTo: vc.view.centerYAnchor),
            stackView.leadingAnchor.constraint(equalTo: vc.view.leadingAnchor, constant: 16),
            stackView.trailingAnchor.constraint(equalTo: vc.view.trailingAnchor, constant: -16),
            stackView.heightAnchor.constraint(equalToConstant: 52)
        ])

        return vc
    }
}

#endif
