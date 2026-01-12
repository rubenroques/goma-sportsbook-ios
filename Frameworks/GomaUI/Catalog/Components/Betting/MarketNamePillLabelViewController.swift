import UIKit
import GomaUI

class MarketNamePillLabelViewController: UIViewController {
    
    // MARK: - UI Components
    private var scrollView: UIScrollView!
    private var contentStackView: UIStackView!
    private var pillView: MarketNamePillLabelView!
    private var viewModel: MockMarketNamePillLabelViewModel!
    
    // MARK: - Mock Examples
    private let mockExamples: [(title: String, viewModel: MockMarketNamePillLabelViewModel)] = [
        ("Standard Pill", MockMarketNamePillLabelViewModel.standardPill),
        ("Highlighted Pill", MockMarketNamePillLabelViewModel.highlightedPill),
        ("Disabled Pill", MockMarketNamePillLabelViewModel.disabledPill),
        ("Interactive Pill", MockMarketNamePillLabelViewModel.interactivePill),
        ("Custom Styled Pill", MockMarketNamePillLabelViewModel.customStyledPill),
        ("Pill Without Line", MockMarketNamePillLabelViewModel.pillWithoutLine),
        ("Long Text Pill", MockMarketNamePillLabelViewModel.longTextPill),
        ("Short Text Pill", MockMarketNamePillLabelViewModel.shortTextPill),
        ("1X2 Market", MockMarketNamePillLabelViewModel.winDrawWinMarket),
        ("Over/Under Market", MockMarketNamePillLabelViewModel.overUnderMarket),
        ("Handicap Market", MockMarketNamePillLabelViewModel.handicapMarket),
        ("BTTS Market", MockMarketNamePillLabelViewModel.bothTeamsToScoreMarket)
    ]
    
    private var currentExampleIndex = 0
    
