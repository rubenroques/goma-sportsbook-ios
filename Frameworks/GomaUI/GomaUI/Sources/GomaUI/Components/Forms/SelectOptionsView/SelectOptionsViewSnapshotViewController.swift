//
//  SelectOptionsViewSnapshotViewController.swift
//  GomaUI
//
//  Created by Claude on 13/01/2026.
//

import UIKit
import SwiftUI

// MARK: - Snapshot Category
enum SelectOptionsSnapshotCategory: String, CaseIterable {
    case titleVariants = "Title Variants"
    case selectionStates = "Selection States"
    case itemCountVariants = "Item Count Variants"
}

final class SelectOptionsViewSnapshotViewController: UIViewController {

    private let category: SelectOptionsSnapshotCategory

    init(category: SelectOptionsSnapshotCategory) {
        self.category = category
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .backgroundTestColor
        setupUI()
    }

    private func setupUI() {
        let titleLabel = UILabel()
        titleLabel.text = "SelectOptionsView - \(category.rawValue)"
        titleLabel.font = StyleProvider.fontWith(type: .bold, size: 16)
        titleLabel.textColor = StyleProvider.Color.textPrimary
        titleLabel.translatesAutoresizingMaskIntoConstraints = false

        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 24
        stackView.alignment = .fill
        stackView.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(titleLabel)
        view.addSubview(stackView)

        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),

