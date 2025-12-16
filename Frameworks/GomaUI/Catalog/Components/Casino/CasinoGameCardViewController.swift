import UIKit
import Combine
import GomaUI

class CasinoGameCardViewController: UIViewController {
    
    // MARK: - Properties
    private var interactiveCard: CasinoGameCardView!
    private var currentViewModelIndex = 0
    private let availableViewModels: [MockCasinoGameCardViewModel] = [
        MockCasinoGameCardViewModel.plinkGoal,
        MockCasinoGameCardViewModel.aviator,
        MockCasinoGameCardViewModel.beastBelow
    ]
    
    private var actionLabel: UILabel!
    private var descriptionLabel: UILabel!
    private var cardsStackView: UIStackView!
    
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
        descriptionLabel.text = "The CasinoGameCardView displays casino game information with optional viewModel initialization. Features image loading, thunderbolt ratings in a capsule, and runtime configuration support."
        descriptionLabel.font = StyleProvider.fontWith(type: .regular, size: 14)
        descriptionLabel.textColor = StyleProvider.Color.textSecondary
        descriptionLabel.numberOfLines = 0
        descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        
        // Cards stack view
        cardsStackView = UIStackView()
        cardsStackView.axis = .horizontal
        cardsStackView.spacing = 16
        cardsStackView.alignment = .top
        cardsStackView.distribution = .fillEqually
        cardsStackView.translatesAutoresizingMaskIntoConstraints = false
        
        // Create sample cards
        let plinkGoalCard = CasinoGameCardView(viewModel: MockCasinoGameCardViewModel.plinkGoal)
        let aviatorCard = CasinoGameCardView(viewModel: MockCasinoGameCardViewModel.aviator)
        let placeholderCard = CasinoGameCardView() // No viewModel - shows placeholder
        
        // Setup callbacks
        plinkGoalCard.onGameSelected = { [weak self] gameId in
            self?.actionLabel.text = "Game selected: \(gameId)"
        }
        
        aviatorCard.onGameSelected = { [weak self] gameId in
            self?.actionLabel.text = "Game selected: \(gameId)"
        }
        
        cardsStackView.addArrangedSubview(plinkGoalCard)
        cardsStackView.addArrangedSubview(aviatorCard)
        cardsStackView.addArrangedSubview(placeholderCard)
        
        // Interactive card for runtime configuration
        interactiveCard = CasinoGameCardView(viewModel: availableViewModels[0])
        interactiveCard.onGameSelected = { [weak self] gameId in
            self?.actionLabel.text = "Interactive game selected: \(gameId)"
        }
        interactiveCard.translatesAutoresizingMaskIntoConstraints = false
        
        // Action label
        actionLabel = UILabel()
        actionLabel.text = "No action taken yet"
        actionLabel.font = StyleProvider.fontWith(type: .medium, size: 14)
        actionLabel.textColor = StyleProvider.Color.textPrimary
        actionLabel.textAlignment = .center
        actionLabel.translatesAutoresizingMaskIntoConstraints = false
        
        // Add to view
        view.addSubview(descriptionLabel)
        view.addSubview(cardsStackView)
        view.addSubview(interactiveCard)
        view.addSubview(actionLabel)
        
        // Setup constraints
        NSLayoutConstraint.activate([
            // Description at top
            descriptionLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            descriptionLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            descriptionLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            // Cards stack view
            cardsStackView.topAnchor.constraint(equalTo: descriptionLabel.bottomAnchor, constant: 24),
            cardsStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            cardsStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            // Interactive card centered
            interactiveCard.topAnchor.constraint(equalTo: cardsStackView.bottomAnchor, constant: 40),
            interactiveCard.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            // Action label
            actionLabel.topAnchor.constraint(equalTo: interactiveCard.bottomAnchor, constant: 20),
            actionLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            actionLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20)
        ])
    }
    
    private func setupNavigationBar() {
        title = "Casino Game Card"
        
        // Switch game button
        let switchButton = UIBarButtonItem(
            title: "Switch",
            style: .plain,
            target: self,
            action: #selector(switchGame)
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
    @objc private func switchGame() {
        currentViewModelIndex = (currentViewModelIndex + 1) % availableViewModels.count
        let newViewModel = availableViewModels[currentViewModelIndex]
        
        // Demonstrate runtime configuration
        interactiveCard.configure(with: newViewModel)
        
        actionLabel.text = "Switched to: \(newViewModel.gameData.name)"
    }
    
    @objc private func clearViewModel() {
        // Demonstrate clearing viewModel (shows placeholder state)
        interactiveCard.configure(with: nil)
        actionLabel.text = "ViewModel cleared - showing placeholder state"
    }
}
