import UIKit
import Combine
import SwiftUI

/// Compact inline score display for live events
/// Displays scores horizontally with home scores on top row and away scores on bottom row
final public class InlineScoreView: UIView {

    // MARK: - UI Components
    private lazy var containerStackView: UIStackView = Self.createContainerStackView()

    // MARK: - Properties
    private var cancellables = Set<AnyCancellable>()
    private var viewModel: InlineScoreViewModelProtocol?
    private var columnViews: [InlineScoreColumnView] = []

    // MARK: - Initialization
    public init(viewModel: InlineScoreViewModelProtocol? = nil) {
        self.viewModel = viewModel
        super.init(frame: .zero)
        setupSubviews()

        if let viewModel = viewModel {
            configureImmediately(with: viewModel)
            setupBindings()
        }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Configuration
    /// Configures the view with a new view model for efficient reuse
    public func configure(with newViewModel: InlineScoreViewModelProtocol?) {
        cancellables.removeAll()
        self.viewModel = newViewModel

        if let viewModel = newViewModel {
            configureImmediately(with: viewModel)
            setupBindings()
        } else {
            clearColumns()
        }
    }

    /// Prepare for reuse in table/collection view cells
    public func cleanupForReuse() {
        cancellables.removeAll()
        clearColumns()
    }

    // MARK: - Private Configuration
    private func configureImmediately(with viewModel: InlineScoreViewModelProtocol) {
        render(state: viewModel.currentDisplayState)
    }

    private func clearColumns() {
        columnViews.forEach { $0.removeFromSuperview() }
        columnViews.removeAll()
        isHidden = true
    }
}

// MARK: - ViewCode
extension InlineScoreView {
    private func setupSubviews() {
        translatesAutoresizingMaskIntoConstraints = false
        buildViewHierarchy()
        setupConstraints()
        setupAdditionalConfiguration()
    }

    private func buildViewHierarchy() {
        addSubview(containerStackView)
    }

    private func setupConstraints() {
        NSLayoutConstraint.activate([
            containerStackView.topAnchor.constraint(equalTo: topAnchor),
            containerStackView.leadingAnchor.constraint(equalTo: leadingAnchor),
            containerStackView.trailingAnchor.constraint(equalTo: trailingAnchor),
            containerStackView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])

        setContentHuggingPriority(.required, for: .horizontal)
        setContentCompressionResistancePriority(.required, for: .horizontal)
    }

    private func setupAdditionalConfiguration() {
        backgroundColor = .clear
        isHidden = true
    }

    private func setupBindings() {
        guard let viewModel = viewModel else { return }

        viewModel.displayStatePublisher
            .dropFirst()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] state in
                self?.render(state: state)
            }
            .store(in: &cancellables)
    }

    private func render(state: InlineScoreDisplayState) {
        isHidden = !state.isVisible || state.isEmpty

        guard state.isVisible && !state.isEmpty else {
            clearColumns()
            return
        }

        updateColumns(with: state.columns)
    }

    private func updateColumns(with columns: [InlineScoreColumnData]) {
        // Clear existing column views
        columnViews.forEach { $0.removeFromSuperview() }
        columnViews.removeAll()

        // Create new column views
        for (index, columnData) in columns.enumerated() {
            let columnView = InlineScoreColumnView(data: columnData)
            containerStackView.addArrangedSubview(columnView)
            columnViews.append(columnView)

            // Add separator if needed (between current column and next)
            if columnData.showsTrailingSeparator && index < columns.count - 1 {
                let separator = Self.createSeparatorView()
                containerStackView.addArrangedSubview(separator)
            }
        }
    }
}

// MARK: - UI Elements Factory
extension InlineScoreView {
    private static func createContainerStackView() -> UIStackView {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .horizontal
        stackView.alignment = .center
        stackView.distribution = .fill
        stackView.spacing = 0
        return stackView
    }

    private static func createSeparatorView() -> UIView {
        let separator = UIView()
        separator.translatesAutoresizingMaskIntoConstraints = false
        separator.backgroundColor = StyleProvider.Color.textSecondary.withAlphaComponent(0.3)
        separator.widthAnchor.constraint(equalToConstant: 1).isActive = true
        separator.heightAnchor.constraint(equalToConstant: 32).isActive = true
        return separator
    }
}

