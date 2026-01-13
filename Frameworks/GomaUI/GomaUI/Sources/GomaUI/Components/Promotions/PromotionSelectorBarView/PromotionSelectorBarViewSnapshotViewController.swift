import UIKit
import SwiftUI

// MARK: - Snapshot Category
enum PromotionSelectorBarSnapshotCategory: String, CaseIterable {
    case basicLayouts = "Basic Layouts"
    case selectionStates = "Selection States"
    case contentVariants = "Content Variants"
    case interactionModes = "Interaction Modes"
}

final class PromotionSelectorBarViewSnapshotViewController: UIViewController {

    private let category: PromotionSelectorBarSnapshotCategory

    init(category: PromotionSelectorBarSnapshotCategory) {
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
        titleLabel.text = "PromotionSelectorBarView - \(category.rawValue)"
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
            stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])

        addVariants(to: stackView)
    }

    private func addVariants(to stackView: UIStackView) {
        switch category {
        case .basicLayouts:
            addBasicLayoutsVariants(to: stackView)
        case .selectionStates:
            addSelectionStatesVariants(to: stackView)
        case .contentVariants:
            addContentVariants(to: stackView)
        case .interactionModes:
            addInteractionModesVariants(to: stackView)
        }
    }

    // MARK: - Category Variants

    private func addBasicLayoutsVariants(to stackView: UIStackView) {
        // Two items
        stackView.addArrangedSubview(createLabeledVariant(
            label: "Two Items",
            view: createSelectorBar(items: [
                PromotionItemData(id: "1", title: "Sports", isSelected: true),
                PromotionItemData(id: "2", title: "Casino", isSelected: false)
            ], selectedId: "1")
        ))

        // Four items (fits on screen)
        stackView.addArrangedSubview(createLabeledVariant(
            label: "Four Items",
            view: createSelectorBar(items: [
                PromotionItemData(id: "1", title: "Welcome", isSelected: true),
                PromotionItemData(id: "2", title: "Sports", isSelected: false),
                PromotionItemData(id: "3", title: "Casino", isSelected: false),
                PromotionItemData(id: "4", title: "Bonuses", isSelected: false)
            ], selectedId: "1")
        ))

        // Six items (requires scrolling)
        stackView.addArrangedSubview(createLabeledVariant(
            label: "Six Items (Scrollable)",
            view: createSelectorBar(items: [
                PromotionItemData(id: "1", title: "Welcome", isSelected: true),
                PromotionItemData(id: "2", title: "Sports", isSelected: false),
                PromotionItemData(id: "3", title: "Casino", isSelected: false),
                PromotionItemData(id: "4", title: "Bonuses", isSelected: false),
                PromotionItemData(id: "5", title: "Live Casino", isSelected: false),
                PromotionItemData(id: "6", title: "Virtual", isSelected: false)
            ], selectedId: "1")
        ))
    }

    private func addSelectionStatesVariants(to stackView: UIStackView) {
        let baseItems = [
            PromotionItemData(id: "1", title: "Welcome", isSelected: false),
            PromotionItemData(id: "2", title: "Sports", isSelected: false),
            PromotionItemData(id: "3", title: "Casino", isSelected: false),
            PromotionItemData(id: "4", title: "Bonuses", isSelected: false)
        ]

        // First selected
        stackView.addArrangedSubview(createLabeledVariant(
            label: "First Selected",
            view: createSelectorBar(items: baseItems, selectedId: "1")
        ))

        // Middle selected
        stackView.addArrangedSubview(createLabeledVariant(
            label: "Middle Selected",
            view: createSelectorBar(items: baseItems, selectedId: "2")
        ))

        // Last selected
        stackView.addArrangedSubview(createLabeledVariant(
            label: "Last Selected",
            view: createSelectorBar(items: baseItems, selectedId: "4")
        ))

        // None selected
        stackView.addArrangedSubview(createLabeledVariant(
            label: "None Selected",
            view: createSelectorBar(items: baseItems, selectedId: nil)
        ))
    }

    private func addContentVariants(to stackView: UIStackView) {
        // Short titles
        stackView.addArrangedSubview(createLabeledVariant(
            label: "Short Titles",
            view: createSelectorBar(items: [
                PromotionItemData(id: "1", title: "All", isSelected: true),
                PromotionItemData(id: "2", title: "New", isSelected: false),
                PromotionItemData(id: "3", title: "Hot", isSelected: false)
            ], selectedId: "1")
        ))

        // Long titles
        stackView.addArrangedSubview(createLabeledVariant(
            label: "Long Titles",
            view: createSelectorBar(items: [
                PromotionItemData(id: "1", title: "Welcome Bonus", isSelected: true),
                PromotionItemData(id: "2", title: "Sports Promotions", isSelected: false),
                PromotionItemData(id: "3", title: "Casino Offers", isSelected: false)
            ], selectedId: "1")
        ))

        // Mixed lengths
        stackView.addArrangedSubview(createLabeledVariant(
            label: "Mixed Lengths",
            view: createSelectorBar(items: [
                PromotionItemData(id: "1", title: "All", isSelected: true),
                PromotionItemData(id: "2", title: "Sports Betting", isSelected: false),
                PromotionItemData(id: "3", title: "VIP", isSelected: false),
                PromotionItemData(id: "4", title: "Live Casino Games", isSelected: false)
            ], selectedId: "1")
        ))

        // With categories
        stackView.addArrangedSubview(createLabeledVariant(
            label: "With Categories",
            view: createSelectorBar(items: [
                PromotionItemData(id: "1", title: "Welcome", isSelected: true, category: "new-user"),
                PromotionItemData(id: "2", title: "Sports", isSelected: false, category: "sports"),
                PromotionItemData(id: "3", title: "Casino", isSelected: false, category: "casino")
            ], selectedId: "1")
        ))
    }

    private func addInteractionModesVariants(to stackView: UIStackView) {
        let items = [
            PromotionItemData(id: "1", title: "Welcome", isSelected: true),
            PromotionItemData(id: "2", title: "Sports", isSelected: false),
            PromotionItemData(id: "3", title: "Casino", isSelected: false)
        ]

        // Scroll enabled (default)
        stackView.addArrangedSubview(createLabeledVariant(
            label: "Scroll Enabled",
            view: createSelectorBar(
                items: items,
                selectedId: "1",
                isScrollEnabled: true
            )
        ))

        // Scroll disabled
        stackView.addArrangedSubview(createLabeledVariant(
            label: "Scroll Disabled",
            view: createSelectorBar(
                items: items,
                selectedId: "1",
                isScrollEnabled: false
            )
        ))

        // Read-only mode (visual changes disabled)
        stackView.addArrangedSubview(createLabeledVariant(
            label: "Read-Only Mode",
            view: createSelectorBar(
                items: items,
                selectedId: "1",
                allowsVisualStateChanges: false
            )
        ))

        // User interaction disabled
        let disabledBar = createSelectorBar(items: items, selectedId: "1")
        disabledBar.isUserInteractionEnabled = false
        disabledBar.alpha = 0.5
        stackView.addArrangedSubview(createLabeledVariant(
            label: "Interaction Disabled",
            view: disabledBar
        ))
    }

    // MARK: - Helper Methods

    private func createSelectorBar(
        items: [PromotionItemData],
        selectedId: String?,
        isScrollEnabled: Bool = true,
        allowsVisualStateChanges: Bool = true
    ) -> PromotionSelectorBarView {
        let barData = PromotionSelectorBarData(
            id: UUID().uuidString,
            promotionItems: items,
            selectedPromotionId: selectedId,
            isScrollEnabled: isScrollEnabled,
            allowsVisualStateChanges: allowsVisualStateChanges
        )
        let viewModel = MockPromotionSelectorBarViewModel(barData: barData)
        let selectorBar = PromotionSelectorBarView(viewModel: viewModel)
        selectorBar.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            selectorBar.heightAnchor.constraint(equalToConstant: 60)
        ])

        return selectorBar
    }

    private func createLabeledVariant(label: String, view: UIView) -> UIStackView {
        let labelView = UILabel()
        labelView.text = label
        labelView.font = StyleProvider.fontWith(type: .medium, size: 12)
        labelView.textColor = StyleProvider.Color.textSecondary
        labelView.translatesAutoresizingMaskIntoConstraints = false

        let container = UIView()
        container.translatesAutoresizingMaskIntoConstraints = false

        labelView.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(labelView)

        NSLayoutConstraint.activate([
            labelView.topAnchor.constraint(equalTo: container.topAnchor),
            labelView.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 16),
            labelView.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -16),
            labelView.bottomAnchor.constraint(equalTo: container.bottomAnchor)
        ])

        let stack = UIStackView(arrangedSubviews: [container, view])
        stack.axis = .vertical
        stack.spacing = 8
        stack.alignment = .fill
        return stack
    }
}

// MARK: - Preview
#if DEBUG
#Preview("Basic Layouts") {
    PromotionSelectorBarViewSnapshotViewController(category: .basicLayouts)
}

#Preview("Selection States") {
    PromotionSelectorBarViewSnapshotViewController(category: .selectionStates)
}

#Preview("Content Variants") {
    PromotionSelectorBarViewSnapshotViewController(category: .contentVariants)
}

#Preview("Interaction Modes") {
    PromotionSelectorBarViewSnapshotViewController(category: .interactionModes)
}
#endif
