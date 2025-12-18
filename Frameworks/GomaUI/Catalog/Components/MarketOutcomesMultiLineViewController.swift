import UIKit
import GomaUI

class MarketOutcomesMultiLineViewController: UIViewController {

    // MARK: - Properties
    private var multiLineView: MarketOutcomesMultiLineView!
    private var currentViewModelIndex = 0
    
    // Different view models to demonstrate various states
    private let viewModels: [(name: String, viewModel: MarketOutcomesMultiLineViewModelProtocol)] = [
        ("Over/Under Market Group", MockMarketOutcomesMultiLineViewModel.overUnderMarketGroup),
        ("Home/Draw/Away Market Group", MockMarketOutcomesMultiLineViewModel.homeDrawAwayMarketGroup),
        ("Market Group with Suspended Line", MockMarketOutcomesMultiLineViewModel.overUnderWithSuspendedLine),
        ("Mixed Layout Market Group", MockMarketOutcomesMultiLineViewModel.mixedLayoutMarketGroup),
        ("Market Group with Odds Changes", MockMarketOutcomesMultiLineViewModel.marketGroupWithOddsChanges),
        ("Empty Market Group (with title)", MockMarketOutcomesMultiLineViewModel.emptyMarketGroupWithTitle),
        ("Empty Market Group (no title)", MockMarketOutcomesMultiLineViewModel.emptyMarketGroup)
    ]

    // MARK: - View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        setupNavigationBar()
    }

    // MARK: - Setup
    private func setupViews() {
        view.backgroundColor = .systemGroupedBackground
        
        // Create initial multi-line view
        createMultiLineView()
        
        // Add description label
        let descriptionLabel = UILabel()
        descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        descriptionLabel.text = "The MarketOutcomesMultiLineView is now a simple aggregator that displays line view models provided by its parent view model. Each line view model handles its own state and API connections independently. This demonstrates the simplified composition pattern with support for empty states when no markets are available. Tap 'Switch' to see different configurations including empty state examples."
        descriptionLabel.textAlignment = .left
        descriptionLabel.numberOfLines = 0
        descriptionLabel.font = StyleProvider.fontWith(type: .regular, size: 16)
        descriptionLabel.textColor = StyleProvider.Color.textPrimary
        
        view.addSubview(descriptionLabel)
        
        // Set up constraints
        NSLayoutConstraint.activate([
            // Multi-line view
            multiLineView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            multiLineView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            multiLineView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            
            // Description label
            descriptionLabel.topAnchor.constraint(equalTo: multiLineView.bottomAnchor, constant: 30),
            descriptionLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            descriptionLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            descriptionLabel.bottomAnchor.constraint(lessThanOrEqualTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20)
        ])
    }
    
    private func createMultiLineView() {
        // Remove existing view if any
        multiLineView?.removeFromSuperview()
        
        // Create new multi-line view with current view model
        let currentViewModel = viewModels[currentViewModelIndex].viewModel
        multiLineView = MarketOutcomesMultiLineView(viewModel: currentViewModel)
        multiLineView.translatesAutoresizingMaskIntoConstraints = false
        
        // Set up callbacks
        setupMultiLineViewCallbacks()
        
        view.addSubview(multiLineView)
    }
    
    private func setupMultiLineViewCallbacks() {
        multiLineView.onOutcomeSelected = { lineId, outcomeType in
            print("✅ Outcome selected: \(outcomeType)")
            self.showAlert(title: "Outcome Selected", message: "Selected \(outcomeType) (individual line VMs handle their own state)")
        }
        
        multiLineView.onOutcomeDeselected = { lineId, outcomeType in
            print("❌ Outcome deselected: \(outcomeType)")
            self.showAlert(title: "Outcome Deselected", message: "Deselected \(outcomeType) (individual line VMs handle their own state)")
        }
        
        multiLineView.onOutcomeLongPress = { lineId, outcomeType in
            print("🔄 Long press on: \(outcomeType)")
            self.showAlert(title: "Long Press", message: "Long pressed \(outcomeType) (individual line VMs handle their own state)")
        }
        
        multiLineView.onLineSuspended = { lineId in
            print("⏸️ Line suspended (individual line VMs handle suspension)")
        }
        
        multiLineView.onLineResumed = { lineId in
            print("▶️ Line resumed (individual line VMs handle resumption)")
        }
        
        multiLineView.onOddsChanged = { lineId, outcomeType, oldValue, newValue in
            print("📈 Odds changed: \(oldValue) -> \(newValue) (individual line VMs handle odds updates)")
        }
        
        multiLineView.onGroupExpansionToggled = { isExpanded in
            print("🔄 Group expansion toggled: \(isExpanded)")
        }
    }
    
    private func setupNavigationBar() {
        // Add switch button to cycle through different view models
        let switchButton = UIBarButtonItem(
            title: "Switch",
            style: .plain,
            target: self,
            action: #selector(switchViewModel)
        )
        
        // Add test actions button
        let testButton = UIBarButtonItem(
            title: "Test",
            style: .plain,
            target: self,
            action: #selector(showTestActions)
        )
        
        navigationItem.rightBarButtonItems = [switchButton, testButton]
        
        // Update title with current view model name
        updateTitle()
    }
    
    private func updateTitle() {
        title = viewModels[currentViewModelIndex].name
    }
    
    // MARK: - Actions
    @objc private func switchViewModel() {
        currentViewModelIndex = (currentViewModelIndex + 1) % viewModels.count
        
        // Recreate the multi-line view with new view model
        createMultiLineView()
        
        // Update constraints for the new view
        NSLayoutConstraint.activate([
            multiLineView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            multiLineView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            multiLineView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16)
        ])
        
        updateTitle()
        
        // Animate the transition
        UIView.transition(with: view, duration: 0.3, options: .transitionCrossDissolve, animations: nil)
    }
    
    @objc private func showTestActions() {
        let alertController = UIAlertController(title: "Test Actions", message: "Choose an action to test", preferredStyle: .actionSheet)
        
        // Access individual line view models
        alertController.addAction(UIAlertAction(title: "Access Line View Models", style: .default) { _ in
            print("Not implemented.")
        })
        
        // Test view model aggregation
        alertController.addAction(UIAlertAction(title: "Test View Model Aggregation", style: .default) { _ in
            print("Not implemented.")
        })
        
        // Show simplified architecture info
        alertController.addAction(UIAlertAction(title: "Show Architecture Info", style: .default) { _ in
            print("Not implemented.")
        })
                
        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        
        // For iPad
        if let popover = alertController.popoverPresentationController {
            popover.barButtonItem = navigationItem.rightBarButtonItems?.last
        }
        
        present(alertController, animated: true)
    }
    
    // MARK: - Helper Methods
    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
} 
