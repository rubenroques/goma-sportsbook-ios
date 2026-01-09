//
//  PromotionCardView.swift
//  GomaUI
//
//  Created on 29/08/2025.
//

import UIKit
import Combine
import Kingfisher
import SwiftUI

public class PromotionCardView: UIView {
    
    // MARK: - Private Properties
    private lazy var containerView: UIView = Self.createContainerView()
    private lazy var imageView: UIImageView = Self.createImageView()
    private lazy var tagView: UIView = Self.createTagView()
    private lazy var tagLabel: UILabel = Self.createTagLabel()
    private lazy var titleLabel: UILabel = Self.createTitleLabel()
    private lazy var infoStackView: UIStackView = Self.createInfoStackView()
    private lazy var noteLabel: UILabel = Self.createNoteLabel()
    private lazy var descriptionLabel: UILabel = Self.createDescriptionLabel()
    private lazy var buttonsStackView: UIStackView = Self.createButtonsStackView()
    private lazy var ctaButton: ButtonView = self.createCTAButton()
    private lazy var readMoreButton: ButtonView = self.createReadMoreButton()
    
    private let viewModel: PromotionCardViewModelProtocol
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Lifetime and Cycle
    public init(viewModel: PromotionCardViewModelProtocol) {
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
        self.noteLabel.textColor = StyleProvider.Color.textSecondary
        self.descriptionLabel.textColor = StyleProvider.Color.textPrimary
    }
    
    // MARK: - Binding
    private func bind(toViewModel viewModel: PromotionCardViewModelProtocol) {
        viewModel.displayStatePublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] displayState in
                self?.configure(with: displayState)
            }
            .store(in: &cancellables)
    }
    
    // MARK: - Functions
    private func configure(with displayState: PromotionCardDisplayState) {
        // Configure image
        if let imageURL = URL(string: displayState.imageURL) {
            self.imageView.kf.setImage(with: imageURL)
        }
        
        // Configure tag
        self.tagLabel.text = displayState.tag
        self.tagView.isHidden = displayState.tag == nil
        
        // Configure content
        self.titleLabel.text = displayState.title
        
        self.noteLabel.isHidden = displayState.note == nil
        self.noteLabel.text = displayState.note

        self.descriptionLabel.isHidden = displayState.description == nil
        self.descriptionLabel.text = displayState.description
        
        // Configure CTA button visibility
        self.ctaButton.isHidden = displayState.ctaText == nil
        
        // Configure read more button visibility
        self.readMoreButton.isHidden = !displayState.showReadMoreButton
    }
}


// MARK: - Subviews Initialization and Setup
extension PromotionCardView {
    
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
    
    private static func createInfoStackView() -> UIStackView {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.spacing = 8
        stackView.distribution = .equalSpacing
        return stackView
    }
    
    private static func createNoteLabel() -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = StyleProvider.fontWith(type: .regular, size: 16)
        label.numberOfLines = 0
        return label
    }
    
    private static func createDescriptionLabel() -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = StyleProvider.fontWith(type: .regular, size: 16)
        label.numberOfLines = 0
        return label
    }
    
    private static func createButtonsStackView() -> UIStackView {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.spacing = 8
        stackView.distribution = .equalSpacing
        return stackView
    }
    
    private func createCTAButton() -> ButtonView {
        let button = ButtonView(viewModel: self.viewModel.ctaButtonViewModel)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }
    
    private func createReadMoreButton() -> ButtonView {
        let button = ButtonView(viewModel: self.viewModel.readMoreButtonViewModel)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }
    
    private func setupSubviews() {
        self.addSubview(self.containerView)
        
        self.containerView.addSubview(self.imageView)
        self.imageView.addSubview(self.tagView)
        self.tagView.addSubview(self.tagLabel)
        
        self.containerView.addSubview(self.titleLabel)
        
        self.containerView.addSubview(self.infoStackView)
        
        self.infoStackView.addArrangedSubview(self.noteLabel)
        self.infoStackView.addArrangedSubview(self.descriptionLabel)
        
        self.containerView.addSubview(self.buttonsStackView)
        
        self.buttonsStackView.addArrangedSubview(self.ctaButton)
        self.buttonsStackView.addArrangedSubview(self.readMoreButton)
        
        self.setupTapGesture()
        self.initConstraints()
    }
    
    private func setupTapGesture() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleCardTap))
        self.containerView.addGestureRecognizer(tapGesture)
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
            
            self.imageView.leadingAnchor.constraint(equalTo: self.containerView.leadingAnchor),
            self.imageView.trailingAnchor.constraint(equalTo: self.containerView.trailingAnchor),
            self.imageView.topAnchor.constraint(equalTo: self.containerView.topAnchor),
            self.imageView.heightAnchor.constraint(equalToConstant: 131),
            
            // Tag view
            self.tagView.leadingAnchor.constraint(equalTo: self.imageView.leadingAnchor),
            self.tagView.topAnchor.constraint(equalTo: self.imageView.topAnchor, constant: 15),
            self.tagView.heightAnchor.constraint(equalToConstant: 20),
            
            // Tag label
            self.tagLabel.leadingAnchor.constraint(equalTo: self.tagView.leadingAnchor, constant: 8),
            self.tagLabel.trailingAnchor.constraint(equalTo: self.tagView.trailingAnchor, constant: -8),
            self.tagLabel.topAnchor.constraint(equalTo: self.tagView.topAnchor),
            self.tagLabel.bottomAnchor.constraint(equalTo: self.tagView.bottomAnchor),
            
            // Title label
            self.titleLabel.leadingAnchor.constraint(equalTo: self.containerView.leadingAnchor, constant: 24),
            self.titleLabel.trailingAnchor.constraint(equalTo: self.containerView.trailingAnchor, constant: -24),
            self.titleLabel.topAnchor.constraint(equalTo: self.imageView.bottomAnchor, constant: 16),
            
            self.infoStackView.leadingAnchor.constraint(equalTo: self.containerView.leadingAnchor, constant: 24),
            self.infoStackView.trailingAnchor.constraint(equalTo: self.containerView.trailingAnchor, constant: -24),
            self.infoStackView.topAnchor.constraint(equalTo: self.titleLabel.bottomAnchor, constant: 8),
            
            self.buttonsStackView.leadingAnchor.constraint(equalTo: self.containerView.leadingAnchor, constant: 24),
            self.buttonsStackView.trailingAnchor.constraint(equalTo: self.containerView.trailingAnchor, constant: -24),
            self.buttonsStackView.topAnchor.constraint(equalTo: self.infoStackView.bottomAnchor, constant: 26),
            self.buttonsStackView.bottomAnchor.constraint(equalTo: self.containerView.bottomAnchor, constant: -16)
        ])
    }
}

// MARK: - SwiftUI Previews
#if DEBUG
#Preview("Single Card") {
    PreviewUIViewController {
        let vc = UIViewController()
        let cardView = PromotionCardView(viewModel: MockPromotionCardViewModel.defaultMock)
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

#Preview("Casino Card") {
    PreviewUIViewController {
        let vc = UIViewController()
        let cardView = PromotionCardView(viewModel: MockPromotionCardViewModel.casinoMock)
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

#Preview("No CTA Card") {
    PreviewUIViewController {
        let vc = UIViewController()
        let cardView = PromotionCardView(viewModel: MockPromotionCardViewModel.noCTAMock)
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
