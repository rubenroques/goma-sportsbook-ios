import UIKit
import Combine
import GomaUI

class CasinoCategoryBarViewController: UIViewController {
    
    // MARK: - Properties
    private var interactiveCategoryBar: CasinoCategoryBarView!
    private var currentViewModelIndex = 0
    private let availableViewModels: [MockCasinoCategoryBarViewModel] = [
        MockCasinoCategoryBarViewModel.newGames,
        MockCasinoCategoryBarViewModel.popularGames,
        MockCasinoCategoryBarViewModel.slotGames,
        MockCasinoCategoryBarViewModel.liveGames,
        MockCasinoCategoryBarViewModel.jackpotGames
    ]
    
    private var actionLabel: UILabel!
    private var descriptionLabel: UILabel!
    private var categoryBarsStackView: UIStackView!
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        setupNavigationBar()
    }
    
    // MARK: - Setup
    private func setupViews() {
        view.backgroundColor = UIColor(red: 0.1, green: 0, blue: 0, alpha: 1)
        
        // Description label
        descriptionLabel = UILabel()
        descriptionLabel.text = "The CasinoCategoryBarView displays category information with a title on the left and an action button with count and chevron on the right. Features optional viewModel initialization and runtime configuration support."
        descriptionLabel.font = StyleProvider.fontWith(type: .regular, size: 14)
        descriptionLabel.textColor = StyleProvider.Color.textSecondary
        descriptionLabel.numberOfLines = 0
        descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        
        // Category bars stack view
        categoryBarsStackView = UIStackView()
        categoryBarsStackView.axis = .vertical
        categoryBarsStackView.spacing = 8
        categoryBarsStackView.alignment = .fill
        categoryBarsStackView.distribution = .fill
        categoryBarsStackView.translatesAutoresizingMaskIntoConstraints = false
        
        // Create sample category bars
        let newGamesBar = CasinoCategoryBarView(viewModel: MockCasinoCategoryBarViewModel.newGames)
        let popularGamesBar = CasinoCategoryBarView(viewModel: MockCasinoCategoryBarViewModel.popularGames)
        let slotGamesBar = CasinoCategoryBarView(viewModel: MockCasinoCategoryBarViewModel.slotGames)
        let placeholderBar = CasinoCategoryBarView() // No viewModel - shows placeholder
        
        // Setup callbacks
        newGamesBar.onButtonTapped = { [weak self] categoryId in
            self?.actionLabel.text = "Button tapped for category: \(categoryId)"
        }
        
        popularGamesBar.onButtonTapped = { [weak self] categoryId in
            self?.actionLabel.text = "Button tapped for category: \(categoryId)"
        }
        
        slotGamesBar.onButtonTapped = { [weak self] categoryId in
            self?.actionLabel.text = "Button tapped for category: \(categoryId)"
        }
        
        categoryBarsStackView.addArrangedSubview(newGamesBar)
        categoryBarsStackView.addArrangedSubview(popularGamesBar)
        categoryBarsStackView.addArrangedSubview(slotGamesBar)
        categoryBarsStackView.addArrangedSubview(placeholderBar)
        
        // Interactive category bar for runtime configuration
        interactiveCategoryBar = CasinoCategoryBarView(viewModel: availableViewModels[0])
        interactiveCategoryBar.onButtonTapped = { [weak self] categoryId in
            self?.actionLabel.text = "Interactive button tapped for: \(categoryId)"
        }
        interactiveCategoryBar.translatesAutoresizingMaskIntoConstraints = false
        
        // Action label
        actionLabel = UILabel()
        actionLabel.text = "No action taken yet"
        actionLabel.font = StyleProvider.fontWith(type: .medium, size: 14)
        actionLabel.textColor = StyleProvider.Color.textPrimary
        actionLabel.textAlignment = .center
        actionLabel.numberOfLines = 0
        actionLabel.translatesAutoresizingMaskIntoConstraints = false
        
        // Add to view
        view.addSubview(descriptionLabel)
        view.addSubview(categoryBarsStackView)
        view.addSubview(interactiveCategoryBar)
        view.addSubview(actionLabel)
        
        // Setup constraints
        NSLayoutConstraint.activate([
            // Description at top
            descriptionLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            descriptionLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            descriptionLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            // Category bars stack view
            categoryBarsStackView.topAnchor.constraint(equalTo: descriptionLabel.bottomAnchor, constant: 24),
            categoryBarsStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            categoryBarsStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            
            // Interactive category bar
            interactiveCategoryBar.topAnchor.constraint(equalTo: categoryBarsStackView.bottomAnchor, constant: 40),
            interactiveCategoryBar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            interactiveCategoryBar.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            
            // Action label
            actionLabel.topAnchor.constraint(equalTo: interactiveCategoryBar.bottomAnchor, constant: 20),
            actionLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            actionLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20)
        ])
    }
    
    private func setupNavigationBar() {
        title = "Casino Category Bar"
        
        // Switch category button
        let switchButton = UIBarButtonItem(
            title: "Switch",
            style: .plain,
            target: self,
            action: #selector(switchCategory)
        )
        
        // Clear viewModel button
        let clearButton = UIBarButtonItem(
            title: "Clear",
            style: .plain,
            target: self,
            action: #selector(clearViewModel)
        )
        
        navigationItem.rightBarButtonItems = [switchButton, clearButton]
    }
    
    // MARK: - Actions
    @objc private func switchCategory() {
        currentViewModelIndex = (currentViewModelIndex + 1) % availableViewModels.count
        let newViewModel = availableViewModels[currentViewModelIndex]
        
        // Demonstrate runtime configuration
        interactiveCategoryBar.configure(with: newViewModel)
        
        actionLabel.text = "Switched to: \(newViewModel.categoryData.title)"
    }
    
    @objc private func clearViewModel() {
        // Demonstrate clearing viewModel (shows placeholder state)
        interactiveCategoryBar.configure(with: nil)
        actionLabel.text = "ViewModel cleared - showing placeholder state"
    }
}
