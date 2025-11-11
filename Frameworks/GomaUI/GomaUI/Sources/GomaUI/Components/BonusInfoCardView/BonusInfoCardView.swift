//
//  BonusInfoCardView.swift
//  GomaUI
//
//  Created by Claude on October 24, 2025.
//

import UIKit
import Combine
import Kingfisher

/// A comprehensive card view displaying bonus information including header image,
/// bonus amounts, wagering progress, and expiry details
public class BonusInfoCardView: UIView {
    
    // MARK: Private properties
    
    private lazy var containerView: UIView = Self.createContainerView()
    private lazy var containerStackView: UIStackView = Self.createContainerStackView()
    private lazy var headerImageView: UIImageView = Self.createHeaderImageView()
    
    // Title section
    private lazy var titleContainerView: UIView = Self.createTitleContainerView()
    private lazy var titleLabel: UILabel = Self.createTitleLabel()
    private lazy var subtitleLabel: UILabel = Self.createSubtitleLabel()
    private lazy var statusPillView: UIView = Self.createStatusPillView()
    private lazy var statusLabel: UILabel = Self.createStatusLabel()
    
    // Simple bonus amount (horizontal layout)
    private lazy var simpleBonusAmountView: UIView = Self.createSimpleBonusAmountView()
    private lazy var simpleBonusAmountTitleLabel: UILabel = Self.createSimpleBonusAmountTitleLabel()
    private lazy var simpleBonusAmountValueLabel: UILabel = Self.createSimpleBonusAmountValueLabel()
    
    // Amount boxes (two boxes side by side)
    private lazy var amountBoxesStackView: UIStackView = Self.createAmountBoxesStackView()
    private lazy var bonusAmountBoxView: UIView = Self.createAmountBoxView()
    private lazy var bonusAmountTitleLabel: UILabel = Self.createAmountTitleLabel()
    private lazy var bonusAmountValueLabel: UILabel = Self.createAmountValueLabel()
    private lazy var remainingAmountBoxView: UIView = Self.createAmountBoxView()
    private lazy var remainingAmountTitleLabel: UILabel = Self.createAmountTitleLabel()
    private lazy var remainingAmountValueLabel: UILabel = Self.createRemainingAmountValueLabel()
    
    // Wagering progress section
    private lazy var wageringTitleStackView: UIStackView = Self.createWageringTitleStackView()
    private lazy var wageringIconImageView: UIImageView = Self.createWageringIconImageView()
    private lazy var wageringTitleLabel: UILabel = Self.createWageringTitleLabel()
    private lazy var progressView: UIProgressView = Self.createProgressView()
    private lazy var remainingToWagerLabel: UILabel = Self.createRemainingToWagerLabel()
    
    // Action button
    private lazy var termsButton: UIButton = Self.createTermsButton()
    
    // Expiry section
    private lazy var expiryContainerView: UIView = Self.createExpiryContainerView()
    private lazy var separatorLineView: UIView = Self.createSeparatorLineView()
    private lazy var expiryStackView: UIStackView = Self.createExpiryStackView()
    private lazy var expiryIconImageView: UIImageView = Self.createExpiryIconImageView()
    private lazy var expiryLabel: UILabel = Self.createExpiryLabel()
    
    private let viewModel: BonusInfoCardViewModelProtocol
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Lifetime and Cycle
    
