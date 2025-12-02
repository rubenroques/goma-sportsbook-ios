import UIKit
import Combine
import GomaUI

/// Demo ViewController for InlineScoreView showing different sport formats
final class InlineScoreViewController: UIViewController {

    // MARK: - Constants

    private enum Constants {
        static let padding: CGFloat = 16
        static let spacing: CGFloat = 20
    }

    // MARK: - Properties

    private var cancellables = Set<AnyCancellable>()

    private var footballVM: MockInlineScoreViewModel!
    private var tennisVM: MockInlineScoreViewModel!
    private var basketballVM: MockInlineScoreViewModel!

    // MARK: - UI Components

    private lazy var scrollView: UIScrollView = Self.createScrollView()
    private lazy var stackView: UIStackView = Self.createStackView()

    private var footballScoreView: InlineScoreView!
    private var tennisScoreView: InlineScoreView!
    private var basketballScoreView: InlineScoreView!

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigation()
        setupViews()
        setupConstraints()
        setupComponents()
        setupControls()
    }

    // MARK: - Setup

    private func setupNavigation() {
        title = "Inline Score View"
        navigationController?.navigationBar.prefersLargeTitles = false
        view.backgroundColor = StyleProvider.Color.backgroundPrimary
    }

    private func setupViews() {
        view.addSubview(scrollView)
        scrollView.addSubview(stackView)
    }

    private func setupConstraints() {
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        stackView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            stackView.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: Constants.padding),
            stackView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: Constants.padding),
            stackView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor, constant: -Constants.padding),
            stackView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor, constant: -Constants.padding),
            stackView.widthAnchor.constraint(equalTo: scrollView.widthAnchor, constant: -2 * Constants.padding)
        ])
    }

    private func setupComponents() {
        // Football
        addSection(title: "Football", description: "Single score column with both highlight") {
            self.footballVM = MockInlineScoreViewModel.footballMatch
            self.footballScoreView = InlineScoreView(viewModel: self.footballVM)
            return self.footballScoreView
        }

        // Tennis
        addSection(title: "Tennis", description: "Multiple columns: Sets + Current Game") {
            self.tennisVM = MockInlineScoreViewModel.tennisMatch
            self.tennisScoreView = InlineScoreView(viewModel: self.tennisVM)
            return self.tennisScoreView
        }

        // Basketball
        addSection(title: "Basketball", description: "Quarters with different highlighting") {
            self.basketballVM = MockInlineScoreViewModel.basketballMatch
            self.basketballScoreView = InlineScoreView(viewModel: self.basketballVM)
            return self.basketballScoreView
        }

        // Hidden state
        addSection(title: "Hidden State", description: "Score view when not visible (pre-live)") {
            let vm = MockInlineScoreViewModel.hidden
            return InlineScoreView(viewModel: vm)
        }
    }

    private func setupControls() {
        addSeparator()

        // Controls title
        let controlsTitle = UILabel()
        controlsTitle.text = "Interactive Controls"
        controlsTitle.font = StyleProvider.fontWith(type: .semibold, size: 18)
        controlsTitle.textColor = StyleProvider.Color.textPrimary
        stackView.addArrangedSubview(controlsTitle)

        // Update Football Score button
        let updateFootballButton = createButton(title: "Update Football Score (Random)")
        updateFootballButton.addTarget(self, action: #selector(updateFootballScore), for: .touchUpInside)
        stackView.addArrangedSubview(updateFootballButton)

        // Update Tennis Score button
        let updateTennisButton = createButton(title: "Update Tennis Score (Random)")
        updateTennisButton.addTarget(self, action: #selector(updateTennisScore), for: .touchUpInside)
        stackView.addArrangedSubview(updateTennisButton)

        // Clear All button
        let clearButton = createButton(title: "Clear All Scores", color: .systemOrange)
        clearButton.addTarget(self, action: #selector(clearAllScores), for: .touchUpInside)
        stackView.addArrangedSubview(clearButton)

        // Reset All button
        let resetButton = createButton(title: "Reset to Default", color: .systemGreen)
        resetButton.addTarget(self, action: #selector(resetAllScores), for: .touchUpInside)
        stackView.addArrangedSubview(resetButton)
    }

    // MARK: - Helpers

    private func addSection(title: String, description: String, componentFactory: () -> UIView) {
        // Title
        let titleLabel = UILabel()
        titleLabel.text = title
        titleLabel.font = StyleProvider.fontWith(type: .semibold, size: 18)
        titleLabel.textColor = StyleProvider.Color.textPrimary
        stackView.addArrangedSubview(titleLabel)

        // Description
        let descLabel = UILabel()
        descLabel.text = description
        descLabel.font = StyleProvider.fontWith(type: .regular, size: 14)
        descLabel.textColor = StyleProvider.Color.textSecondary
        descLabel.numberOfLines = 0
        stackView.addArrangedSubview(descLabel)

        // Container with component
        let container = UIView()
        container.backgroundColor = StyleProvider.Color.backgroundSecondary
        container.layer.cornerRadius = 8

        let component = componentFactory()
        component.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(component)

        NSLayoutConstraint.activate([
            component.topAnchor.constraint(equalTo: container.topAnchor, constant: 16),
            component.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 16),
            component.trailingAnchor.constraint(lessThanOrEqualTo: container.trailingAnchor, constant: -16),
            component.bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: -16)
        ])

        stackView.addArrangedSubview(container)
    }

    private func addSeparator() {
        let separator = UIView()
        separator.backgroundColor = StyleProvider.Color.separatorLine
        separator.heightAnchor.constraint(equalToConstant: 1).isActive = true
        stackView.addArrangedSubview(separator)
    }

    private func createButton(title: String, color: UIColor = StyleProvider.Color.highlightPrimary) -> UIButton {
        let button = UIButton(type: .system)
        button.setTitle(title, for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = color
        button.layer.cornerRadius = 8
        button.titleLabel?.font = StyleProvider.fontWith(type: .semibold, size: 16)
        button.heightAnchor.constraint(equalToConstant: 44).isActive = true
        return button
    }

    // MARK: - Actions

    @objc private func updateFootballScore() {
        let homeScore = String(Int.random(in: 0...5))
        let awayScore = String(Int.random(in: 0...5))

        footballVM.updateColumns([
            InlineScoreColumnData(
                id: "score",
                homeScore: homeScore,
                awayScore: awayScore,
                highlightingMode: .bothHighlight
            )
        ])

        print("[Demo] Football score updated: \(homeScore)-\(awayScore)")
    }

    @objc private func updateTennisScore() {
        let homeSets = Int.random(in: 0...2)
        let awaySets = Int.random(in: 0...2)
        let homeGame = ["0", "15", "30", "40", "AD"].randomElement()!
        let awayGame = ["0", "15", "30", "40", "AD"].randomElement()!

        tennisVM.updateColumns([
            InlineScoreColumnData(
                id: "sets",
                homeScore: "\(homeSets)",
                awayScore: "\(awaySets)",
                highlightingMode: .winnerLoser,
                showsTrailingSeparator: true
            ),
            InlineScoreColumnData(
                id: "game",
                homeScore: homeGame,
                awayScore: awayGame,
                highlightingMode: .bothHighlight
            )
        ])

        print("[Demo] Tennis score updated: Sets \(homeSets)-\(awaySets), Game \(homeGame)-\(awayGame)")
    }

    @objc private func clearAllScores() {
        footballVM.clearScores()
        tennisVM.clearScores()
        basketballVM.clearScores()
        print("[Demo] All scores cleared")
    }

    @objc private func resetAllScores() {
        // Recreate with default values
        footballVM.updateColumns([
            InlineScoreColumnData(id: "score", homeScore: "2", awayScore: "1", highlightingMode: .bothHighlight)
        ])

        tennisVM.updateColumns([
            InlineScoreColumnData(id: "sets", homeScore: "1", awayScore: "0", highlightingMode: .winnerLoser, showsTrailingSeparator: true),
            InlineScoreColumnData(id: "game", homeScore: "30", awayScore: "15", highlightingMode: .bothHighlight)
        ])

        basketballVM.updateColumns([
            InlineScoreColumnData(id: "q1", homeScore: "24", awayScore: "21", highlightingMode: .noHighlight, showsTrailingSeparator: true),
            InlineScoreColumnData(id: "q2", homeScore: "28", awayScore: "25", highlightingMode: .noHighlight, showsTrailingSeparator: true),
            InlineScoreColumnData(id: "total", homeScore: "52", awayScore: "46", highlightingMode: .bothHighlight)
        ])

        print("[Demo] All scores reset to default")
    }

    // MARK: - Factory Methods

    private static func createScrollView() -> UIScrollView {
        let scrollView = UIScrollView()
        scrollView.showsVerticalScrollIndicator = true
        scrollView.alwaysBounceVertical = true
        return scrollView
    }

    private static func createStackView() -> UIStackView {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = Constants.spacing
        stackView.alignment = .fill
        return stackView
    }
}
