//
//  StatisticsWidgetViewController.swift
//  GomaUICatalog
//
//  Created on 2025-07-11.
//

import UIKit
import Combine
import GomaUI

class StatisticsWidgetViewController: UIViewController {
    
    // MARK: - Properties
    
    private let scrollView = UIScrollView()
    private let contentView = UIView()
    private let stackView = UIStackView()
    
    // Constants
    private let statisticsWidgetHeight: CGFloat = 220
    
    // Collapsible demo components
    private let collapsibleContainer = UIView()
    private let topContentView = UIView()
    private let toggleBarView = UIView()
    private let statsToggleButton = UIButton(type: .system)
    private let collapsibleStatsWidget = StatisticsWidgetView(viewModel: MockStatisticsWidgetViewModel.footballMatch)
    private let bottomContentView = UIView()
    private var statsHeightConstraint: NSLayoutConstraint!
    private var isStatsExpanded = false
    
    // Demo instances
    private let footballStatsWidget = StatisticsWidgetView(viewModel: MockStatisticsWidgetViewModel.footballMatch)
    private let tennisStatsWidget = StatisticsWidgetView(viewModel: MockStatisticsWidgetViewModel.tennisMatch)
    private let loadingStatsWidget = StatisticsWidgetView(viewModel: MockStatisticsWidgetViewModel.loadingState)
    private let errorStatsWidget = StatisticsWidgetView(viewModel: MockStatisticsWidgetViewModel.errorState)
    
    // Interactive controls
    private let controlsContainer = UIView()
    private let controlsStackView = UIStackView()
    
    private let refreshButton = UIButton(type: .system)
    private let errorSimulationButton = UIButton(type: .system)
    private let stateSegmentedControl = UISegmentedControl(items: ["Football", "Tennis", "Loading", "Error"])
    private let selectionEventLabel = UILabel()
    
    private var cancellables = Set<AnyCancellable>()
    
