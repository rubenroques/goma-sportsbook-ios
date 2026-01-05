import UIKit
import SwiftUI

// MARK: - Snapshot Category
enum AmountPillsSnapshotCategory: String, CaseIterable {
    case selectionStates = "Selection States"
    case pillCounts = "Pill Counts"
}

final class AmountPillsViewSnapshotViewController: UIViewController {

    private let category: AmountPillsSnapshotCategory

    init(category: AmountPillsSnapshotCategory) {
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
        titleLabel.text = "AmountPillsView - \(category.rawValue)"
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
        case .selectionStates:
            addSelectionStatesVariants(to: stackView)
        case .pillCounts:
            addPillCountsVariants(to: stackView)
        }
    }

    // MARK: - Category Variants

    private func addSelectionStatesVariants(to stackView: UIStackView) {
        // No selection
        let noSelectionData = AmountPillsData(
            id: "no_selection",
            pills: [
                AmountPillData(id: "250", amount: "250", isSelected: false),
                AmountPillData(id: "500", amount: "500", isSelected: false),
                AmountPillData(id: "1000", amount: "1000", isSelected: false),
                AmountPillData(id: "2000", amount: "2000", isSelected: false)
            ],
            selectedPillId: nil
        )
        let noSelectionView = AmountPillsView(viewModel: MockAmountPillsViewModel(pillsData: noSelectionData))
        noSelectionView.translatesAutoresizingMaskIntoConstraints = false
        noSelectionView.heightAnchor.constraint(equalToConstant: 40).isActive = true
        stackView.addArrangedSubview(createLabeledVariant(
            label: "No Selection",
            view: noSelectionView
        ))

        // With selection
        let withSelectionData = AmountPillsData(
            id: "with_selection",
            pills: [
                AmountPillData(id: "250", amount: "250", isSelected: false),
                AmountPillData(id: "500", amount: "500", isSelected: true),
                AmountPillData(id: "1000", amount: "1000", isSelected: false),
                AmountPillData(id: "2000", amount: "2000", isSelected: false)
            ],
            selectedPillId: "500"
        )
        let withSelectionView = AmountPillsView(viewModel: MockAmountPillsViewModel(pillsData: withSelectionData))
        withSelectionView.translatesAutoresizingMaskIntoConstraints = false
        withSelectionView.heightAnchor.constraint(equalToConstant: 40).isActive = true
        stackView.addArrangedSubview(createLabeledVariant(
            label: "With Selection (500)",
            view: withSelectionView
        ))
    }

    private func addPillCountsVariants(to stackView: UIStackView) {
        // Few pills
        let fewPillsData = AmountPillsData(
            id: "few",
            pills: [
                AmountPillData(id: "100", amount: "100", isSelected: false),
                AmountPillData(id: "500", amount: "500", isSelected: false),
                AmountPillData(id: "1000", amount: "1000", isSelected: false)
            ],
            selectedPillId: nil
        )
        let fewPillsView = AmountPillsView(viewModel: MockAmountPillsViewModel(pillsData: fewPillsData))
        fewPillsView.translatesAutoresizingMaskIntoConstraints = false
        fewPillsView.heightAnchor.constraint(equalToConstant: 40).isActive = true
        stackView.addArrangedSubview(createLabeledVariant(
            label: "Few Pills (3)",
            view: fewPillsView
        ))

        // Many pills (scrollable)
        let manyPillsData = AmountPillsData(
            id: "many",
            pills: [
                AmountPillData(id: "250", amount: "250", isSelected: false),
                AmountPillData(id: "500", amount: "500", isSelected: false),
                AmountPillData(id: "1000", amount: "1000", isSelected: false),
                AmountPillData(id: "2000", amount: "2000", isSelected: false),
                AmountPillData(id: "3000", amount: "3000", isSelected: false),
                AmountPillData(id: "5000", amount: "5000", isSelected: false),
                AmountPillData(id: "10000", amount: "10000", isSelected: false),
                AmountPillData(id: "20000", amount: "20000", isSelected: false)
            ],
            selectedPillId: nil
        )
        let manyPillsView = AmountPillsView(viewModel: MockAmountPillsViewModel(pillsData: manyPillsData))
        manyPillsView.translatesAutoresizingMaskIntoConstraints = false
        manyPillsView.heightAnchor.constraint(equalToConstant: 40).isActive = true
        stackView.addArrangedSubview(createLabeledVariant(
            label: "Many Pills (8, scrollable)",
            view: manyPillsView
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
        stack.alignment = .fill
        return stack
    }
}

// MARK: - Preview
#if DEBUG
@available(iOS 17.0, *)
#Preview("Selection States") {
    AmountPillsViewSnapshotViewController(category: .selectionStates)
}

@available(iOS 17.0, *)
#Preview("Pill Counts") {
    AmountPillsViewSnapshotViewController(category: .pillCounts)
}
#endif