    public init(viewModel: BonusInfoCardViewModelProtocol) {
        self.viewModel = viewModel
        super.init(frame: .zero)
        self.commonInit()
        self.setupWithTheme()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func commonInit() {
        self.setupSubviews()
        self.setupActions()
        self.bind(toViewModel: self.viewModel)
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        self.containerView.layer.cornerRadius = 12
        self.statusPillView.layer.cornerRadius = 13
        self.bonusAmountBoxView.layer.cornerRadius = 8
        self.remainingAmountBoxView.layer.cornerRadius = 8
    }
    
    func setupWithTheme() {
        self.containerView.backgroundColor = StyleProvider.Color.backgroundTertiary
        self.containerView.layer.borderColor = StyleProvider.Color.backgroundBorder.cgColor
        
        self.titleLabel.textColor = StyleProvider.Color.textPrimary
        self.subtitleLabel.textColor = StyleProvider.Color.textSecondary
        
        self.simpleBonusAmountView.backgroundColor = StyleProvider.Color.backgroundSecondary
        self.simpleBonusAmountTitleLabel.textColor = StyleProvider.Color.textSecondary
        self.simpleBonusAmountValueLabel.textColor = StyleProvider.Color.textPrimary
        
        self.bonusAmountBoxView.backgroundColor = StyleProvider.Color.backgroundSecondary
        self.bonusAmountTitleLabel.textColor = StyleProvider.Color.textSecondary
        self.bonusAmountValueLabel.textColor = StyleProvider.Color.textPrimary
        
        self.remainingAmountBoxView.backgroundColor = StyleProvider.Color.backgroundSecondary
        self.remainingAmountTitleLabel.textColor = StyleProvider.Color.textSecondary
        self.remainingAmountValueLabel.textColor = StyleProvider.Color.highlightPrimary
        
        self.wageringIconImageView.tintColor = StyleProvider.Color.iconSecondary
        self.wageringTitleLabel.textColor = StyleProvider.Color.textPrimary
        self.progressView.progressTintColor = StyleProvider.Color.highlightSecondary
        self.progressView.trackTintColor = StyleProvider.Color.separatorLineSecondary
        self.remainingToWagerLabel.textColor = StyleProvider.Color.textSecondary
        
        self.termsButton.backgroundColor = StyleProvider.Color.backgroundSecondary
        self.termsButton.setTitleColor(StyleProvider.Color.highlightPrimary, for: .normal)
        
        self.expiryContainerView.backgroundColor = StyleProvider.Color.backgroundSecondary
        self.separatorLineView.backgroundColor = StyleProvider.Color.separatorLine
        self.expiryLabel.textColor = StyleProvider.Color.alertWarning
        self.expiryIconImageView.tintColor = StyleProvider.Color.alertWarning
    }
    
    // MARK: - Binding
    
    private func bind(toViewModel viewModel: BonusInfoCardViewModelProtocol) {
        viewModel.displayStatePublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] displayState in
                self?.configure(with: displayState)
            }
            .store(in: &cancellables)
    }
    
    // MARK: Functions
    
    private func configure(with displayState: BonusInfoCardDisplayState) {
        // Configure header image (optional)
        if let headerImageURL = displayState.headerImageURL, let url = URL(string: headerImageURL) {
            self.headerImageView.kf.setImage(with: url)
            self.headerImageView.isHidden = false
        } else {
            self.headerImageView.isHidden = true
        }
        
        // Configure title section
        self.titleLabel.text = displayState.title
        
        if let subtitle = displayState.subtitle {
            self.subtitleLabel.text = subtitle
            self.subtitleLabel.isHidden = false
        } else {
            self.subtitleLabel.isHidden = true
        }
        
        // Configure status pill
        self.statusLabel.text = displayState.status.displayText
        self.updateStatusPillAppearance(for: displayState.status)
        
        // Configure amount display based on type
        switch displayState.bonusAmountType {
        case .simple:
            self.simpleBonusAmountView.isHidden = false
            self.amountBoxesStackView.isHidden = true
            self.simpleBonusAmountValueLabel.text = displayState.bonusAmountText
        case .combo:
            self.simpleBonusAmountView.isHidden = true
            self.amountBoxesStackView.isHidden = false
            self.bonusAmountValueLabel.text = displayState.bonusAmountText
            self.remainingAmountValueLabel.text = displayState.remainingAmountText
        }
        
        // Configure wagering progress
        self.progressView.progress = displayState.wageringProgress
        
        if let remainingText = displayState.remainingToWagerText {
            self.remainingToWagerLabel.text = remainingText
            self.remainingToWagerLabel.isHidden = false
        } else {
            self.remainingToWagerLabel.isHidden = true
        }
        
        // Configure expiry
        self.expiryLabel.text = "\(LocalizationProvider.string("expires")): \(displayState.expiryText)"
    }
    
    private func updateStatusPillAppearance(for status: BonusStatus) {
        switch status {
        case .active:
            self.statusPillView.backgroundColor = StyleProvider.Color.alertSuccess.withAlphaComponent(0.1)
            self.statusLabel.textColor = StyleProvider.Color.alertSuccess
        case .released:
            self.statusPillView.backgroundColor = StyleProvider.Color.highlightTertiary.withAlphaComponent(0.1)
            self.statusLabel.textColor = StyleProvider.Color.highlightTertiary
        }
    }
    
    private func setupActions() {
        self.termsButton.addTarget(self, action: #selector(termsButtonTapped), for: .touchUpInside)
    }
    
    @objc private func termsButtonTapped() {
        self.viewModel.didTapTermsAndConditions()
    }
}

