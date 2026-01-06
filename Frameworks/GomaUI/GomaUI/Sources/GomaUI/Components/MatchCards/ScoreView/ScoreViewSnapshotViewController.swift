import UIKit

// MARK: - Snapshot Category
enum ScoreViewSnapshotCategory: String, CaseIterable {
    case sportVariants = "Sport Variants"
    case visualStates = "Visual States"
    case styleVariants = "Style Variants"
}

final class ScoreViewSnapshotViewController: UIViewController {

    private let category: ScoreViewSnapshotCategory

    init(category: ScoreViewSnapshotCategory) {
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
        titleLabel.text = "ScoreView - \(category.rawValue)"
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
        case .sportVariants:
            addSportVariants(to: stackView)
        case .visualStates:
            addVisualStates(to: stackView)
        case .styleVariants:
            addStyleVariants(to: stackView)
        }
    }

    // MARK: - Category Variants

    private func addSportVariants(to stackView: UIStackView) {
        // Tennis Match
        stackView.addArrangedSubview(createLabeledVariant(
            label: "Tennis Match",
            view: createScoreView(viewModel: MockScoreViewModel.tennisMatch)
        ))

        // Tennis Advantage
        stackView.addArrangedSubview(createLabeledVariant(
            label: "Tennis Advantage",
            view: createScoreView(viewModel: MockScoreViewModel.tennisAdvantage)
        ))

        // Basketball Match
        stackView.addArrangedSubview(createLabeledVariant(
            label: "Basketball Match",
            view: createScoreView(viewModel: MockScoreViewModel.basketballMatch)
        ))

        // Football Match
        stackView.addArrangedSubview(createLabeledVariant(
            label: "Football Match",
            view: createScoreView(viewModel: MockScoreViewModel.footballMatch)
        ))

        // Hockey Match
        stackView.addArrangedSubview(createLabeledVariant(
            label: "Hockey Match",
            view: createScoreView(viewModel: MockScoreViewModel.hockeyMatch)
        ))
    }

    private func addVisualStates(to stackView: UIStackView) {
        // Display State
        stackView.addArrangedSubview(createLabeledVariant(
            label: "Display State",
            view: createScoreView(viewModel: MockScoreViewModel.simpleExample)
        ))

        // Empty State
        stackView.addArrangedSubview(createLabeledVariant(
            label: "Empty State",
            view: createScoreView(viewModel: MockScoreViewModel.empty)
        ))

        // Idle State
        stackView.addArrangedSubview(createLabeledVariant(
            label: "Idle State",
            view: createScoreView(viewModel: MockScoreViewModel.idle)
        ))
    }

    private func addStyleVariants(to stackView: UIStackView) {
        // Simple Style
        let simpleVM = MockScoreViewModel(scoreCells: [
            ScoreDisplayData(id: "s1", homeScore: "6", awayScore: "4", style: .simple),
            ScoreDisplayData(id: "s2", homeScore: "3", awayScore: "6", style: .simple)
        ], visualState: .display)
        stackView.addArrangedSubview(createLabeledVariant(
            label: "Simple Style",
            view: createScoreView(viewModel: simpleVM)
        ))

        // Border Style
        let borderVM = MockScoreViewModel(scoreCells: [
            ScoreDisplayData(id: "b1", homeScore: "25", awayScore: "23", style: .border),
            ScoreDisplayData(id: "b2", homeScore: "21", awayScore: "25", style: .border)
        ], visualState: .display)
        stackView.addArrangedSubview(createLabeledVariant(
            label: "Border Style",
            view: createScoreView(viewModel: borderVM)
        ))

        // Background Style
        let backgroundVM = MockScoreViewModel(scoreCells: [
            ScoreDisplayData(id: "bg1", homeScore: "100", awayScore: "98", style: .background),
            ScoreDisplayData(id: "bg2", homeScore: "89", awayScore: "112", style: .background)
        ], visualState: .display)
        stackView.addArrangedSubview(createLabeledVariant(
            label: "Background Style",
            view: createScoreView(viewModel: backgroundVM)
        ))

        // Mixed Styles
        stackView.addArrangedSubview(createLabeledVariant(
            label: "Mixed Styles",
            view: createScoreView(viewModel: MockScoreViewModel.mixedStyles)
        ))
    }

    // MARK: - Helper Methods

    private func createScoreView(viewModel: MockScoreViewModel) -> ScoreView {
        let scoreView = ScoreView()
        scoreView.configure(with: viewModel)
        scoreView.translatesAutoresizingMaskIntoConstraints = false
        return scoreView
    }

    private func createLabeledVariant(label: String, view: UIView) -> UIStackView {
        let labelView = UILabel()
        labelView.text = label
        labelView.font = StyleProvider.fontWith(type: .medium, size: 12)
        labelView.textColor = StyleProvider.Color.textSecondary

        let containerView = UIView()
        containerView.backgroundColor = StyleProvider.Color.backgroundSecondary
        containerView.layer.cornerRadius = 8
        containerView.translatesAutoresizingMaskIntoConstraints = false

        containerView.addSubview(view)

        NSLayoutConstraint.activate([
            view.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 12),
            view.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -12),
            view.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -12),
            view.leadingAnchor.constraint(greaterThanOrEqualTo: containerView.leadingAnchor, constant: 12),
            containerView.heightAnchor.constraint(greaterThanOrEqualToConstant: 50)
        ])

        let stack = UIStackView(arrangedSubviews: [labelView, containerView])
        stack.axis = .vertical
        stack.spacing = 6
        stack.alignment = .fill
        return stack
    }
}

// MARK: - Preview
#if DEBUG
@available(iOS 17.0, *)
#Preview("Sport Variants") {
    ScoreViewSnapshotViewController(category: .sportVariants)
}

@available(iOS 17.0, *)
#Preview("Visual States") {
    ScoreViewSnapshotViewController(category: .visualStates)
}

@available(iOS 17.0, *)
#Preview("Style Variants") {
    ScoreViewSnapshotViewController(category: .styleVariants)
}
#endif
