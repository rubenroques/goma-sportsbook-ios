import UIKit
import Combine
import SwiftUI

/// A view that displays a horizontal series of score cells for sports matches
public class ScoreView: UIView {
    
    // MARK: - Private Properties
    private lazy var containerStackView: UIStackView = Self.createContainerStackView()
    private lazy var loadingIndicator: UIActivityIndicatorView = Self.createLoadingIndicator()
    private lazy var emptyLabel: UILabel = Self.createEmptyLabel()
    
    // Conditional constraints for empty state
    private var emptyLabelConstraints: [NSLayoutConstraint] = []
    
    // MARK: - ViewModel
    private var viewModel: ScoreViewModelProtocol?
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Initialization
    public override init(frame: CGRect) {
        super.init(frame: frame)
        setupSubviews()
        setupConstraints()
        setupWithTheme()
    }
    
    public required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupSubviews()
        setupConstraints()
        setupWithTheme()
    }
    
    // MARK: - Intrinsic Content Size
    public override var intrinsicContentSize: CGSize {
        let stackIntrinsicSize = containerStackView.intrinsicContentSize
        return CGSize(
            width: stackIntrinsicSize.width,
            height: 42 // Fixed height for score cells
        )
    }
    
    // MARK: - Configuration
    /// Configure the view with a ViewModel
    public func configure(with viewModel: ScoreViewModelProtocol) {
        self.viewModel = viewModel
        setupBindings()
    }
    
    /// Clean up for reuse in collection views
    public func cleanupForReuse() {
        viewModel = nil
        cancellables.removeAll()
        clearScoreCells()
    }
    
    // MARK: - Private Methods
    private func setupSubviews() {
        translatesAutoresizingMaskIntoConstraints = false
        
        addSubview(containerStackView)
        addSubview(loadingIndicator)
        addSubview(emptyLabel)
        
        // Initial state
        loadingIndicator.isHidden = true
        emptyLabel.isHidden = true
        
        // Set content hugging and compression resistance
        setContentHuggingPriority(.required, for: .horizontal)
        setContentCompressionResistancePriority(.required, for: .horizontal)
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            // Container stack view - trailing aligned, intrinsic width
            containerStackView.topAnchor.constraint(equalTo: topAnchor),
            containerStackView.trailingAnchor.constraint(equalTo: trailingAnchor),
            containerStackView.bottomAnchor.constraint(equalTo: bottomAnchor),
            containerStackView.leadingAnchor.constraint(greaterThanOrEqualTo: leadingAnchor),
            
            // Loading indicator (centered)
            loadingIndicator.centerXAnchor.constraint(equalTo: centerXAnchor),
            loadingIndicator.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])
        
        // Create but don't activate empty label constraints yet
        emptyLabelConstraints = [
            emptyLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
            emptyLabel.centerYAnchor.constraint(equalTo: centerYAnchor),
            emptyLabel.leadingAnchor.constraint(greaterThanOrEqualTo: leadingAnchor, constant: 8),
            emptyLabel.trailingAnchor.constraint(lessThanOrEqualTo: trailingAnchor, constant: -8)
        ]
    }
    
    private func setupWithTheme() {
        backgroundColor = .clear
        emptyLabel.textColor = StyleProvider.Color.highlightSecondary
    }
    
    private func setupBindings() {
        guard let viewModel = viewModel else { return }
        
        cancellables.removeAll()
        
        // Bind visual state
        viewModel.visualStatePublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] state in
                self?.updateVisualState(state)
            }
            .store(in: &cancellables)
        
        // Bind score cells
        viewModel.scoreCellsPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] scoreCells in
                self?.updateScoreCells(scoreCells)
            }
            .store(in: &cancellables)
    }
    
    private func updateVisualState(_ state: ScoreDisplayData.VisualState) {
        // Deactivate empty label constraints first
        NSLayoutConstraint.deactivate(emptyLabelConstraints)
        
        switch state {
        case .idle:
            containerStackView.isHidden = false
            loadingIndicator.isHidden = true
            loadingIndicator.stopAnimating()
            emptyLabel.isHidden = true
            
        case .loading:
            containerStackView.isHidden = true
            loadingIndicator.isHidden = false
            loadingIndicator.startAnimating()
            emptyLabel.isHidden = true
            
        case .display:
            containerStackView.isHidden = false
            loadingIndicator.isHidden = true
            loadingIndicator.stopAnimating()
            emptyLabel.isHidden = true
            
        case .empty:
            containerStackView.isHidden = true
            loadingIndicator.isHidden = true
            loadingIndicator.stopAnimating()
            emptyLabel.isHidden = false
            // Only activate empty label constraints when showing empty state
            NSLayoutConstraint.activate(emptyLabelConstraints)
        }
        
        // Invalidate intrinsic content size when state changes
        invalidateIntrinsicContentSize()
    }
    
    private func updateScoreCells(_ scoreCells: [ScoreDisplayData]) {
        clearScoreCells()

        for (index, scoreData) in scoreCells.enumerated() {
            // Add serving indicator column as FIRST element (only once, for first cell with serving data)
            if index == 0 && scoreData.servingPlayer != nil {
                let servingIndicator = ServingIndicatorView(servingPlayer: scoreData.servingPlayer)
                containerStackView.addArrangedSubview(servingIndicator)
            }

            // Add score cell
            let cellView = ScoreCellView(data: scoreData)
            containerStackView.addArrangedSubview(cellView)

            // Add separator line if needed
            if scoreData.showsTrailingSeparator {
                let separator = Self.createSeparatorLine()
                containerStackView.addArrangedSubview(separator)
            }
        }

        // Invalidate intrinsic content size when cells change
        invalidateIntrinsicContentSize()
    }
    
    private func clearScoreCells() {
        containerStackView.arrangedSubviews.forEach { view in
            containerStackView.removeArrangedSubview(view)
            view.removeFromSuperview()
        }
    }
}

