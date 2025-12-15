import UIKit
import GomaUI

class WalletDetailViewController: UIViewController {
    
    private var walletDetailView: WalletDetailView!
    private var currentMockIndex = 0
    
    // Available mock states for cycling through
    private let mockViewModels: [(String, MockWalletDetailViewModel)] = [
        ("Default", MockWalletDetailViewModel.defaultMock),
        ("Empty Balance", MockWalletDetailViewModel.emptyBalanceMock),
        ("High Balance", MockWalletDetailViewModel.highBalanceMock),
        ("Bonus Only", MockWalletDetailViewModel.bonusOnlyMock),
        ("Cashback Focus", MockWalletDetailViewModel.cashbackFocusMock)
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationBar()
        setupView()
        setupWalletDetailView()
    }
    
    private func setupNavigationBar() {
        title = "Wallet Detail View"
        navigationController?.navigationBar.prefersLargeTitles = false
        
        // Add button to cycle through different mock states
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            title: "Next State",
            style: .plain,
            target: self,
            action: #selector(switchToNextMockState)
        )
    }
    
    private func setupView() {
        view.backgroundColor = StyleProvider.Color.backgroundPrimary
    }
    
    private func setupWalletDetailView() {
        // Start with the default mock
        let viewModel = mockViewModels[currentMockIndex].1
        walletDetailView = WalletDetailView(viewModel: viewModel)
        walletDetailView.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(walletDetailView)
        
        NSLayoutConstraint.activate([
            walletDetailView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            walletDetailView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            walletDetailView.leadingAnchor.constraint(greaterThanOrEqualTo: view.leadingAnchor, constant: 20),
            walletDetailView.trailingAnchor.constraint(lessThanOrEqualTo: view.trailingAnchor, constant: -20)
        ])
        
        // Connect to mock callbacks for demo purposes
        if let mockViewModel = viewModel as? MockWalletDetailViewModel {
            mockViewModel.onWithdrawCallback = { [weak self] in
                self?.showActionAlert(title: "Withdraw", message: "Withdraw button was tapped. In a real app, this would navigate to the withdrawal screen.")
            }
            
            mockViewModel.onDepositCallback = { [weak self] in
                self?.showActionAlert(title: "Deposit", message: "Deposit button was tapped. In a real app, this would navigate to the deposit screen.")
            }
        }
        
        updateNavigationTitle()
    }
    
    @objc private func switchToNextMockState() {
        currentMockIndex = (currentMockIndex + 1) % mockViewModels.count
        
        // Remove current view
        walletDetailView.removeFromSuperview()
        
        // Create new view with next mock
        setupWalletDetailView()
        
        // Show transition feedback
        let mockName = mockViewModels[currentMockIndex].0
        showBriefNotification(message: "Switched to: \(mockName)")
    }
    
    private func updateNavigationTitle() {
        let mockName = mockViewModels[currentMockIndex].0
        title = "Wallet Detail - \(mockName)"
    }
    
    private func showActionAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
    
    private func showBriefNotification(message: String) {
        let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        present(alert, animated: true)
        
        // Auto-dismiss after 1.5 seconds
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            alert.dismiss(animated: true)
        }
    }
}

// MARK: - Interactive Demo Features
extension WalletDetailViewController {
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Show instruction on first appearance
        if isMovingToParent {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
                self?.showInstructionsAlert()
            }
        }
    }
    
    private func showInstructionsAlert() {
        let alert = UIAlertController(
            title: "WalletDetailView Demo", 
            message: "• Tap 'Next State' to cycle through different balance scenarios\n• Tap the Withdraw or Deposit buttons to see action handling\n• The component uses real Combine bindings and follows GomaUI patterns", 
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "Got it!", style: .default))
        present(alert, animated: true)
    }
}
