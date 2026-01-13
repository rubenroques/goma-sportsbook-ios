import UIKit
import SwiftUI

// MARK: - Snapshot Category
enum MarketGroupSelectorTabSnapshotCategory: String, CaseIterable {
    case basicLayouts = "Basic Layouts"
    case selectionStates = "Selection States"
    case contentVariants = "Content Variants"
    case layoutModes = "Layout Modes"
}

final class MarketGroupSelectorTabViewSnapshotViewController: UIViewController {

    private let category: MarketGroupSelectorTabSnapshotCategory

    init(category: MarketGroupSelectorTabSnapshotCategory) {
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
        titleLabel.text = "MarketGroupSelectorTabView - \(category.rawValue)"
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
        case .layoutModes:
            addLayoutModesVariants(to: stackView)
        }
    }

    // MARK: - Category Variants

    private func addBasicLayoutsVariants(to stackView: UIStackView) {
        stackView.addArrangedSubview(createLabeledVariant(
            label: "Standard Sports Markets",
            view: createTabView(viewModel: MockMarketGroupSelectorTabViewModel.standardSportsMarkets)
        ))
        stackView.addArrangedSubview(createLabeledVariant(
            label: "Limited Markets (2 tabs)",
            view: createTabView(viewModel: MockMarketGroupSelectorTabViewModel.limitedMarkets)
        ))
        stackView.addArrangedSubview(createLabeledVariant(
            label: "Empty State",
            view: createTabView(viewModel: MockMarketGroupSelectorTabViewModel.emptyMarkets)
        ))
    }

    private func addSelectionStatesVariants(to stackView: UIStackView) {
        stackView.addArrangedSubview(createLabeledVariant(
            label: "First Tab Selected",
            view: createTabView(viewModel: MockMarketGroupSelectorTabViewModel.standardSportsMarkets)
        ))
        stackView.addArrangedSubview(createLabeledVariant(
            label: "No Selection (Disabled)",
            view: createTabView(viewModel: MockMarketGroupSelectorTabViewModel.disabledMarkets)
        ))
        stackView.addArrangedSubview(createLabeledVariant(
            label: "Mixed State Markets",
            view: createTabView(viewModel: MockMarketGroupSelectorTabViewModel.mixedStateMarkets)
        ))
    }

    private func addContentVariants(to stackView: UIStackView) {
        stackView.addArrangedSubview(createLabeledVariant(
            label: "Market Category Tabs (with badges)",
            view: createTabView(viewModel: MockMarketGroupSelectorTabViewModel.marketCategoryTabs)
        ))

        // Custom tabs with icons and badges
        let iconTabs = [
            MarketGroupTabItemData(
                id: "live",
                title: LocalizationProvider.string("live"),
                visualState: .selected,
                prefixIconTypeName: "flame",
                suffixIconTypeName: nil,
                badgeCount: 3
            ),
            MarketGroupTabItemData(
                id: "popular",
                title: LocalizationProvider.string("popular_string"),
                visualState: .idle,
                prefixIconTypeName: "star",
                suffixIconTypeName: nil,
                badgeCount: 12
            ),
            MarketGroupTabItemData(
                id: "games",
                title: "Games",
                visualState: .idle,
                prefixIconTypeName: nil,
                suffixIconTypeName: "gamecontroller",
                badgeCount: nil
            )
        ]
        let iconViewModel = MockMarketGroupSelectorTabViewModel.customMarkets(
            id: "iconTabs",
            marketGroups: iconTabs,
            selectedMarketGroupId: "live"
        )
        stackView.addArrangedSubview(createLabeledVariant(
            label: "Tabs with Icons",
            view: createTabView(viewModel: iconViewModel)
        ))
    }

    private func addLayoutModesVariants(to stackView: UIStackView) {
        stackView.addArrangedSubview(createLabeledVariant(
            label: "Automatic Layout (scrollable)",
            view: createTabView(
                viewModel: MockMarketGroupSelectorTabViewModel.standardSportsMarkets,
                layoutMode: .automatic
            )
        ))
        stackView.addArrangedSubview(createLabeledVariant(
            label: "Stretch Layout (2 tabs)",
            view: createTabView(
                viewModel: MockMarketGroupSelectorTabViewModel.limitedMarkets,
                layoutMode: .stretch
            )
        ))
        stackView.addArrangedSubview(createLabeledVariant(
            label: "Stretch Layout (4 tabs)",
            view: createTabView(
                viewModel: MockMarketGroupSelectorTabViewModel.standardSportsMarkets,
                layoutMode: .stretch
            )
        ))
    }

    // MARK: - Helper Methods

    private func createTabView(
        viewModel: MockMarketGroupSelectorTabViewModel,
        layoutMode: MarketGroupSelectorTabLayoutMode = .automatic
    ) -> MarketGroupSelectorTabView {
        let tabView = MarketGroupSelectorTabView(
            viewModel: viewModel,
            layoutMode: layoutMode
        )
        tabView.translatesAutoresizingMaskIntoConstraints = false
        return tabView
    }

    private func createLabeledVariant(label: String, view: UIView) -> UIStackView {
        let labelView = UILabel()
        labelView.text = label
        labelView.font = StyleProvider.fontWith(type: .medium, size: 12)
        labelView.textColor = StyleProvider.Color.textSecondary

        let stack = UIStackView(arrangedSubviews: [labelView, view])
        stack.axis = .vertical
        stack.spacing = 8
        stack.alignment = .fill
        stack.layoutMargins = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        stack.isLayoutMarginsRelativeArrangement = true
        return stack
    }
}

// MARK: - Preview
#if DEBUG
#Preview("Basic Layouts") {
    MarketGroupSelectorTabViewSnapshotViewController(category: .basicLayouts)
}

#Preview("Selection States") {
    MarketGroupSelectorTabViewSnapshotViewController(category: .selectionStates)
}

#Preview("Content Variants") {
    MarketGroupSelectorTabViewSnapshotViewController(category: .contentVariants)
}

#Preview("Layout Modes") {
    MarketGroupSelectorTabViewSnapshotViewController(category: .layoutModes)
}
#endif
