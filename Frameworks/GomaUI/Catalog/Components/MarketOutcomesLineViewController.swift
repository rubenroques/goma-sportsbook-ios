import UIKit
import Combine
import GomaUI

class MarketOutcomesLineViewController: UIViewController {
    
    // MARK: - Private Properties
    private let scrollView = UIScrollView()
    private let stackView = UIStackView()
    private var cancellables = Set<AnyCancellable>()
    
    // Demo components
    private var threeWayMarketView: MarketOutcomesLineView!
    private var twoWayMarketView: MarketOutcomesLineView!
    private var oddsChangesView: MarketOutcomesLineView!
    private var suspendedView: MarketOutcomesLineView!
    private var seeAllView: MarketOutcomesLineView!
    
    // Demo controls
    private let controlsStackView = UIStackView()
    private let stateSegmentedControl = UISegmentedControl(items: ["Triple", "Double", "Suspended", "See All"])
    private let oddsUpdateButton = UIButton(type: .system)
    private let rapidUpdatesButton = UIButton(type: .system)
    private let selectionEventLabel = UILabel()
    
    // Layout Constants
    private struct Constants {
        static let spacing: CGFloat = 20.0
        static let padding: CGFloat = 16.0
        static let componentHeight: CGFloat = 48.0
        static let controlHeight: CGFloat = 44.0
    }
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationBar()
        setupViews()
        setupConstraints()
        setupComponents()
        setupControls()
        setupEventHandling()
    }
    
    // MARK: - Setup Methods
    private func setupNavigationBar() {
        title = "Market Outcomes Line"
        navigationController?.navigationBar.prefersLargeTitles = true
        view.backgroundColor = .systemBackground
    }
    
    private func setupViews() {
        // Scroll view setup
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.showsVerticalScrollIndicator = true
        scrollView.alwaysBounceVertical = true
        view.addSubview(scrollView)
        
        // Stack view setup
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.spacing = Constants.spacing
        stackView.alignment = .fill
        stackView.distribution = .fill
        scrollView.addSubview(stackView)
        
        // Controls stack view setup
        controlsStackView.translatesAutoresizingMaskIntoConstraints = false
        controlsStackView.axis = .vertical
        controlsStackView.spacing = 12
        controlsStackView.alignment = .fill
        controlsStackView.distribution = .fill
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            // Scroll view
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            // Stack view
            stackView.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: Constants.padding),
            stackView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: Constants.padding),
            stackView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor, constant: -Constants.padding),
            stackView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor, constant: -Constants.padding),
            stackView.widthAnchor.constraint(equalTo: scrollView.widthAnchor, constant: -2 * Constants.padding)
        ])
    }
    
    private func setupComponents() {
        // Three-way market (1X2)
        addDemoSection(
            title: "Three-Way Market (1X2)",
            description: "Standard football match with Home, Draw, Away options"
        ) {
            self.threeWayMarketView = MarketOutcomesLineView(viewModel: MockMarketOutcomesLineViewModel.threeWayMarket)
            return self.threeWayMarketView
        }
        
        // Two-way market (Over/Under)
        addDemoSection(
            title: "Two-Way Market (Over/Under)",
            description: "Market with only two outcomes, middle option hidden"
        ) {
            self.twoWayMarketView = MarketOutcomesLineView(viewModel: MockMarketOutcomesLineViewModel.twoWayMarket)
            return self.twoWayMarketView
        }
        
        // Market with odds changes
        addDemoSection(
            title: "Odds Change Indicators",
            description: "Visual indicators showing odds movements"
        ) {
            self.oddsChangesView = MarketOutcomesLineView(viewModel: MockMarketOutcomesLineViewModel.oddsChanges)
            return self.oddsChangesView
        }
        
        // Suspended market
        addDemoSection(
            title: "Suspended Market",
            description: "Market temporarily unavailable for betting"
        ) {
            self.suspendedView = MarketOutcomesLineView(viewModel: MockMarketOutcomesLineViewModel.suspendedMarket)
            return self.suspendedView
        }
        
        // See all markets
        addDemoSection(
            title: "See All Markets",
            description: "Navigation trigger to view all available markets"
        ) {
            self.seeAllView = MarketOutcomesLineView(viewModel: MockMarketOutcomesLineViewModel.seeAllMarket)
            return self.seeAllView
        }
        
        // Add controls section
        stackView.addArrangedSubview(createSeparator())
        stackView.addArrangedSubview(controlsStackView)
    }
    
    private func setupControls() {
        // State control
        let stateLabel = UILabel()
        stateLabel.text = "Display Mode (affects first market):"
        stateLabel.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        stateLabel.textColor = .label
        controlsStackView.addArrangedSubview(stateLabel)
        
        stateSegmentedControl.selectedSegmentIndex = 0
        stateSegmentedControl.addTarget(self, action: #selector(stateChanged), for: .valueChanged)
        controlsStackView.addArrangedSubview(stateSegmentedControl)
        
        // Odds update button
        let actionsLabel = UILabel()
        actionsLabel.text = "Actions:"
        actionsLabel.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        actionsLabel.textColor = .label
        controlsStackView.addArrangedSubview(actionsLabel)
        
        oddsUpdateButton.setTitle("Simulate Odds Update", for: .normal)
        oddsUpdateButton.setTitleColor(.white, for: .normal)
        oddsUpdateButton.backgroundColor = .systemBlue
        oddsUpdateButton.layer.cornerRadius = 8
        oddsUpdateButton.addTarget(self, action: #selector(updateOddsTapped), for: .touchUpInside)
        controlsStackView.addArrangedSubview(oddsUpdateButton)
        
        // Rapid updates button for testing animation interruption
        rapidUpdatesButton.setTitle("Test Animation Interruption", for: .normal)
        rapidUpdatesButton.setTitleColor(.white, for: .normal)
        rapidUpdatesButton.backgroundColor = .systemOrange
        rapidUpdatesButton.layer.cornerRadius = 8
        rapidUpdatesButton.addTarget(self, action: #selector(rapidUpdatesTapped), for: .touchUpInside)
        controlsStackView.addArrangedSubview(rapidUpdatesButton)
        
        // Selection event label
        let eventsLabel = UILabel()
        eventsLabel.text = "Selection Events:"
        eventsLabel.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        eventsLabel.textColor = .label
        controlsStackView.addArrangedSubview(eventsLabel)
        
        selectionEventLabel.text = "Tap on any outcome to see events here"
        selectionEventLabel.font = UIFont.systemFont(ofSize: 14)
        selectionEventLabel.textColor = .secondaryLabel
        selectionEventLabel.numberOfLines = 0
        selectionEventLabel.textAlignment = .center
        selectionEventLabel.backgroundColor = .systemGray6
        selectionEventLabel.layer.cornerRadius = 8
        selectionEventLabel.layer.masksToBounds = true
        
        // Add padding to the label
        let paddedContainer = UIView()
        paddedContainer.addSubview(selectionEventLabel)
        selectionEventLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            selectionEventLabel.topAnchor.constraint(equalTo: paddedContainer.topAnchor, constant: 12),
            selectionEventLabel.leadingAnchor.constraint(equalTo: paddedContainer.leadingAnchor, constant: 12),
            selectionEventLabel.trailingAnchor.constraint(equalTo: paddedContainer.trailingAnchor, constant: -12),
            selectionEventLabel.bottomAnchor.constraint(equalTo: paddedContainer.bottomAnchor, constant: -12)
        ])
        
        controlsStackView.addArrangedSubview(paddedContainer)
    }
    
    private func setupEventHandling() {
        // Setup event handlers for all market views
        setupMarketEventHandlers(threeWayMarketView, name: "Three-Way Market")
        setupMarketEventHandlers(twoWayMarketView, name: "Two-Way Market")
        setupMarketEventHandlers(oddsChangesView, name: "Odds Changes Market")
        setupMarketEventHandlers(suspendedView, name: "Suspended Market")
        setupMarketEventHandlers(seeAllView, name: "See All Market")
    }
    
    private func setupMarketEventHandlers(_ marketView: MarketOutcomesLineView, name: String) {
        marketView.onOutcomeSelected = { [weak self] _, outcomeType in
            self?.updateSelectionEvent("✅ Selected \(outcomeType) in \(name)")
        }
        
        marketView.onOutcomeDeselected = { [weak self] _, outcomeType in
            self?.updateSelectionEvent("❌ Deselected \(outcomeType) in \(name)")
        }
        
        marketView.onOutcomeLongPress = { [weak self] outcomeType in
            self?.updateSelectionEvent("👆 Long pressed \(outcomeType) in \(name)")
        }
        
        marketView.onSeeAllTapped = { [weak self] in
            self?.updateSelectionEvent("📋 See All tapped in \(name)")
        }
    }
    
    // MARK: - Helper Methods
    private func addDemoSection(title: String, description: String, componentFactory: () -> UIView) {
        // Title label
        let titleLabel = UILabel()
        titleLabel.text = title
        titleLabel.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        titleLabel.textColor = .label
        stackView.addArrangedSubview(titleLabel)
        
        // Description label
        let descriptionLabel = UILabel()
        descriptionLabel.text = description
        descriptionLabel.font = UIFont.systemFont(ofSize: 14)
        descriptionLabel.textColor = .secondaryLabel
        descriptionLabel.numberOfLines = 0
        stackView.addArrangedSubview(descriptionLabel)
        
        // Component container
        let containerView = UIView()
        containerView.backgroundColor = .systemGray6
        containerView.layer.cornerRadius = 8
        containerView.layer.masksToBounds = true
        
        let component = componentFactory()
        component.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(component)
        
        NSLayoutConstraint.activate([
            component.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 12),
            component.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 12),
            component.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -12),
            component.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -12),
            component.heightAnchor.constraint(equalToConstant: Constants.componentHeight)
        ])
        
        stackView.addArrangedSubview(containerView)
    }
    
    private func createSeparator() -> UIView {
        let separator = UIView()
        separator.backgroundColor = .separator
        separator.translatesAutoresizingMaskIntoConstraints = false
        separator.heightAnchor.constraint(equalToConstant: 1).isActive = true
        return separator
    }
    
    private func updateSelectionEvent(_ message: String) {
        selectionEventLabel.text = message
        
        // Add a subtle animation
        UIView.animate(withDuration: 0.2, animations: {
            self.selectionEventLabel.transform = CGAffineTransform(scaleX: 1.05, y: 1.05)
        }) { _ in
            UIView.animate(withDuration: 0.2) {
                self.selectionEventLabel.transform = .identity
            }
        }
    }
    
    // MARK: - Actions
    @objc private func stateChanged() {
        guard let viewModel = threeWayMarketView.viewModel as? MockMarketOutcomesLineViewModel else { return }
        
        let mode: MarketDisplayMode
        switch stateSegmentedControl.selectedSegmentIndex {
        case 0: mode = .triple
        case 1: mode = .double
        case 2: mode = .suspended(text: "Market Temporarily Suspended")
        case 3: mode = .seeAll(text: "View All Available Markets")
        default: mode = .triple
        }
        
        viewModel.setDisplayMode(mode)
        updateSelectionEvent("🔄 Display mode changed to \(mode)")
    }
    
    @objc private func updateOddsTapped() {
        guard let viewModel = oddsChangesView.viewModel as? MockMarketOutcomesLineViewModel else { return }
        
        // Simulate realistic odds changes with automatic direction calculation
        let outcomeTypes: [OutcomeType] = [.left, .middle, .right]
        let randomOutcome = outcomeTypes.randomElement() ?? .left
        let newOdds = String(format: "%.2f", Double.random(in: 1.5...5.0))
        
        // Use the enhanced method that automatically calculates direction
        viewModel.updateOddsValue(type: randomOutcome, newValue: newOdds)
        updateSelectionEvent("📈 Updated \(randomOutcome) odds to \(newOdds) (auto-calculated direction)")
    }
    
    @objc private func rapidUpdatesTapped() {
        guard let viewModel = oddsChangesView.viewModel as? MockMarketOutcomesLineViewModel else { return }
        
        // Test animation interruption by sending rapid updates to the same outcome
        let outcomeType: OutcomeType = .left
        
        // First update - should trigger up animation
        let firstOdds = "2.50"
        viewModel.updateOddsValue(type: outcomeType, newValue: firstOdds)
        updateSelectionEvent("🔄 First update: \(firstOdds) (should show UP)")
        
        // Second update after 1 second - should interrupt and show down animation
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            let secondOdds = "1.80"
            viewModel.updateOddsValue(type: outcomeType, newValue: secondOdds)
            self.updateSelectionEvent("🔄 Second update: \(secondOdds) (should interrupt UP and show DOWN)")
        }
        
        // Third update after another 1 second - should interrupt and show up animation
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            let thirdOdds = "3.20"
            viewModel.updateOddsValue(type: outcomeType, newValue: thirdOdds)
            self.updateSelectionEvent("🔄 Third update: \(thirdOdds) (should interrupt DOWN and show UP)")
        }
    }
}

// MARK: - Extensions
extension MarketOutcomesLineView {
    var viewModel: MarketOutcomesLineViewModelProtocol? {
        // This is a helper property to access the viewModel for demo purposes
        // In a real implementation, you might not expose this
        return Mirror(reflecting: self).children.first { $0.label == "viewModel" }?.value as? MarketOutcomesLineViewModelProtocol
    }
} 
