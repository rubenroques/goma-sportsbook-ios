import UIKit
import SwiftUI

// MARK: - Snapshot Category
enum PromotionItemSnapshotCategory: String, CaseIterable {
    case selectionStates = "Selection States"
    case contentVariants = "Content Variants"
}

final class PromotionItemViewSnapshotViewController: UIViewController {

    private let category: PromotionItemSnapshotCategory

    init(category: PromotionItemSnapshotCategory) {
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
        titleLabel.text = "PromotionItemView - \(category.rawValue)"
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
        // Selected state
        let selectedData = PromotionItemData(id: "1", title: "Welcome", isSelected: true)
        let selectedViewModel = MockPromotionItemViewModel(promotionItemData: selectedData, isReadOnly: true)
        stackView.addArrangedSubview(createLabeledVariant(
            label: "Selected",
            view: createPromotionItemView(viewModel: selectedViewModel)
        ))

        // Unselected state
        let unselectedData = PromotionItemData(id: "2", title: "Sports", isSelected: false)
        let unselectedViewModel = MockPromotionItemViewModel(promotionItemData: unselectedData, isReadOnly: true)
        stackView.addArrangedSubview(createLabeledVariant(
            label: "Unselected",
            view: createPromotionItemView(viewModel: unselectedViewModel)
        ))

        // Multiple items in a row (simulating selector bar)
        let rowStack = UIStackView()
        rowStack.axis = .horizontal
        rowStack.spacing = 8
        rowStack.distribution = .fill

        let item1Data = PromotionItemData(id: "r1", title: "All", isSelected: true)
        let item1VM = MockPromotionItemViewModel(promotionItemData: item1Data, isReadOnly: true)
        rowStack.addArrangedSubview(createPromotionItemView(viewModel: item1VM))

        let item2Data = PromotionItemData(id: "r2", title: "Sports", isSelected: false)
        let item2VM = MockPromotionItemViewModel(promotionItemData: item2Data, isReadOnly: true)
        rowStack.addArrangedSubview(createPromotionItemView(viewModel: item2VM))

        let item3Data = PromotionItemData(id: "r3", title: "Casino", isSelected: false)
        let item3VM = MockPromotionItemViewModel(promotionItemData: item3Data, isReadOnly: true)
        rowStack.addArrangedSubview(createPromotionItemView(viewModel: item3VM))

        stackView.addArrangedSubview(createLabeledVariant(
            label: "Multiple Items (Row)",
            view: rowStack
        ))
    }

    private func addContentVariants(to stackView: UIStackView) {
        // Short title
        let shortData = PromotionItemData(id: "1", title: "All", isSelected: false)
        let shortViewModel = MockPromotionItemViewModel(promotionItemData: shortData, isReadOnly: true)
        stackView.addArrangedSubview(createLabeledVariant(
            label: "Short Title",
            view: createPromotionItemView(viewModel: shortViewModel)
        ))

        // Medium title
        let mediumData = PromotionItemData(id: "2", title: "Casino Games", isSelected: false)
        let mediumViewModel = MockPromotionItemViewModel(promotionItemData: mediumData, isReadOnly: true)
        stackView.addArrangedSubview(createLabeledVariant(
            label: "Medium Title",
            view: createPromotionItemView(viewModel: mediumViewModel)
        ))

        // Long title
        let longData = PromotionItemData(id: "3", title: "Special Promotions", isSelected: false)
        let longViewModel = MockPromotionItemViewModel(promotionItemData: longData, isReadOnly: true)
        stackView.addArrangedSubview(createLabeledVariant(
            label: "Long Title",
            view: createPromotionItemView(viewModel: longViewModel)
        ))

        // With category
        let categoryData = PromotionItemData(id: "4", title: "Welcome Bonus", isSelected: true, category: "New Users")
        let categoryViewModel = MockPromotionItemViewModel(promotionItemData: categoryData, isReadOnly: true)
        stackView.addArrangedSubview(createLabeledVariant(
            label: "With Category (Selected)",
            view: createPromotionItemView(viewModel: categoryViewModel)
        ))
    }

    // MARK: - Helper Methods

    private func createPromotionItemView(viewModel: MockPromotionItemViewModel) -> PromotionItemView {
        let view = PromotionItemView(viewModel: viewModel)
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
        stack.alignment = .leading
        return stack
    }
}

// MARK: - Preview
#if DEBUG
#Preview("Selection States") {
    PromotionItemViewSnapshotViewController(category: .selectionStates)
}

#Preview("Content Variants") {
    PromotionItemViewSnapshotViewController(category: .contentVariants)
}
#endif
