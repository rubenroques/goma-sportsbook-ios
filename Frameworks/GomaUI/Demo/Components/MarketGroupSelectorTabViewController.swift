import UIKit
import Combine
import GomaUI

class MarketGroupSelectorTabViewController: UIViewController {
    
    // MARK: - Private Properties
    private let scrollView = UIScrollView()
    private let stackView = UIStackView()
    private var viewModels: [MockMarketGroupSelectorTabViewModel] = []
    private var tabViews: [MarketGroupSelectorTabView] = []
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Demo Controls
    private let controlsStackView = UIStackView()
    private let stateSegmentedControl = UISegmentedControl(items: ["Idle", "Loading", "Empty", "Disabled"])
    private let addTabButton = UIButton(type: .system)
    private let removeTabButton = UIButton(type: .system)
    private let clearSelectionButton = UIButton(type: .system)
    private let selectFirstButton = UIButton(type: .system)
    private let selectionEventLabel = UILabel()
    
    // MARK: - Layout Constants
    private struct Constants {
        static let spacing: CGFloat = 20.0
        static let padding: CGFloat = 16.0
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
        setupSelectionObservation()
    }
    
    // MARK: - Setup Methods
    private func setupNavigationBar() {
        title = "Market Group Selector Tab"
        navigationController?.navigationBar.prefersLargeTitles = true
        view.backgroundColor = .systemBackground
    }
    