// MARK: - Factory Methods
extension ScoreView {
    private static func createContainerStackView() -> UIStackView {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .horizontal
        stackView.spacing = 4
        stackView.distribution = .fill
        stackView.alignment = .center
        stackView.backgroundColor = .clear
        
        // Ensure the stack view hugs its content
        stackView.setContentHuggingPriority(.required, for: .horizontal)
        stackView.setContentCompressionResistancePriority(.required, for: .horizontal)
        
        return stackView
    }
    
    private static func createSeparatorLine() -> UIView {
        let separator = UIView()
        separator.translatesAutoresizingMaskIntoConstraints = false
        separator.backgroundColor = StyleProvider.Color.separatorLine
        separator.widthAnchor.constraint(equalToConstant: 1).isActive = true
        return separator
    }

    private static func createLoadingIndicator() -> UIActivityIndicatorView {
        let indicator = UIActivityIndicatorView(style: .medium)
        indicator.translatesAutoresizingMaskIntoConstraints = false
        indicator.color = StyleProvider.Color.highlightPrimary
        indicator.hidesWhenStopped = true
        return indicator
    }
    
    private static func createEmptyLabel() -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = LocalizationProvider.string("no_scores")
        label.font = StyleProvider.fontWith(type: .regular, size: 14)
        label.textAlignment = .center
        label.numberOfLines = 1
        return label
    }
}

