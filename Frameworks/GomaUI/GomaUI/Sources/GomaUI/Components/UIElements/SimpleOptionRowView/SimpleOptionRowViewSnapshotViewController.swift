import UIKit
import SwiftUI

// MARK: - Snapshot Category
enum SimpleOptionRowSnapshotCategory: String, CaseIterable {
    case selectionStates = "Selection States"
    case contentVariants = "Content Variants"
}

final class SimpleOptionRowViewSnapshotViewController: UIViewController {

    private let category: SimpleOptionRowSnapshotCategory

    init(category: SimpleOptionRowSnapshotCategory) {
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
        titleLabel.text = "SimpleOptionRowView - \(category.rawValue)"
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
        case .selectionStates:
            addSelectionStatesVariants(to: stackView)
        case .contentVariants:
            addContentVariants(to: stackView)
        }
    }

    // MARK: - Category Variants

    private func addSelectionStatesVariants(to stackView: UIStackView) {
        stackView.addArrangedSubview(createLabeledVariant(
            label: "Selected",
            view: createRowView(viewModel: MockSimpleOptionRowViewModel.sampleSelected, isSelected: true)
        ))
        stackView.addArrangedSubview(createLabeledVariant(
            label: "Unselected",
            view: createRowView(viewModel: MockSimpleOptionRowViewModel.sampleUnselected, isSelected: false)
        ))
    }

    private func addContentVariants(to stackView: UIStackView) {
        // Short text
        let shortOption = SortOption(
            id: "short",
            icon: nil,
            title: "Yes",
            count: -1,
            iconTintChange: false
        )
        stackView.addArrangedSubview(createLabeledVariant(
            label: "Short Text",
            view: createRowView(viewModel: MockSimpleOptionRowViewModel(option: shortOption), isSelected: false)
        ))

        // Medium text
        let mediumOption = SortOption(
            id: "medium",
            icon: nil,
            title: "Enable notifications",
            count: -1,
            iconTintChange: false
        )
        stackView.addArrangedSubview(createLabeledVariant(
            label: "Medium Text",
            view: createRowView(viewModel: MockSimpleOptionRowViewModel(option: mediumOption), isSelected: true)
        ))

        // Long text
        let longOption = SortOption(
            id: "long",
            icon: nil,
            title: "Receive personalized offers and promotional updates via email",
            count: -1,
            iconTintChange: false
        )
        stackView.addArrangedSubview(createLabeledVariant(
            label: "Long Text",
            view: createRowView(viewModel: MockSimpleOptionRowViewModel(option: longOption), isSelected: false)
        ))
    }

    // MARK: - Helper Methods

    private func createRowView(viewModel: MockSimpleOptionRowViewModel, isSelected: Bool) -> SimpleOptionRowView {
        let view = SimpleOptionRowView(viewModel: viewModel)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.isSelected = isSelected
        view.configure()

        NSLayoutConstraint.activate([
            view.heightAnchor.constraint(equalToConstant: 48)
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
        stack.alignment = .fill
        return stack
    }
}

// MARK: - Preview
#if DEBUG
#Preview("Selection States") {
    SimpleOptionRowViewSnapshotViewController(category: .selectionStates)
}

#Preview("Content Variants") {
    SimpleOptionRowViewSnapshotViewController(category: .contentVariants)
}
#endif
