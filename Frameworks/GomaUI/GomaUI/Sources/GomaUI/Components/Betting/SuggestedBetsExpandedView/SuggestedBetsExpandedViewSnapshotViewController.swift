import UIKit
import SwiftUI

// MARK: - Snapshot Category
enum SuggestedBetsExpandedSnapshotCategory: String, CaseIterable {
    case expandedState = "Expanded State"
    case collapsedState = "Collapsed State"
    case multipleCards = "Multiple Cards"
}

final class SuggestedBetsExpandedViewSnapshotViewController: UIViewController {

    private let category: SuggestedBetsExpandedSnapshotCategory

    init(category: SuggestedBetsExpandedSnapshotCategory) {
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
        titleLabel.text = "SuggestedBetsExpandedView - \(category.rawValue)"
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
        case .expandedState:
            addExpandedStateVariants(to: stackView)
        case .collapsedState:
            addCollapsedStateVariants(to: stackView)
        case .multipleCards:
            addMultipleCardsVariants(to: stackView)
        }
    }

    // MARK: - Category Variants

    private func addExpandedStateVariants(to stackView: UIStackView) {
        // Single card expanded
        stackView.addArrangedSubview(createLabeledVariant(
            label: "Single Card (Expanded)",
            view: createSuggestedBetsView(
                title: "Explore More Bets",
                isExpanded: true,
                matchCards: [.premierLeagueMock(singleLineOutcomes: true)]
            )
        ))

        // Multiple cards expanded
        stackView.addArrangedSubview(createLabeledVariant(
            label: "Two Cards (Expanded)",
            view: createSuggestedBetsView(
                title: "Popular Bets",
                isExpanded: true,
                matchCards: [
                    .premierLeagueMock(singleLineOutcomes: true),
                    .liveMock(singleLineOutcomes: true)
                ]
            )
        ))
    }

    private func addCollapsedStateVariants(to stackView: UIStackView) {
        // Collapsed with single card
        stackView.addArrangedSubview(createLabeledVariant(
            label: "Single Card (Collapsed)",
            view: createSuggestedBetsView(
                title: "Explore More Bets",
                isExpanded: false,
                matchCards: [.premierLeagueMock(singleLineOutcomes: true)]
            )
        ))

        // Collapsed with multiple cards
        stackView.addArrangedSubview(createLabeledVariant(
            label: "Multiple Cards (Collapsed)",
            view: createSuggestedBetsView(
                title: "Top Picks",
                isExpanded: false,
                matchCards: [
                    .premierLeagueMock(singleLineOutcomes: true),
                    .liveMock(singleLineOutcomes: true),
                    .compactMock(singleLineOutcomes: true)
                ]
            )
        ))
    }

    private func addMultipleCardsVariants(to stackView: UIStackView) {
        // Three cards showing page control
        stackView.addArrangedSubview(createLabeledVariant(
            label: "Three Cards with Page Control",
            view: createSuggestedBetsView(
                title: "Suggested Bets",
                isExpanded: true,
                matchCards: [
                    .premierLeagueMock(singleLineOutcomes: true),
                    .liveMock(singleLineOutcomes: true),
                    .bundesliegaMock(singleLineOutcomes: true)
                ]
            )
        ))

        // Four cards (demo preset)
        stackView.addArrangedSubview(createLabeledVariant(
            label: "Four Cards (Demo)",
            view: createSuggestedBetsViewFromMock(.demo)
        ))
    }

    // MARK: - Helper Methods

    private func createSuggestedBetsView(
        title: String,
        isExpanded: Bool,
        matchCards: [MockTallOddsMatchCardViewModel]
    ) -> UIView {
        let viewModel = MockSuggestedBetsExpandedViewModel(
            title: title,
            isExpanded: isExpanded,
            isVisible: true,
            initialPage: 0,
            matchCardViewModels: matchCards
        )
        return createViewWithViewModel(viewModel)
    }

    private func createSuggestedBetsViewFromMock(_ mock: MockSuggestedBetsExpandedViewModel) -> UIView {
        return createViewWithViewModel(mock)
    }

    private func createViewWithViewModel(_ viewModel: MockSuggestedBetsExpandedViewModel) -> UIView {
        let suggestedBetsView = SuggestedBetsExpandedView(viewModel: viewModel)
        suggestedBetsView.translatesAutoresizingMaskIntoConstraints = false

        let containerView = UIView()
        containerView.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(suggestedBetsView)

        NSLayoutConstraint.activate([
            suggestedBetsView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            suggestedBetsView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            suggestedBetsView.topAnchor.constraint(equalTo: containerView.topAnchor),
            suggestedBetsView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor)
        ])

        return containerView
    }

    private func createLabeledVariant(label: String, view: UIView) -> UIStackView {
        let labelView = UILabel()
        labelView.text = label
        labelView.font = StyleProvider.fontWith(type: .medium, size: 12)
        labelView.textColor = StyleProvider.Color.textSecondary
        labelView.translatesAutoresizingMaskIntoConstraints = false

        let labelContainer = UIView()
        labelContainer.addSubview(labelView)
        NSLayoutConstraint.activate([
            labelView.leadingAnchor.constraint(equalTo: labelContainer.leadingAnchor, constant: 16),
            labelView.trailingAnchor.constraint(equalTo: labelContainer.trailingAnchor, constant: -16),
            labelView.topAnchor.constraint(equalTo: labelContainer.topAnchor),
            labelView.bottomAnchor.constraint(equalTo: labelContainer.bottomAnchor)
        ])

        let stack = UIStackView(arrangedSubviews: [labelContainer, view])
        stack.axis = .vertical
        stack.spacing = 8
        stack.alignment = .fill
        return stack
    }
}

// MARK: - Preview
#if DEBUG
#Preview("Expanded State") {
    SuggestedBetsExpandedViewSnapshotViewController(category: .expandedState)
}

#Preview("Collapsed State") {
    SuggestedBetsExpandedViewSnapshotViewController(category: .collapsedState)
}

#Preview("Multiple Cards") {
    SuggestedBetsExpandedViewSnapshotViewController(category: .multipleCards)
}
#endif
