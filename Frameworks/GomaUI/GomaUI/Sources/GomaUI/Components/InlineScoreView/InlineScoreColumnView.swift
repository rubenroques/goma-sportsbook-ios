import UIKit
import SwiftUI

/// Individual score column displaying home/away scores vertically
final class InlineScoreColumnView: UIView {

    // MARK: - UI Components
    private lazy var homeScoreLabel: UILabel = Self.createScoreLabel()
    private lazy var awayScoreLabel: UILabel = Self.createScoreLabel()

    // MARK: - Properties
    private let data: InlineScoreColumnData

    // MARK: - Initialization
    init(data: InlineScoreColumnData) {
        self.data = data
        super.init(frame: .zero)
        setupSubviews()
        configure(with: data)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Configuration
    private func configure(with data: InlineScoreColumnData) {
        homeScoreLabel.text = data.homeScore
        awayScoreLabel.text = data.awayScore
        applyHighlighting(data.highlightingMode)
    }

    private func applyHighlighting(_ mode: InlineScoreColumnData.HighlightingMode) {
        switch mode {
        case .winnerLoser:
            // Regular font for completed sets/periods
            homeScoreLabel.font = StyleProvider.fontWith(type: .regular, size: 14)
            awayScoreLabel.font = StyleProvider.fontWith(type: .regular, size: 14)

            // Compare scores to determine winner
            if data.homeScore > data.awayScore {
                homeScoreLabel.textColor = StyleProvider.Color.highlightPrimary
                awayScoreLabel.textColor = StyleProvider.Color.textSecondary
            } else if data.awayScore > data.homeScore {
                homeScoreLabel.textColor = StyleProvider.Color.textSecondary
                awayScoreLabel.textColor = StyleProvider.Color.highlightPrimary
            } else {
                homeScoreLabel.textColor = StyleProvider.Color.textPrimary
                awayScoreLabel.textColor = StyleProvider.Color.textPrimary
            }

        case .bothHighlight:
            // Bold font for current/active scores (maximum emphasis)
            homeScoreLabel.font = StyleProvider.fontWith(type: .bold, size: 14)
            awayScoreLabel.font = StyleProvider.fontWith(type: .bold, size: 14)

            homeScoreLabel.textColor = StyleProvider.Color.highlightPrimary
            awayScoreLabel.textColor = StyleProvider.Color.highlightPrimary

        case .noHighlight:
            // Regular font for neutral/informational scores
            homeScoreLabel.font = StyleProvider.fontWith(type: .regular, size: 14)
            awayScoreLabel.font = StyleProvider.fontWith(type: .regular, size: 14)

            homeScoreLabel.textColor = StyleProvider.Color.textPrimary
            awayScoreLabel.textColor = StyleProvider.Color.textPrimary
        }
    }
}

// MARK: - ViewCode
extension InlineScoreColumnView {
    private func setupSubviews() {
        translatesAutoresizingMaskIntoConstraints = false
        buildViewHierarchy()
        setupConstraints()
    }

    private func buildViewHierarchy() {
        addSubview(homeScoreLabel)
        addSubview(awayScoreLabel)
    }

    private func setupConstraints() {
        NSLayoutConstraint.activate([
            // Home score (top)
            homeScoreLabel.topAnchor.constraint(equalTo: topAnchor),
            homeScoreLabel.leadingAnchor.constraint(equalTo: leadingAnchor),
            homeScoreLabel.trailingAnchor.constraint(equalTo: trailingAnchor),
            homeScoreLabel.heightAnchor.constraint(equalToConstant: 19),

            // Away score (bottom)
            awayScoreLabel.topAnchor.constraint(equalTo: homeScoreLabel.bottomAnchor, constant: 2),
            awayScoreLabel.leadingAnchor.constraint(equalTo: leadingAnchor),
            awayScoreLabel.trailingAnchor.constraint(equalTo: trailingAnchor),
            awayScoreLabel.bottomAnchor.constraint(equalTo: bottomAnchor),
            awayScoreLabel.heightAnchor.constraint(equalToConstant: 19),

            // Minimum width for proper alignment
            widthAnchor.constraint(greaterThanOrEqualToConstant: 19)
        ])

        setContentHuggingPriority(.required, for: .horizontal)
        setContentCompressionResistancePriority(.required, for: .horizontal)
    }

    // MARK: - Factory Methods
    private static func createScoreLabel() -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = StyleProvider.fontWith(type: .medium, size: 14)
        label.textAlignment = .center
        label.numberOfLines = 1
        label.setContentHuggingPriority(.required, for: .horizontal)
        label.setContentCompressionResistancePriority(.required, for: .horizontal)
        return label
    }
}