// MARK: - Subviews Initialization and Setup

extension BonusInfoCardView {
    
    private static func createContainerView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.cornerRadius = 8
        view.layer.borderWidth = 1
        view.clipsToBounds = true
        return view
    }
    
    private static func createContainerStackView() -> UIStackView {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.spacing = 0
        stackView.alignment = .fill
        stackView.distribution = .fill
        return stackView
    }
    
    private static func createHeaderImageView() -> UIImageView {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 12
        imageView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        return imageView
    }
    
    // MARK: Title Section
    
    private static func createTitleContainerView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }
    
    private static func createTitleLabel() -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = StyleProvider.fontWith(type: .semibold, size: 16)
        label.numberOfLines = 1
        return label
    }
    
    private static func createSubtitleLabel() -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = StyleProvider.fontWith(type: .regular, size: 12)
        label.numberOfLines = 1
        return label
    }
    
    private static func createStatusPillView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }
    
    private static func createStatusLabel() -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = StyleProvider.fontWith(type: .medium, size: 12)
        label.numberOfLines = 1
        return label
    }
    
    // MARK: Simple Bonus Amount Section
    
    private static func createSimpleBonusAmountView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.cornerRadius = 8
        return view
    }
    
    private static func createSimpleBonusAmountTitleLabel() -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = StyleProvider.fontWith(type: .regular, size: 14)
        label.text = LocalizationProvider.string("bonus_amount")
        label.numberOfLines = 1
        return label
    }
    
    private static func createSimpleBonusAmountValueLabel() -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = StyleProvider.fontWith(type: .bold, size: 14)
        label.numberOfLines = 1
        return label
    }
    
    // MARK: Amount Boxes Section
    
    private static func createAmountBoxesStackView() -> UIStackView {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .horizontal
        stackView.spacing = 12
        stackView.distribution = .fillEqually
        return stackView
    }
    
    private static func createAmountBoxView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }
    
    private static func createAmountTitleLabel() -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = StyleProvider.fontWith(type: .regular, size: 12)
        label.numberOfLines = 1
        return label
    }
    
    private static func createAmountValueLabel() -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = StyleProvider.fontWith(type: .bold, size: 18)
        label.numberOfLines = 1
        return label
    }
    
    private static func createRemainingAmountValueLabel() -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = StyleProvider.fontWith(type: .bold, size: 18)
        label.numberOfLines = 1
        return label
    }
    
    // MARK: Wagering Progress Section
    
    private static func createWageringTitleStackView() -> UIStackView {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .horizontal
        stackView.spacing = 6
        stackView.alignment = .center
        return stackView
    }
    
    private static func createWageringIconImageView() -> UIImageView {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        imageView.tintColor = StyleProvider.Color.textPrimary
        // Use SF Symbol for casino chips icon
        if let customImage = UIImage(named: "coins_icon") {
            imageView.image = customImage.withRenderingMode(.alwaysTemplate)
        }
        else {
            imageView.image = UIImage(systemName: "circle.stack.fill")?.withRenderingMode(.alwaysTemplate)
        }
        return imageView
    }
    
    private static func createWageringTitleLabel() -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = StyleProvider.fontWith(type: .medium, size: 14)
        label.text = LocalizationProvider.string("wagering_progress")
        label.numberOfLines = 1
        return label
    }
    
    private static func createProgressView() -> UIProgressView {
        let progressView = UIProgressView(progressViewStyle: .default)
        progressView.translatesAutoresizingMaskIntoConstraints = false
        progressView.layer.cornerRadius = 4
        progressView.clipsToBounds = true
        return progressView
    }
    
    private static func createRemainingToWagerLabel() -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = StyleProvider.fontWith(type: .regular, size: 12)
        label.numberOfLines = 1
        return label
    }
    
    // MARK: Action Button
    
    private static func createTermsButton() -> UIButton {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle(LocalizationProvider.string("terms_conditions"), for: .normal)
        button.titleLabel?.font = StyleProvider.fontWith(type: .semibold, size: 16)
        button.layer.cornerRadius = 8
        button.clipsToBounds = true
        return button
    }
    
    // MARK: Expiry Section
    
    private static func createExpiryContainerView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }
    
    private static func createSeparatorLineView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }
    
    private static func createExpiryStackView() -> UIStackView {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .horizontal
        stackView.spacing = 6
        stackView.alignment = .center
        stackView.clipsToBounds = true
        return stackView
    }
    
    private static func createExpiryIconImageView() -> UIImageView {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        if let customImage = UIImage(named: "calendar_expire_icon") {
            imageView.image = customImage.withRenderingMode(.alwaysTemplate)
        }
        else {
            imageView.image = UIImage(systemName: "calendar")?.withRenderingMode(.alwaysTemplate)
        }
        return imageView
    }
    
    private static func createExpiryLabel() -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = StyleProvider.fontWith(type: .medium, size: 13)
        label.numberOfLines = 1
        return label
    }
    
    // MARK: Setup Methods
    
    private func setupSubviews() {
        // Add main container
        self.addSubview(self.containerView)
        
        // Add stack view to container
        self.containerView.addSubview(self.containerStackView)
        
        // Build title section
        self.statusPillView.addSubview(self.statusLabel)
        self.titleContainerView.addSubview(self.titleLabel)
        self.titleContainerView.addSubview(self.subtitleLabel)
        self.titleContainerView.addSubview(self.statusPillView)
        
        // Build simple bonus amount
        self.simpleBonusAmountView.addSubview(self.simpleBonusAmountTitleLabel)
        self.simpleBonusAmountView.addSubview(self.simpleBonusAmountValueLabel)
        
        // Build amount boxes
        self.bonusAmountBoxView.addSubview(self.bonusAmountTitleLabel)
        self.bonusAmountBoxView.addSubview(self.bonusAmountValueLabel)
        self.bonusAmountTitleLabel.text = LocalizationProvider.string("bonus_amount")
        
        self.remainingAmountBoxView.addSubview(self.remainingAmountTitleLabel)
        self.remainingAmountBoxView.addSubview(self.remainingAmountValueLabel)
        self.remainingAmountTitleLabel.text = LocalizationProvider.string("remaining")
        
        self.amountBoxesStackView.addArrangedSubview(self.bonusAmountBoxView)
        self.amountBoxesStackView.addArrangedSubview(self.remainingAmountBoxView)
        
        // Build wagering section
        self.wageringTitleStackView.addArrangedSubview(self.wageringIconImageView)
        self.wageringTitleStackView.addArrangedSubview(self.wageringTitleLabel)
        
        // Build expiry section
        self.expiryStackView.addArrangedSubview(self.expiryIconImageView)
        self.expiryStackView.addArrangedSubview(self.expiryLabel)
        self.expiryContainerView.addSubview(self.separatorLineView)
        self.expiryContainerView.addSubview(self.expiryStackView)
        
        // Add all sections to main stack view
        self.containerStackView.addArrangedSubview(self.headerImageView)
        self.containerStackView.addArrangedSubview(self.titleContainerView)
        self.containerStackView.addArrangedSubview(self.simpleBonusAmountView)
        self.containerStackView.addArrangedSubview(self.amountBoxesStackView)
        self.containerStackView.addArrangedSubview(self.wageringTitleStackView)
        self.containerStackView.addArrangedSubview(self.progressView)
        self.containerStackView.addArrangedSubview(self.remainingToWagerLabel)
        self.containerStackView.addArrangedSubview(self.termsButton)
        self.containerStackView.addArrangedSubview(self.expiryContainerView)
        
        // Set custom spacing between elements
        self.containerStackView.setCustomSpacing(-6, after: self.headerImageView)
        self.containerStackView.setCustomSpacing(2, after: self.titleContainerView)
        self.containerStackView.setCustomSpacing(14, after: self.simpleBonusAmountView)
        self.containerStackView.setCustomSpacing(14, after: self.amountBoxesStackView)
        self.containerStackView.setCustomSpacing(10, after: self.wageringTitleStackView)
        self.containerStackView.setCustomSpacing(10, after: self.progressView)
        self.containerStackView.setCustomSpacing(16, after: self.remainingToWagerLabel)
        self.containerStackView.setCustomSpacing(16, after: self.termsButton)
        
        self.initConstraints()
    }
    
    private func initConstraints() {
        NSLayoutConstraint.activate([
            // Container
            self.containerView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            self.containerView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            self.containerView.topAnchor.constraint(equalTo: self.topAnchor),
            self.containerView.bottomAnchor.constraint(equalTo: self.bottomAnchor),
            
            // Container Stack View
            self.containerStackView.leadingAnchor.constraint(equalTo: self.containerView.leadingAnchor),
            self.containerStackView.trailingAnchor.constraint(equalTo: self.containerView.trailingAnchor),
            self.containerStackView.topAnchor.constraint(equalTo: self.containerView.topAnchor),
            self.containerStackView.bottomAnchor.constraint(equalTo: self.containerView.bottomAnchor),
            
            // Header Image (height only, width managed by stack view)
            self.headerImageView.heightAnchor.constraint(equalToConstant: 160),
            
            // Title Container (horizontal margins only)
            self.titleContainerView.leadingAnchor.constraint(equalTo: self.containerStackView.leadingAnchor, constant: 10),
            self.titleContainerView.trailingAnchor.constraint(equalTo: self.containerStackView.trailingAnchor, constant: -10),
            
            // Title Label (left side)
            self.titleLabel.leadingAnchor.constraint(equalTo: self.titleContainerView.leadingAnchor),
            self.titleLabel.topAnchor.constraint(equalTo: self.titleContainerView.topAnchor, constant: 16),
            self.titleLabel.trailingAnchor.constraint(lessThanOrEqualTo: self.statusPillView.leadingAnchor, constant: -12),
            
            // Subtitle Label (below title, left side)
            self.subtitleLabel.leadingAnchor.constraint(equalTo: self.titleLabel.leadingAnchor),
            self.subtitleLabel.topAnchor.constraint(equalTo: self.titleLabel.bottomAnchor, constant: 4),
            self.subtitleLabel.bottomAnchor.constraint(equalTo: self.titleContainerView.bottomAnchor, constant: -8),
            self.subtitleLabel.trailingAnchor.constraint(lessThanOrEqualTo: self.statusPillView.leadingAnchor, constant: -12),
            
            // Status Pill (right side, vertically centered)
            self.statusPillView.trailingAnchor.constraint(equalTo: self.titleContainerView.trailingAnchor),
            self.statusPillView.centerYAnchor.constraint(equalTo: self.titleContainerView.centerYAnchor),
            self.statusPillView.heightAnchor.constraint(equalToConstant: 26),
            
            // Status Label (inside pill)
            self.statusLabel.leadingAnchor.constraint(equalTo: self.statusPillView.leadingAnchor, constant: 12),
            self.statusLabel.trailingAnchor.constraint(equalTo: self.statusPillView.trailingAnchor, constant: -12),
            self.statusLabel.topAnchor.constraint(equalTo: self.statusPillView.topAnchor, constant: 4),
            self.statusLabel.bottomAnchor.constraint(equalTo: self.statusPillView.bottomAnchor, constant: -4),
            
            // Simple Bonus Amount (horizontal margins and height)
            self.simpleBonusAmountView.leadingAnchor.constraint(equalTo: self.containerStackView.leadingAnchor, constant: 10),
            self.simpleBonusAmountView.trailingAnchor.constraint(equalTo: self.containerStackView.trailingAnchor, constant: -10),
            self.simpleBonusAmountView.heightAnchor.constraint(equalToConstant: 33),
            
            // Simple Bonus Amount Title (left side)
            self.simpleBonusAmountTitleLabel.leadingAnchor.constraint(equalTo: self.simpleBonusAmountView.leadingAnchor, constant: 12),
            self.simpleBonusAmountTitleLabel.centerYAnchor.constraint(equalTo: self.simpleBonusAmountView.centerYAnchor),
            
            // Simple Bonus Amount Value (right side)
            self.simpleBonusAmountValueLabel.trailingAnchor.constraint(equalTo: self.simpleBonusAmountView.trailingAnchor, constant: -12),
            self.simpleBonusAmountValueLabel.centerYAnchor.constraint(equalTo: self.simpleBonusAmountView.centerYAnchor),
            self.simpleBonusAmountValueLabel.leadingAnchor.constraint(greaterThanOrEqualTo: self.simpleBonusAmountTitleLabel.trailingAnchor, constant: 12),
            
            // Amount Boxes Stack (horizontal margins and height)
            self.amountBoxesStackView.leadingAnchor.constraint(equalTo: self.containerStackView.leadingAnchor, constant: 10),
            self.amountBoxesStackView.trailingAnchor.constraint(equalTo: self.containerStackView.trailingAnchor, constant: -10),
            self.amountBoxesStackView.heightAnchor.constraint(equalToConstant: 70),
            
            // Bonus Amount Box Content
            self.bonusAmountTitleLabel.leadingAnchor.constraint(equalTo: self.bonusAmountBoxView.leadingAnchor, constant: 12),
            self.bonusAmountTitleLabel.trailingAnchor.constraint(equalTo: self.bonusAmountBoxView.trailingAnchor, constant: -12),
            self.bonusAmountTitleLabel.topAnchor.constraint(equalTo: self.bonusAmountBoxView.topAnchor, constant: 10),
            
            self.bonusAmountValueLabel.leadingAnchor.constraint(equalTo: self.bonusAmountTitleLabel.leadingAnchor),
            self.bonusAmountValueLabel.trailingAnchor.constraint(equalTo: self.bonusAmountTitleLabel.trailingAnchor),
            self.bonusAmountValueLabel.topAnchor.constraint(equalTo: self.bonusAmountTitleLabel.bottomAnchor, constant: 4),
            
            // Remaining Amount Box Content
            self.remainingAmountTitleLabel.leadingAnchor.constraint(equalTo: self.remainingAmountBoxView.leadingAnchor, constant: 12),
            self.remainingAmountTitleLabel.trailingAnchor.constraint(equalTo: self.remainingAmountBoxView.trailingAnchor, constant: -12),
            self.remainingAmountTitleLabel.topAnchor.constraint(equalTo: self.remainingAmountBoxView.topAnchor, constant: 10),
            
            self.remainingAmountValueLabel.leadingAnchor.constraint(equalTo: self.remainingAmountTitleLabel.leadingAnchor),
            self.remainingAmountValueLabel.trailingAnchor.constraint(equalTo: self.remainingAmountTitleLabel.trailingAnchor),
            self.remainingAmountValueLabel.topAnchor.constraint(equalTo: self.remainingAmountTitleLabel.bottomAnchor, constant: 4),
            
            // Wagering Title Stack (horizontal margins)
            self.wageringTitleStackView.leadingAnchor.constraint(equalTo: self.containerStackView.leadingAnchor, constant: 10),
            self.wageringTitleStackView.trailingAnchor.constraint(equalTo: self.containerStackView.trailingAnchor, constant: -10),
            
            self.wageringIconImageView.widthAnchor.constraint(equalToConstant: 16),
            self.wageringIconImageView.heightAnchor.constraint(equalToConstant: 16),
            
            // Progress View (horizontal margins and height)
            self.progressView.leadingAnchor.constraint(equalTo: self.containerStackView.leadingAnchor, constant: 16),
            self.progressView.trailingAnchor.constraint(equalTo: self.containerStackView.trailingAnchor, constant: -16),
            self.progressView.heightAnchor.constraint(equalToConstant: 8),
            
            // Remaining to Wager Label (horizontal margins)
            self.remainingToWagerLabel.leadingAnchor.constraint(equalTo: self.containerStackView.leadingAnchor, constant: 10),
            self.remainingToWagerLabel.trailingAnchor.constraint(equalTo: self.containerStackView.trailingAnchor, constant: -10),
            
            // Terms Button (horizontal margins and height)
            self.termsButton.leadingAnchor.constraint(equalTo: self.containerStackView.leadingAnchor, constant: 10),
            self.termsButton.trailingAnchor.constraint(equalTo: self.containerStackView.trailingAnchor, constant: -10),
            self.termsButton.heightAnchor.constraint(equalToConstant: 27),
            
            // Expiry Container (full width and height)
            self.expiryContainerView.heightAnchor.constraint(equalToConstant: 42),
            self.expiryContainerView.leadingAnchor.constraint(equalTo: self.containerStackView.leadingAnchor),
            self.expiryContainerView.trailingAnchor.constraint(equalTo: self.containerStackView.trailingAnchor),
            
            // Separator Line (at top of expiry container)
            self.separatorLineView.leadingAnchor.constraint(equalTo: self.expiryContainerView.leadingAnchor),
            self.separatorLineView.trailingAnchor.constraint(equalTo: self.expiryContainerView.trailingAnchor),
            self.separatorLineView.topAnchor.constraint(equalTo: self.expiryContainerView.topAnchor),
            self.separatorLineView.heightAnchor.constraint(equalToConstant: 1),
            
            // Expiry Stack
            self.expiryStackView.centerXAnchor.constraint(equalTo: self.expiryContainerView.centerXAnchor),
            self.expiryStackView.centerYAnchor.constraint(equalTo: self.expiryContainerView.centerYAnchor),
            
            self.expiryIconImageView.widthAnchor.constraint(equalToConstant: 16),
            self.expiryIconImageView.heightAnchor.constraint(equalToConstant: 16)
        ])
    }
}

