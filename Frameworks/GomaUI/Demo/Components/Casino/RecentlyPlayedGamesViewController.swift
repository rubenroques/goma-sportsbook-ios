import UIKit
import Combine
import GomaUI

class RecentlyPlayedGamesViewController: UIViewController {
    
    // MARK: - Properties
    private var interactiveRecentlyPlayedView: RecentlyPlayedGamesView!
    private var currentViewModelIndex = 0
    private let availableViewModels: [MockRecentlyPlayedGamesViewModel] = [
        MockRecentlyPlayedGamesViewModel.defaultRecentlyPlayed,
        MockRecentlyPlayedGamesViewModel.fewGames,
        MockRecentlyPlayedGamesViewModel.longGameNames,
        MockRecentlyPlayedGamesViewModel.emptyRecentlyPlayed
    ]
    
    private var actionLabel: UILabel!
    private var descriptionLabel: UILabel!
    private var examplesStackView: UIStackView!
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        setupNavigationBar()
    }
    
    // MARK: - Setup
    private func setupViews() {
        view.backgroundColor = UIColor(red: 1, green: 0.92, blue: 0.92, alpha: 1)
        
        // Description label
        descriptionLabel = UILabel()
        descriptionLabel.text = "The RecentlyPlayedGamesView displays a horizontal collection of recently played casino games with a PillView header. Features include game selection callbacks, image loading, and placeholder states for empty collections."
        descriptionLabel.font = StyleProvider.fontWith(type: .regular, size: 14)
        descriptionLabel.textColor = StyleProvider.Color.textSecondary
        descriptionLabel.numberOfLines = 0
        descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        
        // Examples stack view
        examplesStackView = UIStackView()
        examplesStackView.axis = .vertical
        examplesStackView.spacing = 24
        examplesStackView.alignment = .fill
        examplesStackView.distribution = .fill
        examplesStackView.translatesAutoresizingMaskIntoConstraints = false
        
        // Create sample recently played views
        let defaultView = RecentlyPlayedGamesView(viewModel: MockRecentlyPlayedGamesViewModel.defaultRecentlyPlayed)
        let fewGamesView = RecentlyPlayedGamesView(viewModel: MockRecentlyPlayedGamesViewModel.fewGames)
        let placeholderView = RecentlyPlayedGamesView() // No viewModel - shows placeholder
        
        // Setup callbacks
        defaultView.onGameSelected = { [weak self] gameId in
            self?.actionLabel.text = "Game selected from default view: \(gameId)"
        }
        
        fewGamesView.onGameSelected = { [weak self] gameId in
            self?.actionLabel.text = "Game selected from few games view: \(gameId)"
        }
        
        placeholderView.onGameSelected = { [weak self] gameId in
            self?.actionLabel.text = "Game selected from placeholder view: \(gameId)"
        }
        
        // Add example labels
        let defaultLabelContainer = createSectionLabelContainer("Default (5 games):")
        let fewGamesLabelContainer = createSectionLabelContainer("Few games (2 games):")
        let placeholderLabelContainer = createSectionLabelContainer("Placeholder (no viewModel):")
        
        examplesStackView.addArrangedSubview(defaultLabelContainer)
        examplesStackView.addArrangedSubview(defaultView)
        examplesStackView.addArrangedSubview(fewGamesLabelContainer)
        examplesStackView.addArrangedSubview(fewGamesView)
        examplesStackView.addArrangedSubview(placeholderLabelContainer)
        examplesStackView.addArrangedSubview(placeholderView)
        
        // Interactive recently played view for runtime configuration
        interactiveRecentlyPlayedView = RecentlyPlayedGamesView(viewModel: availableViewModels[0])
        interactiveRecentlyPlayedView.onGameSelected = { [weak self] gameId in
            self?.actionLabel.text = "Interactive game selected: \(gameId)"
        }
        interactiveRecentlyPlayedView.translatesAutoresizingMaskIntoConstraints = false
        
        // Action label
        actionLabel = UILabel()
        actionLabel.text = "No action taken yet"
        actionLabel.font = StyleProvider.fontWith(type: .medium, size: 14)
        actionLabel.textColor = StyleProvider.Color.textPrimary
        actionLabel.textAlignment = .center
        actionLabel.numberOfLines = 0
        actionLabel.translatesAutoresizingMaskIntoConstraints = false
        
        // Scroll view for content
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scrollView)
        
        let contentView = UIView()
        contentView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(contentView)
        
        // Add to content view
        contentView.addSubview(descriptionLabel)
        contentView.addSubview(examplesStackView)
        
        let interactiveLabelContainer = createSectionLabelContainer("Interactive (runtime configuration):")
        contentView.addSubview(interactiveLabelContainer)
        contentView.addSubview(interactiveRecentlyPlayedView)
        contentView.addSubview(actionLabel)
        
        // Setup constraints
        NSLayoutConstraint.activate([
            // Scroll view
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            // Content view
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
            
            // Description at top
            descriptionLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 20),
            descriptionLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            descriptionLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            // Examples stack view
            examplesStackView.topAnchor.constraint(equalTo: descriptionLabel.bottomAnchor, constant: 24),
            examplesStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            examplesStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            
            // Interactive section
            interactiveLabelContainer.topAnchor.constraint(equalTo: examplesStackView.bottomAnchor, constant: 40),
            interactiveLabelContainer.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            interactiveLabelContainer.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            interactiveRecentlyPlayedView.topAnchor.constraint(equalTo: interactiveLabelContainer.bottomAnchor, constant: 12),
            interactiveRecentlyPlayedView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            interactiveRecentlyPlayedView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            
            // Action label
            actionLabel.topAnchor.constraint(equalTo: interactiveRecentlyPlayedView.bottomAnchor, constant: 20),
            actionLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            actionLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            actionLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -20)
        ])
    }
    
    private func createSectionLabelContainer(_ text: String) -> UIView {
        let label = UILabel()
        label.text = text
        label.font = StyleProvider.fontWith(type: .bold, size: 16)
        label.textColor = StyleProvider.Color.textPrimary
        label.translatesAutoresizingMaskIntoConstraints = false
        
        // Add padding
        let containerView = UIView()
        containerView.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(label)
        
        NSLayoutConstraint.activate([
            label.topAnchor.constraint(equalTo: containerView.topAnchor),
            label.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 20),
            label.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -20),
            label.bottomAnchor.constraint(equalTo: containerView.bottomAnchor)
        ])
        
        return containerView
    }
    
    private func setupNavigationBar() {
        title = "Recently Played Games"
        
        // Switch viewModel button
        let switchButton = UIBarButtonItem(
            title: "Switch",
            style: .plain,
            target: self,
            action: #selector(switchViewModel)
        )
        
        // Clear viewModel button
        let clearButton = UIBarButtonItem(
            title: "Clear",
            style: .plain,
            target: self,
            action: #selector(clearViewModel)
        )
        
        // Refresh button
        let refreshButton = UIBarButtonItem(
            title: "Refresh",
            style: .plain,
            target: self,
            action: #selector(refreshGames)
        )
        
        navigationItem.rightBarButtonItems = [switchButton, clearButton, refreshButton]
    }
    
    // MARK: - Actions
    @objc private func switchViewModel() {
        currentViewModelIndex = (currentViewModelIndex + 1) % availableViewModels.count
        let newViewModel = availableViewModels[currentViewModelIndex]
        
        // Demonstrate runtime configuration
        interactiveRecentlyPlayedView.configure(with: newViewModel)
        
        let description = getViewModelDescription(for: currentViewModelIndex)
        actionLabel.text = "Switched to: \(description)"
    }
    
    @objc private func clearViewModel() {
        // Demonstrate clearing viewModel (shows placeholder state)
        interactiveRecentlyPlayedView.configure(with: nil)
        actionLabel.text = "ViewModel cleared - showing placeholder state"
    }
    
    @objc private func refreshGames() {
        // Demonstrate refresh functionality
        if let viewModel = availableViewModels.first {
            viewModel.refreshGames()
            actionLabel.text = "Games refreshed - games were shuffled"
        }
    }
    
    private func getViewModelDescription(for index: Int) -> String {
        switch index {
        case 0: return "Default (5 games)"
        case 1: return "Few games (2 games)"
        case 2: return "Long game names"
        case 3: return "Empty (no games)"
        default: return "Unknown"
        }
    }
}
