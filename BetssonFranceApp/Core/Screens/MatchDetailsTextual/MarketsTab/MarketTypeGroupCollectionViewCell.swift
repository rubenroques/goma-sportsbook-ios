//
//  MarketTypeGroupCollectionViewCell.swift
//  Sportsbook
//
//  Created on 2025-07-18.
//

import UIKit
import GomaUI
import Combine

class MarketTypeGroupCollectionViewCell: UICollectionViewCell {
    
    // MARK: - Properties
    
    static let reuseIdentifier = "MarketTypeGroupCollectionViewCell"
    
    // MARK: - UI Components
    
    private let containerView = UIView()
    private let headerView = UIView()
    private let titleLabel = UILabel()
    private let iconsStackView = UIStackView()
    private var marketOutcomesView: MarketOutcomesMultiLineView!
    
    // MARK: - Callbacks
    
    var onOutcomeSelected: ((String, OutcomeType) -> Void)?
    var onOutcomeDeselected: ((String, OutcomeType) -> Void)?
    
    // MARK: - Private Properties
    
    private var currentViewModel: MarketOutcomesMultiLineViewModel?
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Initialization
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
        setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        // Reset to loading state instead of removing the view
        let loadingViewModel = MockMarketOutcomesMultiLineViewModel.loadingMarketGroup
        marketOutcomesView.configure(with: loadingViewModel)
        currentViewModel = nil
        
        // Clear icons
        iconsStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        
        // Reset callbacks
        onOutcomeSelected = nil
        onOutcomeDeselected = nil
        
        // Clear subscriptions
        cancellables.removeAll()
    }
    
    // MARK: - Setup
    
    private func setupUI() {
        contentView.backgroundColor = .clear
        
        // Container view
        containerView.translatesAutoresizingMaskIntoConstraints = false
        containerView.backgroundColor = UIColor.App.backgroundSecondary
        containerView.layer.cornerRadius = 12
        containerView.layer.masksToBounds = true
        contentView.addSubview(containerView)
        
        // Header view
        headerView.translatesAutoresizingMaskIntoConstraints = false
        headerView.backgroundColor = .clear
        containerView.addSubview(headerView)
        
        // Title label
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.font = StyleProvider.fontWith(type: .semibold, size: 14)
        titleLabel.textColor = UIColor.App.textPrimary
        titleLabel.numberOfLines = 1
        headerView.addSubview(titleLabel)
        
        // Icons stack view
        iconsStackView.translatesAutoresizingMaskIntoConstraints = false
        iconsStackView.axis = .horizontal
        iconsStackView.spacing = 4
        iconsStackView.alignment = .center
        iconsStackView.distribution = .fill
        headerView.addSubview(iconsStackView)
        
        // Market outcomes view - create with loading state initially
        let loadingViewModel = MockMarketOutcomesMultiLineViewModel.loadingMarketGroup
        marketOutcomesView = MarketOutcomesMultiLineView(viewModel: loadingViewModel)
        marketOutcomesView.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(marketOutcomesView)
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            // Container view fills content view with padding
            containerView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            containerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            containerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            containerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8),
            
            // Header view
            headerView.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 12),
            headerView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
            headerView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -16),
            headerView.heightAnchor.constraint(equalToConstant: 24),
            
            // Title label
            titleLabel.leadingAnchor.constraint(equalTo: headerView.leadingAnchor),
            titleLabel.centerYAnchor.constraint(equalTo: headerView.centerYAnchor),
            titleLabel.trailingAnchor.constraint(lessThanOrEqualTo: iconsStackView.leadingAnchor, constant: -8),
            
            // Icons stack view
            iconsStackView.trailingAnchor.constraint(equalTo: headerView.trailingAnchor),
            iconsStackView.centerYAnchor.constraint(equalTo: headerView.centerYAnchor),
            iconsStackView.heightAnchor.constraint(equalToConstant: 20),
            
            // Market outcomes view - complete the constraint chain
            marketOutcomesView.topAnchor.constraint(equalTo: headerView.bottomAnchor, constant: 12),
            marketOutcomesView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
            marketOutcomesView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -16),
            marketOutcomesView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -16)
        ])
    }
    
    // MARK: - Configuration
    
    func configure(with marketGroupWithIcons: MarketGroupWithIcons) {
        let marketGroup = marketGroupWithIcons.marketGroup
        let icons = marketGroupWithIcons.icons
        
        // Set title
        titleLabel.text = marketGroupWithIcons.groupName
        
        // Configure icons
        configureIcons(icons)
        
        // Create and configure market outcomes view model
        let viewModel = MarketOutcomesMultiLineViewModel(marketGroupData: marketGroup)
        currentViewModel = viewModel
        
        // Use configure method instead of recreating the view
        marketOutcomesView.configure(with: viewModel)
        
        // Set up callbacks (view instance stays the same)
        marketOutcomesView.onOutcomeSelected = { [weak self] lineId, outcomeType in
            self?.onOutcomeSelected?(lineId, outcomeType)
        }
        
        marketOutcomesView.onOutcomeDeselected = { [weak self] lineId, outcomeType in
            self?.onOutcomeDeselected?(lineId, outcomeType)
        }
        
        // Force layout update after content configuration
        setNeedsLayout()
        invalidateIntrinsicContentSize()
    }
    
    private func configureIcons(_ icons: [MarketInfoIcon]) {
        // Clear existing icons
        iconsStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        
        // Add new icons
        for icon in icons where icon.isVisible {
            let iconImageView = UIImageView()
            iconImageView.translatesAutoresizingMaskIntoConstraints = false
            iconImageView.contentMode = .scaleAspectFit
            iconImageView.image = UIImage(named: icon.iconName)
            
            NSLayoutConstraint.activate([
                iconImageView.widthAnchor.constraint(equalToConstant: 20),
                iconImageView.heightAnchor.constraint(equalToConstant: 20)
            ])
            
            iconsStackView.addArrangedSubview(iconImageView)
        }
    }
}
