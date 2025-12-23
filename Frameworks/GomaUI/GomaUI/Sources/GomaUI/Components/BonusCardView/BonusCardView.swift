//
//  BonusCardView.swift
//  GomaUI
//
//  Created by Claude on 23/10/2025.
//

import UIKit
import Combine
import Kingfisher
import SwiftUI

public class BonusCardView: UIView {
    
    // MARK: - Private Properties
    private lazy var containerView: UIView = Self.createContainerView()
    private lazy var imageView: UIImageView = Self.createImageView()
    private lazy var tagView: UIView = Self.createTagView()
    private lazy var tagLabel: UILabel = Self.createTagLabel()
    private lazy var titleLabel: UILabel = Self.createTitleLabel()
    private lazy var descriptionLabel: UILabel = Self.createDescriptionLabel()
    private lazy var ctaButton: ButtonView = self.createCTAButton()
    private lazy var termsButton: ButtonView = self.createTermsButton()
    
    private let viewModel: BonusCardViewModelProtocol
    private var cancellables = Set<AnyCancellable>()
    
    // Constraint references for dynamic updates
    private var titleLabelTopConstraint: NSLayoutConstraint?
    private var termsButtonTopConstraint: NSLayoutConstraint?
    
    // MARK: - Lifetime and Cycle
    public init(viewModel: BonusCardViewModelProtocol) {
        self.viewModel = viewModel
        super.init(frame: .zero)
        self.commonInit()
        self.setupWithTheme()
    }
    
    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func commonInit() {
        self.setupSubviews()
        self.bind(toViewModel: self.viewModel)
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        self.containerView.layer.cornerRadius = 8
        self.containerView.layer.borderWidth = 1
        self.tagView.layer.cornerRadius = 4
        self.tagView.layer.maskedCorners = [
            .layerMaxXMinYCorner, .layerMaxXMaxYCorner
        ]
    }
    
    func setupWithTheme() {
        self.backgroundColor = .clear
        self.containerView.backgroundColor = StyleProvider.Color.backgroundCards
        self.containerView.layer.borderColor = StyleProvider.Color.backgroundBorder.cgColor
        self.imageView.backgroundColor = StyleProvider.Color.backgroundSecondary
        self.tagView.backgroundColor = StyleProvider.Color.highlightPrimary
        self.tagLabel.textColor = StyleProvider.Color.allWhite
        self.titleLabel.textColor = StyleProvider.Color.textPrimary
        self.descriptionLabel.textColor = StyleProvider.Color.textPrimary
    }
    