    private func setupViews() {
        view.addSubview(scrollView)
        scrollView.addSubview(stackView)
        view.addSubview(controlsStackView)
        
        // Scroll view setup
        scrollView.showsVerticalScrollIndicator = true
        scrollView.alwaysBounceVertical = true
        
        // Stack view setup
        stackView.axis = .vertical
        stackView.spacing = Constants.spacing
        stackView.alignment = .fill
        stackView.distribution = .fill
        
        // Controls stack view setup
        controlsStackView.axis = .vertical
        controlsStackView.spacing = 12
        controlsStackView.alignment = .fill
        controlsStackView.backgroundColor = .systemGroupedBackground
        controlsStackView.layer.cornerRadius = 12
        controlsStackView.layoutMargins = UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)
        controlsStackView.isLayoutMarginsRelativeArrangement = true
    }
    
    private func setupConstraints() {
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        stackView.translatesAutoresizingMaskIntoConstraints = false
        controlsStackView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            // Controls stack view (fixed at bottom)
            controlsStackView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: Constants.padding),
            controlsStackView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -Constants.padding),
            controlsStackView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -Constants.padding),
            
            // Scroll view (above controls)
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: controlsStackView.topAnchor, constant: -Constants.padding),
            
            // Stack view (content)
            stackView.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: Constants.padding),
            stackView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: Constants.padding),
            stackView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor, constant: -Constants.padding),
            stackView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor, constant: -Constants.padding),
            stackView.widthAnchor.constraint(equalTo: scrollView.widthAnchor, constant: -Constants.padding * 2)
        ])
    }
    
    private func setupComponents() {
        // Create demo configurations
        let demoConfigurations: [(String, MockMarketGroupSelectorTabViewModel)] = [
            ("Standard Sports Markets", MockMarketGroupSelectorTabViewModel.standardSportsMarkets),
            ("Limited Markets", MockMarketGroupSelectorTabViewModel.limitedMarkets),
            ("Mixed State Markets", MockMarketGroupSelectorTabViewModel.mixedStateMarkets),
            ("Empty Markets", MockMarketGroupSelectorTabViewModel.emptyMarkets),
            ("Loading Markets", MockMarketGroupSelectorTabViewModel.loadingMarkets),
            ("Disabled Markets", MockMarketGroupSelectorTabViewModel.disabledMarkets)
        ]
        
        for (title, viewModel) in demoConfigurations {
            addDemoSection(title: title, viewModel: viewModel)
        }
    }
    
    private func addDemoSection(title: String, viewModel: MockMarketGroupSelectorTabViewModel) {
        // Section title
        let titleLabel = UILabel()
        titleLabel.text = title
        titleLabel.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        titleLabel.textColor = .label
        stackView.addArrangedSubview(titleLabel)
        
        // Create tab view
        let tabView = MarketGroupSelectorTabView(viewModel: viewModel)
        tabView.backgroundColor = .systemBackground
        tabView.layer.borderColor = UIColor.separator.cgColor
        tabView.layer.borderWidth = 1
        tabView.layer.cornerRadius = 8
        
        // Set height constraint
        let heightConstraint = tabView.heightAnchor.constraint(equalToConstant: 70)
        heightConstraint.isActive = true
        
        stackView.addArrangedSubview(tabView)
        
        // Store references
        viewModels.append(viewModel)
        tabViews.append(tabView)
        
        // Add separator
        let separator = UIView()
        separator.backgroundColor = .separator
        separator.heightAnchor.constraint(equalToConstant: 1).isActive = true
        stackView.addArrangedSubview(separator)
    }
    
    private func setupControls() {
        // State control
        let stateLabel = UILabel()
        stateLabel.text = "Component State:"
        stateLabel.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        stateLabel.textColor = .label
        controlsStackView.addArrangedSubview(stateLabel)
        
        stateSegmentedControl.selectedSegmentIndex = 0
        stateSegmentedControl.addTarget(self, action: #selector(stateChanged), for: .valueChanged)
        controlsStackView.addArrangedSubview(stateSegmentedControl)
        
        // Action buttons
        let actionsLabel = UILabel()
        actionsLabel.text = "Actions (affects first component):"
        actionsLabel.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        actionsLabel.textColor = .label
        controlsStackView.addArrangedSubview(actionsLabel)
        
        let buttonStackView = UIStackView()
        buttonStackView.axis = .horizontal
        buttonStackView.spacing = 8
        buttonStackView.distribution = .fillEqually
        
        // Add tab button
        addTabButton.setTitle("Add Tab", for: .normal)
        addTabButton.setTitleColor(.white, for: .normal)
        addTabButton.backgroundColor = .systemBlue
        addTabButton.layer.cornerRadius = 8
        addTabButton.addTarget(self, action: #selector(addTabTapped), for: .touchUpInside)
        buttonStackView.addArrangedSubview(addTabButton)
        
        // Remove tab button
        removeTabButton.setTitle("Remove Tab", for: .normal)
        removeTabButton.setTitleColor(.white, for: .normal)
        removeTabButton.backgroundColor = .systemRed
        removeTabButton.layer.cornerRadius = 8
        removeTabButton.addTarget(self, action: #selector(removeTabTapped), for: .touchUpInside)
        buttonStackView.addArrangedSubview(removeTabButton)
        
        controlsStackView.addArrangedSubview(buttonStackView)
        
        let actionButtonStackView = UIStackView()
        actionButtonStackView.axis = .horizontal
        actionButtonStackView.spacing = 8
        actionButtonStackView.distribution = .fillEqually
        
        // Clear selection button
        clearSelectionButton.setTitle("Clear Selection", for: .normal)
        clearSelectionButton.setTitleColor(.white, for: .normal)
        clearSelectionButton.backgroundColor = .systemOrange
        clearSelectionButton.layer.cornerRadius = 8
        clearSelectionButton.addTarget(self, action: #selector(clearSelectionTapped), for: .touchUpInside)
        actionButtonStackView.addArrangedSubview(clearSelectionButton)
        
        // Select first button
        selectFirstButton.setTitle("Select First", for: .normal)
        selectFirstButton.setTitleColor(.white, for: .normal)
        selectFirstButton.backgroundColor = .systemGreen
        selectFirstButton.layer.cornerRadius = 8
        selectFirstButton.addTarget(self, action: #selector(selectFirstTapped), for: .touchUpInside)
        actionButtonStackView.addArrangedSubview(selectFirstButton)
        
        controlsStackView.addArrangedSubview(actionButtonStackView)
        
        // Selection event label
        let selectionLabel = UILabel()
        selectionLabel.text = "Last Selection Event:"
        selectionLabel.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        selectionLabel.textColor = .label
        controlsStackView.addArrangedSubview(selectionLabel)
        
        selectionEventLabel.text = "None"
        selectionEventLabel.font = UIFont.systemFont(ofSize: 14)
        selectionEventLabel.textColor = .secondaryLabel
        selectionEventLabel.numberOfLines = 0
        controlsStackView.addArrangedSubview(selectionEventLabel)
    }
    
    private func setupSelectionObservation() {
        // Observe selection events from all view models
        for (index, viewModel) in viewModels.enumerated() {
            viewModel.selectionEventPublisher
                .sink { [weak self] selectionEvent in
                    self?.handleSelectionEvent(selectionEvent, from: index)
                }
                .store(in: &cancellables)
        }
    }
    
    // MARK: - Action Handlers
    @objc private func stateChanged() {

    }
    
    @objc private func addTabTapped() {
        guard let firstViewModel = viewModels.first else { return }
        
        let newTabId = "dynamic_\(Date().timeIntervalSince1970)"
        let newTab = MarketGroupTabItemData(
            id: newTabId,
            title: "New Tab",
            visualState: .idle
        )
        
        firstViewModel.addMarketGroup(newTab)
    }
    
    @objc private func removeTabTapped() {
        guard let firstViewModel = viewModels.first else { return }
        
        let currentGroups = firstViewModel.currentMarketGroups
        if let lastGroup = currentGroups.last {
            firstViewModel.removeMarketGroup(id: lastGroup.id)
        }
    }
    
    @objc private func clearSelectionTapped() {
        guard let firstViewModel = viewModels.first else { return }
        firstViewModel.clearSelection()
    }
    
    @objc private func selectFirstTapped() {
        guard let firstViewModel = viewModels.first else { return }
        firstViewModel.selectFirstAvailableMarketGroup()
    }
    
    private func handleSelectionEvent(_ event: MarketGroupSelectionEvent, from componentIndex: Int) {
        
    }
} 