// MARK: - SwiftUI Preview

#if DEBUG
import SwiftUI


@available(iOS 17.0, *)
#Preview("Complete Bonus - Combo") {
    PreviewUIViewController {
        let vc = UIViewController()
        vc.view.backgroundColor = StyleProvider.Color.backgroundPrimary
        
        let bonusCard = BonusInfoCardView(viewModel: MockBonusInfoCardViewModel.complete)
        bonusCard.translatesAutoresizingMaskIntoConstraints = false
        vc.view.addSubview(bonusCard)
        
        NSLayoutConstraint.activate([
            bonusCard.leadingAnchor.constraint(equalTo: vc.view.leadingAnchor, constant: 16),
            bonusCard.trailingAnchor.constraint(equalTo: vc.view.trailingAnchor, constant: -16),
            bonusCard.topAnchor.constraint(equalTo: vc.view.safeAreaLayoutGuide.topAnchor, constant: 20)
        ])
        
        return vc
    }
}

@available(iOS 17.0, *)
#Preview("Simple Bonus") {
    PreviewUIViewController {
        let vc = UIViewController()
        vc.view.backgroundColor = StyleProvider.Color.backgroundPrimary
        
        let bonusCard = BonusInfoCardView(viewModel: MockBonusInfoCardViewModel.simple)
        bonusCard.translatesAutoresizingMaskIntoConstraints = false
        vc.view.addSubview(bonusCard)
        
        NSLayoutConstraint.activate([
            bonusCard.leadingAnchor.constraint(equalTo: vc.view.leadingAnchor, constant: 16),
            bonusCard.trailingAnchor.constraint(equalTo: vc.view.trailingAnchor, constant: -16),
            bonusCard.topAnchor.constraint(equalTo: vc.view.safeAreaLayoutGuide.topAnchor, constant: 20)
        ])
        
        return vc
    }
}

