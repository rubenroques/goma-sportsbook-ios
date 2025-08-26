//
//  PillSelectorBarViewController.swift
//  TestCase
//
//  Created by Ruben Roques Code on 14/06/2025.
//

import UIKit
import GomaUI

class PillSelectorBarViewController: UIViewController {

    // MARK: - Properties
    private let scrollView = UIScrollView()
    private let contentStackView = UIStackView()
    
    // Collection of pill selector bars for demonstration
    private var pillSelectorBars: [PillSelectorBarView] = []

    // MARK: - View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        setupPillSelectorBars()
    }

    // MARK: - Setup
    private func setupViews() {
        view.backgroundColor = .systemBackground

        // Main scroll view for vertical scrolling
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.showsVerticalScrollIndicator = true
        scrollView.alwaysBounceVertical = true
        view.addSubview(scrollView)

        // Content stack view to hold all examples
        contentStackView.translatesAutoresizingMaskIntoConstraints = false
        contentStackView.axis = .vertical
        contentStackView.spacing = 32
        contentStackView.alignment = .fill
        contentStackView.distribution = .fill
        scrollView.addSubview(contentStackView)

        // Constraints
        NSLayoutConstraint.activate([
            // Scroll view
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            // Content stack view
            contentStackView.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor, constant: 20),
            contentStackView.leadingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.leadingAnchor),
            contentStackView.trailingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.trailingAnchor),
            contentStackView.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor, constant: -20),
            contentStackView.widthAnchor.constraint(equalTo: scrollView.frameLayoutGuide.widthAnchor)
        ])

        // Add description label
        let descriptionLabel = UILabel()
        descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        descriptionLabel.text = "The PillSelectorBarView component provides a horizontal scrollable collection of pill items with fade effects at the edges. It supports various configurations including different pill counts, selection states, and interaction modes."
        descriptionLabel.textAlignment = .left
        descriptionLabel.numberOfLines = 0
        descriptionLabel.font = StyleProvider.fontWith(type: .regular, size: 16)
        descriptionLabel.textColor = StyleProvider.Color.textColor
        contentStackView.addArrangedSubview(descriptionLabel)
    }

    private func setupPillSelectorBars() {
        // Create various pill selector bar configurations
        let configurations = [
            (
                title: "Sports Categories",
                description: "Interactive sports selector with icons and expand indicators",
                viewModel: MockPillSelectorBarViewModel.sportsCategories,
                backgroundColor: StyleProvider.Color.backgroundSecondary
            ),
            (
                title: "Market Filters",
                description: "Betting market filters with mixed icon and text pills",
                viewModel: MockPillSelectorBarViewModel.marketFilters,
                backgroundColor: StyleProvider.Color.backgroundSecondary
            ),
            (
                title: "Time Periods",
                description: "Time-based filter options with calendar integration",
                viewModel: MockPillSelectorBarViewModel.timePeriods,
                backgroundColor: StyleProvider.Color.backgroundSecondary
            ),
            (
                title: "Limited Pills (No Scroll)",
                description: "Few pills that fit in viewport without scrolling",
                viewModel: MockPillSelectorBarViewModel.limitedPills,
                backgroundColor: StyleProvider.Color.backgroundSecondary
            ),
            (
                title: "Read-Only States",
                description: "Multiple selection states without interaction",
                viewModel: MockPillSelectorBarViewModel.readOnlyMarketFilters,
                backgroundColor: StyleProvider.Color.backgroundSecondary
            ),
            (
                title: "Text Only Pills",
                description: "Simple text-based pills without icons",
                viewModel: MockPillSelectorBarViewModel.textOnlyPills,
                backgroundColor: StyleProvider.Color.backgroundSecondary
            ),
            (
                title: "Football Popular Leagues",
                description: "Sport-specific league filters with custom states",
                viewModel: MockPillSelectorBarViewModel.footballPopularLeagues,
                backgroundColor: StyleProvider.Color.backgroundSecondary
            )
        ]

        // Add each configuration to the content stack
        for (title, description, viewModel, backgroundColor) in configurations {
            let sectionView = createSectionView(
                title: title,
                description: description,
                viewModel: viewModel,
                backgroundColor: backgroundColor
            )
            contentStackView.addArrangedSubview(sectionView)
        }
    }
    
    private func createSectionView(
        title: String,
        description: String,
        viewModel: MockPillSelectorBarViewModel,
        backgroundColor: UIColor
    ) -> UIView {
        let containerView = UIView()
        containerView.translatesAutoresizingMaskIntoConstraints = false

        // Title label
        let titleLabel = UILabel()
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.text = title
        titleLabel.font = StyleProvider.fontWith(type: .semibold, size: 18)
        titleLabel.textColor = StyleProvider.Color.textColor
        titleLabel.numberOfLines = 0

        // Description label
        let descriptionLabel = UILabel()
        descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        descriptionLabel.text = description
        descriptionLabel.font = StyleProvider.fontWith(type: .regular, size: 14)
        descriptionLabel.textColor = StyleProvider.Color.textSecondary
        descriptionLabel.numberOfLines = 0

        // Container for the pill selector bar
        let pillContainer = UIView()
        pillContainer.translatesAutoresizingMaskIntoConstraints = false
        pillContainer.backgroundColor = backgroundColor
        pillContainer.layer.cornerRadius = 8
        pillContainer.layer.borderWidth = 1
        pillContainer.layer.borderColor = StyleProvider.Color.separatorLine.cgColor

        // Create the pill selector bar
        let pillSelectorBarView = PillSelectorBarView(viewModel: viewModel)
        pillSelectorBarView.translatesAutoresizingMaskIntoConstraints = false
        
        // Handle pill selection
        pillSelectorBarView.onPillSelected = { [weak self] pillId in
            self?.showSelectionFeedback(pillId: pillId, title: title)
        }

        // Add subviews
        containerView.addSubview(titleLabel)
        containerView.addSubview(descriptionLabel)
        containerView.addSubview(pillContainer)
        pillContainer.addSubview(pillSelectorBarView)

        // Store reference
        pillSelectorBars.append(pillSelectorBarView)

        // Constraints
        NSLayoutConstraint.activate([
            // Title label
            titleLabel.topAnchor.constraint(equalTo: containerView.topAnchor),
            titleLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
            titleLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -16),

            // Description label
            descriptionLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 4),
            descriptionLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
            descriptionLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -16),

            // Pill container
            pillContainer.topAnchor.constraint(equalTo: descriptionLabel.bottomAnchor, constant: 12),
            pillContainer.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
            pillContainer.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -16),
            pillContainer.bottomAnchor.constraint(equalTo: containerView.bottomAnchor),
            pillContainer.heightAnchor.constraint(equalToConstant: 80),

            // Pill selector bar
            pillSelectorBarView.topAnchor.constraint(equalTo: pillContainer.topAnchor, constant: 10),
            pillSelectorBarView.leadingAnchor.constraint(equalTo: pillContainer.leadingAnchor),
            pillSelectorBarView.trailingAnchor.constraint(equalTo: pillContainer.trailingAnchor),
            pillSelectorBarView.bottomAnchor.constraint(equalTo: pillContainer.bottomAnchor, constant: -10)
        ])

        return containerView
    }
    
    private func showSelectionFeedback(pillId: String, title: String) {
        // Create a simple alert to show selection feedback
        let message = "Selected '\(pillId)' from '\(title)'"
        print("PillSelectorBar Selection: \(message)")
        
        // Show a brief toast-like feedback
        let alert = UIAlertController(title: "Pill Selected", message: message, preferredStyle: .alert)
        present(alert, animated: true)
        
        // Auto-dismiss after 1.5 seconds
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            alert.dismiss(animated: true)
        }
    }
}