// MARK: - Preview Provider
#if DEBUG
@available(iOS 17.0, *)
#Preview("InlineScoreView - All Sports & States") {
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
        func createExampleContainer(with scoreView: InlineScoreView, title: String, description: String) -> UIView {
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
            container.addSubview(scoreView)

            NSLayoutConstraint.activate([
                titleLabel.topAnchor.constraint(equalTo: container.topAnchor, constant: 12),
                titleLabel.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 12),
                titleLabel.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -12),

                descLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 4),
                descLabel.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 12),
                descLabel.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -12),

                scoreView.topAnchor.constraint(equalTo: descLabel.bottomAnchor, constant: 12),
                scoreView.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 12),
                scoreView.trailingAnchor.constraint(lessThanOrEqualTo: container.trailingAnchor, constant: -12),
                scoreView.bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: -12)
            ])

            return container
        }

        // TENNIS EXAMPLES
        stackView.addArrangedSubview(createSectionLabel("Tennis - Set & Game Scores"))

        // Tennis Match - Current Game
        let tennisMatchView = InlineScoreView(viewModel: MockInlineScoreViewModel.tennisMatch)
        stackView.addArrangedSubview(createExampleContainer(
            with: tennisMatchView,
            title: "Tennis - Live Match with Game Points",
            description: "Format: [Current Points] | [Set 1] [Set 2] [Set 3]. First column (30-40) shows current game with both highlighted. Separator (|) divides current from historical. Sets use winner/loser highlighting."
        ))

        // Tennis - Close Match
        let tennisCloseVM = MockInlineScoreViewModel(
            columns: [
                InlineScoreColumnData(id: "game", homeScore: "40", awayScore: "A", highlightingMode: .bothHighlight, showsTrailingSeparator: true),
                InlineScoreColumnData(id: "s1", homeScore: "6", awayScore: "7", highlightingMode: .winnerLoser),
                InlineScoreColumnData(id: "s2", homeScore: "7", awayScore: "6", highlightingMode: .winnerLoser),
                InlineScoreColumnData(id: "s3", homeScore: "5", awayScore: "6", highlightingMode: .bothHighlight)
            ],
            isVisible: true
        )
        let tennisCloseView = InlineScoreView(viewModel: tennisCloseVM)
        stackView.addArrangedSubview(createExampleContainer(
            with: tennisCloseView,
            title: "Tennis - Advantage Point (40-A)",
            description: "Away player has advantage. Current set (5-6) highlighted as it's in progress. Historical sets show winner/loser."
        ))

        // Tennis - Early Game
        let tennisEarlyVM = MockInlineScoreViewModel(
            columns: [
                InlineScoreColumnData(id: "game", homeScore: "15", awayScore: "0", highlightingMode: .bothHighlight, showsTrailingSeparator: true),
                InlineScoreColumnData(id: "s1", homeScore: "6", awayScore: "4", highlightingMode: .winnerLoser),
                InlineScoreColumnData(id: "s2", homeScore: "0", awayScore: "0", highlightingMode: .bothHighlight)
            ],
            isVisible: true
        )
        let tennisEarlyView = InlineScoreView(viewModel: tennisEarlyVM)
        stackView.addArrangedSubview(createExampleContainer(
            with: tennisEarlyView,
            title: "Tennis - Early Second Set (15-0)",
            description: "First set completed (6-4), second set just started (0-0). Current game shows 15-0."
        ))

        // FOOTBALL EXAMPLES
        stackView.addArrangedSubview(createSectionLabel("Football - Single Score Display"))

        // Football Match
        let footballView = InlineScoreView(viewModel: MockInlineScoreViewModel.footballMatch)
        stackView.addArrangedSubview(createExampleContainer(
            with: footballView,
            title: "Football - Live Match Score",
            description: "Single column display (2-1). Both scores highlighted as this is the primary/only score. No separator needed for single-column sports."
        ))

        // Football - High Scoring
        let footballHighVM = MockInlineScoreViewModel(
            columns: [
                InlineScoreColumnData(id: "score", homeScore: "5", awayScore: "3", highlightingMode: .bothHighlight)
            ],
            isVisible: true
        )
        let footballHighView = InlineScoreView(viewModel: footballHighVM)
        stackView.addArrangedSubview(createExampleContainer(
            with: footballHighView,
            title: "Football - High Scoring Match (5-3)",
            description: "Unusual high-scoring match. Same compact display format."
        ))

        // Football - Draw
        let footballDrawVM = MockInlineScoreViewModel(
            columns: [
                InlineScoreColumnData(id: "score", homeScore: "1", awayScore: "1", highlightingMode: .bothHighlight)
            ],
            isVisible: true
        )
        let footballDrawView = InlineScoreView(viewModel: footballDrawVM)
        stackView.addArrangedSubview(createExampleContainer(
            with: footballDrawView,
            title: "Football - Draw (1-1)",
            description: "Tied match. Both scores equal and highlighted."
        ))

        // BASKETBALL EXAMPLES
        stackView.addArrangedSubview(createSectionLabel("Basketball - Quarter Breakdown"))

        // Basketball Match
        let basketballView = InlineScoreView(viewModel: MockInlineScoreViewModel.basketballMatch)
        stackView.addArrangedSubview(createExampleContainer(
            with: basketballView,
            title: "Basketball - Live with Quarter Scores",
            description: "Format: [Total] | [Q1] [Q2] [Q3] [Q4]. Total score highlighted (105-98), individual quarters use neutral styling for informational display."
        ))

        // Basketball - Close Game
        let basketballCloseVM = MockInlineScoreViewModel(
            columns: [
                InlineScoreColumnData(id: "total", homeScore: "88", awayScore: "88", highlightingMode: .bothHighlight, showsTrailingSeparator: true),
                InlineScoreColumnData(id: "q1", homeScore: "22", awayScore: "25", highlightingMode: .noHighlight),
                InlineScoreColumnData(id: "q2", homeScore: "24", awayScore: "20", highlightingMode: .noHighlight),
                InlineScoreColumnData(id: "q3", homeScore: "20", awayScore: "23", highlightingMode: .noHighlight),
                InlineScoreColumnData(id: "q4", homeScore: "22", awayScore: "20", highlightingMode: .noHighlight)
            ],
            isVisible: true
        )
        let basketballCloseView = InlineScoreView(viewModel: basketballCloseVM)
        stackView.addArrangedSubview(createExampleContainer(
            with: basketballCloseView,
            title: "Basketball - Tied Game (88-88)",
            description: "Tied total score. All four quarters shown with neutral highlighting. Total emphasized."
        ))

        // Basketball - Early Game
        let basketballEarlyVM = MockInlineScoreViewModel(
            columns: [
                InlineScoreColumnData(id: "total", homeScore: "42", awayScore: "38", highlightingMode: .bothHighlight, showsTrailingSeparator: true),
                InlineScoreColumnData(id: "q1", homeScore: "28", awayScore: "24", highlightingMode: .noHighlight),
                InlineScoreColumnData(id: "q2", homeScore: "14", awayScore: "14", highlightingMode: .noHighlight)
            ],
            isVisible: true
        )
        let basketballEarlyView = InlineScoreView(viewModel: basketballEarlyVM)
        stackView.addArrangedSubview(createExampleContainer(
            with: basketballEarlyView,
            title: "Basketball - Second Quarter In Progress",
            description: "Only completed + current quarters shown. Q1 and Q2 displayed, Q3/Q4 not yet played."
        ))

        // VISIBILITY STATES
        stackView.addArrangedSubview(createSectionLabel("Visibility & Edge Cases"))

        // Hidden State
        let hiddenVM = MockInlineScoreViewModel(columns: [], isVisible: false)
        let hiddenView = InlineScoreView(viewModel: hiddenVM)
        stackView.addArrangedSubview(createExampleContainer(
            with: hiddenView,
            title: "Hidden State (Pre-Live Match)",
            description: "Score view hidden when isVisible = false. Used for pre-live events with no scores yet. View collapses to zero height."
        ))

        // Empty Columns
        let emptyVM = MockInlineScoreViewModel(columns: [], isVisible: true)
        let emptyView = InlineScoreView(viewModel: emptyVM)
        stackView.addArrangedSubview(createExampleContainer(
            with: emptyView,
            title: "Empty Columns (No Score Data)",
            description: "Visible but no columns. Edge case where data is missing. View shows but displays nothing."
        ))

        // Single Column No Separator
        let singleVM = MockInlineScoreViewModel(
            columns: [
                InlineScoreColumnData(id: "only", homeScore: "0", awayScore: "0", highlightingMode: .bothHighlight)
            ],
            isVisible: true
        )
        let singleView = InlineScoreView(viewModel: singleVM)
        stackView.addArrangedSubview(createExampleContainer(
            with: singleView,
            title: "Start of Match (0-0)",
            description: "Match just started. Both scores zero. Single column, no separator."
        ))

        // Many Columns (Tennis Long Match)
        let longTennisVM = MockInlineScoreViewModel(
            columns: [
                InlineScoreColumnData(id: "game", homeScore: "30", awayScore: "15", highlightingMode: .bothHighlight, showsTrailingSeparator: true),
                InlineScoreColumnData(id: "s1", homeScore: "6", awayScore: "7", highlightingMode: .winnerLoser),
                InlineScoreColumnData(id: "s2", homeScore: "7", awayScore: "6", highlightingMode: .winnerLoser),
                InlineScoreColumnData(id: "s3", homeScore: "4", awayScore: "6", highlightingMode: .winnerLoser),
                InlineScoreColumnData(id: "s4", homeScore: "6", awayScore: "3", highlightingMode: .winnerLoser),
                InlineScoreColumnData(id: "s5", homeScore: "5", awayScore: "4", highlightingMode: .bothHighlight)
            ],
            isVisible: true
        )
        let longTennisView = InlineScoreView(viewModel: longTennisVM)
        stackView.addArrangedSubview(createExampleContainer(
            with: longTennisView,
            title: "Tennis - Long Five-Set Match",
            description: "Maximum columns scenario. Five sets plus current game. Horizontal scrolling if needed. Tests layout with many columns."
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
