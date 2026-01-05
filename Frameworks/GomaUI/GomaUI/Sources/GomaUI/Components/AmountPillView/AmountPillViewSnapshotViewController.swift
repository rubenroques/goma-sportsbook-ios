import UIKit
import SwiftUI

// MARK: - Snapshot Category
enum AmountPillSnapshotCategory: String, CaseIterable {
    case selectionStates = "Selection States"
    case contentVariants = "Content Variants"
}

final class AmountPillViewSnapshotViewController: UIViewController {

    private let category: AmountPillSnapshotCategory

    init(category: AmountPillSnapshotCategory) {
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
        titleLabel.text = "AmountPillView - \(category.rawValue)"
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
        case .contentVariants:
            addContentVariants(to: stackView)
        }
    }

    // MARK: - Category Variants

    private func addSelectionStatesVariants(to stackView: UIStackView) {
        // Unselected
        let unselectedData = AmountPillData(id: "500", amount: "500", isSelected: false)
        let unselectedPill = AmountPillView(viewModel: MockAmountPillViewModel(pillData: unselectedData))
        stackView.addArrangedSubview(createLabeledVariant(
            label: "Unselected",
            view: unselectedPill
        ))

        // Selected
        let selectedData = AmountPillData(id: "500", amount: "500", isSelected: true)
        let selectedPill = AmountPillView(viewModel: MockAmountPillViewModel(pillData: selectedData))
        stackView.addArrangedSubview(createLabeledVariant(
            label: "Selected",
            view: selectedPill
        ))
    }

    private func addContentVariants(to stackView: UIStackView) {
        // Small amount
        let smallData = AmountPillData(id: "100", amount: "100", isSelected: false)
        let smallPill = AmountPillView(viewModel: MockAmountPillViewModel(pillData: smallData))
        stackView.addArrangedSubview(createLabeledVariant(
            label: "Small Amount (100)",
            view: smallPill
        ))

        // Medium amount
        let mediumData = AmountPillData(id: "1000", amount: "1000", isSelected: false)
        let mediumPill = AmountPillView(viewModel: MockAmountPillViewModel(pillData: mediumData))
        stackView.addArrangedSubview(createLabeledVariant(
            label: "Medium Amount (1000)",
            view: mediumPill
        ))

        // Large amount
        let largeData = AmountPillData(id: "50000", amount: "50000", isSelected: false)
        let largePill = AmountPillView(viewModel: MockAmountPillViewModel(pillData: largeData))
        stackView.addArrangedSubview(createLabeledVariant(
            label: "Large Amount (50000)",
            view: largePill
        ))
    }

    // MARK: - Helper Methods

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
@available(iOS 17.0, *)
#Preview("Selection States") {
    AmountPillViewSnapshotViewController(category: .selectionStates)
}

@available(iOS 17.0, *)
#Preview("Content Variants") {
    AmountPillViewSnapshotViewController(category: .contentVariants)
}
#endif
