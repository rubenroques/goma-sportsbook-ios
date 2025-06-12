import UIKit
import GomaUI

class OutcomeItemViewController: UIViewController {

    // MARK: - UI Components
    private lazy var descriptionLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "The OutcomeItemView is a reusable component for displaying individual betting market outcomes. It supports selection states, odds change animations, and accessibility features. Tap outcomes to select them, or use the test buttons to simulate odds changes."
        label.textAlignment = .left
        label.numberOfLines = 0
        label.font = StyleProvider.fontWith(type: .regular, size: 16)
        label.textColor = StyleProvider.Color.textColor
        return label
    }()

    private lazy var containerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .lightGray
        view.layer.cornerRadius = 0
        view.accessibilityIdentifier = "outcomeContainerView"
        return view
    }()

    private lazy var outcomeStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .horizontal
        stackView.spacing = 2
        stackView.distribution = .fillEqually
        stackView.accessibilityIdentifier = "outcomeStackView"
        return stackView
    }()

    // MARK: - Properties
    private var outcomeViews: [OutcomeItemView] = []
    private var currentStateIndex = 0

    // Different view model states to demonstrate
    private let viewModelStates: [(name: String, viewModels: [MockOutcomeItemViewModel])] = [
        ("Home/Draw/Away Market", [
            MockOutcomeItemViewModel.homeOutcome,
            MockOutcomeItemViewModel.drawOutcome,
            MockOutcomeItemViewModel.awayOutcome
        ]),
        ("Over/Under Market", [
            MockOutcomeItemViewModel.customOutcome(id: "over_2_5", title: "Over 2.5", value: "1.95"),
            MockOutcomeItemViewModel.customOutcome(id: "under_2_5", title: "Under 2.5", value: "1.80")
        ]),
        ("Odds Change Examples", [
            MockOutcomeItemViewModel.overOutcomeUp,
            MockOutcomeItemViewModel.underOutcomeDown
        ]),
        ("Mixed States", [
            MockOutcomeItemViewModel.homeOutcome,
            MockOutcomeItemViewModel.disabledOutcome,
            MockOutcomeItemViewModel.customOutcome(id: "custom", title: "Custom", value: "2.50", isSelected: true)
        ])
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

        // Create initial outcome views
        createOutcomeViews()

        // Add views to hierarchy
        view.addSubview(descriptionLabel)
        view.addSubview(containerView)
        containerView.addSubview(outcomeStackView)

        // Add outcome views to stack
        outcomeViews.forEach { outcomeStackView.addArrangedSubview($0) }

        // Set up constraints
        NSLayoutConstraint.activate([
            // Container view
            containerView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            containerView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            containerView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            containerView.heightAnchor.constraint(equalToConstant: 70),

            // Stack view
            outcomeStackView.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 10),
            outcomeStackView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 10),
            outcomeStackView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -10),
            outcomeStackView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -10),

            // Description label
            descriptionLabel.topAnchor.constraint(equalTo: containerView.bottomAnchor, constant: 30),
            descriptionLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            descriptionLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            descriptionLabel.bottomAnchor.constraint(lessThanOrEqualTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20)
        ])
    }

    private func createOutcomeViews() {
        // Remove existing views
        outcomeViews.forEach { $0.removeFromSuperview() }
        outcomeViews.removeAll()

        // Create new views with current state
        let currentViewModels = viewModelStates[currentStateIndex].viewModels

        for (index, viewModel) in currentViewModels.enumerated() {
            let outcomeView = OutcomeItemView(viewModel: viewModel)
            
            // Set position based on index and total count (only for items that need corner radius)
            if let position = determinePosition(index: index, totalCount: currentViewModels.count) {
                outcomeView.setPosition(position)
            }
            
            setupOutcomeViewCallbacks(outcomeView)
            outcomeViews.append(outcomeView)
        }
    }
    
    private func determinePosition(index: Int, totalCount: Int) -> OutcomePosition? {
        if totalCount == 1 {
            return .single
        } else if totalCount == 2 {
            // For two items, treat as single line
            return index == 0 ? .singleFirst : .singleLast
        } else {
            // For three or more items, treat as single line for now
            // In a real implementation, you'd determine if it's multi-line based on layout
            if index == 0 {
                return .singleFirst
            } else if index == totalCount - 1 {
                return .singleLast
            } else {
                // Middle items don't get corner radius in single line
                return .middle
            }
        }
    }

    private func setupOutcomeViewCallbacks(_ outcomeView: OutcomeItemView) {
        outcomeView.onTap = {
            print("✅ Outcome tapped")
        }

        outcomeView.onLongPress = {
            print("🔄 Outcome long pressed")
        }
    }

    private func setupNavigationBar() {
        // Add switch button to cycle through different states
        let switchButton = UIBarButtonItem(
            title: "Switch",
            style: .plain,
            target: self,
            action: #selector(switchState)
        )

        // Add test actions button
        let testButton = UIBarButtonItem(
            title: "Test",
            style: .plain,
            target: self,
            action: #selector(showTestActions)
        )

        navigationItem.rightBarButtonItems = [switchButton, testButton]

        // Update title with current state name
        updateTitle()
    }

    private func updateTitle() {
        title = viewModelStates[currentStateIndex].name
    }

    // MARK: - Actions
    @objc private func switchState() {
        currentStateIndex = (currentStateIndex + 1) % viewModelStates.count

        // Recreate the outcome views with new state
        createOutcomeViews()

        // Update the stack view
        outcomeStackView.arrangedSubviews.forEach { outcomeStackView.removeArrangedSubview($0) }
        outcomeViews.forEach { outcomeStackView.addArrangedSubview($0) }

        updateTitle()

        // Animate the transition
        UIView.transition(with: view, duration: 0.3, options: .transitionCrossDissolve, animations: nil)
    }

    @objc private func showTestActions() {
        let alertController = UIAlertController(title: "Test Actions", message: "Choose an action to test", preferredStyle: .actionSheet)

        // Simulate odds increase
        alertController.addAction(UIAlertAction(title: "Simulate Odds Increase", style: .default) { _ in
            self.simulateOddsIncrease()
        })

        // Simulate odds decrease
        alertController.addAction(UIAlertAction(title: "Simulate Odds Decrease", style: .default) { _ in
            self.simulateOddsDecrease()
        })

        // Toggle first outcome selection
        alertController.addAction(UIAlertAction(title: "Toggle First Outcome", style: .default) { _ in
            self.toggleFirstOutcome()
        })

        // Disable/Enable random outcome
        alertController.addAction(UIAlertAction(title: "Toggle Random Outcome Disabled", style: .default) { _ in
            self.toggleRandomOutcomeDisabled()
        })

        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel))

        // For iPad
        if let popover = alertController.popoverPresentationController {
            popover.barButtonItem = navigationItem.rightBarButtonItems?.last
        }

        present(alertController, animated: true)
    }

    // MARK: - Test Methods
    private func simulateOddsIncrease() {
        guard !outcomeViews.isEmpty else { return }

        let randomOutcome = outcomeViews.randomElement()!
        let newValue = String(format: "%.2f", Double.random(in: 2.00...5.00))

        randomOutcome.simulateOddsChange(newValue: newValue)
        showAlert(title: "Odds Increased", message: "Simulated odds increase to \(newValue)")
    }

    private func simulateOddsDecrease() {
        guard !outcomeViews.isEmpty else { return }

        let randomOutcome = outcomeViews.randomElement()!
        let newValue = String(format: "%.2f", Double.random(in: 1.10...1.90))

        randomOutcome.simulateOddsChange(newValue: newValue)
        showAlert(title: "Odds Decreased", message: "Simulated odds decrease to \(newValue)")
    }

    private func toggleFirstOutcome() {
        guard !outcomeViews.isEmpty else { return }

        let firstOutcome = outcomeViews[0]
        // The tap will handle the toggle through the view model
        firstOutcome.onTap()

        showAlert(title: "Selection Toggled", message: "First outcome selection toggled")
    }

    private func toggleRandomOutcomeDisabled() {
        guard !outcomeViews.isEmpty else { return }

        let randomOutcome = outcomeViews.randomElement()!

        // For simplicity, we'll just disable it (in a real app, you'd track the state)
        randomOutcome.setDisabled(true)

        // Re-enable after 3 seconds
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
            randomOutcome.setDisabled(false)
        }

        showAlert(title: "Outcome Disabled", message: "Random outcome disabled for 3 seconds")
    }

    // MARK: - Helper Methods
    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}