// MARK: - SwiftUI Previews
#if DEBUG
@available(iOS 17.0, *)
#Preview("ScoreView - All States & Variations") {
    PreviewUIViewController {
        let vc = UIViewController()
        vc.view.backgroundColor = .systemGray6

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
            label.translatesAutoresizingMaskIntoConstraints = false
            return label
        }

        // Helper to create score view containers
        func createScoreContainer(with scoreView: ScoreView, title: String) -> UIView {
            let container = UIView()
            container.translatesAutoresizingMaskIntoConstraints = false
            container.backgroundColor = .systemGray5
            container.layer.cornerRadius = 8

            let titleLabel = UILabel()
            titleLabel.text = title
            titleLabel.font = StyleProvider.fontWith(type: .medium, size: 14)
            titleLabel.textColor = StyleProvider.Color.textSecondary
            titleLabel.translatesAutoresizingMaskIntoConstraints = false

            container.addSubview(titleLabel)
            container.addSubview(scoreView)
            
            NSLayoutConstraint.activate([
                titleLabel.topAnchor.constraint(equalTo: container.topAnchor, constant: 8),
                titleLabel.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 12),
                titleLabel.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -12),

                scoreView.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -8),
                scoreView.bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: -8),

                container.heightAnchor.constraint(equalToConstant: 80)
            ])

            return container
        }

        // VISUAL STATES
        stackView.addArrangedSubview(createSectionLabel("Visual States"))

        // Loading State
        let loadingView = ScoreView()
        loadingView.configure(with: MockScoreViewModel.loading)
        stackView.addArrangedSubview(createScoreContainer(with: loadingView, title: "Loading State"))

        // Empty State
        let emptyView = ScoreView()
        emptyView.configure(with: MockScoreViewModel.empty)
        stackView.addArrangedSubview(createScoreContainer(with: emptyView, title: "Empty State"))

        // Idle State
        let idleView = ScoreView()
        idleView.configure(with: MockScoreViewModel.idle)
        stackView.addArrangedSubview(createScoreContainer(with: idleView, title: "Idle State"))

        // SPORT-SPECIFIC EXAMPLES
        stackView.addArrangedSubview(createSectionLabel("Sport-Specific Score Examples"))

        // Tennis Match
        let tennisView = ScoreView()
        tennisView.configure(with: MockScoreViewModel.tennisMatch)
        stackView.addArrangedSubview(createScoreContainer(with: tennisView, title: "Tennis Match - Mixed Styles"))

        // Tennis with Advantage
        let tennisAdvView = ScoreView()
        tennisAdvView.configure(with: MockScoreViewModel.tennisAdvantage)
        stackView.addArrangedSubview(createScoreContainer(with: tennisAdvView, title: "Tennis Match - Advantage Scoring"))

        // Basketball Match
        let basketballView = ScoreView()
        basketballView.configure(with: MockScoreViewModel.basketballMatch)
        stackView.addArrangedSubview(createScoreContainer(with: basketballView, title: "Basketball Match - Quarters & Total"))

        // Football/Soccer Match
        let footballView = ScoreView()
        footballView.configure(with: MockScoreViewModel.footballMatch)
        stackView.addArrangedSubview(createScoreContainer(with: footballView, title: "Football Match - Single Score"))

        // Volleyball Match
        let volleyballView = ScoreView()
        volleyballView.configure(with: MockScoreViewModel.volleyballMatch)
        stackView.addArrangedSubview(createScoreContainer(with: volleyballView, title: "Volleyball Match - Set Scores"))

        // Hockey Match
        let hockeyView = ScoreView()
        hockeyView.configure(with: MockScoreViewModel.hockeyMatch)
        stackView.addArrangedSubview(createScoreContainer(with: hockeyView, title: "Hockey Match - Periods & Total"))

        // American Football
        let americanFootballView = ScoreView()
        americanFootballView.configure(with: MockScoreViewModel.americanFootballMatch)
        stackView.addArrangedSubview(createScoreContainer(with: americanFootballView, title: "American Football - Quarters & Total"))

        // SPECIAL CASES
        stackView.addArrangedSubview(createSectionLabel("Special Cases & Edge Scenarios"))

        // Tied Match
        let tiedView = ScoreView()
        tiedView.configure(with: MockScoreViewModel.tiedMatch)
        stackView.addArrangedSubview(createScoreContainer(with: tiedView, title: "Tied Match - Equal Scores"))

        // Maximum Cells
        let maxCellsView = ScoreView()
        maxCellsView.configure(with: MockScoreViewModel.maxCells)
        stackView.addArrangedSubview(createScoreContainer(with: maxCellsView, title: "Maximum Cells - Long Tennis Match"))

        // Mixed Styles
        let mixedStylesView = ScoreView()
        mixedStylesView.configure(with: MockScoreViewModel.mixedStyles)
        stackView.addArrangedSubview(createScoreContainer(with: mixedStylesView, title: "Mixed Styles - Different Visual Treatments"))

        // SINGLE STYLE DEMONSTRATIONS
        stackView.addArrangedSubview(createSectionLabel("Individual Style Demonstrations"))

        // Simple Style Only
        let simpleStyleView = ScoreView()
        let simpleVM = MockScoreViewModel(scoreCells: [
            ScoreDisplayData(id: "s1", homeScore: "6", awayScore: "4", style: .simple),
            ScoreDisplayData(id: "s2", homeScore: "3", awayScore: "6", style: .simple),
            ScoreDisplayData(id: "s3", homeScore: "7", awayScore: "6", style: .simple)
        ], visualState: .display)
        simpleStyleView.configure(with: simpleVM)
        stackView.addArrangedSubview(createScoreContainer(with: simpleStyleView, title: "Simple Style Only - Winner Highlighting"))

        // Border Style Only
        let borderStyleView = ScoreView()
        let borderVM = MockScoreViewModel(scoreCells: [
            ScoreDisplayData(id: "b1", homeScore: "25", awayScore: "23", style: .border),
            ScoreDisplayData(id: "b2", homeScore: "21", awayScore: "25", style: .border),
            ScoreDisplayData(id: "b3", homeScore: "15", awayScore: "12", style: .border)
        ], visualState: .display)
        borderStyleView.configure(with: borderVM)
        stackView.addArrangedSubview(createScoreContainer(with: borderStyleView, title: "Border Style Only - Outlined Appearance"))

        // Background Style Only
        let backgroundStyleView = ScoreView()
        let backgroundVM = MockScoreViewModel(scoreCells: [
            ScoreDisplayData(id: "bg1", homeScore: "105", awayScore: "98", style: .background),
            ScoreDisplayData(id: "bg2", homeScore: "89", awayScore: "112", style: .background),
            ScoreDisplayData(id: "bg3", homeScore: "95", awayScore: "95", style: .background)
        ], visualState: .display)
        backgroundStyleView.configure(with: backgroundVM)
        stackView.addArrangedSubview(createScoreContainer(with: backgroundStyleView, title: "Background Style Only - Filled Appearance"))

        // EDGE CASES & STRESS TESTS
        stackView.addArrangedSubview(createSectionLabel("Edge Cases & Stress Tests"))

        // Very Large Numbers
        let largeNumbersView = ScoreView()
        let largeVM = MockScoreViewModel(scoreCells: [
            ScoreDisplayData(id: "l1", homeScore: "999", awayScore: "0", style: .simple),
            ScoreDisplayData(id: "l2", homeScore: "123", awayScore: "456", style: .border),
            ScoreDisplayData(id: "l3", homeScore: "88", awayScore: "99", style: .background)
        ], visualState: .display)
        largeNumbersView.configure(with: largeVM)
        stackView.addArrangedSubview(createScoreContainer(with: largeNumbersView, title: "Large Numbers - Layout Stress Test"))

        // Special Tennis Notation
        let specialNotationView = ScoreView()
        let specialVM = MockScoreViewModel(scoreCells: [
            ScoreDisplayData(id: "sp1", homeScore: "AD", awayScore: "40", style: .simple),
            ScoreDisplayData(id: "sp2", homeScore: "DEU", awayScore: "40", style: .border),
            ScoreDisplayData(id: "sp3", homeScore: "A", awayScore: "40", style: .background)
        ], visualState: .display)
        specialNotationView.configure(with: specialVM)
        stackView.addArrangedSubview(createScoreContainer(with: specialNotationView, title: "Special Tennis Notation - AD, DEU, A"))

        // Single Cell Examples
        let singleCellView1 = ScoreView()
        let singleVM1 = MockScoreViewModel(scoreCells: [
            ScoreDisplayData(id: "single", homeScore: "3", awayScore: "1", style: .background)
        ], visualState: .display)
        singleCellView1.configure(with: singleVM1)
        stackView.addArrangedSubview(createScoreContainer(with: singleCellView1, title: "Single Cell - Minimal Display"))

        // Two Cell Comparison
        let twoCellView = ScoreView()
        let twoVM = MockScoreViewModel(scoreCells: [
            ScoreDisplayData(id: "prev", homeScore: "6", awayScore: "4", style: .simple),
            ScoreDisplayData(id: "curr", homeScore: "2", awayScore: "5", style: .background)
        ], visualState: .display)
        twoCellView.configure(with: twoVM)
        stackView.addArrangedSubview(createScoreContainer(with: twoCellView, title: "Two Cells - Previous vs Current"))

        scrollView.addSubview(stackView)
        vc.view.addSubview(scrollView)

        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: vc.view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: vc.view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: vc.view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: vc.view.bottomAnchor),

            stackView.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: 20),
            stackView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: 16),
            stackView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor, constant: -16),
            stackView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor, constant: -20),
            stackView.widthAnchor.constraint(equalTo: scrollView.widthAnchor, constant: -32)
        ])

        return vc
    }
}