@available(iOS 17.0, *)
#Preview("Without Header") {
    PreviewUIViewController {
        let vc = UIViewController()
        vc.view.backgroundColor = StyleProvider.Color.backgroundPrimary
        
        let bonusCard = BonusInfoCardView(viewModel: MockBonusInfoCardViewModel.withoutHeader)
        bonusCard.translatesAutoresizingMaskIntoConstraints = false
        vc.view.addSubview(bonusCard)
        
        NSLayoutConstraint.activate([
            bonusCard.leadingAnchor.constraint(equalTo: vc.view.leadingAnchor, constant: 16),
            bonusCard.trailingAnchor.constraint(equalTo: vc.view.trailingAnchor, constant: -16),
            bonusCard.topAnchor.constraint(equalTo: vc.view.safeAreaLayoutGuide.topAnchor, constant: 20)
        ])
        
        return vc
    }
}

@available(iOS 17.0, *)
#Preview("Minimal (No Optional Elements)") {
    PreviewUIViewController {
        let vc = UIViewController()
        vc.view.backgroundColor = StyleProvider.Color.backgroundPrimary
        
        let bonusCard = BonusInfoCardView(viewModel: MockBonusInfoCardViewModel.minimal)
        bonusCard.translatesAutoresizingMaskIntoConstraints = false
        vc.view.addSubview(bonusCard)
        
        NSLayoutConstraint.activate([
            bonusCard.leadingAnchor.constraint(equalTo: vc.view.leadingAnchor, constant: 16),
            bonusCard.trailingAnchor.constraint(equalTo: vc.view.trailingAnchor, constant: -16),
            bonusCard.topAnchor.constraint(equalTo: vc.view.safeAreaLayoutGuide.topAnchor, constant: 20)
        ])
        
        return vc
    }
}

