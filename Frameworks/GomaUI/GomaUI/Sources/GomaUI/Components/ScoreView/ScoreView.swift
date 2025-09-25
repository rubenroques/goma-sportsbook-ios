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
    
    private func updateVisualState(_ state: ScoreViewVisualState) {
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
        
        for scoreData in scoreCells {
            let cellView = ScoreCellView(data: scoreData)
            containerStackView.addArrangedSubview(cellView)
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
        label.text = "No scores"
        label.font = StyleProvider.fontWith(type: .regular, size: 14)
        label.textAlignment = .center
        label.numberOfLines = 1
        return label
    }
}

// MARK: - SwiftUI Previews
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
