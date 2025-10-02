//
//  MarketTypeGroupTableViewCell.swift
//  Sportsbook
//
//  Created on 2025-10-02.
//

import UIKit
import GomaUI
import Combine

class MarketTypeGroupTableViewCell: UITableViewCell {

    // MARK: - Properties

    static let reuseIdentifier = "MarketTypeGroupTableViewCell"

    // MARK: - UI Components

    private lazy var containerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = UIColor.App.backgroundSecondary
        view.layer.masksToBounds = true
        return view
    }()

    private let headerView = UIView()
    private let titleLabel = UILabel()
    private let iconsStackView = UIStackView()

    // Market outcomes view - created eagerly with loading state
    private var marketOutcomesView: MarketOutcomesMultiLineView!

    // MARK: - Callbacks

    var onOutcomeSelected: ((String, OutcomeType) -> Void)?
    var onOutcomeDeselected: ((String, OutcomeType) -> Void)?

    // MARK: - Private Properties

    private var currentViewModel: MarketOutcomesMultiLineViewModel?
    private var cancellables = Set<AnyCancellable>()

    // MARK: - Initialization

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        // Create market outcomes view with loading state immediately
        let loadingViewModel = MockMarketOutcomesMultiLineViewModel.loadingMarketGroup
        self.marketOutcomesView = MarketOutcomesMultiLineView(viewModel: loadingViewModel)
        self.marketOutcomesView.translatesAutoresizingMaskIntoConstraints = false

        setupUI()
        setupConstraints()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Lifecycle

    override func prepareForReuse() {
        super.prepareForReuse()

        // Reset to loading state
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
        self.backgroundColor = UIColor.App.backgroundPrimary //.clear
        self.contentView.backgroundColor = UIColor.App.backgroundPrimary // .clear
        self.selectionStyle = .none

        self.containerView.backgroundColor = UIColor.App.backgroundTertiary
        
        // Add container view to content view
        self.contentView.addSubview(containerView)

        // Header view
        headerView.translatesAutoresizingMaskIntoConstraints = false
        headerView.backgroundColor = .clear
        containerView.addSubview(headerView)

        // Title label
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.font = StyleProvider.fontWith(type: .semibold, size: 15)
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

        // Market outcomes view (already created in init)
        containerView.addSubview(marketOutcomesView)
    }

    private func setupConstraints() {
        NSLayoutConstraint.activate([
            // Container view - creates spacing between cells
            // Leading/trailing: 16pt padding
            // Top: 8pt, Bottom: -13pt (12pt spacing + 1pt visual adjustment)
            containerView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 0),
            containerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 0),
            containerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: 0),
            containerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -1),

            // Header view
            headerView.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 0),
            headerView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
            headerView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -16),
            headerView.heightAnchor.constraint(equalToConstant: 26),

            // Title label
            titleLabel.leadingAnchor.constraint(equalTo: headerView.leadingAnchor),
            titleLabel.centerYAnchor.constraint(equalTo: headerView.centerYAnchor),
            titleLabel.trailingAnchor.constraint(lessThanOrEqualTo: iconsStackView.leadingAnchor, constant: -8),

            // Icons stack view
            iconsStackView.trailingAnchor.constraint(equalTo: headerView.trailingAnchor),
            iconsStackView.centerYAnchor.constraint(equalTo: headerView.centerYAnchor),
            iconsStackView.heightAnchor.constraint(equalToConstant: 20),

            // Market outcomes view - completes constraint chain for automatic dimension
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

        // Configure the existing view with new view model
        marketOutcomesView.configure(with: viewModel)

        // Set up callbacks
        marketOutcomesView.onOutcomeSelected = { [weak self] lineId, outcomeType in
            self?.onOutcomeSelected?(lineId, outcomeType)
        }

        marketOutcomesView.onOutcomeDeselected = { [weak self] lineId, outcomeType in
            self?.onOutcomeDeselected?(lineId, outcomeType)
        }

        // Betslip synchronization
        Env.betslipManager.bettingTicketsPublisher
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] tickets in
                guard let self = self,
                      let currentViewModel = self.currentViewModel else { return }

                // Synchronize selection state with betslip
                for lineViewModel in currentViewModel.lineViewModels {
                    // Check left outcome
                    if let leftOutcome = lineViewModel.marketStateSubject.value.leftOutcome {
                        let shouldBeSelected = tickets.contains { $0.outcomeId == leftOutcome.id }
                        if shouldBeSelected {
                            lineViewModel.setOutcomeSelected(type: .left)
                        } else {
                            lineViewModel.setOutcomeDeselected(type: .left)
                        }
                    }

                    // Check middle outcome
                    if let middleOutcome = lineViewModel.marketStateSubject.value.middleOutcome {
                        let shouldBeSelected = tickets.contains { $0.outcomeId == middleOutcome.id }
                        if shouldBeSelected {
                            lineViewModel.setOutcomeSelected(type: .middle)
                        } else {
                            lineViewModel.setOutcomeDeselected(type: .middle)
                        }
                    }

                    // Check right outcome
                    if let rightOutcome = lineViewModel.marketStateSubject.value.rightOutcome {
                        let shouldBeSelected = tickets.contains { $0.outcomeId == rightOutcome.id }
                        if shouldBeSelected {
                            lineViewModel.setOutcomeSelected(type: .right)
                        } else {
                            lineViewModel.setOutcomeDeselected(type: .right)
                        }
                    }
                }
            })
            .store(in: &cancellables)
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