@available(iOS 17.0, *)
#Preview("ScoreView - Simple Test") {
    PreviewUIViewController {
        let vc = UIViewController()
        vc.view.backgroundColor = .systemBlue // Blue background to see view boundaries

        // Create a simple tennis match score
        let scoreView = ScoreView()
        scoreView.translatesAutoresizingMaskIntoConstraints = false

        let tennisViewModel = MockScoreViewModel(scoreCells: [
            ScoreDisplayData(id: "set1", homeScore: "6", awayScore: "4", style: .simple),
            ScoreDisplayData(id: "set2", homeScore: "3", awayScore: "6", style: .border),
            ScoreDisplayData(id: "game", homeScore: "30", awayScore: "15", style: .background)
        ], visualState: .display)

        scoreView.configure(with: tennisViewModel)

        vc.view.addSubview(scoreView)

        NSLayoutConstraint.activate([
            scoreView.centerXAnchor.constraint(equalTo: vc.view.centerXAnchor),
            scoreView.centerYAnchor.constraint(equalTo: vc.view.centerYAnchor),
        ])

        return vc
    }
}

@available(iOS 17.0, *)
#Preview("ScoreView - Tennis with Serving Indicator & Separator") {
    PreviewUIViewController {
        let vc = UIViewController()
        vc.view.backgroundColor = .systemGray6

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
            label.translatesAutoresizingMaskIntoConstraints = false
            return label
        }

        // Helper to create score view containers with description
        func createScoreContainer(with scoreView: ScoreView, title: String, description: String) -> UIView {
            let container = UIView()
            container.translatesAutoresizingMaskIntoConstraints = false
            container.backgroundColor = .systemGray5
            container.layer.cornerRadius = 8

            let titleLabel = UILabel()
            titleLabel.text = title
            titleLabel.font = StyleProvider.fontWith(type: .bold, size: 16)
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
                scoreView.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -12),
                scoreView.bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: -12)
            ])

            return container
        }

        // TENNIS EXAMPLES WITH NEW LAYOUT
        stackView.addArrangedSubview(createSectionLabel("Tennis: Serving Indicator + Separator + Highlighting"))

        // Example 1: Home serving
        let homeServingView = ScoreView()
        let homeServingVM = MockScoreViewModel(scoreCells: [
            ScoreDisplayData(
                id: "game",
                homeScore: "40",
                awayScore: "15",
                style: .background,
                highlightingMode: .bothHighlight,
                showsTrailingSeparator: true,
                servingPlayer: .home
            ),
            ScoreDisplayData(id: "s1", homeScore: "6", awayScore: "4", style: .simple, highlightingMode: .winnerLoser),
            ScoreDisplayData(id: "s2", homeScore: "4", awayScore: "6", style: .simple, highlightingMode: .winnerLoser),
            ScoreDisplayData(id: "s3", homeScore: "3", awayScore: "2", style: .simple, highlightingMode: .bothHighlight)
        ], visualState: .display)
        homeServingView.configure(with: homeServingVM)
        stackView.addArrangedSubview(createScoreContainer(
            with: homeServingView,
            title: "Home Player Serving (40-15)",
            description: "[●] [40/15] | [6/4] [4/6] [3/2] - Serving indicator (●) in separate column, separator (|) after game, winner/loser highlighting on completed sets"
        ))

        // Example 2: Away serving
        let awayServingView = ScoreView()
        let awayServingVM = MockScoreViewModel(scoreCells: [
            ScoreDisplayData(
                id: "game",
                homeScore: "15",
                awayScore: "30",
                style: .background,
                highlightingMode: .bothHighlight,
                showsTrailingSeparator: true,
                servingPlayer: .away
            ),
            ScoreDisplayData(id: "s1", homeScore: "6", awayScore: "4", style: .simple, highlightingMode: .winnerLoser),
            ScoreDisplayData(id: "s2", homeScore: "4", awayScore: "6", style: .simple, highlightingMode: .winnerLoser),
            ScoreDisplayData(id: "s3", homeScore: "7", awayScore: "6", style: .simple, highlightingMode: .bothHighlight)
        ], visualState: .display)
        awayServingView.configure(with: awayServingVM)
        stackView.addArrangedSubview(createScoreContainer(
            with: awayServingView,
            title: "Away Player Serving (15-30)",
            description: "[●] [15/30] | [6/4] [4/6] [7/6] - Serving indicator on away row, both scores in current game/set highlighted in orange"
        ))

        // Example 3: Advantage scoring
        let advantageView = ScoreView()
        let advantageVM = MockScoreViewModel(scoreCells: [
            ScoreDisplayData(
                id: "game",
                homeScore: "A",
                awayScore: "40",
                style: .background,
                highlightingMode: .bothHighlight,
                showsTrailingSeparator: true,
                servingPlayer: .home
            ),
            ScoreDisplayData(id: "s1", homeScore: "6", awayScore: "3", style: .simple, highlightingMode: .winnerLoser),
            ScoreDisplayData(id: "s2", homeScore: "5", awayScore: "6", style: .simple, highlightingMode: .winnerLoser),
            ScoreDisplayData(id: "s3", homeScore: "6", awayScore: "6", style: .simple, highlightingMode: .bothHighlight)
        ], visualState: .display)
        advantageView.configure(with: advantageVM)
        stackView.addArrangedSubview(createScoreContainer(
            with: advantageView,
            title: "Advantage Point (A-40)",
            description: "[●] [A/40] | [6/3] [5/6] [6/6] - Shows 'A' for advantage, tied current set shows both highlighted"
        ))

        // Example 4: Deuce situation
        let deuceView = ScoreView()
        let deuceVM = MockScoreViewModel(scoreCells: [
            ScoreDisplayData(
                id: "game",
                homeScore: "40",
                awayScore: "40",
                style: .background,
                highlightingMode: .bothHighlight,
                showsTrailingSeparator: true,
                servingPlayer: .away
            ),
            ScoreDisplayData(id: "s1", homeScore: "7", awayScore: "6", style: .simple, highlightingMode: .winnerLoser),
            ScoreDisplayData(id: "s2", homeScore: "3", awayScore: "6", style: .simple, highlightingMode: .winnerLoser),
            ScoreDisplayData(id: "s3", homeScore: "5", awayScore: "4", style: .simple, highlightingMode: .bothHighlight)
        ], visualState: .display)
        deuceView.configure(with: deuceVM)
        stackView.addArrangedSubview(createScoreContainer(
            with: deuceView,
            title: "Deuce (40-40)",
            description: "[●] [40/40] | [7/6] [3/6] [5/4] - Equal game score shows both highlighted, away player serving"
        ))

        // COMPARISON: Basketball (no serving indicator)
        stackView.addArrangedSubview(createSectionLabel("Basketball: No Serving Indicator"))

        let basketballView = ScoreView()
        let basketballVM = MockScoreViewModel(scoreCells: [
            ScoreDisplayData(id: "q1", homeScore: "25", awayScore: "22", style: .simple, highlightingMode: .winnerLoser),
            ScoreDisplayData(id: "q2", homeScore: "18", awayScore: "28", style: .simple, highlightingMode: .winnerLoser),
            ScoreDisplayData(id: "q3", homeScore: "31", awayScore: "24", style: .simple, highlightingMode: .winnerLoser),
            ScoreDisplayData(id: "q4", homeScore: "26", awayScore: "30", style: .simple, highlightingMode: .winnerLoser),
            ScoreDisplayData(id: "total", homeScore: "100", awayScore: "104", style: .background, highlightingMode: .bothHighlight)
        ], visualState: .display)
        basketballView.configure(with: basketballVM)
        stackView.addArrangedSubview(createScoreContainer(
            with: basketballView,
            title: "Basketball Quarters + Total",
            description: "[25/22] [18/28] [31/24] [26/30] [100/104] - No serving column, quarters show winner/loser, total shows both highlighted"
        ))

        scrollView.addSubview(stackView)
        vc.view.addSubview(scrollView)

        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: vc.view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: vc.view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: vc.view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: vc.view.bottomAnchor),

            stackView.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: 20),
            stackView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: 16),
            stackView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor, constant: -16),
            stackView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor, constant: -20),
            stackView.widthAnchor.constraint(equalTo: scrollView.widthAnchor, constant: -32)
        ])

        return vc
    }
}