    // MARK: - Binding
    private func bind(toViewModel viewModel: BonusCardViewModelProtocol) {
        viewModel.displayStatePublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] displayState in
                self?.configure(with: displayState)
            }
            .store(in: &cancellables)
    }
    
    // MARK: - Functions
    private func configure(with displayState: BonusCardDisplayState) {
        // Check if imageURL exists and is not empty
        let hasImageURL = !displayState.imageURL.isEmpty && URL(string: displayState.imageURL) != nil
        
        // Configure image
        if hasImageURL, let imageURL = URL(string: displayState.imageURL) {
            self.imageView.kf.setImage(with: imageURL)
            self.imageView.isHidden = false
        } else {
            self.imageView.isHidden = true
        }
        
        // Configure tag
        self.tagLabel.text = displayState.tag
        self.tagView.isHidden = displayState.tag == nil
        
        // Update constraints based on imageURL presence
        self.updateConstraints(hasImageURL: hasImageURL)
        
        // Configure content
        self.titleLabel.text = displayState.title
        self.descriptionLabel.text = displayState.description
        
        // CTA button is always visible (not hidden)
        self.ctaButton.isHidden = false
        
        // Configure terms button visibility based on termsURL
        let hasTermsURL = displayState.hasTermsURL
        self.termsButton.isHidden = !hasTermsURL
        self.updateTermsButtonConstraint(hasTermsButton: hasTermsURL)
    }
    
    private func updateConstraints(hasImageURL: Bool) {
        // Update titleLabel top constraint
        if let titleLabelTopConstraint = self.titleLabelTopConstraint {
            titleLabelTopConstraint.isActive = false
        }
        
        if hasImageURL {
            // Title label below imageView
            self.titleLabelTopConstraint = self.titleLabel.topAnchor.constraint(equalTo: self.imageView.bottomAnchor, constant: 16)
        } else {
            // Title label below tagLabel (or containerView top if no tag)
            if let tag = self.tagLabel.text, !tag.isEmpty, !self.tagView.isHidden {
                self.titleLabelTopConstraint = self.titleLabel.topAnchor.constraint(equalTo: self.tagLabel.bottomAnchor, constant: 16)
            } else {
                self.titleLabelTopConstraint = self.titleLabel.topAnchor.constraint(equalTo: self.containerView.topAnchor, constant: 16)
            }
        }
        self.titleLabelTopConstraint?.isActive = true
    }
    
    private func updateTermsButtonConstraint(hasTermsButton: Bool) {
        // Update terms button top constraint based on terms button visibility
        // CTA button is always visible, so terms button is always positioned below CTA button when visible
        if let termsButtonTopConstraint = self.termsButtonTopConstraint {
            termsButtonTopConstraint.isActive = false
        }
        
        if hasTermsButton {
            // Terms button is visible - position it below CTA button (which is always visible)
            self.termsButtonTopConstraint = self.termsButton.topAnchor.constraint(equalTo: self.ctaButton.bottomAnchor, constant: 8)
        } else {
            // Terms button is hidden - set constraint to description label (will be hidden anyway)
            self.termsButtonTopConstraint = self.termsButton.topAnchor.constraint(equalTo: self.descriptionLabel.bottomAnchor, constant: 16)
        }
        self.termsButtonTopConstraint?.isActive = true
    }
}

// MARK: - Subviews Initialization and Setup
extension BonusCardView {
    
