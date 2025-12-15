import UIKit
import GomaUI

/// Comprehensive demo showing all combinations of ScoreCellStyle and HighlightingMode
class ScoreStylesViewController: UIViewController {

    // MARK: - Private Properties
    private lazy var scrollView: UIScrollView = Self.createScrollView()
    private lazy var stackView: UIStackView = Self.createStackView()

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "ScoreView Styles & Highlighting"
        setupViews()
        setupConstraints()
        populateExamples()
    }

    // MARK: - Setup
    private func setupViews() {
        view.backgroundColor = .backgroundTestColor
        view.addSubview(scrollView)
        scrollView.addSubview(stackView)
    }

    private func setupConstraints() {
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            stackView.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: 20),
            stackView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: 16),
            stackView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor, constant: -16),
            stackView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor, constant: -20),
            stackView.widthAnchor.constraint(equalTo: scrollView.widthAnchor, constant: -32)
        ])
    }

    private func populateExamples() {
        // Introduction
        addIntroduction()

        // Part 1: ScoreCellStyle Dimension
        addSectionHeader("Part 1: ScoreCellStyle (Container Appearance)")
        addExplanationLabel("Controls the visual container: border, background, or plain")
        addStyleExamples()

        // Part 2: HighlightingMode Dimension
        addSectionHeader("Part 2: HighlightingMode (Text Color Logic)")
        addExplanationLabel("Controls text colors based on score comparison")
        addHighlightingExamples()

        // Part 3: Combined Examples
        addSectionHeader("Part 3: Style + Highlighting Combinations")
        addExplanationLabel("Each style can work with any highlighting mode")
        addCombinedExamples()

        // Part 4: Real-World Tennis Example
        addSectionHeader("Part 4: Real-World Tennis Match")
        addExplanationLabel("How these combine in a practical tennis match display")
        addTennisExample()

        // Part 5: Real-World Basketball Example
        addSectionHeader("Part 5: Real-World Basketball Match")
        addExplanationLabel("How these combine in a practical basketball match display")
        addBasketballExample()

        // Summary
        addSummarySection()
    }

    // MARK: - Introduction
    private func addIntroduction() {
        let intro = createDescriptionLabel(
            "ScoreView has two independent styling dimensions:\n\n" +
            "1. ScoreCellStyle - Container appearance (border/background/plain)\n" +
            "2. HighlightingMode - Text color logic (winner/loser, both, none)\n\n" +
            "These work together to create flexible score displays."
        )
        intro.font = StyleProvider.fontWith(type: .medium, size: 15)
        stackView.addArrangedSubview(intro)
        addSpacer(height: 12)
    }

    // MARK: - Part 1: ScoreCellStyle Examples
    private func addStyleExamples() {
        // Simple Style
        addSubsectionLabel("Simple Style")
        addExample(
            title: "Plain container, no border, no background",
            description: "Width: 26pt, transparent background",
            scoreCells: [
                ScoreDisplayData(id: "1", homeScore: "6", awayScore: "4", style: .simple, highlightingMode: .noHighlight)
            ]
        )

        // Border Style
        addSubsectionLabel("Border Style")
        addExample(
            title: "1pt border outline in highlightPrimary color",
            description: "Width: 26pt, transparent background, bordered",
            scoreCells: [
                ScoreDisplayData(id: "2", homeScore: "25", awayScore: "22", style: .border, highlightingMode: .noHighlight)
            ]
        )

        // Background Style
        addSubsectionLabel("Background Style")
        addExample(
            title: "Filled background in backgroundPrimary color",
            description: "Width: 29pt (slightly wider), filled background",
            scoreCells: [
                ScoreDisplayData(id: "3", homeScore: "105", awayScore: "98", style: .background, highlightingMode: .noHighlight)
            ]
        )

        addSpacer(height: 8)
    }

    // MARK: - Part 2: HighlightingMode Examples
    private func addHighlightingExamples() {
        // Winner/Loser Highlighting
        addSubsectionLabel("Winner/Loser Highlighting")
        addExample(
            title: "Winner: black (textPrimary), Loser: gray (textSecondary)",
            description: "Used for completed sets/quarters - compares scores",
            scoreCells: [
                ScoreDisplayData(id: "4", homeScore: "6", awayScore: "4", style: .simple, highlightingMode: .winnerLoser),
                ScoreDisplayData(id: "5", homeScore: "3", awayScore: "6", style: .simple, highlightingMode: .winnerLoser),
                ScoreDisplayData(id: "6", homeScore: "5", awayScore: "5", style: .simple, highlightingMode: .winnerLoser)
            ]
        )
        addDetailLabel("Left: Home wins (6>4), Middle: Away wins (6>3), Right: Tied (5=5)")

        // Both Highlight
        addSubsectionLabel("Both Highlight")
        addExample(
            title: "Both scores: orange (highlightPrimary)",
            description: "Used for current game/set and match totals",
            scoreCells: [
                ScoreDisplayData(id: "7", homeScore: "30", awayScore: "15", style: .simple, highlightingMode: .bothHighlight),
                ScoreDisplayData(id: "8", homeScore: "7", awayScore: "6", style: .simple, highlightingMode: .bothHighlight)
            ]
        )
        addDetailLabel("Both scores highlighted regardless of winner")

        // No Highlight
        addSubsectionLabel("No Highlight")
        addExample(
            title: "Both scores: black (textPrimary)",
            description: "Default colors, no special highlighting",
            scoreCells: [
                ScoreDisplayData(id: "9", homeScore: "2", awayScore: "1", style: .simple, highlightingMode: .noHighlight),
                ScoreDisplayData(id: "10", homeScore: "0", awayScore: "3", style: .simple, highlightingMode: .noHighlight)
            ]
        )
        addDetailLabel("No color differentiation for winners")

        addSpacer(height: 8)
    }

    // MARK: - Part 3: Combined Examples
    private func addCombinedExamples() {
        // Simple + All Highlighting Modes
        addSubsectionLabel("Simple Style × All Highlighting Modes")
        addExample(
            title: "Simple container with different highlighting",
            description: "Left: winnerLoser, Middle: bothHighlight, Right: noHighlight",
            scoreCells: [
                ScoreDisplayData(id: "11", homeScore: "6", awayScore: "4", style: .simple, highlightingMode: .winnerLoser),
                ScoreDisplayData(id: "12", homeScore: "7", awayScore: "6", style: .simple, highlightingMode: .bothHighlight),
                ScoreDisplayData(id: "13", homeScore: "2", awayScore: "1", style: .simple, highlightingMode: .noHighlight)
            ]
        )

        // Border + All Highlighting Modes
        addSubsectionLabel("Border Style × All Highlighting Modes")
        addExample(
            title: "Bordered container with different highlighting",
            description: "Left: winnerLoser, Middle: bothHighlight, Right: noHighlight",
            scoreCells: [
                ScoreDisplayData(id: "14", homeScore: "25", awayScore: "22", style: .border, highlightingMode: .winnerLoser),
                ScoreDisplayData(id: "15", homeScore: "5", awayScore: "4", style: .border, highlightingMode: .bothHighlight),
                ScoreDisplayData(id: "16", homeScore: "3", awayScore: "1", style: .border, highlightingMode: .noHighlight)
            ]
        )

        // Background + All Highlighting Modes
        addSubsectionLabel("Background Style × All Highlighting Modes")
        addExample(
            title: "Filled background with different highlighting",
            description: "Left: winnerLoser, Middle: bothHighlight, Right: noHighlight",
            scoreCells: [
                ScoreDisplayData(id: "17", homeScore: "105", awayScore: "98", style: .background, highlightingMode: .winnerLoser),
                ScoreDisplayData(id: "18", homeScore: "7", awayScore: "6", style: .background, highlightingMode: .bothHighlight),
                ScoreDisplayData(id: "19", homeScore: "2", awayScore: "1", style: .background, highlightingMode: .noHighlight)
            ]
        )

        addSpacer(height: 8)
    }

    // MARK: - Part 4: Tennis Example
    private func addTennisExample() {
        let tennisViewModel = MockScoreViewModel(scoreCells: [
            ScoreDisplayData(
                id: "current_game",
                homeScore: "30",
                awayScore: "15",
                style: .background,
                highlightingMode: .bothHighlight,
                showsTrailingSeparator: true,
                servingPlayer: .home
            ),
            ScoreDisplayData(
                id: "set1",
                homeScore: "6",
                awayScore: "4",
                style: .simple,
                highlightingMode: .winnerLoser
            ),
            ScoreDisplayData(
                id: "set2",
                homeScore: "4",
                awayScore: "6",
                style: .simple,
                highlightingMode: .winnerLoser
            ),
            ScoreDisplayData(
                id: "set3",
                homeScore: "7",
                awayScore: "6",
                style: .simple,
                highlightingMode: .bothHighlight
            )
        ], visualState: .display)

        addExample(
            title: "Tennis: [●] [30/15] | [6/4] [4/6] [7/6]",
            description: "Current game (background + bothHighlight) | Completed sets (simple + winnerLoser) | Current set (simple + bothHighlight)",
            viewModel: tennisViewModel
        )

        addDetailLabel(
            "• Current game: background style (filled) + bothHighlight (both orange)\n" +
            "• Separator (|) after current game\n" +
            "• Serving indicator (●) shows home player serving\n" +
            "• Set 1: simple style + winnerLoser (6 black, 4 gray)\n" +
            "• Set 2: simple style + winnerLoser (4 gray, 6 black)\n" +
            "• Set 3: simple style + bothHighlight (both orange - tied)"
        )

        addSpacer(height: 8)
    }

    // MARK: - Part 5: Basketball Example
    private func addBasketballExample() {
        let basketballViewModel = MockScoreViewModel(scoreCells: [
            ScoreDisplayData(id: "q1", homeScore: "25", awayScore: "22", style: .simple, highlightingMode: .winnerLoser),
            ScoreDisplayData(id: "q2", homeScore: "18", awayScore: "28", style: .simple, highlightingMode: .winnerLoser),
            ScoreDisplayData(id: "q3", homeScore: "31", awayScore: "24", style: .simple, highlightingMode: .winnerLoser),
            ScoreDisplayData(id: "q4", homeScore: "26", awayScore: "30", style: .simple, highlightingMode: .winnerLoser),
            ScoreDisplayData(id: "total", homeScore: "100", awayScore: "104", style: .background, highlightingMode: .bothHighlight)
        ], visualState: .display)

        addExample(
            title: "Basketball: [25/22] [18/28] [31/24] [26/30] [100/104]",
            description: "Quarters (simple + winnerLoser) | Final Score (background + bothHighlight)",
            viewModel: basketballViewModel
        )

        addDetailLabel(
            "• Q1-Q4: simple style + winnerLoser (quarter winners highlighted)\n" +
            "• Total: background style (filled) + bothHighlight (both orange)\n" +
            "• No serving indicator for basketball"
        )

        addSpacer(height: 8)
    }

    // MARK: - Summary
    private func addSummarySection() {
        addSectionHeader("Summary: Style vs Highlighting")

        let summary = createDescriptionLabel(
            "Key Takeaways:\n\n" +
            "ScoreCellStyle (Container):\n" +
            "• .simple - Plain, 26pt wide\n" +
            "• .border - 1pt outline, 26pt wide\n" +
            "• .background - Filled, 29pt wide\n\n" +
            "HighlightingMode (Text Color):\n" +
            "• .winnerLoser - Black/gray based on score\n" +
            "• .bothHighlight - Both orange\n" +
            "• .noHighlight - Both black\n\n" +
            "They're independent and combinable!\n" +
            "Each of 3 styles × 3 highlighting modes = 9 combinations"
        )
        summary.font = StyleProvider.fontWith(type: .medium, size: 14)
        summary.backgroundColor = StyleProvider.Color.backgroundPrimary
        summary.layer.cornerRadius = 8
        summary.clipsToBounds = true

        let padding: CGFloat = 16
        summary.layoutMargins = UIEdgeInsets(top: padding, left: padding, bottom: padding, right: padding)

        stackView.addArrangedSubview(summary)
    }

    // MARK: - Helper Methods
    private func addExample(title: String, description: String, scoreCells: [ScoreDisplayData]) {
        let viewModel = MockScoreViewModel(scoreCells: scoreCells, visualState: .display)
        addExample(title: title, description: description, viewModel: viewModel)
    }

    private func addExample(title: String, description: String, viewModel: MockScoreViewModel) {
        let container = createExampleContainer(title: title, description: description, viewModel: viewModel)
        stackView.addArrangedSubview(container)
        addSpacer(height: 12)
    }

    private func createExampleContainer(title: String, description: String, viewModel: MockScoreViewModel) -> UIView {
        let container = UIView()
        container.translatesAutoresizingMaskIntoConstraints = false
        container.backgroundColor = StyleProvider.Color.backgroundPrimary
        container.layer.cornerRadius = 8

        let titleLabel = UILabel()
        titleLabel.text = title
        titleLabel.font = StyleProvider.fontWith(type: .medium, size: 14)
        titleLabel.textColor = StyleProvider.Color.textPrimary
        titleLabel.numberOfLines = 0
        titleLabel.translatesAutoresizingMaskIntoConstraints = false

        let descLabel = UILabel()
        descLabel.text = description
        descLabel.font = StyleProvider.fontWith(type: .regular, size: 12)
        descLabel.textColor = StyleProvider.Color.textSecondary
        descLabel.numberOfLines = 0
        descLabel.translatesAutoresizingMaskIntoConstraints = false

        let scoreView = ScoreView()
        scoreView.configure(with: viewModel)
        scoreView.translatesAutoresizingMaskIntoConstraints = false

        container.addSubview(titleLabel)
        container.addSubview(descLabel)
        container.addSubview(scoreView)

        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: container.topAnchor, constant: 12),
            titleLabel.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 12),
            titleLabel.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -12),

            descLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 4),
            descLabel.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 12),
            descLabel.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -12),

            scoreView.topAnchor.constraint(equalTo: descLabel.bottomAnchor, constant: 12),
            scoreView.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -12),
            scoreView.bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: -12)
        ])

        return container
    }

    private func addSectionHeader(_ text: String) {
        let label = UILabel()
        label.text = text
        label.font = StyleProvider.fontWith(type: .bold, size: 20)
        label.textColor = StyleProvider.Color.highlightPrimary
        label.translatesAutoresizingMaskIntoConstraints = false
        stackView.addArrangedSubview(label)
        addSpacer(height: 8)
    }

    private func addSubsectionLabel(_ text: String) {
        let label = UILabel()
        label.text = text
        label.font = StyleProvider.fontWith(type: .bold, size: 16)
        label.textColor = StyleProvider.Color.textPrimary
        label.translatesAutoresizingMaskIntoConstraints = false
        stackView.addArrangedSubview(label)
        addSpacer(height: 4)
    }

    private func addExplanationLabel(_ text: String) {
        let label = createDescriptionLabel(text)
        label.font = StyleProvider.fontWith(type: .light, size: 14)
        label.textColor = StyleProvider.Color.textSecondary
        stackView.addArrangedSubview(label)
        addSpacer(height: 12)
    }

    private func addDetailLabel(_ text: String) {
        let label = createDescriptionLabel(text)
        label.font = StyleProvider.fontWith(type: .regular, size: 12)
        label.textColor = StyleProvider.Color.textSecondary
        label.backgroundColor = UIColor.systemGray5
        label.layer.cornerRadius = 6
        label.clipsToBounds = true

        let padding: CGFloat = 8
        label.layoutMargins = UIEdgeInsets(top: padding, left: padding, bottom: padding, right: padding)

        stackView.addArrangedSubview(label)
    }

    private func createDescriptionLabel(_ text: String) -> UILabel {
        let label = UILabel()
        label.text = text
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }

    private func addSpacer(height: CGFloat) {
        let spacer = UIView()
        spacer.translatesAutoresizingMaskIntoConstraints = false
        spacer.heightAnchor.constraint(equalToConstant: height).isActive = true
        stackView.addArrangedSubview(spacer)
    }

    // MARK: - Factory Methods
    private static func createScrollView() -> UIScrollView {
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.showsVerticalScrollIndicator = true
        return scrollView
    }

    private static func createStackView() -> UIStackView {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 0
        stackView.alignment = .fill
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }
}
