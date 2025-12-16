import UIKit
import Combine
import GomaUI

class CasinoCategorySectionViewController: UIViewController {
    
    // MARK: - Properties
    private var interactiveCategorySection: CasinoCategorySectionView!
    private var currentViewModelIndex = 0
    private let availableViewModels: [MockCasinoCategorySectionViewModel] = [
        MockCasinoCategorySectionViewModel.newGamesSection,
        MockCasinoCategorySectionViewModel.popularGamesSection,
        MockCasinoCategorySectionViewModel.slotGamesSection,
        MockCasinoCategorySectionViewModel.emptySection
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
        view.backgroundColor = StyleProvider.Color.backgroundPrimary
        
        // Description label
        descriptionLabel = UILabel()
        descriptionLabel.text = "The CasinoCategorySectionView combines a CasinoCategoryBarView header with a horizontal collection of CasinoGameCardViews. Features MVVM-compliant child ViewModel management, game selection callbacks, and reactive updates."
        descriptionLabel.font = StyleProvider.fontWith(type: .regular, size: 14)
        descriptionLabel.textColor = StyleProvider.Color.textSecondary
        descriptionLabel.numberOfLines = 0
        descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        
        // Examples stack view
        examplesStackView = UIStackView()
        examplesStackView.axis = .vertical
        examplesStackView.spacing = 32
        examplesStackView.alignment = .fill
        examplesStackView.distribution = .fill
        examplesStackView.translatesAutoresizingMaskIntoConstraints = false
        
        // Create sample category sections
        let newGamesSection = CasinoCategorySectionView(viewModel: MockCasinoCategorySectionViewModel.newGamesSection)
        let popularGamesSection = CasinoCategorySectionView(viewModel: MockCasinoCategorySectionViewModel.popularGamesSection)
        let slotGamesSection = CasinoCategorySectionView(viewModel: MockCasinoCategorySectionViewModel.slotGamesSection)
        let placeholderSection = CasinoCategorySectionView() // No viewModel - shows placeholder
        
        // Setup callbacks
        newGamesSection.onGameSelected = { [weak self] gameId in
            self?.actionLabel.text = "Game selected from New Games: \(gameId)"
        }
        
        newGamesSection.onCategoryButtonTapped = { [weak self] categoryId in
            self?.actionLabel.text = "Category button tapped: \(categoryId)"
        }
        
        popularGamesSection.onGameSelected = { [weak self] gameId in
            self?.actionLabel.text = "Game selected from Popular Games: \(gameId)"
        }
        
        popularGamesSection.onCategoryButtonTapped = { [weak self] categoryId in
            self?.actionLabel.text = "Category button tapped: \(categoryId)"
        }
        
        slotGamesSection.onGameSelected = { [weak self] gameId in
            self?.actionLabel.text = "Game selected from Slot Games: \(gameId)"
        }
        
        slotGamesSection.onCategoryButtonTapped = { [weak self] categoryId in
            self?.actionLabel.text = "Category button tapped: \(categoryId)"
        }
        
        placeholderSection.onGameSelected = { [weak self] gameId in
            self?.actionLabel.text = "Game selected from Placeholder: \(gameId)"
        }
        
        // Add example labels and sections
        let newGamesLabel = createSectionLabel("New Games Section (4 games):")
        let popularGamesLabel = createSectionLabel("Popular Games Section (3 games):")
        let slotGamesLabel = createSectionLabel("Slot Games Section (2 games):")
        let placeholderLabel = createSectionLabel("Placeholder Section (no viewModel):")
        
        examplesStackView.addArrangedSubview(newGamesLabel)
        examplesStackView.addArrangedSubview(newGamesSection)
        examplesStackView.addArrangedSubview(popularGamesLabel)
        examplesStackView.addArrangedSubview(popularGamesSection)
        examplesStackView.addArrangedSubview(slotGamesLabel)
        examplesStackView.addArrangedSubview(slotGamesSection)
        examplesStackView.addArrangedSubview(placeholderLabel)
        examplesStackView.addArrangedSubview(placeholderSection)
        
        // Interactive category section for runtime configuration
        interactiveCategorySection = CasinoCategorySectionView(viewModel: availableViewModels[0])
        interactiveCategorySection.onGameSelected = { [weak self] gameId in
            self?.actionLabel.text = "Interactive game selected: \(gameId)"
        }
        interactiveCategorySection.onCategoryButtonTapped = { [weak self] categoryId in
            self?.actionLabel.text = "Interactive category button tapped: \(categoryId)"
        }
        interactiveCategorySection.translatesAutoresizingMaskIntoConstraints = false
        
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
        
        let interactiveLabel = createSectionLabel("Interactive Section (runtime configuration):")
        contentView.addSubview(interactiveLabel)
        contentView.addSubview(interactiveCategorySection)
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
            interactiveLabel.topAnchor.constraint(equalTo: examplesStackView.bottomAnchor, constant: 40),
            interactiveLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            interactiveLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            interactiveCategorySection.topAnchor.constraint(equalTo: interactiveLabel.bottomAnchor, constant: 12),
            interactiveCategorySection.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            interactiveCategorySection.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            
            // Action label
            actionLabel.topAnchor.constraint(equalTo: interactiveCategorySection.bottomAnchor, constant: 20),
            actionLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            actionLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            actionLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -20)
        ])
    }
    
    private func createSectionLabel(_ text: String) -> UIView {
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
        title = "Casino Category Section"
        
        // Switch section button
        let switchButton = UIBarButtonItem(
            title: "Switch",
            style: .plain,
            target: self,
            action: #selector(switchSection)
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
    @objc private func switchSection() {
        currentViewModelIndex = (currentViewModelIndex + 1) % availableViewModels.count
        let newViewModel = availableViewModels[currentViewModelIndex]
        
        // Demonstrate runtime configuration
        interactiveCategorySection.configure(with: newViewModel)
        
        let description = getSectionDescription(for: currentViewModelIndex)
        actionLabel.text = "Switched to: \(description)"
    }
    
    @objc private func clearViewModel() {
        // Demonstrate clearing viewModel (shows placeholder state)
        interactiveCategorySection.configure(with: nil)
        actionLabel.text = "ViewModel cleared - showing placeholder state"
    }
    
    @objc private func refreshGames() {
        // Demonstrate refresh functionality
        if currentViewModelIndex < availableViewModels.count {
            let currentViewModel = availableViewModels[currentViewModelIndex]
            currentViewModel.refreshGames()
            actionLabel.text = "Games refreshed - games were shuffled"
        }
    }
    
    private func getSectionDescription(for index: Int) -> String {
        switch index {
        case 0: return "New Games (4 games)"
        case 1: return "Popular Games (3 games)"
        case 2: return "Slot Games (2 games)"
        case 3: return "Empty Section (0 games)"
        default: return "Unknown"
        }
    }
}