    private static func createContainerView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.masksToBounds = true
        return view
    }
    
    private static func createImageView() -> UIImageView {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        return imageView
    }
    
    private static func createTagView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.masksToBounds = true
        return view
    }
    
    private static func createTagLabel() -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = StyleProvider.fontWith(type: .semibold, size: 12)
        label.textAlignment = .center
        label.numberOfLines = 1
        return label
    }
    
    private static func createTitleLabel() -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = StyleProvider.fontWith(type: .bold, size: 16)
        label.numberOfLines = 0
        return label
    }
    
    private static func createDescriptionLabel() -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = StyleProvider.fontWith(type: .regular, size: 14)
        label.numberOfLines = 0
        return label
    }
    
    private func createCTAButton() -> ButtonView {
        let button = ButtonView(viewModel: self.viewModel.ctaButtonViewModel)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }
    
    private func createTermsButton() -> ButtonView {
        let button = ButtonView(viewModel: self.viewModel.termsButtonViewModel)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }
    
    private func setupSubviews() {
        self.addSubview(self.containerView)
        
        self.containerView.addSubview(self.imageView)
        self.containerView.addSubview(self.tagView)
        self.tagView.addSubview(self.tagLabel)
        
        self.containerView.addSubview(self.titleLabel)
        self.containerView.addSubview(self.descriptionLabel)
        self.containerView.addSubview(self.ctaButton)
        self.containerView.addSubview(self.termsButton)
        
        self.setupGestures()
        self.initConstraints()
    }
    
    private func setupGestures() {
        // Card tap gesture
        let cardTapGesture = UITapGestureRecognizer(target: self, action: #selector(handleCardTap))
        self.containerView.addGestureRecognizer(cardTapGesture)
        self.containerView.isUserInteractionEnabled = true
    }
    
    @objc private func handleCardTap() {
        self.viewModel.didTapCard()
    }
    
    private func initConstraints() {
        NSLayoutConstraint.activate([
            // Container
            self.containerView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            self.containerView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            self.containerView.topAnchor.constraint(equalTo: self.topAnchor),
            self.containerView.bottomAnchor.constraint(equalTo: self.bottomAnchor),
            
            // Image
            self.imageView.leadingAnchor.constraint(equalTo: self.containerView.leadingAnchor),
            self.imageView.trailingAnchor.constraint(equalTo: self.containerView.trailingAnchor),
            self.imageView.topAnchor.constraint(equalTo: self.containerView.topAnchor),
            self.imageView.heightAnchor.constraint(equalToConstant: 131),
            
            // Tag view - positioned relative to containerView with same positioning
            self.tagView.leadingAnchor.constraint(equalTo: self.containerView.leadingAnchor),
            self.tagView.topAnchor.constraint(equalTo: self.containerView.topAnchor, constant: 15),
            self.tagView.heightAnchor.constraint(equalToConstant: 20),
            
            // Tag label
            self.tagLabel.leadingAnchor.constraint(equalTo: self.tagView.leadingAnchor, constant: 8),
            self.tagLabel.trailingAnchor.constraint(equalTo: self.tagView.trailingAnchor, constant: -8),
            self.tagLabel.topAnchor.constraint(equalTo: self.tagView.topAnchor),
            self.tagLabel.bottomAnchor.constraint(equalTo: self.tagView.bottomAnchor),
            
            // Title label - constraint will be set dynamically in updateConstraints
            self.titleLabel.leadingAnchor.constraint(equalTo: self.containerView.leadingAnchor, constant: 24),
            self.titleLabel.trailingAnchor.constraint(equalTo: self.containerView.trailingAnchor, constant: -24),
            
            // Description label
            self.descriptionLabel.leadingAnchor.constraint(equalTo: self.containerView.leadingAnchor, constant: 24),
            self.descriptionLabel.trailingAnchor.constraint(equalTo: self.containerView.trailingAnchor, constant: -24),
            self.descriptionLabel.topAnchor.constraint(equalTo: self.titleLabel.bottomAnchor, constant: 8),
            
            // CTA Button
            self.ctaButton.leadingAnchor.constraint(equalTo: self.containerView.leadingAnchor, constant: 24),
            self.ctaButton.trailingAnchor.constraint(equalTo: self.containerView.trailingAnchor, constant: -24),
            self.ctaButton.topAnchor.constraint(equalTo: self.descriptionLabel.bottomAnchor, constant: 16),
            
            // Terms Button - top constraint will be set dynamically in updateTermsButtonConstraint
            self.termsButton.leadingAnchor.constraint(equalTo: self.containerView.leadingAnchor, constant: 24),
            self.termsButton.trailingAnchor.constraint(equalTo: self.containerView.trailingAnchor, constant: -24),
            self.termsButton.bottomAnchor.constraint(equalTo: self.containerView.bottomAnchor, constant: -16)
        ])
        
        // Set initial titleLabel constraint (will be updated in configure)
        self.titleLabelTopConstraint = self.titleLabel.topAnchor.constraint(equalTo: self.imageView.bottomAnchor, constant: 16)
        self.titleLabelTopConstraint?.isActive = true
        
        // Set initial termsButton top constraint (will be updated in configure)
        self.termsButtonTopConstraint = self.termsButton.topAnchor.constraint(equalTo: self.ctaButton.bottomAnchor, constant: 8)
        self.termsButtonTopConstraint?.isActive = true
    }
}

// MARK: - SwiftUI Previews
#if DEBUG
@available(iOS 17.0, *)
#Preview("Default Bonus") {
    PreviewUIViewController {
        let vc = UIViewController()
        let cardView = BonusCardView(viewModel: MockBonusCardViewModel.defaultMock)
        cardView.translatesAutoresizingMaskIntoConstraints = false
        vc.view.addSubview(cardView)
        
        NSLayoutConstraint.activate([
            cardView.leadingAnchor.constraint(equalTo: vc.view.leadingAnchor, constant: 16),
            cardView.trailingAnchor.constraint(equalTo: vc.view.trailingAnchor, constant: -16),
            cardView.topAnchor.constraint(equalTo: vc.view.safeAreaLayoutGuide.topAnchor, constant: 20)
        ])
        
        return vc
    }
}