@available(iOS 17.0, *)
#Preview("Released Status") {
    PreviewUIViewController {
        let vc = UIViewController()
        vc.view.backgroundColor = StyleProvider.Color.backgroundPrimary
        
        let bonusCard = BonusInfoCardView(viewModel: MockBonusInfoCardViewModel.released)
        bonusCard.translatesAutoresizingMaskIntoConstraints = false
        vc.view.addSubview(bonusCard)
        
        NSLayoutConstraint.activate([
            bonusCard.leadingAnchor.constraint(equalTo: vc.view.leadingAnchor, constant: 16),
            bonusCard.trailingAnchor.constraint(equalTo: vc.view.trailingAnchor, constant: -16),
            bonusCard.topAnchor.constraint(equalTo: vc.view.safeAreaLayoutGuide.topAnchor, constant: 20)
        ])
        
        return vc
    }
}

@available(iOS 17.0, *)
#Preview("Almost Complete") {
    PreviewUIViewController {
        let vc = UIViewController()
        vc.view.backgroundColor = StyleProvider.Color.backgroundPrimary
        
        let bonusCard = BonusInfoCardView(viewModel: MockBonusInfoCardViewModel.almostComplete)
        bonusCard.translatesAutoresizingMaskIntoConstraints = false
        vc.view.addSubview(bonusCard)
        
        NSLayoutConstraint.activate([
            bonusCard.leadingAnchor.constraint(equalTo: vc.view.leadingAnchor, constant: 16),
            bonusCard.trailingAnchor.constraint(equalTo: vc.view.trailingAnchor, constant: -16),
            bonusCard.topAnchor.constraint(equalTo: vc.view.safeAreaLayoutGuide.topAnchor, constant: 20)
        ])
        
        return vc
    }
}

#endif

