//
//  PillItemViewController.swift
//  TestCase
//
//  Created by Ruben Roques on 19/05/2025.
//

import UIKit
import GomaUI

class PillItemViewController: UIViewController {

    // MARK: - Properties
    private let pillsContainerView = UIView()
    private let horizontalScrollView = UIScrollView()
    private let stackView = UIStackView()

    // Collection of pill views for demonstration
    private var pillItemViews: [PillItemView] = []

    // MARK: - View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        setupPills()
    }

    // MARK: - Setup
    private func setupViews() {
        view.backgroundColor = .systemBackground

        // Container view
        pillsContainerView.translatesAutoresizingMaskIntoConstraints = false
        pillsContainerView.backgroundColor = UIColor(hex: 0xE7E7E7)
        view.addSubview(pillsContainerView)

        // Scroll view for horizontal scrolling
        horizontalScrollView.translatesAutoresizingMaskIntoConstraints = false
        horizontalScrollView.showsHorizontalScrollIndicator = false
        pillsContainerView.addSubview(horizontalScrollView)

        // Stack view to hold pills
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .horizontal
        stackView.spacing = 16
        stackView.alignment = .center
        stackView.distribution = .fill
        horizontalScrollView.addSubview(stackView)

        // Constraints
        NSLayoutConstraint.activate([
            // Container view
            pillsContainerView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            pillsContainerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            pillsContainerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            pillsContainerView.heightAnchor.constraint(equalToConstant: 60),

            // Scroll view
            horizontalScrollView.topAnchor.constraint(equalTo: pillsContainerView.topAnchor),
            horizontalScrollView.bottomAnchor.constraint(equalTo: pillsContainerView.bottomAnchor),
            horizontalScrollView.leadingAnchor.constraint(equalTo: pillsContainerView.leadingAnchor, constant: 16),
            horizontalScrollView.trailingAnchor.constraint(equalTo: pillsContainerView.trailingAnchor, constant: -16),

            // Stack view
            stackView.topAnchor.constraint(equalTo: horizontalScrollView.topAnchor),
            stackView.bottomAnchor.constraint(equalTo: horizontalScrollView.bottomAnchor),
            stackView.leadingAnchor.constraint(equalTo: horizontalScrollView.contentLayoutGuide.leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: horizontalScrollView.contentLayoutGuide.trailingAnchor),
            stackView.heightAnchor.constraint(equalTo: horizontalScrollView.frameLayoutGuide.heightAnchor)
        ])

        // Add description label
        let descriptionLabel = UILabel()
        descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        descriptionLabel.text = "The Pill component provides a flexible way to create pill-shaped buttons with icons and selection states. Tap on any pill to toggle its selection state."
        descriptionLabel.textAlignment = .left
        descriptionLabel.numberOfLines = 0
        descriptionLabel.font = StyleProvider.fontWith(type: .regular, size: 16)
        descriptionLabel.textColor = StyleProvider.Color.textColor
        view.addSubview(descriptionLabel)

        NSLayoutConstraint.activate([
            descriptionLabel.topAnchor.constraint(equalTo: pillsContainerView.bottomAnchor, constant: 30),
            descriptionLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            descriptionLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20)
        ])
    }

    private func setupPills() {
        // Create various pill configurations
        let pills = [
            (MockPillItemViewModel.footballPill, "Football selected with expand icon"),
            (MockPillItemViewModel.popularPill, "Popular with left icon only"),
            (MockPillItemViewModel.allPill, "All with left icon and expand icon"),
            (
                MockPillItemViewModel(
                    pillData: PillData(
                        id: "baseball",
                        title: "Baseball",
                        leftIconName: "baseball.fill",
                        showExpandIcon: false,
                        isSelected: true
                    )
                ),
                "Baseball unselected"
            ),
            (
                MockPillItemViewModel(
                    pillData: PillData(
                        id: "basketball",
                        title: "Basketball",
                        leftIconName: "basketball.fill",
                        showExpandIcon: true,
                        isSelected: false
                    )
                ),
                "Basketball with expand icon"
            ),
            (
                MockPillItemViewModel(
                    pillData: PillData(
                        id: "text-only",
                        title: "Text Only",
                        leftIconName: nil,
                        showExpandIcon: false,
                        isSelected: false
                    )
                ),
                "Text only pill"
            )
        ]

        // Add pills to the stack view
        for (viewModel, description) in pills {
            let pillItemView = PillItemView(viewModel: viewModel)
            pillItemView.translatesAutoresizingMaskIntoConstraints = false
            pillItemView.accessibilityHint = description

            // Set minimum width for pill
            NSLayoutConstraint.activate([
               pillItemView.heightAnchor.constraint(equalToConstant: 40)
            ])

            // Handle selection
            pillItemView.onPillSelected = {
                // Output to console for demonstration
                print("Pill selected: \(description)")
            }

            // Add to stack view and keep reference
            stackView.addArrangedSubview(pillItemView)
            pillItemViews.append(pillItemView)
        }
    }
}
