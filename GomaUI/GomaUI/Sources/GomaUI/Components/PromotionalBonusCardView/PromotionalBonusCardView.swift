//
//  PromotionalBonusCardView.swift
//  GomaUI
//
//  Created by André Lascas on 09/06/2025.
//

import Foundation
import UIKit
import Combine
import SwiftUI

final public class PromotionalBonusCardView: UIView {
    // MARK: - Private Properties
    private let containerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.cornerRadius = 16
        view.clipsToBounds = true
        return view
    }()
    
    private let backgroundImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()
    
    private let gradientView: GradientView = {
        let view = GradientView.customGradient(colors: [
            (StyleProvider.Color.topBarGradient1, 0.33),
            (StyleProvider.Color.topBarGradient2, 0.66),
            (StyleProvider.Color.topBarGradient3, 1.0),
        ], gradientDirection: .invertedDiagonal)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.clipsToBounds = true
        view.alpha = 0.7
        return view
    }()
    
    private let headerLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = StyleProvider.fontWith(type: .regular, size: 12)
        label.textColor = StyleProvider.Color.buttonTextPrimary
        label.numberOfLines = 0
        return label
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = StyleProvider.fontWith(type: .bold, size: 20)
        label.textColor = StyleProvider.Color.buttonTextPrimary
        label.numberOfLines = 0
        return label
    }()
    
    private let avatarsStackView: UIStackView = {
        let stack = UIStackView()
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .horizontal
        stack.spacing = -8 // Overlapping avatars
        stack.alignment = .center
        return stack
    }()
    
    private let playersLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = StyleProvider.fontWith(type: .regular, size: 12)
        label.textColor = StyleProvider.Color.buttonTextPrimary
        label.numberOfLines = 0
        return label
    }()
    
    private let avatarsAndCountStackView: UIStackView = {
        let stack = UIStackView()
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .horizontal
        stack.spacing = 12
        stack.alignment = .center
        return stack
    }()
    
    private let buttonsStackView: UIStackView = {
        let stack = UIStackView()
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .vertical
        stack.spacing = 6
        stack.alignment = .fill
        return stack
    }()
    
    private var claimButton: ButtonView = {
        let claimButtonData = ButtonData(
            id: "claim_bonus",
            title: "Claim bonus",
            style: .solidBackground,
            isEnabled: true
        )
        
        let claimButtonViewModel = MockButtonViewModel(buttonData: claimButtonData)
        
        let button = ButtonView(viewModel: claimButtonViewModel)
        button.translatesAutoresizingMaskIntoConstraints = false
        
        return button
    }()
    
    private var termsButton: ButtonView = {
        let termsButtonData = ButtonData(
            id: "terms_conditions",
            title: "Terms and Conditions",
            style: .transparent,
            isEnabled: true
        )
        
        let termsButtonViewModel = MockButtonViewModel(buttonData: termsButtonData)
        
        let button = ButtonView(viewModel: termsButtonViewModel)
        button.translatesAutoresizingMaskIntoConstraints = false
        
        return button
    }()
    
    private var cancellables = Set<AnyCancellable>()
    private let viewModel: PromotionalBonusCardViewModelProtocol
    
    // MARK: - Public Properties
    public var onClaimBonus: (() -> Void) = { }
    public var onTermsTapped: (() -> Void) = { }
    
    // MARK: - Initialization
    public init(viewModel: PromotionalBonusCardViewModelProtocol) {
        self.viewModel = viewModel
        super.init(frame: .zero)
        setupSubviews()
        setupBindings()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Setup
    private func setupSubviews() {
        backgroundColor = .clear
        
        addSubview(containerView)
        containerView.addSubview(backgroundImageView)
        containerView.addSubview(gradientView)
        
        // Setup buttons
        setupButtons()
        
        // Setup avatar and count container
//        avatarsAndCountStackView.addArrangedSubview(avatarsStackView)
        avatarsAndCountStackView.addArrangedSubview(playersLabel)
        
        // Setup main content stack
        containerView.addSubview(headerLabel)
        containerView.addSubview(titleLabel)
        containerView.addSubview(avatarsAndCountStackView)
        
        containerView.addSubview(buttonsStackView)
        
        NSLayoutConstraint.activate([
            containerView.topAnchor.constraint(equalTo: topAnchor),
            containerView.leadingAnchor.constraint(equalTo: leadingAnchor),
            containerView.trailingAnchor.constraint(equalTo: trailingAnchor),
            containerView.bottomAnchor.constraint(equalTo: bottomAnchor),
            containerView.heightAnchor.constraint(equalToConstant: 415),
            
            backgroundImageView.topAnchor.constraint(equalTo: containerView.topAnchor),
            backgroundImageView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            backgroundImageView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            backgroundImageView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor),
            
            gradientView.topAnchor.constraint(equalTo: containerView.topAnchor),
            gradientView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            gradientView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            gradientView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor),
            
            headerLabel.leadingAnchor.constraint(equalTo: self.containerView.leadingAnchor, constant: 16),
            headerLabel.trailingAnchor.constraint(equalTo: self.containerView.trailingAnchor, constant: -16),
            headerLabel.topAnchor.constraint(equalTo: self.containerView.topAnchor, constant: 24),
            
            titleLabel.leadingAnchor.constraint(equalTo: self.containerView.leadingAnchor, constant: 16),
            titleLabel.trailingAnchor.constraint(equalTo: self.containerView.trailingAnchor, constant: -16),
            titleLabel.topAnchor.constraint(equalTo: self.headerLabel.bottomAnchor, constant: 20),
            
            self.avatarsAndCountStackView.leadingAnchor.constraint(equalTo: self.containerView.leadingAnchor, constant: 16),
            self.avatarsAndCountStackView.trailingAnchor.constraint(equalTo: self.containerView.trailingAnchor, constant: -16),
            self.avatarsAndCountStackView.topAnchor.constraint(equalTo: self.titleLabel.bottomAnchor, constant: 20),
            
            self.buttonsStackView.leadingAnchor.constraint(equalTo: self.containerView.leadingAnchor, constant: 16),
            self.buttonsStackView.trailingAnchor.constraint(equalTo: self.containerView.trailingAnchor, constant: -16),
            self.buttonsStackView.bottomAnchor.constraint(equalTo: self.containerView.bottomAnchor, constant: -20)
        ])
        
    }
    
    private func setupButtons() {
        
        // Add button actions
        claimButton.onButtonTapped = { [weak self] in
            self?.viewModel.claimBonusTapped()
            self?.onClaimBonus()
        }
        
        termsButton.onButtonTapped = { [weak self] in
            self?.viewModel.termsTapped()
            self?.onTermsTapped()
        }
        
        // Add buttons to stack
        buttonsStackView.addArrangedSubview(claimButton)
        buttonsStackView.addArrangedSubview(termsButton)
    }
    
    override public func layoutSubviews() {
        super.layoutSubviews()
        if let gradientLayer = containerView.layer.sublayers?.first as? CAGradientLayer {
            gradientLayer.frame = containerView.bounds
        }
    }
    
    private func setupBindings() {
        viewModel.cardDataPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] cardData in
                self?.configure(cardData: cardData)
            }
            .store(in: &cancellables)
    }
    
    // MARK: - Configuration
    private func configure(cardData: PromotionalBonusCardData) {
        // Update text content
        headerLabel.text = cardData.headerText
        titleLabel.text = cardData.mainTitle
        playersLabel.text = "\(cardData.playersCount) players chose this bonus"
        
        // Update background image
        if let backgroundImageName = cardData.backgroundImageName {
            backgroundImageView.image = UIImage(named: backgroundImageName)
        }
        
        // Update button titles
        updateButtonTitles(claimTitle: cardData.claimButtonTitle, termsTitle: cardData.termsButtonTitle)
        
        // Setup user avatars
        setupUserAvatars(cardData.userAvatars)
    }
    
    private func updateButtonTitles(claimTitle: String, termsTitle: String) {
        // Update claim button
        let claimButtonData = ButtonData(
            id: "claim_bonus",
            title: claimTitle,
            style: .solidBackground,
            isEnabled: true
        )
        if let claimViewModel = claimButton.viewModel as? MockButtonViewModel {
            // Would need to add method to update title in real implementation
        }
        
        // Update terms button
        let termsButtonData = ButtonData(
            id: "terms_conditions",
            title: termsTitle,
            style: .transparent,
            isEnabled: true
        )
        if let termsViewModel = termsButton.viewModel as? MockButtonViewModel {
            // Would need to add method to update title in real implementation
        }
    }
    
    private func setupUserAvatars(_ avatars: [UserAvatar]) {
        // Clear existing avatars
        avatarsStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        
        // Add new avatars (limit to 4 for UI purposes)
        let displayAvatars = Array(avatars.prefix(4))
        
        for avatar in displayAvatars {
            let avatarView = createAvatarView(for: avatar)
            avatarsStackView.addArrangedSubview(avatarView)
        }
    }
    
    private func createAvatarView(for avatar: UserAvatar) -> UIView {
        let containerView = UIView()
        containerView.translatesAutoresizingMaskIntoConstraints = false
        containerView.layer.cornerRadius = 20
        containerView.layer.borderWidth = 2
        containerView.layer.borderColor = UIColor.white.cgColor
        containerView.clipsToBounds = true
        
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFill
        imageView.backgroundColor = StyleProvider.Color.backgroundSecondary
        
        // Set placeholder or actual image
        if let imageName = avatar.imageName {
            imageView.image = UIImage(named: imageName)
        } else {
            // Use system person icon as placeholder
            let personImage = UIImage(systemName: "person.circle.fill")
            imageView.image = personImage
            imageView.tintColor = StyleProvider.Color.textSecondary
        }
        
        containerView.addSubview(imageView)
        
        NSLayoutConstraint.activate([
            containerView.widthAnchor.constraint(equalToConstant: 40),
            containerView.heightAnchor.constraint(equalToConstant: 40),
            
            imageView.topAnchor.constraint(equalTo: containerView.topAnchor),
            imageView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            imageView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor)
        ])
        
        return containerView
    }
}

// MARK: - Preview Provider
#if DEBUG

@available(iOS 17.0, *)
#Preview("Promotional Bonus Card") {
    PreviewUIView {
        PromotionalBonusCardView(viewModel: MockPromotionalBonusCardViewModel.defaultMock)
    }
    .frame(height: 415)
    .padding()
}

#endif
