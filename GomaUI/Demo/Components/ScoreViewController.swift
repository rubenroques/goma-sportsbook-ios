import UIKit
import GomaUI

class ScoreViewController: UIViewController {

    // MARK: - Properties
    private var scrollView: UIScrollView!
    private var stackView: UIStackView!
    private var descriptionLabel: UILabel!
    private var actionLabel: UILabel!
    
    // Score view examples
    private var tennisScoreView: ScoreView!
    private var basketballScoreView: ScoreView!
    private var footballScoreView: ScoreView!
    private var loadingScoreView: ScoreView!
    private var emptyScoreView: ScoreView!
    
    // Controls
    private var updateTennisButton: UIButton!
    private var updateBasketballButton: UIButton!
    private var toggleLoadingButton: UIButton!
    private var clearScoresButton: UIButton!
    
    // ViewModels
    private var tennisViewModel: MockScoreViewModel!
    private var basketballViewModel: MockScoreViewModel!
    private var footballViewModel: MockScoreViewModel!
    private var loadingViewModel: MockScoreViewModel!
    private var emptyViewModel: MockScoreViewModel!

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "ScoreView Demo"
        setupViews()
        layoutViews()
        setupActions()
    }

    // MARK: - Setup
    private func setupViews() {
        view.backgroundColor = .systemGray6
        
        // Create scroll view for multiple examples
        scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        
        stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 24
        stackView.alignment = .trailing
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        // Description label
        descriptionLabel = UILabel()
        descriptionLabel.text = "The ScoreView displays sports match scores with multiple cells and different visual styles. It supports real-time updates and various sports formats."
        descriptionLabel.font = StyleProvider.fontWith(type: .regular, size: 14)
        descriptionLabel.textColor = .secondaryLabel
        descriptionLabel.numberOfLines = 0
        descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        
        // Action label
        actionLabel = UILabel()
        actionLabel.text = "Interact with the buttons below to see score updates"
        actionLabel.font = StyleProvider.fontWith(type: .medium, size: 14)
        actionLabel.textAlignment = .center
        actionLabel.numberOfLines = 0
        actionLabel.translatesAutoresizingMaskIntoConstraints = false
        
        // Create score views with different examples
        setupScoreExamples()
        setupControlButtons()
        
        // Add to stack view
        stackView.addArrangedSubview(descriptionLabel)
        let tennisLabel = createSectionLabel("Tennis Match")
        stackView.addArrangedSubview(tennisLabel)
        stackView.addArrangedSubview(tennisScoreView)
        let basketballLabel = createSectionLabel("Basketball Game")
        stackView.addArrangedSubview(basketballLabel)
        stackView.addArrangedSubview(basketballScoreView)
        let footballLabel = createSectionLabel("Football Match")
        stackView.addArrangedSubview(footballLabel)
        stackView.addArrangedSubview(footballScoreView)
        let loadingLabel = createSectionLabel("Loading State")
        stackView.addArrangedSubview(loadingLabel)
        stackView.addArrangedSubview(loadingScoreView)
        let emptyLabel = createSectionLabel("Empty State")
        stackView.addArrangedSubview(emptyLabel)
        stackView.addArrangedSubview(emptyScoreView)
        let controlsLabel = createSectionLabel("Controls")
        stackView.addArrangedSubview(controlsLabel)
        stackView.addArrangedSubview(updateTennisButton)
        stackView.addArrangedSubview(updateBasketballButton)
        stackView.addArrangedSubview(toggleLoadingButton)
        stackView.addArrangedSubview(clearScoresButton)
        stackView.addArrangedSubview(actionLabel)
        
        // Override alignment for elements that should fill width
        descriptionLabel.setContentHuggingPriority(.defaultLow, for: .horizontal)
        actionLabel.setContentHuggingPriority(.defaultLow, for: .horizontal)
        
        // Manually set constraints for elements that should span full width
        NSLayoutConstraint.activate([
            descriptionLabel.leadingAnchor.constraint(equalTo: stackView.leadingAnchor),
            descriptionLabel.trailingAnchor.constraint(equalTo: stackView.trailingAnchor),
            
            tennisLabel.leadingAnchor.constraint(equalTo: stackView.leadingAnchor),
            tennisLabel.trailingAnchor.constraint(equalTo: stackView.trailingAnchor),
            
            basketballLabel.leadingAnchor.constraint(equalTo: stackView.leadingAnchor),
            basketballLabel.trailingAnchor.constraint(equalTo: stackView.trailingAnchor),
            
            footballLabel.leadingAnchor.constraint(equalTo: stackView.leadingAnchor),
            footballLabel.trailingAnchor.constraint(equalTo: stackView.trailingAnchor),
            
            loadingLabel.leadingAnchor.constraint(equalTo: stackView.leadingAnchor),
            loadingLabel.trailingAnchor.constraint(equalTo: stackView.trailingAnchor),
            
            emptyLabel.leadingAnchor.constraint(equalTo: stackView.leadingAnchor),
            emptyLabel.trailingAnchor.constraint(equalTo: stackView.trailingAnchor),
            
            controlsLabel.leadingAnchor.constraint(equalTo: stackView.leadingAnchor),
            controlsLabel.trailingAnchor.constraint(equalTo: stackView.trailingAnchor),
            
            actionLabel.leadingAnchor.constraint(equalTo: stackView.leadingAnchor),
            actionLabel.trailingAnchor.constraint(equalTo: stackView.trailingAnchor),
            
            updateTennisButton.leadingAnchor.constraint(equalTo: stackView.leadingAnchor),
            updateTennisButton.trailingAnchor.constraint(equalTo: stackView.trailingAnchor),
            
            updateBasketballButton.leadingAnchor.constraint(equalTo: stackView.leadingAnchor),
            updateBasketballButton.trailingAnchor.constraint(equalTo: stackView.trailingAnchor),
            
            toggleLoadingButton.leadingAnchor.constraint(equalTo: stackView.leadingAnchor),
            toggleLoadingButton.trailingAnchor.constraint(equalTo: stackView.trailingAnchor),
            
            clearScoresButton.leadingAnchor.constraint(equalTo: stackView.leadingAnchor),
            clearScoresButton.trailingAnchor.constraint(equalTo: stackView.trailingAnchor)
        ])
        
        scrollView.addSubview(stackView)
        view.addSubview(scrollView)
    }
    
    private func setupScoreExamples() {
        // Tennis score view
        tennisViewModel = MockScoreViewModel.tennisMatch
        tennisScoreView = ScoreView()
        tennisScoreView.configure(with: tennisViewModel)
        tennisScoreView.backgroundColor = StyleProvider.Color.backgroundColor
        tennisScoreView.layer.cornerRadius = 8
        tennisScoreView.translatesAutoresizingMaskIntoConstraints = false
        
        // Basketball score view
        basketballViewModel = MockScoreViewModel.basketballMatch
        basketballScoreView = ScoreView()
        basketballScoreView.configure(with: basketballViewModel)
        basketballScoreView.backgroundColor = StyleProvider.Color.backgroundColor
        basketballScoreView.layer.cornerRadius = 8
        basketballScoreView.translatesAutoresizingMaskIntoConstraints = false
        
        // Football score view
        footballViewModel = MockScoreViewModel.footballMatch
        footballScoreView = ScoreView()
        footballScoreView.configure(with: footballViewModel)
        footballScoreView.backgroundColor = StyleProvider.Color.backgroundColor
        footballScoreView.layer.cornerRadius = 8
        footballScoreView.translatesAutoresizingMaskIntoConstraints = false
        
        // Loading score view
        loadingViewModel = MockScoreViewModel.loading
        loadingScoreView = ScoreView()
        loadingScoreView.configure(with: loadingViewModel)
        loadingScoreView.backgroundColor = StyleProvider.Color.backgroundColor
        loadingScoreView.layer.cornerRadius = 8
        loadingScoreView.translatesAutoresizingMaskIntoConstraints = false
        
        // Empty score view
        emptyViewModel = MockScoreViewModel.empty
        emptyScoreView = ScoreView()
        emptyScoreView.configure(with: emptyViewModel)
        emptyScoreView.backgroundColor = StyleProvider.Color.backgroundColor
        emptyScoreView.layer.cornerRadius = 8
        emptyScoreView.translatesAutoresizingMaskIntoConstraints = false
    }
    
    private func setupControlButtons() {
        // Update tennis button
        updateTennisButton = createButton(title: "Update Tennis Score", backgroundColor: .systemBlue)
        
        // Update basketball button
        updateBasketballButton = createButton(title: "Update Basketball Score", backgroundColor: .systemOrange)
        
        // Toggle loading button
        toggleLoadingButton = createButton(title: "Toggle Loading State", backgroundColor: .systemPurple)
        
        // Clear scores button
        clearScoresButton = createButton(title: "Clear All Scores", backgroundColor: .systemRed)
    }
    
    private func createButton(title: String, backgroundColor: UIColor) -> UIButton {
        let button = UIButton(type: .system)
        button.setTitle(title, for: .normal)
        button.backgroundColor = backgroundColor
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = StyleProvider.fontWith(type: .medium, size: 16)
        button.layer.cornerRadius = 8
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }
    
    private func createSectionLabel(_ text: String) -> UILabel {
        let label = UILabel()
        label.text = text
        label.font = StyleProvider.fontWith(type: .bold, size: 16)
        label.textColor = StyleProvider.Color.textColor
        label.textAlignment = .left
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }
    
    private func layoutViews() {
        NSLayoutConstraint.activate([
            // Scroll view
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            // Stack view
            stackView.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: 20),
            stackView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: 20),
            stackView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor, constant: -20),
            stackView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor, constant: -20),
            stackView.widthAnchor.constraint(equalTo: scrollView.widthAnchor, constant: -40),
            
            // Button heights (score views now use intrinsic content size)
            updateTennisButton.heightAnchor.constraint(equalToConstant: 44),
            updateBasketballButton.heightAnchor.constraint(equalToConstant: 44),
            toggleLoadingButton.heightAnchor.constraint(equalToConstant: 44),
            clearScoresButton.heightAnchor.constraint(equalToConstant: 44)
        ])
    }
    
    private func setupActions() {
        updateTennisButton.addTarget(self, action: #selector(updateTennisScore), for: .touchUpInside)
        updateBasketballButton.addTarget(self, action: #selector(updateBasketballScore), for: .touchUpInside)
        toggleLoadingButton.addTarget(self, action: #selector(toggleLoadingState), for: .touchUpInside)
        clearScoresButton.addTarget(self, action: #selector(clearAllScores), for: .touchUpInside)
    }

    // MARK: - Actions
    @objc private func updateTennisScore() {
        // Simulate updating the tennis score
        let gameScores = ["15", "30", "40", "A"]
        let newGameScore = gameScores.randomElement() ?? "15"
        
        tennisViewModel.simulateScoreUpdate(homeScore: newGameScore, awayScore: "30", for: "current")
        
        actionLabel.text = "Updated tennis game score to \(newGameScore)-30"
    }
    
    @objc private func updateBasketballScore() {
        // Simulate updating basketball total score
        let homeScore = Int.random(in: 95...115)
        let awayScore = Int.random(in: 95...115)
        
        basketballViewModel.simulateScoreUpdate(homeScore: "\(homeScore)", awayScore: "\(awayScore)", for: "total")
        
        actionLabel.text = "Updated basketball final score to \(homeScore)-\(awayScore)"
    }
    
    @objc private func toggleLoadingState() {
        let currentState = loadingViewModel.currentVisualState
        
        switch currentState {
        case .loading:
            loadingViewModel.setVisualState(.display)
            loadingViewModel.updateScoreCells([
                ScoreDisplayData(id: "demo", homeScore: "3", awayScore: "1", style: .background)
            ])
            actionLabel.text = "Switched to display state"
        case .display:
            loadingViewModel.setLoading()
            actionLabel.text = "Switched to loading state"
        default:
            loadingViewModel.setLoading()
            actionLabel.text = "Started loading"
        }
    }
    
    @objc private func clearAllScores() {
        // Clear all score views temporarily
        tennisViewModel.clearScores()
        basketballViewModel.clearScores()
        footballViewModel.clearScores()
        
        actionLabel.text = "Cleared all scores - they will reload in 2 seconds"
        
        // Reload after 2 seconds
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) { [weak self] in
            self?.reloadAllScores()
        }
    }
    
    private func reloadAllScores() {
        // Restore original scores
        tennisViewModel = MockScoreViewModel.tennisMatch
        tennisScoreView.configure(with: tennisViewModel)
        
        basketballViewModel = MockScoreViewModel.basketballMatch
        basketballScoreView.configure(with: basketballViewModel)
        
        footballViewModel = MockScoreViewModel.footballMatch
        footballScoreView.configure(with: footballViewModel)
        
        actionLabel.text = "All scores reloaded"
    }
} 