import UIKit
import SwiftUI

// MARK: - Snapshot Category
enum TallOddsMatchCardSnapshotCategory: String, CaseIterable {
    case preLiveMatches = "Pre-Live Matches"
    case liveMatchStates = "Live Match States"
    case leagueVariants = "League Variants"
    case outcomesConfigurations = "Outcomes Configurations"
}

final class TallOddsMatchCardViewSnapshotViewController: UIViewController {

    private let category: TallOddsMatchCardSnapshotCategory

    init(category: TallOddsMatchCardSnapshotCategory) {
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
        titleLabel.text = "TallOddsMatchCardView - \(category.rawValue)"
        titleLabel.font = StyleProvider.fontWith(type: .bold, size: 16)
        titleLabel.textColor = StyleProvider.Color.textPrimary
        titleLabel.translatesAutoresizingMaskIntoConstraints = false

        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false

        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 20
        stackView.alignment = .fill
        stackView.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(titleLabel)
        view.addSubview(scrollView)
        scrollView.addSubview(stackView)

        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),

            scrollView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 16),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            stackView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            stackView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: 16),
            stackView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor, constant: -16),
            stackView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor, constant: -16),
            stackView.widthAnchor.constraint(equalTo: scrollView.widthAnchor, constant: -32)
        ])

        addVariants(to: stackView)
    }

    private func addVariants(to stackView: UIStackView) {
        switch category {
        case .preLiveMatches:
            addPreLiveMatchesVariants(to: stackView)
        case .liveMatchStates:
            addLiveMatchStatesVariants(to: stackView)
        case .leagueVariants:
            addLeagueVariants(to: stackView)
        case .outcomesConfigurations:
            addOutcomesConfigurationsVariants(to: stackView)
        }
    }

    // MARK: - Category Variants

    private func addPreLiveMatchesVariants(to stackView: UIStackView) {
        stackView.addArrangedSubview(createLabeledVariant(
            label: "Premier League (Pre-Live)",
            view: createCardView(viewModel: MockTallOddsMatchCardViewModel.premierLeagueMock)
        ))
        stackView.addArrangedSubview(createLabeledVariant(
            label: "La Liga (Compact)",
            view: createCardView(viewModel: MockTallOddsMatchCardViewModel.compactMock)
        ))
    }

    private func addLiveMatchStatesVariants(to stackView: UIStackView) {
        stackView.addArrangedSubview(createLabeledVariant(
            label: "Live Match with Score",
            view: createCardView(viewModel: MockTallOddsMatchCardViewModel.liveMock)
        ))
        stackView.addArrangedSubview(createLabeledVariant(
            label: "Live Match (Single Line Outcomes)",
            view: createCardView(viewModel: MockTallOddsMatchCardViewModel.liveMock(singleLineOutcomes: true))
        ))
    }

    private func addLeagueVariants(to stackView: UIStackView) {
        stackView.addArrangedSubview(createLabeledVariant(
            label: "Premier League",
            view: createCardView(viewModel: MockTallOddsMatchCardViewModel.premierLeagueMock)
        ))
        stackView.addArrangedSubview(createLabeledVariant(
            label: "Bundesliga",
            view: createCardView(viewModel: MockTallOddsMatchCardViewModel.bundesliegaMock)
        ))
        stackView.addArrangedSubview(createLabeledVariant(
            label: "La Liga",
            view: createCardView(viewModel: MockTallOddsMatchCardViewModel.compactMock)
        ))
    }

    private func addOutcomesConfigurationsVariants(to stackView: UIStackView) {
        stackView.addArrangedSubview(createLabeledVariant(
            label: "Multi-Line Outcomes (Default)",
            view: createCardView(viewModel: MockTallOddsMatchCardViewModel.premierLeagueMock(singleLineOutcomes: false))
        ))
        stackView.addArrangedSubview(createLabeledVariant(
            label: "Single-Line Outcomes",
            view: createCardView(viewModel: MockTallOddsMatchCardViewModel.premierLeagueMock(singleLineOutcomes: true))
        ))
        stackView.addArrangedSubview(createLabeledVariant(
            label: "Bundesliga Multi-Line",
            view: createCardView(viewModel: MockTallOddsMatchCardViewModel.bundesliegaMock(singleLineOutcomes: false))
        ))
    }

    // MARK: - Helper Methods

    private func createCardView(viewModel: MockTallOddsMatchCardViewModel) -> TallOddsMatchCardView {
        let cardView = TallOddsMatchCardView(viewModel: viewModel)
        cardView.translatesAutoresizingMaskIntoConstraints = false
        return cardView
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
        return stack
    }
}

// MARK: - Preview
#if DEBUG
#Preview("Pre-Live Matches") {
    TallOddsMatchCardViewSnapshotViewController(category: .preLiveMatches)
}

#Preview("Live Match States") {
    TallOddsMatchCardViewSnapshotViewController(category: .liveMatchStates)
}

#Preview("League Variants") {
    TallOddsMatchCardViewSnapshotViewController(category: .leagueVariants)
}

#Preview("Outcomes Configurations") {
    TallOddsMatchCardViewSnapshotViewController(category: .outcomesConfigurations)
}
#endif
