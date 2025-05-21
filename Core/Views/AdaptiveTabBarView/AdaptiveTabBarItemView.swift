//
//  AdaptiveTabBarItemView.swift
//  Sportsbook
//
//  Created by Ruben Roques on 16/05/2025.
//

import UIKit
import SwiftUI
import Combine

final class AdaptiveTabBarItemView: UIView {
    // MARK: - Models
    struct Configuration {
        let icon: UIImage
        let title: String
        let isActive: Bool
    }
    
    // MARK: - Private Properties
    private lazy var iconImageView: UIImageView = Self.createIconImageView()
    private lazy var titleLabel: UILabel = Self.createTitleLabel()
    private lazy var containerStackView: UIStackView = Self.createContainerStackView()
    
    // MARK: - Properties
    var onTap: (() -> Void)?
    
    private var isActive: Bool = false {
        didSet { updateAppearance() }
    }
    
    // MARK: - Initialization
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupSubviews()
        setupGestures()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Configuration
    func configure(with config: Configuration) {
        iconImageView.image = config.icon
        titleLabel.text = config.title
        isActive = config.isActive
    }
    
    // MARK: - Private Methods
    private func setupSubviews() {
        addSubview(containerStackView)
        
        containerStackView.addArrangedSubview(iconImageView)
        containerStackView.addArrangedSubview(titleLabel)
        
        initConstraints()
    }
    
    private func setupGestures() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        addGestureRecognizer(tapGesture)
        isUserInteractionEnabled = true
    }
    
    private func updateAppearance() {
        let color: UIColor = isActive ? UIColor.App.highlightPrimary : UIColor.App.iconSecondary
        iconImageView.setImageColor(color: color)
        titleLabel.textColor = color
        alpha = isActive ? 1.0 : 0.52
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
        return imageView
    }
    
    static func createTitleLabel() -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = AppFont.with(type: .bold, size: 10)
        label.textAlignment = .center
        return label
    }
}

// MARK: - Constraints
private extension AdaptiveTabBarItemView {
    func initConstraints() {
        NSLayoutConstraint.activate([
            containerStackView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 4),
            containerStackView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -4),
            containerStackView.topAnchor.constraint(equalTo: topAnchor),
            containerStackView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -2),
            
            iconImageView.widthAnchor.constraint(equalToConstant: 20),
            iconImageView.heightAnchor.constraint(equalToConstant: 20),
            
            titleLabel.heightAnchor.constraint(equalToConstant: 19)
        ])
    }
}

#if DEBUG
@available(iOS 17.0, *)
#Preview("Default") {
    PreviewUIView {
        AdaptiveTabBarItemView(frame: .zero)
    }
    .frame(width: 52, height: 52)
    .padding()
}
#endif