    // MARK: - View Controller Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        setupInitialState()
    }
    
    // MARK: - Setup
    private func setupViews() {
        view.backgroundColor = .systemGroupedBackground
        title = "Market Name Pill Label"
        
        // Create scroll view
        scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.showsVerticalScrollIndicator = true
        view.addSubview(scrollView)
        
        // Create content stack view
        contentStackView = UIStackView()
        contentStackView.translatesAutoresizingMaskIntoConstraints = false
        contentStackView.axis = .vertical
        contentStackView.spacing = 20
        contentStackView.alignment = .fill
        contentStackView.distribution = .fill
        scrollView.addSubview(contentStackView)
        
        // Setup constraints
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            contentStackView.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: 20),
            contentStackView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: 16),
            contentStackView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor, constant: -16),
            contentStackView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor, constant: -20),
            contentStackView.widthAnchor.constraint(equalTo: scrollView.widthAnchor, constant: -32)
        ])
        
        // Add example selection controls
        addExampleControls()
        
        // Add main pill view
        addMainPillView()
        
        // Add action buttons
        addActionButtons()
        
        // Add demo section
        addDemoSection()
    }
    
    private func addExampleControls() {
        let controlsContainer = createSectionContainer(title: "Examples")
        contentStackView.addArrangedSubview(controlsContainer)
        
        // Current example label
        let currentExampleLabel = UILabel()
        currentExampleLabel.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        currentExampleLabel.textAlignment = .center
        currentExampleLabel.tag = 100 // Tag for easy access
        controlsContainer.addArrangedSubview(currentExampleLabel)
        
        // Navigation buttons
        let buttonStack = UIStackView()
        buttonStack.axis = .horizontal
        buttonStack.spacing = 12
        buttonStack.distribution = .fillEqually
        
        let previousButton = createButton(title: "Previous Example", color: .systemBlue)
        previousButton.addTarget(self, action: #selector(previousExample), for: .touchUpInside)
        
        let nextButton = createButton(title: "Next Example", color: .systemBlue)
        nextButton.addTarget(self, action: #selector(nextExample), for: .touchUpInside)
        
        buttonStack.addArrangedSubview(previousButton)
        buttonStack.addArrangedSubview(nextButton)
        controlsContainer.addArrangedSubview(buttonStack)
    }
    
    private func addMainPillView() {
        let pillContainer = createSectionContainer(title: "Live Preview")
        contentStackView.addArrangedSubview(pillContainer)
        
        // Initialize with first example
        viewModel = mockExamples[0].viewModel
        pillView = MarketNamePillLabelView(viewModel: viewModel)
        pillView.translatesAutoresizingMaskIntoConstraints = false
        
        // Center the pill view
        let centerContainer = UIView()
        centerContainer.backgroundColor = .systemBackground
        centerContainer.layer.cornerRadius = 12
        centerContainer.addSubview(pillView)
        
        NSLayoutConstraint.activate([
            pillView.centerXAnchor.constraint(equalTo: centerContainer.centerXAnchor),
            pillView.centerYAnchor.constraint(equalTo: centerContainer.centerYAnchor),
            centerContainer.heightAnchor.constraint(equalToConstant: 80)
        ])
        
        pillContainer.addArrangedSubview(centerContainer)
        
        // Handle pill interactions
        pillView.onInteraction = { [weak self] in
            print("Pill tapped!")
            self?.showInteractionAlert()
        }
    }
    
    private func addActionButtons() {
        let actionsContainer = createSectionContainer(title: "Actions")
        contentStackView.addArrangedSubview(actionsContainer)
        
        let cycleStylesButton = createButton(title: "Cycle Styles", color: .systemPurple)
        cycleStylesButton.addTarget(self, action: #selector(cycleStyles), for: .touchUpInside)
        
        actionsContainer.addArrangedSubview(cycleStylesButton)
    }
    
    private func addDemoSection() {
        let demoContainer = createSectionContainer(title: "Common Betting Markets")
        contentStackView.addArrangedSubview(demoContainer)
        
        let marketsStack = UIStackView()
        marketsStack.axis = .vertical
        marketsStack.spacing = 12
        marketsStack.distribution = .fill
        
        let bettingMarkets = [
            MockMarketNamePillLabelViewModel.winDrawWinMarket,
            MockMarketNamePillLabelViewModel.overUnderMarket,
            MockMarketNamePillLabelViewModel.handicapMarket,
            MockMarketNamePillLabelViewModel.bothTeamsToScoreMarket
        ]
        
        for market in bettingMarkets {
            let marketView = MarketNamePillLabelView(viewModel: market)
            marketView.translatesAutoresizingMaskIntoConstraints = false
            
            let marketContainer = UIView()
            marketContainer.backgroundColor = .systemBackground
            marketContainer.layer.cornerRadius = 8
            marketContainer.addSubview(marketView)
            
            NSLayoutConstraint.activate([
                marketView.leadingAnchor.constraint(equalTo: marketContainer.leadingAnchor, constant: 16),
                marketView.centerYAnchor.constraint(equalTo: marketContainer.centerYAnchor),
                marketContainer.heightAnchor.constraint(equalToConstant: 50)
            ])
            
            marketsStack.addArrangedSubview(marketContainer)
        }
        
        demoContainer.addArrangedSubview(marketsStack)
    }
    
    private func setupInitialState() {
        loadCurrentExample()
    }
    
    // MARK: - Helper Methods
    private func createSectionContainer(title: String) -> UIStackView {
        let container = UIStackView()
        container.axis = .vertical
        container.spacing = 12
        container.alignment = .fill
        container.distribution = .fill
        
        let titleLabel = UILabel()
        titleLabel.text = title
        titleLabel.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        titleLabel.textColor = .label
        
        container.addArrangedSubview(titleLabel)
        return container
    }
    
    private func createButton(title: String, color: UIColor) -> UIButton {
        let button = UIButton(type: .system)
        button.setTitle(title, for: .normal)
        button.backgroundColor = color
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 8
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        button.heightAnchor.constraint(equalToConstant: 44).isActive = true
        return button
    }
    
    private func loadCurrentExample() {
        let example = mockExamples[currentExampleIndex]
        
        // Get the current state from the mock and update our view model
        let currentState = example.viewModel.currentDisplayState
        viewModel.updateDisplayState(currentState)
        
        // Update current example label
        if let label = view.viewWithTag(100) as? UILabel {
            label.text = "\(currentExampleIndex + 1)/\(mockExamples.count): \(example.title)"
        }
    }
    
    private func showInteractionAlert() {
        let alert = UIAlertController(
            title: "Pill Interaction",
            message: "The pill was tapped! This is where you would handle market selection.",
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
    
    // MARK: - Actions
    @objc private func previousExample() {
        currentExampleIndex = (currentExampleIndex - 1 + mockExamples.count) % mockExamples.count
        loadCurrentExample()
    }
    
    @objc private func nextExample() {
        currentExampleIndex = (currentExampleIndex + 1) % mockExamples.count
        loadCurrentExample()
    }
    
    
    @objc private func cycleStyles() {
        viewModel.cycleStyles()
    }
}