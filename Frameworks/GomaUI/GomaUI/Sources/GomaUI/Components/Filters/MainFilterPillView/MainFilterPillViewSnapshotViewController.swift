import UIKit
import SwiftUI

// MARK: - Snapshot Category
enum MainFilterPillSnapshotCategory: String, CaseIterable {
    case selectionStates = "Selection States"
    case counterVariants = "Counter Variants"
}

final class MainFilterPillViewSnapshotViewController: UIViewController {

    private let category: MainFilterPillSnapshotCategory

    init(category: MainFilterPillSnapshotCategory) {
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
        titleLabel.text = "MainFilterPillView - \(category.rawValue)"
        titleLabel.font = StyleProvider.fontWith(type: .bold, size: 16)
        titleLabel.textColor = StyleProvider.Color.textPrimary
        titleLabel.translatesAutoresizingMaskIntoConstraints = false

        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 16
        stackView.alignment = .leading
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
        case .selectionStates:
            addSelectionStatesVariants(to: stackView)
        case .counterVariants:
            addCounterVariants(to: stackView)
        }
    }

    // MARK: - Category Variants

    private func addSelectionStatesVariants(to stackView: UIStackView) {
        // Not Selected state
        stackView.addArrangedSubview(createLabeledVariant(
            label: "Not Selected",
            view: createMainFilterPillView(state: .notSelected)
        ))

        // Selected state with single filter
        stackView.addArrangedSubview(createLabeledVariant(
            label: "Selected (1 filter)",
            view: createMainFilterPillView(state: .selected(selections: "1"))
        ))

        // Selected state with multiple filters
        stackView.addArrangedSubview(createLabeledVariant(
            label: "Selected (3 filters)",
            view: createMainFilterPillView(state: .selected(selections: "3"))
        ))
    }

    private func addCounterVariants(to stackView: UIStackView) {
        // Single digit counter
        stackView.addArrangedSubview(createLabeledVariant(
            label: "Counter: 5",
            view: createMainFilterPillView(state: .selected(selections: "5"))
        ))

        // Double digit counter
        stackView.addArrangedSubview(createLabeledVariant(
            label: "Counter: 12",
            view: createMainFilterPillView(state: .selected(selections: "12"))
        ))

        // High counter
        stackView.addArrangedSubview(createLabeledVariant(
            label: "Counter: 99",
            view: createMainFilterPillView(state: .selected(selections: "99"))
        ))

        // Edge case - very high
        stackView.addArrangedSubview(createLabeledVariant(
            label: "Counter: 99+",
            view: createMainFilterPillView(state: .selected(selections: "99+"))
        ))
    }

    // MARK: - Helper Methods

    private func createMainFilterPillView(state: MainFilterStateType) -> MainFilterPillView {
        let mainFilterItem = MainFilterItem(
            type: .mainFilter,
            title: LocalizationProvider.string("filter")
        )
        let viewModel = MockMainFilterPillViewModel(
            mainFilter: mainFilterItem,
            initialState: state
        )
        let pillView = MainFilterPillView(viewModel: viewModel)
        pillView.translatesAutoresizingMaskIntoConstraints = false
        return pillView
    }

    private func createLabeledVariant(label: String, view: UIView) -> UIStackView {
        let labelView = UILabel()
        labelView.text = label
        labelView.font = StyleProvider.fontWith(type: .medium, size: 12)
        labelView.textColor = StyleProvider.Color.textSecondary

        let stack = UIStackView(arrangedSubviews: [labelView, view])
        stack.axis = .vertical
        stack.spacing = 6
        stack.alignment = .leading
        return stack
    }
}

// MARK: - Preview
#if DEBUG
#Preview("Selection States") {
    MainFilterPillViewSnapshotViewController(category: .selectionStates)
}

#Preview("Counter Variants") {
    MainFilterPillViewSnapshotViewController(category: .counterVariants)
}
#endif