// MARK: - Preview Provider
#if DEBUG
@available(iOS 17.0, *)
#Preview("InlineScoreColumnView - All Highlighting Modes") {
    PreviewUIViewController {
        let vc = UIViewController()
        vc.view.backgroundColor = StyleProvider.Color.backgroundPrimary

        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false

        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 24
        stackView.alignment = .fill
        stackView.translatesAutoresizingMaskIntoConstraints = false

        // Helper to create section headers
        func createSectionLabel(_ text: String) -> UILabel {
            let label = UILabel()
            label.text = text
            label.font = StyleProvider.fontWith(type: .bold, size: 20)
            label.textColor = StyleProvider.Color.textPrimary
            label.textAlignment = .left
            return label
        }

        // Helper to create example containers
        func createExampleContainer(with columnView: InlineScoreColumnView, title: String, description: String) -> UIView {
            let container = UIView()
            container.translatesAutoresizingMaskIntoConstraints = false
            container.backgroundColor = StyleProvider.Color.backgroundCards
            container.layer.cornerRadius = 8

            let titleLabel = UILabel()
            titleLabel.text = title
            titleLabel.font = StyleProvider.fontWith(type: .semibold, size: 16)
            titleLabel.textColor = StyleProvider.Color.textPrimary
            titleLabel.translatesAutoresizingMaskIntoConstraints = false

            let descLabel = UILabel()
            descLabel.text = description
            descLabel.font = StyleProvider.fontWith(type: .regular, size: 12)
            descLabel.textColor = StyleProvider.Color.textSecondary
            descLabel.numberOfLines = 0
            descLabel.translatesAutoresizingMaskIntoConstraints = false

            container.addSubview(titleLabel)
            container.addSubview(descLabel)
            container.addSubview(columnView)

            NSLayoutConstraint.activate([
                titleLabel.topAnchor.constraint(equalTo: container.topAnchor, constant: 12),
                titleLabel.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 12),
                titleLabel.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -12),

                descLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 4),
                descLabel.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 12),
                descLabel.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -12),

                columnView.topAnchor.constraint(equalTo: descLabel.bottomAnchor, constant: 12),
                columnView.centerXAnchor.constraint(equalTo: container.centerXAnchor),
                columnView.bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: -12)
            ])

            return container
        }

        // HIGHLIGHTING MODES
        stackView.addArrangedSubview(createSectionLabel("Highlighting Modes"))

        // Winner/Loser - Home wins
        let winnerHomeColumn = InlineScoreColumnView(data: InlineScoreColumnData(
            id: "set1",
            homeScore: "7",
            awayScore: "5",
            highlightingMode: .winnerLoser,
            showsTrailingSeparator: false
        ))
        stackView.addArrangedSubview(createExampleContainer(
            with: winnerHomeColumn,
            title: "Winner/Loser - Home Wins (7-5)",
            description: "Used for completed sets/periods. Winner score in primary color, loser dimmed. Home player won this set."
        ))

        // Winner/Loser - Away wins
        let winnerAwayColumn = InlineScoreColumnView(data: InlineScoreColumnData(
            id: "set2",
            homeScore: "4",
            awayScore: "6",
            highlightingMode: .winnerLoser,
            showsTrailingSeparator: false
        ))
        stackView.addArrangedSubview(createExampleContainer(
            with: winnerAwayColumn,
            title: "Winner/Loser - Away Wins (4-6)",
            description: "Same mode, away player won. Home score dimmed, away score highlighted."
        ))

        // Winner/Loser - Tied
        let winnerTiedColumn = InlineScoreColumnView(data: InlineScoreColumnData(
            id: "set3",
            homeScore: "6",
            awayScore: "6",
            highlightingMode: .winnerLoser,
            showsTrailingSeparator: false
        ))
        stackView.addArrangedSubview(createExampleContainer(
            with: winnerTiedColumn,
            title: "Winner/Loser - Tied (6-6)",
            description: "When scores are equal, both shown in primary color (no winner/loser)."
        ))

        // Both Highlight
        let bothHighlightColumn = InlineScoreColumnView(data: InlineScoreColumnData(
            id: "points",
            homeScore: "40",
            awayScore: "30",
            highlightingMode: .bothHighlight,
            showsTrailingSeparator: false
        ))
        stackView.addArrangedSubview(createExampleContainer(
            with: bothHighlightColumn,
            title: "Both Highlight (40-30)",
            description: "Used for current game/points in tennis, or active scores. Both scores highlighted in orange to draw attention."
        ))

        // No Highlight
        let noHighlightColumn = InlineScoreColumnView(data: InlineScoreColumnData(
            id: "quarter",
            homeScore: "28",
            awayScore: "24",
            highlightingMode: .noHighlight,
            showsTrailingSeparator: false
        ))
        stackView.addArrangedSubview(createExampleContainer(
            with: noHighlightColumn,
            title: "No Highlight (28-24)",
            description: "Default neutral styling. Both scores in primary text color, no special emphasis."
        ))

        // SPORT-SPECIFIC EXAMPLES
        stackView.addArrangedSubview(createSectionLabel("Sport-Specific Use Cases"))

        // Tennis - Completed Set
        let tennisSetColumn = InlineScoreColumnView(data: InlineScoreColumnData(
            id: "tennis_set",
            homeScore: "6",
            awayScore: "4",
            highlightingMode: .winnerLoser,
            showsTrailingSeparator: false
        ))
        stackView.addArrangedSubview(createExampleContainer(
            with: tennisSetColumn,
            title: "Tennis - Completed Set",
            description: "Historical set score. Winner/loser highlighting shows who won the set."
        ))

        // Tennis - Current Game
        let tennisGameColumn = InlineScoreColumnView(data: InlineScoreColumnData(
            id: "tennis_game",
            homeScore: "15",
            awayScore: "40",
            highlightingMode: .bothHighlight,
            showsTrailingSeparator: false
        ))
        stackView.addArrangedSubview(createExampleContainer(
            with: tennisGameColumn,
            title: "Tennis - Current Game Points",
            description: "Live game score. Both highlighted to show this is the active/current score."
        ))

        // Basketball - Quarter
        let basketballColumn = InlineScoreColumnView(data: InlineScoreColumnData(
            id: "basketball_q",
            homeScore: "32",
            awayScore: "28",
            highlightingMode: .noHighlight,
            showsTrailingSeparator: false
        ))
        stackView.addArrangedSubview(createExampleContainer(
            with: basketballColumn,
            title: "Basketball - Quarter Score",
            description: "Individual quarter score. No highlight, just informational display."
        ))

        // Football - Match Score
        let footballColumn = InlineScoreColumnView(data: InlineScoreColumnData(
            id: "football",
            homeScore: "2",
            awayScore: "1",
            highlightingMode: .bothHighlight,
            showsTrailingSeparator: false
        ))
        stackView.addArrangedSubview(createExampleContainer(
            with: footballColumn,
            title: "Football - Live Match Score",
            description: "Current match score. Both highlighted as this is the primary/only score display."
        ))

        // EDGE CASES
        stackView.addArrangedSubview(createSectionLabel("Edge Cases"))

        // Zero scores
        let zeroColumn = InlineScoreColumnView(data: InlineScoreColumnData(
            id: "zero",
            homeScore: "0",
            awayScore: "0",
            highlightingMode: .bothHighlight,
            showsTrailingSeparator: false
        ))
        stackView.addArrangedSubview(createExampleContainer(
            with: zeroColumn,
            title: "Zero-Zero Score",
            description: "Start of match. Both scores are 0."
        ))

        // Large numbers
        let largeColumn = InlineScoreColumnView(data: InlineScoreColumnData(
            id: "large",
            homeScore: "105",
            awayScore: "98",
            highlightingMode: .noHighlight,
            showsTrailingSeparator: false
        ))
        stackView.addArrangedSubview(createExampleContainer(
            with: largeColumn,
            title: "Large Numbers (105-98)",
            description: "Three-digit scores common in basketball. Layout handles larger numbers."
        ))

        // Special tennis notation
        let tennisAdvColumn = InlineScoreColumnView(data: InlineScoreColumnData(
            id: "adv",
            homeScore: "A",
            awayScore: "40",
            highlightingMode: .bothHighlight,
            showsTrailingSeparator: false
        ))
        stackView.addArrangedSubview(createExampleContainer(
            with: tennisAdvColumn,
            title: "Tennis Advantage Notation",
            description: "Special tennis scoring. 'A' for advantage point."
        ))

        scrollView.addSubview(stackView)
        vc.view.addSubview(scrollView)

        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: vc.view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: vc.view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: vc.view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: vc.view.bottomAnchor),

            stackView.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: 16),
            stackView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: 16),
            stackView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor, constant: -16),
            stackView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor, constant: -16),
            stackView.widthAnchor.constraint(equalTo: scrollView.widthAnchor, constant: -32)
        ])

        return vc
    }
}
#endif