    // ViewModels for interaction
    private let footballViewModel = MockStatisticsWidgetViewModel.footballMatch
    private let tennisViewModel = MockStatisticsWidgetViewModel.tennisMatch
    private let loadingViewModel = MockStatisticsWidgetViewModel.loadingState
    private let errorViewModel = MockStatisticsWidgetViewModel.errorState
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupConstraints()
        setupBindings()
        configureInitialState()
    }
    
    // MARK: - Setup
    
    private func setupUI() {
        view.backgroundColor = StyleProvider.Color.backgroundPrimary
        title = "Statistics Widget"
        
        // Configure scroll view
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.showsVerticalScrollIndicator = true
        
        contentView.translatesAutoresizingMaskIntoConstraints = false
        
        // Configure stack view
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.spacing = 24
        stackView.alignment = .fill
        stackView.distribution = .fill
        
        // Add collapsible demo section first
        addCollapsibleSection()
        
        // Add section labels and widgets
        addSection(title: "Football Match Statistics", widget: footballStatsWidget)
        addSection(title: "Tennis Match Statistics", widget: tennisStatsWidget)
        addSection(title: "Loading State", widget: loadingStatsWidget)
        addSection(title: "Error State", widget: errorStatsWidget)
        
        // Configure controls
        setupControls()
        
        // Add views to hierarchy
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        contentView.addSubview(stackView)
        contentView.addSubview(controlsContainer)
    }
    
    private func addSection(title: String, widget: StatisticsWidgetView) {
        let sectionStack = UIStackView()
        sectionStack.axis = .vertical
        sectionStack.spacing = 8
        
        let titleLabel = UILabel()
        titleLabel.text = title
        titleLabel.font = StyleProvider.fontWith(type: .bold, size: 18)
        titleLabel.textColor = StyleProvider.Color.textPrimary
        
        widget.backgroundColor = StyleProvider.Color.backgroundSecondary
        widget.layer.cornerRadius = 12
        widget.clipsToBounds = true
        widget.translatesAutoresizingMaskIntoConstraints = false
        
        sectionStack.addArrangedSubview(titleLabel)
        sectionStack.addArrangedSubview(widget)
        
        stackView.addArrangedSubview(sectionStack)
        
        // Set height constraint for widget
        widget.heightAnchor.constraint(equalToConstant: statisticsWidgetHeight).isActive = true
    }
    
    private func setupControls() {
        controlsContainer.translatesAutoresizingMaskIntoConstraints = false
        controlsContainer.backgroundColor = StyleProvider.Color.backgroundSecondary
        controlsContainer.layer.cornerRadius = 12
        
        controlsStackView.translatesAutoresizingMaskIntoConstraints = false
        controlsStackView.axis = .vertical
        controlsStackView.spacing = 16
        controlsStackView.alignment = .fill
        
        // State control
        let stateLabel = UILabel()
        stateLabel.text = "Select Demo State:"
        stateLabel.font = StyleProvider.fontWith(type: .regular, size: 12)
        stateLabel.textColor = StyleProvider.Color.textSecondary
        
        stateSegmentedControl.selectedSegmentIndex = 0
        stateSegmentedControl.addTarget(self, action: #selector(stateChanged), for: .valueChanged)
        
        // Refresh button
        refreshButton.setTitle("Refresh Current Widget", for: .normal)
        refreshButton.titleLabel?.font = StyleProvider.fontWith(type: .medium, size: 16)
        refreshButton.backgroundColor = StyleProvider.Color.highlightPrimary
        refreshButton.setTitleColor(StyleProvider.Color.textPrimary, for: .normal)
        refreshButton.layer.cornerRadius = 8
        refreshButton.addTarget(self, action: #selector(refreshTapped), for: .touchUpInside)
        
        // Error simulation button
        errorSimulationButton.setTitle("Simulate Error", for: .normal)
        errorSimulationButton.titleLabel?.font = StyleProvider.fontWith(type: .medium, size: 16)
        errorSimulationButton.backgroundColor = StyleProvider.Color.backgroundSecondary
        errorSimulationButton.setTitleColor(StyleProvider.Color.textPrimary, for: .normal)
        errorSimulationButton.layer.cornerRadius = 8
        errorSimulationButton.addTarget(self, action: #selector(simulateErrorTapped), for: .touchUpInside)
        
        // Selection event label
        selectionEventLabel.text = "Tab Selection Events:"
        selectionEventLabel.font = StyleProvider.fontWith(type: .regular, size: 12)
        selectionEventLabel.textColor = StyleProvider.Color.textSecondary
        selectionEventLabel.numberOfLines = 0
        
        // Add controls to stack
        controlsStackView.addArrangedSubview(stateLabel)
        controlsStackView.addArrangedSubview(stateSegmentedControl)
        controlsStackView.addArrangedSubview(refreshButton)
        controlsStackView.addArrangedSubview(errorSimulationButton)
        controlsStackView.addArrangedSubview(selectionEventLabel)
        
        controlsContainer.addSubview(controlsStackView)
    }
    
    private func addCollapsibleSection() {
        // Create section container
        let sectionStack = UIStackView()
        sectionStack.axis = .vertical
        sectionStack.spacing = 8
        
        // Section title
        let titleLabel = UILabel()
        titleLabel.text = "Collapsible Statistics Test"
        titleLabel.font = StyleProvider.fontWith(type: .bold, size: 18)
        titleLabel.textColor = StyleProvider.Color.textPrimary
        
        // Container for all collapsible demo content
        collapsibleContainer.backgroundColor = StyleProvider.Color.backgroundSecondary
        collapsibleContainer.layer.cornerRadius = 12
        collapsibleContainer.clipsToBounds = true
        collapsibleContainer.translatesAutoresizingMaskIntoConstraints = false
        
        // Setup top content (dummy match info)
        setupTopContent()
        
        // Setup toggle bar
        setupToggleBar()
        
        // Setup collapsible statistics widget
        collapsibleStatsWidget.backgroundColor = StyleProvider.Color.backgroundTertiary
        collapsibleStatsWidget.translatesAutoresizingMaskIntoConstraints = false
        
        // Setup bottom content (dummy match events)
        setupBottomContent()
        
        // Create inner stack for collapsible content
        let innerStack = UIStackView()
        innerStack.axis = .vertical
        innerStack.spacing = 0
        innerStack.translatesAutoresizingMaskIntoConstraints = false
        
        innerStack.addArrangedSubview(topContentView)
        innerStack.addArrangedSubview(toggleBarView)
        innerStack.addArrangedSubview(collapsibleStatsWidget)
        innerStack.addArrangedSubview(bottomContentView)
        
        collapsibleContainer.addSubview(innerStack)
        
        // Add constraints for inner stack
        NSLayoutConstraint.activate([
            innerStack.topAnchor.constraint(equalTo: collapsibleContainer.topAnchor),
            innerStack.leadingAnchor.constraint(equalTo: collapsibleContainer.leadingAnchor),
            innerStack.trailingAnchor.constraint(equalTo: collapsibleContainer.trailingAnchor),
            innerStack.bottomAnchor.constraint(equalTo: collapsibleContainer.bottomAnchor)
        ])
        
        // Set up the height constraint for animation
        statsHeightConstraint = collapsibleStatsWidget.heightAnchor.constraint(equalToConstant: 0)
        statsHeightConstraint.isActive = true
        
        // Add to main section stack
        sectionStack.addArrangedSubview(titleLabel)
        sectionStack.addArrangedSubview(collapsibleContainer)
        
        stackView.addArrangedSubview(sectionStack)
    }
    
    private func setupTopContent() {
        topContentView.backgroundColor = StyleProvider.Color.backgroundPrimary
        topContentView.translatesAutoresizingMaskIntoConstraints = false
        
        let contentStack = UIStackView()
        contentStack.axis = .vertical
        contentStack.spacing = 8
        contentStack.translatesAutoresizingMaskIntoConstraints = false
        
        // Match info title
        let matchLabel = UILabel()
        matchLabel.text = "Premier League - Matchday 23"
        matchLabel.font = StyleProvider.fontWith(type: .medium, size: 14)
        matchLabel.textColor = StyleProvider.Color.textSecondary
        
        // Teams
        let teamsLabel = UILabel()
        teamsLabel.text = "Manchester United vs Liverpool"
        teamsLabel.font = StyleProvider.fontWith(type: .bold, size: 16)
        teamsLabel.textColor = StyleProvider.Color.textPrimary
        
        // Score
        let scoreLabel = UILabel()
        scoreLabel.text = "2 - 1"
        scoreLabel.font = StyleProvider.fontWith(type: .bold, size: 24)
        scoreLabel.textColor = StyleProvider.Color.highlightPrimary
        scoreLabel.textAlignment = .center
        
        contentStack.addArrangedSubview(matchLabel)
        contentStack.addArrangedSubview(teamsLabel)
        contentStack.addArrangedSubview(scoreLabel)
        
        topContentView.addSubview(contentStack)
        
        NSLayoutConstraint.activate([
            contentStack.topAnchor.constraint(equalTo: topContentView.topAnchor, constant: 16),
            contentStack.leadingAnchor.constraint(equalTo: topContentView.leadingAnchor, constant: 16),
            contentStack.trailingAnchor.constraint(equalTo: topContentView.trailingAnchor, constant: -16),
            contentStack.bottomAnchor.constraint(equalTo: topContentView.bottomAnchor, constant: -16)
        ])
    }
    
    private func setupToggleBar() {
        toggleBarView.backgroundColor = StyleProvider.Color.backgroundSecondary
        toggleBarView.translatesAutoresizingMaskIntoConstraints = false
        
        // Add separator line at top
        let separatorLine = UIView()
        separatorLine.backgroundColor = StyleProvider.Color.separatorLine
        separatorLine.translatesAutoresizingMaskIntoConstraints = false
        
        toggleBarView.addSubview(separatorLine)
        
        // Configure toggle button
        statsToggleButton.setTitle("Show Statistics ▼", for: .normal)
        statsToggleButton.titleLabel?.font = StyleProvider.fontWith(type: .medium, size: 16)
        statsToggleButton.setTitleColor(StyleProvider.Color.highlightPrimary, for: .normal)
        statsToggleButton.addTarget(self, action: #selector(toggleStatistics), for: .touchUpInside)
        statsToggleButton.translatesAutoresizingMaskIntoConstraints = false
        
        toggleBarView.addSubview(statsToggleButton)
        
        NSLayoutConstraint.activate([
            // Separator line
            separatorLine.topAnchor.constraint(equalTo: toggleBarView.topAnchor),
            separatorLine.leadingAnchor.constraint(equalTo: toggleBarView.leadingAnchor),
            separatorLine.trailingAnchor.constraint(equalTo: toggleBarView.trailingAnchor),
            separatorLine.heightAnchor.constraint(equalToConstant: 1),
            
            // Toggle button
            statsToggleButton.topAnchor.constraint(equalTo: separatorLine.bottomAnchor),
            statsToggleButton.leadingAnchor.constraint(equalTo: toggleBarView.leadingAnchor),
            statsToggleButton.trailingAnchor.constraint(equalTo: toggleBarView.trailingAnchor),
            statsToggleButton.bottomAnchor.constraint(equalTo: toggleBarView.bottomAnchor),
            statsToggleButton.heightAnchor.constraint(equalToConstant: 44)
        ])
    }
    
    private func setupBottomContent() {
        bottomContentView.backgroundColor = StyleProvider.Color.backgroundPrimary
        bottomContentView.translatesAutoresizingMaskIntoConstraints = false
        
        let contentStack = UIStackView()
        contentStack.axis = .vertical
        contentStack.spacing = 12
        contentStack.translatesAutoresizingMaskIntoConstraints = false
        
        // Match events title
        let eventsTitle = UILabel()
        eventsTitle.text = "Match Events"
        eventsTitle.font = StyleProvider.fontWith(type: .bold, size: 16)
        eventsTitle.textColor = StyleProvider.Color.textPrimary
        
        // Sample events
        let event1 = createEventLabel("⚽ Goal - Bruno Fernandes (23')")
        let event2 = createEventLabel("🟨 Yellow Card - Fabinho (45')")
        let event3 = createEventLabel("⚽ Goal - Mohamed Salah (67')")
        let event4 = createEventLabel("⚽ Goal - Marcus Rashford (78')")
        
        contentStack.addArrangedSubview(eventsTitle)
        contentStack.addArrangedSubview(event1)
        contentStack.addArrangedSubview(event2)
        contentStack.addArrangedSubview(event3)
        contentStack.addArrangedSubview(event4)
        
        bottomContentView.addSubview(contentStack)
        
        NSLayoutConstraint.activate([
            contentStack.topAnchor.constraint(equalTo: bottomContentView.topAnchor, constant: 16),
            contentStack.leadingAnchor.constraint(equalTo: bottomContentView.leadingAnchor, constant: 16),
            contentStack.trailingAnchor.constraint(equalTo: bottomContentView.trailingAnchor, constant: -16),
            contentStack.bottomAnchor.constraint(equalTo: bottomContentView.bottomAnchor, constant: -16)
        ])
    }
    
    private func createEventLabel(_ text: String) -> UILabel {
        let label = UILabel()
        label.text = text
        label.font = StyleProvider.fontWith(type: .regular, size: 14)
        label.textColor = StyleProvider.Color.textSecondary
        return label
    }
    
    @objc private func toggleStatistics() {
        isStatsExpanded.toggle()
        
        // Update button text
        let buttonTitle = isStatsExpanded ? "Hide Statistics ▲" : "Show Statistics ▼"
        statsToggleButton.setTitle(buttonTitle, for: .normal)
        
        // Animate height change
        UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseInOut) {
            self.statsHeightConstraint.constant = self.isStatsExpanded ? self.statisticsWidgetHeight : 0
            self.view.layoutIfNeeded()
        }
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            // Scroll view
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            
            // Content view
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
            
            // Stack view
            stackView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 16),
            stackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            stackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            
            // Controls container
            controlsContainer.topAnchor.constraint(equalTo: stackView.bottomAnchor, constant: 24),
            controlsContainer.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            controlsContainer.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            controlsContainer.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -16),
            
            // Controls stack view
            controlsStackView.topAnchor.constraint(equalTo: controlsContainer.topAnchor, constant: 16),
            controlsStackView.leadingAnchor.constraint(equalTo: controlsContainer.leadingAnchor, constant: 16),
            controlsStackView.trailingAnchor.constraint(equalTo: controlsContainer.trailingAnchor, constant: -16),
            controlsStackView.bottomAnchor.constraint(equalTo: controlsContainer.bottomAnchor, constant: -16),
            
            // Button heights
            refreshButton.heightAnchor.constraint(equalToConstant: 44),
            errorSimulationButton.heightAnchor.constraint(equalToConstant: 44)
        ])
    }
    
    private func setupBindings() {
        // Observe selection changes from all widgets
        let viewModels: [(String, any StatisticsWidgetViewModelProtocol)] = [
            ("Football", footballViewModel),
            ("Tennis", tennisViewModel),
            ("Loading", loadingViewModel),
            ("Error", errorViewModel)
        ]
        
        for (name, viewModel) in viewModels {
            viewModel.selectedTabIndexPublisher
                .combineLatest(viewModel.tabsPublisher)
                .sink { [weak self] index, tabs in
                    guard index < tabs.count else { return }
                    let selectedTab = tabs[index]
                    self?.updateSelectionLabel(widget: name, tab: selectedTab.title, index: index)
                }
                .store(in: &cancellables)
        }
    }
    
    private func configureInitialState() {
        stateSegmentedControl.selectedSegmentIndex = 0
        updateControlsVisibility(for: 0)
    }
    
    // MARK: - Actions
    
    @objc private func stateChanged() {
        updateControlsVisibility(for: stateSegmentedControl.selectedSegmentIndex)
    }
    
    @objc private func refreshTapped() {
        let index = stateSegmentedControl.selectedSegmentIndex
        
        switch index {
        case 0: // Football
            footballViewModel.refreshAllContent()
            showAlert(title: "Refresh", message: "Refreshing Football Statistics...")
        case 1: // Tennis
            tennisViewModel.refreshAllContent()
            showAlert(title: "Refresh", message: "Refreshing Tennis Statistics...")
        case 2: // Loading
            loadingViewModel.refreshAllContent()
            showAlert(title: "Refresh", message: "Refreshing Loading State...")
        case 3: // Error
            errorViewModel.refreshAllContent()
            showAlert(title: "Retry", message: "Retrying Error State...")
        default:
            break
        }
    }
    
    @objc private func simulateErrorTapped() {
        let index = stateSegmentedControl.selectedSegmentIndex
        
        switch index {
        case 0: // Football
            footballViewModel.retryFailedLoad(for: "head-to-head")
            showAlert(title: "Error Simulation", message: "Simulating Error for Football...")
        case 1: // Tennis
            tennisViewModel.retryFailedLoad(for: "head-to-head")
            showAlert(title: "Error Simulation", message: "Simulating Error for Tennis...")
        default:
            showAlert(title: "Not Available", message: "Error simulation only available for Football and Tennis")
        }
    }
    
    // MARK: - Helper Methods
    
    private func updateControlsVisibility(for index: Int) {
        switch index {
        case 0, 1: // Football, Tennis
            refreshButton.isEnabled = true
            errorSimulationButton.isEnabled = true
        case 2: // Loading
            refreshButton.isEnabled = true
            errorSimulationButton.isEnabled = false
        case 3: // Error
            refreshButton.isEnabled = true
            errorSimulationButton.isEnabled = false
        default:
            break
        }
    }
    
    private func updateSelectionLabel(widget: String, tab: String, index: Int) {
        let timestamp = DateFormatter.localizedString(from: Date(), dateStyle: .none, timeStyle: .medium)
        selectionEventLabel.text = "Tab Selection Events:\n[\(timestamp)] \(widget): '\(tab)' (index: \(index))"
    }
    
    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}