            stackView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 24),
            stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16)
        ])

        addVariants(to: stackView)
    }

    private func addVariants(to stackView: UIStackView) {
        switch category {
        case .titleVariants:
            addTitleVariants(to: stackView)
        case .selectionStates:
            addSelectionStatesVariants(to: stackView)
        case .itemCountVariants:
            addItemCountVariants(to: stackView)
        }
    }

    // MARK: - Title Variants

    private func addTitleVariants(to stackView: UIStackView) {
        // With title
        stackView.addArrangedSubview(createLabeledVariant(
            label: "With Title",
            view: createSelectOptionsView(viewModel: MockSelectOptionsViewModel.withTitle)
        ))

        // Without title
        stackView.addArrangedSubview(createLabeledVariant(
            label: "Without Title",
            view: createSelectOptionsView(viewModel: MockSelectOptionsViewModel.withoutTitle)
        ))

        // Long title
        let longTitleOptions = [
            MockSimpleOptionRowViewModel(option: SortOption(id: "opt1", icon: nil, title: "Option One", count: -1, iconTintChange: false)),
            MockSimpleOptionRowViewModel(option: SortOption(id: "opt2", icon: nil, title: "Option Two", count: -1, iconTintChange: false))
        ]
        let longTitleViewModel = MockSelectOptionsViewModel(
            title: "This is a very long title that might wrap to multiple lines to test the layout",
            options: longTitleOptions,
            selectedOption: "opt1"
        )
        stackView.addArrangedSubview(createLabeledVariant(
            label: "Long Title (Multiline)",
            view: createSelectOptionsView(viewModel: longTitleViewModel)
        ))
    }

    // MARK: - Selection States

    private func addSelectionStatesVariants(to stackView: UIStackView) {
        // First option selected
        let firstSelectedOptions = createThreeOptions()
        let firstSelectedViewModel = MockSelectOptionsViewModel(
            title: "Select a preference",
            options: firstSelectedOptions,
            selectedOption: "first"
        )
        stackView.addArrangedSubview(createLabeledVariant(
            label: "First Option Selected",
            view: createSelectOptionsView(viewModel: firstSelectedViewModel)
        ))

        // Middle option selected
        let middleSelectedViewModel = MockSelectOptionsViewModel(
            title: "Select a preference",
            options: createThreeOptions(),
            selectedOption: "middle"
        )
        stackView.addArrangedSubview(createLabeledVariant(
            label: "Middle Option Selected",
            view: createSelectOptionsView(viewModel: middleSelectedViewModel)
        ))

        // Last option selected
        let lastSelectedViewModel = MockSelectOptionsViewModel(
            title: "Select a preference",
            options: createThreeOptions(),
            selectedOption: "last"
        )
        stackView.addArrangedSubview(createLabeledVariant(
            label: "Last Option Selected",
            view: createSelectOptionsView(viewModel: lastSelectedViewModel)
        ))

        // No selection
        let noSelectionViewModel = MockSelectOptionsViewModel(
            title: "Select a preference",
            options: createThreeOptions(),
            selectedOption: nil
        )
        stackView.addArrangedSubview(createLabeledVariant(
            label: "No Selection",
            view: createSelectOptionsView(viewModel: noSelectionViewModel)
        ))
    }

    // MARK: - Item Count Variants

    private func addItemCountVariants(to stackView: UIStackView) {
        // Two options
        let twoOptions = [
            MockSimpleOptionRowViewModel(option: SortOption(id: "yes", icon: nil, title: "Yes", count: -1, iconTintChange: false)),
            MockSimpleOptionRowViewModel(option: SortOption(id: "no", icon: nil, title: "No", count: -1, iconTintChange: false))
        ]
        let twoOptionsViewModel = MockSelectOptionsViewModel(
            title: "Do you agree?",
            options: twoOptions,
            selectedOption: "yes"
        )
        stackView.addArrangedSubview(createLabeledVariant(
            label: "Two Options",
            view: createSelectOptionsView(viewModel: twoOptionsViewModel)
        ))

        // Four options
        let fourOptions = [
            MockSimpleOptionRowViewModel(option: SortOption(id: "daily", icon: nil, title: "Daily", count: -1, iconTintChange: false)),
            MockSimpleOptionRowViewModel(option: SortOption(id: "weekly", icon: nil, title: "Weekly", count: -1, iconTintChange: false)),
            MockSimpleOptionRowViewModel(option: SortOption(id: "monthly", icon: nil, title: "Monthly", count: -1, iconTintChange: false)),
            MockSimpleOptionRowViewModel(option: SortOption(id: "never", icon: nil, title: "Never", count: -1, iconTintChange: false))
        ]
        let fourOptionsViewModel = MockSelectOptionsViewModel(
            title: "Notification Frequency",
            options: fourOptions,
            selectedOption: "weekly"
        )
        stackView.addArrangedSubview(createLabeledVariant(
            label: "Four Options",
            view: createSelectOptionsView(viewModel: fourOptionsViewModel)
        ))

        // Long text options
        let longTextOptions = [
            MockSimpleOptionRowViewModel(option: SortOption(id: "long1", icon: nil, title: "This is a very long option text that might need to wrap", count: -1, iconTintChange: false)),
            MockSimpleOptionRowViewModel(option: SortOption(id: "long2", icon: nil, title: "Another lengthy option with detailed description", count: -1, iconTintChange: false))
        ]
        let longTextViewModel = MockSelectOptionsViewModel(
            title: "Long Text Options",
            options: longTextOptions,
            selectedOption: "long1"
        )
        stackView.addArrangedSubview(createLabeledVariant(
            label: "Long Text Options",
            view: createSelectOptionsView(viewModel: longTextViewModel)
        ))
    }

    // MARK: - Helper Methods

    private func createThreeOptions() -> [MockSimpleOptionRowViewModel] {
        return [
            MockSimpleOptionRowViewModel(option: SortOption(id: "first", icon: nil, title: "First Option", count: -1, iconTintChange: false)),
            MockSimpleOptionRowViewModel(option: SortOption(id: "middle", icon: nil, title: "Middle Option", count: -1, iconTintChange: false)),
            MockSimpleOptionRowViewModel(option: SortOption(id: "last", icon: nil, title: "Last Option", count: -1, iconTintChange: false))
        ]
    }

    private func createSelectOptionsView(viewModel: MockSelectOptionsViewModel) -> SelectOptionsView {
        let view = SelectOptionsView(viewModel: viewModel)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }

    private func createLabeledVariant(label: String, view: UIView) -> UIStackView {
        let labelView = UILabel()
        labelView.text = label
        labelView.font = StyleProvider.fontWith(type: .medium, size: 12)
        labelView.textColor = StyleProvider.Color.textSecondary

        let stack = UIStackView(arrangedSubviews: [labelView, view])
        stack.axis = .vertical
        stack.spacing = 6
        stack.alignment = .fill
        return stack
    }
}

// MARK: - Preview
#if DEBUG
#Preview("Title Variants") {
    SelectOptionsViewSnapshotViewController(category: .titleVariants)
}

#Preview("Selection States") {
    SelectOptionsViewSnapshotViewController(category: .selectionStates)
}

#Preview("Item Count Variants") {
    SelectOptionsViewSnapshotViewController(category: .itemCountVariants)
}
#endif