@available(iOS 17.0, *)
#Preview("No URLs") {
    PreviewUIViewController {
        let vc = UIViewController()
        let cardView = BonusCardView(viewModel: MockBonusCardViewModel.noURLsMock)
        cardView.translatesAutoresizingMaskIntoConstraints = false
        vc.view.addSubview(cardView)
        
        NSLayoutConstraint.activate([
            cardView.leadingAnchor.constraint(equalTo: vc.view.leadingAnchor, constant: 16),
            cardView.trailingAnchor.constraint(equalTo: vc.view.trailingAnchor, constant: -16),
            cardView.topAnchor.constraint(equalTo: vc.view.safeAreaLayoutGuide.topAnchor, constant: 20)
        ])
        
        return vc
    }
}

@available(iOS 17.0, *)
#Preview("Casino Bonus") {
    PreviewUIViewController {
        let vc = UIViewController()
        let cardView = BonusCardView(viewModel: MockBonusCardViewModel.casinoBonusMock)
        cardView.translatesAutoresizingMaskIntoConstraints = false
        vc.view.addSubview(cardView)
        
        NSLayoutConstraint.activate([
            cardView.leadingAnchor.constraint(equalTo: vc.view.leadingAnchor, constant: 16),
            cardView.trailingAnchor.constraint(equalTo: vc.view.trailingAnchor, constant: -16),
            cardView.topAnchor.constraint(equalTo: vc.view.safeAreaLayoutGuide.topAnchor, constant: 20)
        ])
        
        return vc
    }
}

@available(iOS 17.0, *)
#Preview("No Tag") {
    PreviewUIViewController {
        let vc = UIViewController()
        let cardView = BonusCardView(viewModel: MockBonusCardViewModel.noTagMock)
        cardView.translatesAutoresizingMaskIntoConstraints = false
        vc.view.addSubview(cardView)
        
        NSLayoutConstraint.activate([
            cardView.leadingAnchor.constraint(equalTo: vc.view.leadingAnchor, constant: 16),
            cardView.trailingAnchor.constraint(equalTo: vc.view.trailingAnchor, constant: -16),
            cardView.topAnchor.constraint(equalTo: vc.view.safeAreaLayoutGuide.topAnchor, constant: 20)
        ])
        
        return vc
    }
}

@available(iOS 17.0, *)
#Preview("No Image URL") {
    PreviewUIViewController {
        let vc = UIViewController()
        let cardView = BonusCardView(viewModel: MockBonusCardViewModel.noImageURLMock)
        cardView.translatesAutoresizingMaskIntoConstraints = false
        vc.view.addSubview(cardView)
        
        NSLayoutConstraint.activate([
            cardView.leadingAnchor.constraint(equalTo: vc.view.leadingAnchor, constant: 16),
            cardView.trailingAnchor.constraint(equalTo: vc.view.trailingAnchor, constant: -16),
            cardView.topAnchor.constraint(equalTo: vc.view.safeAreaLayoutGuide.topAnchor, constant: 20)
        ])
        
        return vc
    }
}

@available(iOS 17.0, *)
#Preview("Terms Button Hidden") {
    PreviewUIViewController {
        let vc = UIViewController()
        let cardView = BonusCardView(viewModel: MockBonusCardViewModel.noURLsMock)
        cardView.translatesAutoresizingMaskIntoConstraints = false
        vc.view.addSubview(cardView)
        
        NSLayoutConstraint.activate([
            cardView.leadingAnchor.constraint(equalTo: vc.view.leadingAnchor, constant: 16),
            cardView.trailingAnchor.constraint(equalTo: vc.view.trailingAnchor, constant: -16),
            cardView.topAnchor.constraint(equalTo: vc.view.safeAreaLayoutGuide.topAnchor, constant: 20)
        ])
        
        return vc
    }
}

#endif
