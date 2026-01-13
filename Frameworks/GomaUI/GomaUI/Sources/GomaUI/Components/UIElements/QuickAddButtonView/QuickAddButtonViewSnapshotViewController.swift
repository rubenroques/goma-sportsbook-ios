import UIKit
import SwiftUI

// MARK: - Snapshot Category
enum QuickAddButtonSnapshotCategory: String, CaseIterable {
    case amountVariants = "Amount Variants"
    case stateVariants = "State Variants"
}

final class QuickAddButtonViewSnapshotViewController: UIViewController {

    private let category: QuickAddButtonSnapshotCategory

    init(category: QuickAddButtonSnapshotCategory) {
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
        titleLabel.text = "QuickAddButtonView - \(category.rawValue)"
        titleLabel.font = StyleProvider.fontWith(type: .bold, size: 16)
        titleLabel.textColor = StyleProvider.Color.textPrimary
        titleLabel.translatesAutoresizingMaskIntoConstraints = false

        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 16
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
        case .amountVariants:
            addAmountVariants(to: stackView)
        case .stateVariants:
            addStateVariants(to: stackView)
        }
    }

    // MARK: - Category Variants

    private func addAmountVariants(to stackView: UIStackView) {
        stackView.addArrangedSubview(createLabeledVariant(
            label: "Amount: 100",
            view: createQuickAddButton(viewModel: MockQuickAddButtonViewModel.amount100Mock())
        ))
        stackView.addArrangedSubview(createLabeledVariant(
            label: "Amount: 250",
            view: createQuickAddButton(viewModel: MockQuickAddButtonViewModel.amount250Mock())
        ))
        stackView.addArrangedSubview(createLabeledVariant(
            label: "Amount: 500",
            view: createQuickAddButton(viewModel: MockQuickAddButtonViewModel.amount500Mock())
        ))
        stackView.addArrangedSubview(createLabeledVariant(
            label: "Amount: 1000 (Custom)",
            view: createQuickAddButton(viewModel: MockQuickAddButtonViewModel(amount: 1000))
        ))
        stackView.addArrangedSubview(createLabeledVariant(
            label: "Amount: 5000 (Large)",
            view: createQuickAddButton(viewModel: MockQuickAddButtonViewModel(amount: 5000))
        ))
    }

    private func addStateVariants(to stackView: UIStackView) {
        stackView.addArrangedSubview(createLabeledVariant(
            label: "Enabled",
            view: createQuickAddButton(viewModel: MockQuickAddButtonViewModel.amount100Mock())
        ))
        stackView.addArrangedSubview(createLabeledVariant(
            label: "Disabled",
            view: createQuickAddButton(viewModel: MockQuickAddButtonViewModel.disabledMock())
        ))

        // Row of multiple buttons (common usage pattern)
        let rowStack = UIStackView()
        rowStack.axis = .horizontal
        rowStack.spacing = 8
        rowStack.distribution = .fillEqually

        rowStack.addArrangedSubview(createQuickAddButton(viewModel: MockQuickAddButtonViewModel.amount100Mock()))
        rowStack.addArrangedSubview(createQuickAddButton(viewModel: MockQuickAddButtonViewModel.amount250Mock()))
        rowStack.addArrangedSubview(createQuickAddButton(viewModel: MockQuickAddButtonViewModel.amount500Mock()))

        stackView.addArrangedSubview(createLabeledVariant(
            label: "Row of Buttons (Common Usage)",
            view: rowStack
        ))
    }

    // MARK: - Helper Methods

    private func createQuickAddButton(viewModel: MockQuickAddButtonViewModel) -> QuickAddButtonView {
        let view = QuickAddButtonView(viewModel: viewModel)
        view.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            view.widthAnchor.constraint(equalToConstant: 60),
            view.heightAnchor.constraint(equalToConstant: 36)
        ])
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
        stack.alignment = .leading
        return stack
    }
}

// MARK: - Preview
#if DEBUG
#Preview("Amount Variants") {
    QuickAddButtonViewSnapshotViewController(category: .amountVariants)
}

#Preview("State Variants") {
    QuickAddButtonViewSnapshotViewController(category: .stateVariants)
}
#endif
