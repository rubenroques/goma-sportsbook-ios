import UIKit
import GomaUI

class WalletWidgetViewController: UIViewController {

    // MARK: - Properties
    private var walletWidgetView: WalletWidgetView!
    private var descriptionLabel: UILabel!
    private var actionLabel: UILabel!
    private var updateBalanceButton: UIButton!

    private var currentBalance: Double = 2000.00
    private var mockViewModel: MockWalletWidgetViewModel!

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()

        setupViews()
        layoutViews()
        setupActions()
    }

    // MARK: - Setup
    private func setupViews() {
        view.backgroundColor = .systemGray5

        // Create the wallet widget
        mockViewModel = MockWalletWidgetViewModel.defaultMock
        walletWidgetView = WalletWidgetView(viewModel: mockViewModel)
        walletWidgetView.translatesAutoresizingMaskIntoConstraints = false

        // Description label
        descriptionLabel = UILabel()
        descriptionLabel.text = "The WalletWidgetView displays account balance and provides a deposit button for quick access."
        descriptionLabel.font = StyleProvider.fontWith(type: .regular, size: 14)
        descriptionLabel.textColor = .secondaryLabel
        descriptionLabel.numberOfLines = 0
        descriptionLabel.translatesAutoresizingMaskIntoConstraints = false

        // Action label
        actionLabel = UILabel()
        actionLabel.text = "No action taken yet"
        actionLabel.font = StyleProvider.fontWith(type: .medium, size: 14)
        actionLabel.translatesAutoresizingMaskIntoConstraints = false

        // Update balance button
        updateBalanceButton = UIButton(type: .system)
        updateBalanceButton.setTitle("Update Balance", for: .normal)
        updateBalanceButton.backgroundColor = StyleProvider.Color.primaryColor
        updateBalanceButton.setTitleColor(StyleProvider.Color.contrastTextColor, for: .normal)
        updateBalanceButton.layer.cornerRadius = 8
        updateBalanceButton.translatesAutoresizingMaskIntoConstraints = false

        // Add to view
        view.addSubview(walletWidgetView)
        view.addSubview(descriptionLabel)
        view.addSubview(actionLabel)
        view.addSubview(updateBalanceButton)
    }

    private func layoutViews() {
        NSLayoutConstraint.activate([
            // WalletWidgetView at the top center
            walletWidgetView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 24),
            walletWidgetView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            walletWidgetView.widthAnchor.constraint(equalToConstant: 180),

            // Description below wallet widget
            descriptionLabel.topAnchor.constraint(equalTo: walletWidgetView.bottomAnchor, constant: 24),
            descriptionLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            descriptionLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),

            // Update button below description
            updateBalanceButton.topAnchor.constraint(equalTo: descriptionLabel.bottomAnchor, constant: 24),
            updateBalanceButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            updateBalanceButton.widthAnchor.constraint(equalToConstant: 200),
            updateBalanceButton.heightAnchor.constraint(equalToConstant: 44),

            // Action label below the button
            actionLabel.topAnchor.constraint(equalTo: updateBalanceButton.bottomAnchor, constant: 16),
            actionLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
    }

    private func setupActions() {
        // Update balance button action
        updateBalanceButton.addTarget(self, action: #selector(updateBalance), for: .touchUpInside)

        // Wallet widget deposit handler
        walletWidgetView.onDepositTapped = { [weak self] widgetID in
            self?.actionLabel.text = "Deposit action triggered for widget: \(widgetID)"
        }

        // Wallet widget balance tap handler
        walletWidgetView.onBalanceTapped = { [weak self] widgetID in
            self?.actionLabel.text = "Balance tapped for widget: \(widgetID)"

            // Show an alert with the current balance details
            guard let self = self else { return }
            let alert = UIAlertController(
                title: "Account Balance",
                message: "Current balance: $\(String(format: "%.2f", self.currentBalance))",
                preferredStyle: .alert
            )
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            self.present(alert, animated: true)
        }
    }

    // MARK: - Actions
    @objc private func updateBalance() {
        // Randomly increase or decrease the balance
        let change = Double.random(in: -500...500)
        currentBalance += change

        // Format the balance with 2 decimal places
        let formattedBalance = String(format: "%.2f", currentBalance)

        // Update the view model
        mockViewModel.updateBalance(formattedBalance)

        // Update action label
        let direction = change >= 0 ? "increased" : "decreased"
        actionLabel.text = "Balance \(direction) by \(String(format: "%.2f", abs(change)))"
    }
}