@available(iOS 17.0, *)
#Preview("ScoreView - Comprehensive Style Guide") {
    PreviewUIViewController {
        let vc = UIViewController()
        vc.view.backgroundColor = .backgroundTestColor

        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false

        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 0
        stackView.alignment = .fill
        stackView.translatesAutoresizingMaskIntoConstraints = false

        // Helper to create section headers
        func createSectionLabel(_ text: String, size: CGFloat = 20, color: UIColor? = nil) -> UILabel {
            let label = UILabel()
            label.text = text
            label.font = StyleProvider.fontWith(type: .bold, size: size)
            label.textColor = color ?? StyleProvider.Color.highlightPrimary
            label.textAlignment = .left
            label.translatesAutoresizingMaskIntoConstraints = false
            return label
        }

        // Helper to create description labels
        func createDescriptionLabel(_ text: String, italic: Bool = false) -> UILabel {
            let label = UILabel()
            label.text = text
            label.font = StyleProvider.fontWith(type: .regular, size: 13)
            label.textColor = StyleProvider.Color.textSecondary
            label.numberOfLines = 0
            label.translatesAutoresizingMaskIntoConstraints = false
            return label
        }

        // Helper to create detail labels
        func createDetailLabel(_ text: String) -> UILabel {
            let label = UILabel()
            label.text = text
            label.font = StyleProvider.fontWith(type: .regular, size: 11)
            label.textColor = StyleProvider.Color.textSecondary
            label.numberOfLines = 0
            label.backgroundColor = UIColor.systemGray5
            label.layer.cornerRadius = 6
            label.clipsToBounds = true
            label.translatesAutoresizingMaskIntoConstraints = false

            let padding: CGFloat = 8
            label.layoutMargins = UIEdgeInsets(top: padding, left: padding, bottom: padding, right: padding)

            return label
        }

        // Helper to create example containers
        func createExampleContainer(title: String, description: String, viewModel: MockScoreViewModel) -> UIView {
            let container = UIView()
            container.translatesAutoresizingMaskIntoConstraints = false
            container.backgroundColor = .systemGray3
            container.layer.cornerRadius = 8

            let titleLabel = UILabel()
            titleLabel.text = title
            titleLabel.font = StyleProvider.fontWith(type: .medium, size: 13)
            titleLabel.textColor = StyleProvider.Color.textPrimary
            titleLabel.numberOfLines = 0
            titleLabel.translatesAutoresizingMaskIntoConstraints = false

            let descLabel = UILabel()
            descLabel.text = description
            descLabel.font = StyleProvider.fontWith(type: .regular, size: 11)
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
                titleLabel.topAnchor.constraint(equalTo: container.topAnchor, constant: 10),
                titleLabel.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 10),
                titleLabel.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -10),

                descLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 3),
                descLabel.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 10),
                descLabel.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -10),

                scoreView.topAnchor.constraint(equalTo: descLabel.bottomAnchor, constant: 10),
                scoreView.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -10),
                scoreView.bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: -10)
            ])

            return container
        }

        // Helper to add spacer
        func addSpacer(_ height: CGFloat) {
            let spacer = UIView()
            spacer.translatesAutoresizingMaskIntoConstraints = false
            spacer.heightAnchor.constraint(equalToConstant: height).isActive = true
            stackView.addArrangedSubview(spacer)
        }

        // INTRODUCTION
        let intro = createDescriptionLabel(
            "ScoreView has two independent styling dimensions:\n\n" +
            "1. ScoreCellStyle - Container appearance (border/background/plain)\n" +
            "2. HighlightingMode - Text color logic (winner/loser/both/none)\n\n" +
            "These work together to create flexible score displays."
        )
        intro.font = StyleProvider.fontWith(type: .medium, size: 14)
        stackView.addArrangedSubview(intro)
        addSpacer(16)

        // PART 1: SCORECELLSTYLE
        stackView.addArrangedSubview(createSectionLabel("Part 1: ScoreCellStyle (Container)"))
        addSpacer(6)
        stackView.addArrangedSubview(createDescriptionLabel("Controls the visual container: border, background, or plain", italic: true))
        addSpacer(10)

        // Simple Style
        stackView.addArrangedSubview(createSectionLabel("Simple Style", size: 15, color: StyleProvider.Color.textPrimary))
        addSpacer(4)
        let simpleVM = MockScoreViewModel(scoreCells: [
            ScoreDisplayData(id: "1", homeScore: "6", awayScore: "4", style: .simple, highlightingMode: .noHighlight)
        ], visualState: .display)
        stackView.addArrangedSubview(createExampleContainer(
            title: "Plain container, no border, no background",
            description: "Width: 26pt, transparent background",
            viewModel: simpleVM
        ))
        addSpacer(10)

        // Border Style
        stackView.addArrangedSubview(createSectionLabel("Border Style", size: 15, color: StyleProvider.Color.textPrimary))
        addSpacer(4)
        let borderVM = MockScoreViewModel(scoreCells: [
            ScoreDisplayData(id: "2", homeScore: "25", awayScore: "22", style: .border, highlightingMode: .noHighlight)
        ], visualState: .display)
        stackView.addArrangedSubview(createExampleContainer(
            title: "1pt border outline in highlightPrimary color",
            description: "Width: 26pt, transparent background, bordered",
            viewModel: borderVM
        ))
        addSpacer(10)

        // Background Style
        stackView.addArrangedSubview(createSectionLabel("Background Style", size: 15, color: StyleProvider.Color.textPrimary))
        addSpacer(4)
        let backgroundVM = MockScoreViewModel(scoreCells: [
            ScoreDisplayData(id: "3", homeScore: "105", awayScore: "98", style: .background, highlightingMode: .noHighlight)
        ], visualState: .display)
        stackView.addArrangedSubview(createExampleContainer(
            title: "Filled background in backgroundPrimary color",
            description: "Width: 29pt (slightly wider), filled background",
            viewModel: backgroundVM
        ))
        addSpacer(16)

        // PART 2: HIGHLIGHTINGMODE
        stackView.addArrangedSubview(createSectionLabel("Part 2: HighlightingMode (Text Color)"))
        addSpacer(6)
        stackView.addArrangedSubview(createDescriptionLabel("Controls text colors based on score comparison", italic: true))
        addSpacer(10)

        // Winner/Loser
        stackView.addArrangedSubview(createSectionLabel("Winner/Loser Highlighting", size: 15, color: StyleProvider.Color.textPrimary))
        addSpacer(4)
        let winnerLoserVM = MockScoreViewModel(scoreCells: [
            ScoreDisplayData(id: "4", homeScore: "6", awayScore: "4", style: .simple, highlightingMode: .winnerLoser),
            ScoreDisplayData(id: "5", homeScore: "3", awayScore: "6", style: .simple, highlightingMode: .winnerLoser),
            ScoreDisplayData(id: "6", homeScore: "5", awayScore: "5", style: .simple, highlightingMode: .winnerLoser)
        ], visualState: .display)
        stackView.addArrangedSubview(createExampleContainer(
            title: "Winner: black (textPrimary), Loser: gray (textSecondary)",
            description: "Used for completed sets/quarters - compares scores",
            viewModel: winnerLoserVM
        ))
        addSpacer(4)
        stackView.addArrangedSubview(createDetailLabel("Left: Home wins (6>4), Middle: Away wins (6>3), Right: Tied (5=5)"))
        addSpacer(10)

        // Both Highlight
        stackView.addArrangedSubview(createSectionLabel("Both Highlight", size: 15, color: StyleProvider.Color.textPrimary))
        addSpacer(4)
        let bothHighlightVM = MockScoreViewModel(scoreCells: [
            ScoreDisplayData(id: "7", homeScore: "30", awayScore: "15", style: .simple, highlightingMode: .bothHighlight),
            ScoreDisplayData(id: "8", homeScore: "7", awayScore: "6", style: .simple, highlightingMode: .bothHighlight)
        ], visualState: .display)
        stackView.addArrangedSubview(createExampleContainer(
            title: "Both scores: orange (highlightPrimary)",
            description: "Used for current game/set and match totals",
            viewModel: bothHighlightVM
        ))
        addSpacer(4)
        stackView.addArrangedSubview(createDetailLabel("Both scores highlighted regardless of winner"))
        addSpacer(10)

        // No Highlight
        stackView.addArrangedSubview(createSectionLabel("No Highlight", size: 15, color: StyleProvider.Color.textPrimary))
        addSpacer(4)
        let noHighlightVM = MockScoreViewModel(scoreCells: [
            ScoreDisplayData(id: "9", homeScore: "2", awayScore: "1", style: .simple, highlightingMode: .noHighlight),
            ScoreDisplayData(id: "10", homeScore: "0", awayScore: "3", style: .simple, highlightingMode: .noHighlight)
        ], visualState: .display)
        stackView.addArrangedSubview(createExampleContainer(
            title: "Both scores: black (textPrimary)",
            description: "Default colors, no special highlighting",
            viewModel: noHighlightVM
        ))
        addSpacer(4)
        stackView.addArrangedSubview(createDetailLabel("No color differentiation for winners"))
        addSpacer(16)

        // PART 3: COMBINATIONS
        stackView.addArrangedSubview(createSectionLabel("Part 3: Style × Highlighting Combinations"))
        addSpacer(6)
        stackView.addArrangedSubview(createDescriptionLabel("Each style can work with any highlighting mode", italic: true))
        addSpacer(10)

        // Simple × All Modes
        stackView.addArrangedSubview(createSectionLabel("Simple Style × All Highlighting Modes", size: 15, color: StyleProvider.Color.textPrimary))
        addSpacer(4)
        let simpleAllVM = MockScoreViewModel(scoreCells: [
            ScoreDisplayData(id: "11", homeScore: "6", awayScore: "4", style: .simple, highlightingMode: .winnerLoser),
            ScoreDisplayData(id: "12", homeScore: "7", awayScore: "6", style: .simple, highlightingMode: .bothHighlight),
            ScoreDisplayData(id: "13", homeScore: "2", awayScore: "1", style: .simple, highlightingMode: .noHighlight)
        ], visualState: .display)
        stackView.addArrangedSubview(createExampleContainer(
            title: "Simple container with different highlighting",
            description: "Left: winnerLoser, Middle: bothHighlight, Right: noHighlight",
            viewModel: simpleAllVM
        ))
        addSpacer(10)

        // Border × All Modes
        stackView.addArrangedSubview(createSectionLabel("Border Style × All Highlighting Modes", size: 15, color: StyleProvider.Color.textPrimary))
        addSpacer(4)
        let borderAllVM = MockScoreViewModel(scoreCells: [
            ScoreDisplayData(id: "14", homeScore: "25", awayScore: "22", style: .border, highlightingMode: .winnerLoser),
            ScoreDisplayData(id: "15", homeScore: "5", awayScore: "4", style: .border, highlightingMode: .bothHighlight),
            ScoreDisplayData(id: "16", homeScore: "3", awayScore: "1", style: .border, highlightingMode: .noHighlight)
        ], visualState: .display)
        stackView.addArrangedSubview(createExampleContainer(
            title: "Bordered container with different highlighting",
            description: "Left: winnerLoser, Middle: bothHighlight, Right: noHighlight",
            viewModel: borderAllVM
        ))
        addSpacer(10)

        // Background × All Modes
        stackView.addArrangedSubview(createSectionLabel("Background Style × All Highlighting Modes", size: 15, color: StyleProvider.Color.textPrimary))
        addSpacer(4)
        let backgroundAllVM = MockScoreViewModel(scoreCells: [
            ScoreDisplayData(id: "17", homeScore: "105", awayScore: "98", style: .background, highlightingMode: .winnerLoser),
            ScoreDisplayData(id: "18", homeScore: "7", awayScore: "6", style: .background, highlightingMode: .bothHighlight),
            ScoreDisplayData(id: "19", homeScore: "2", awayScore: "1", style: .background, highlightingMode: .noHighlight)
        ], visualState: .display)
        stackView.addArrangedSubview(createExampleContainer(
            title: "Filled background with different highlighting",
            description: "Left: winnerLoser, Middle: bothHighlight, Right: noHighlight",
            viewModel: backgroundAllVM
        ))
        addSpacer(16)

        // PART 4: REAL-WORLD EXAMPLES
        stackView.addArrangedSubview(createSectionLabel("Part 4: Real-World Examples"))
        addSpacer(6)
        stackView.addArrangedSubview(createDescriptionLabel("How styles combine in practical match displays", italic: true))
        addSpacer(10)

        // Tennis Example
        stackView.addArrangedSubview(createSectionLabel("Tennis Match", size: 15, color: StyleProvider.Color.textPrimary))
        addSpacer(4)
        let tennisRealVM = MockScoreViewModel(scoreCells: [
            ScoreDisplayData(
                id: "current_game",
                homeScore: "30",
                awayScore: "15",
                style: .background,
                highlightingMode: .bothHighlight,
                showsTrailingSeparator: true,
                servingPlayer: .home
            ),
            ScoreDisplayData(id: "set1", homeScore: "6", awayScore: "4", style: .simple, highlightingMode: .winnerLoser),
            ScoreDisplayData(id: "set2", homeScore: "4", awayScore: "6", style: .simple, highlightingMode: .winnerLoser),
            ScoreDisplayData(id: "set3", homeScore: "7", awayScore: "6", style: .simple, highlightingMode: .bothHighlight)
        ], visualState: .display)
        stackView.addArrangedSubview(createExampleContainer(
            title: "[●] [30/15] | [6/4] [4/6] [7/6]",
            description: "Current game + separator + completed sets + current set",
            viewModel: tennisRealVM
        ))
        addSpacer(4)
        stackView.addArrangedSubview(createDetailLabel(
            "• Game: background + bothHighlight (both orange)\n" +
            "• Separator (|) after current game\n" +
            "• Serving indicator (●) for home player\n" +
            "• Sets 1-2: simple + winnerLoser (winner black, loser gray)\n" +
            "• Set 3: simple + bothHighlight (both orange - current)"
        ))
        addSpacer(10)

        // Basketball Example
        stackView.addArrangedSubview(createSectionLabel("Basketball Match", size: 15, color: StyleProvider.Color.textPrimary))
        addSpacer(4)
        let basketballRealVM = MockScoreViewModel(scoreCells: [
            ScoreDisplayData(id: "q1", homeScore: "25", awayScore: "22", style: .simple, highlightingMode: .winnerLoser),
            ScoreDisplayData(id: "q2", homeScore: "18", awayScore: "28", style: .simple, highlightingMode: .winnerLoser),
            ScoreDisplayData(id: "q3", homeScore: "31", awayScore: "24", style: .simple, highlightingMode: .winnerLoser),
            ScoreDisplayData(id: "q4", homeScore: "26", awayScore: "30", style: .simple, highlightingMode: .winnerLoser),
            ScoreDisplayData(id: "total", homeScore: "100", awayScore: "104", style: .background, highlightingMode: .bothHighlight)
        ], visualState: .display)
        stackView.addArrangedSubview(createExampleContainer(
            title: "[25/22] [18/28] [31/24] [26/30] [100/104]",
            description: "Quarters + final score",
            viewModel: basketballRealVM
        ))
        addSpacer(4)
        stackView.addArrangedSubview(createDetailLabel(
            "• Q1-Q4: simple + winnerLoser (quarter winners highlighted)\n" +
            "• Total: background + bothHighlight (both orange)\n" +
            "• No serving indicator for basketball"
        ))
        addSpacer(16)

        // SUMMARY
        stackView.addArrangedSubview(createSectionLabel("Summary: Independent Dimensions"))
        addSpacer(6)
        let summary = createDescriptionLabel(
            "ScoreCellStyle (Container):\n" +
            "• .simple - Plain, 26pt\n" +
            "• .border - 1pt outline, 26pt\n" +
            "• .background - Filled, 29pt\n\n" +
            "HighlightingMode (Text Color):\n" +
            "• .winnerLoser - Black/gray by score\n" +
            "• .bothHighlight - Both orange\n" +
            "• .noHighlight - Both black\n\n" +
            "3 styles × 3 modes = 9 combinations"
        )
        summary.font = StyleProvider.fontWith(type: .medium, size: 13)
        summary.backgroundColor = StyleProvider.Color.backgroundPrimary
        summary.layer.cornerRadius = 8
        summary.clipsToBounds = true
        let padding: CGFloat = 12
        summary.layoutMargins = UIEdgeInsets(top: padding, left: padding, bottom: padding, right: padding)
        stackView.addArrangedSubview(summary)

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
