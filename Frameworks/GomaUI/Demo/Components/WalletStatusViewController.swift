import UIKit
import GomaUI
import Combine

class WalletStatusViewController: UIViewController {
    
    // MARK: - Properties
    private var walletStatusView: WalletStatusView!
    private var viewModel: MockWalletStatusViewModel!
    private var overlayView: UIView?
    private var cancellables = Set<AnyCancellable>()
    
    // UI Controls for demo
    private lazy var showAsDialogButton = Self.createDemoButton(title: "Show as Dialog Overlay")
    private lazy var simulateDepositButton = Self.createDemoButton(title: "Simulate Deposit (+500)")
    private lazy var simulateWithdrawButton = Self.createDemoButton(title: "Simulate Withdraw (-100)")
    private lazy var updateBalancesButton = Self.createDemoButton(title: "Random Balance Update")
    private lazy var resetButton = Self.createDemoButton(title: "Reset to Default")
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Wallet Status View"
        view.backgroundColor = StyleProvider.Color.backgroundColor
        
        setupViewModel()
        setupViews()
        setupConstraints()
        setupActions()
    }
    
    // MARK: - Setup
    private func setupViewModel() {
        viewModel = MockWalletStatusViewModel.defaultMock
    }
    
    private func setupViews() {
        // Create wallet status view
        walletStatusView = WalletStatusView(viewModel: self.viewModel)
        walletStatusView.translatesAutoresizingMaskIntoConstraints = false
        
        // Set up button tap handlers
        walletStatusView.onDepositButtonTapped = { [weak self] in
            self?.showAlert(title: "Deposit", message: "Deposit button tapped! In production, this would navigate to deposit screen.")
        }
        
        walletStatusView.onWithdrawButtonTapped = { [weak self] in
            self?.showAlert(title: "Withdraw", message: "Withdraw button tapped! In production, this would navigate to withdrawal screen.")
        }
        
        // Stack view for demo controls
        let controlsStack = UIStackView(arrangedSubviews: [
            showAsDialogButton,
            simulateDepositButton,
            simulateWithdrawButton,
            updateBalancesButton,
            resetButton
        ])
        controlsStack.translatesAutoresizingMaskIntoConstraints = false
        controlsStack.axis = .vertical
        controlsStack.spacing = 12
        controlsStack.distribution = .fillEqually
        
        // Add views
        view.addSubview(walletStatusView)
        view.addSubview(controlsStack)
        
        // Apply constraints for controls
        NSLayoutConstraint.activate([
            controlsStack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            controlsStack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            controlsStack.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20)
        ])
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            walletStatusView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            walletStatusView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            walletStatusView.widthAnchor.constraint(equalToConstant: 350),
            walletStatusView.heightAnchor.constraint(lessThanOrEqualToConstant: 340)
        ])
    }
    
    private func setupActions() {
        showAsDialogButton.addTarget(self, action: #selector(showAsDialog), for: .touchUpInside)
        simulateDepositButton.addTarget(self, action: #selector(simulateDeposit), for: .touchUpInside)
        simulateWithdrawButton.addTarget(self, action: #selector(simulateWithdraw), for: .touchUpInside)
        updateBalancesButton.addTarget(self, action: #selector(updateBalances), for: .touchUpInside)
        resetButton.addTarget(self, action: #selector(resetToDefault), for: .touchUpInside)
    }
    
    // MARK: - Actions
    @objc private func showAsDialog() {
        // Create overlay
        let overlay = UIView()
        overlay.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        overlay.translatesAutoresizingMaskIntoConstraints = false
        overlay.alpha = 0
        
        // Create dialog wallet view
        let dialogViewModel = MockWalletStatusViewModel.highBalanceMock
        let dialogWalletView = WalletStatusView(viewModel: dialogViewModel)
        dialogWalletView.translatesAutoresizingMaskIntoConstraints = false
        
        // Configure dialog button tap handlers
        dialogWalletView.onDepositButtonTapped = { [weak self] in
            self?.dismissDialog()
            self?.showAlert(title: "Dialog Action", message: "Deposit from dialog!")
        }
        
        dialogWalletView.onWithdrawButtonTapped = { [weak self] in
            self?.dismissDialog()
            self?.showAlert(title: "Dialog Action", message: "Withdraw from dialog!")
        }
        
        // Add to view hierarchy
        view.addSubview(overlay)
        overlay.addSubview(dialogWalletView)
        
        // Constraints
        NSLayoutConstraint.activate([
            overlay.topAnchor.constraint(equalTo: view.topAnchor),
            overlay.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            overlay.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            overlay.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            dialogWalletView.centerXAnchor.constraint(equalTo: overlay.centerXAnchor),
            dialogWalletView.centerYAnchor.constraint(equalTo: overlay.centerYAnchor),
            dialogWalletView.widthAnchor.constraint(equalToConstant: 350)
        ])
        
        // Add tap to dismiss
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissDialog))
        overlay.addGestureRecognizer(tapGesture)
        
        // Store reference
        self.overlayView = overlay
        
        // Animate in
        UIView.animate(withDuration: 0.3) {
            overlay.alpha = 1
        }
    }
    
    @objc private func dismissDialog() {
        guard let overlay = overlayView else { return }
        
        UIView.animate(withDuration: 0.3, animations: {
            overlay.alpha = 0
        }) { _ in
            overlay.removeFromSuperview()
            self.overlayView = nil
        }
    }
    
    @objc private func simulateDeposit() {
        viewModel.simulateDepositComplete(amount: 500)
        showToast("Simulated deposit of 500")
    }
    
    @objc private func simulateWithdraw() {
        viewModel.simulateWithdrawalComplete(amount: 100)
        showToast("Simulated withdrawal of 100")
    }
    
    @objc private func updateBalances() {
        let randomTotal = Double.random(in: 1000...5000)
        let randomCurrent = Double.random(in: 500...randomTotal)
        let randomBonus = Double.random(in: 0...(randomTotal - randomCurrent))
        let randomCashback = Double.random(in: 0...200)
        
        viewModel.simulateBalanceUpdate(
            total: String(format: "%.2f", randomTotal),
            current: String(format: "%.2f", randomCurrent),
            bonus: String(format: "%.2f", randomBonus),
            cashback: String(format: "%.2f", randomCashback),
            withdrawable: String(format: "%.2f", randomCurrent)
        )
        
        showToast("Updated with random values")
    }
    
    @objc private func resetToDefault() {
        viewModel.simulateBalanceUpdate(
            total: "2,000.00",
            current: "1,000.00",
            bonus: "965.00",
            cashback: "35.00",
            withdrawable: "1,000.00"
        )
        showToast("Reset to default values")
    }
    
    // MARK: - Helper Methods
    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
    
    private func showToast(_ message: String) {
        let toast = UILabel()
        toast.text = message
        toast.backgroundColor = UIColor.black.withAlphaComponent(0.7)
        toast.textColor = .white
        toast.textAlignment = .center
        toast.font = StyleProvider.fontWith(type: .medium, size: 14)
        toast.layer.cornerRadius = 8
        toast.clipsToBounds = true
        toast.translatesAutoresizingMaskIntoConstraints = false
        toast.alpha = 0
        
        view.addSubview(toast)
        
        NSLayoutConstraint.activate([
            toast.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            toast.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -100),
            toast.widthAnchor.constraint(greaterThanOrEqualToConstant: 200),
            toast.heightAnchor.constraint(equalToConstant: 40),
            toast.leadingAnchor.constraint(greaterThanOrEqualTo: view.leadingAnchor, constant: 20),
            toast.trailingAnchor.constraint(lessThanOrEqualTo: view.trailingAnchor, constant: -20)
        ])
        
        UIView.animate(withDuration: 0.3, animations: {
            toast.alpha = 1
        }) { _ in
            UIView.animate(withDuration: 0.3, delay: 2.0, options: [], animations: {
                toast.alpha = 0
            }) { _ in
                toast.removeFromSuperview()
            }
        }
    }
    
    // MARK: - Factory Methods
    private static func createDemoButton(title: String) -> UIButton {
        let button = UIButton(type: .system)
        button.setTitle(title, for: .normal)
        button.titleLabel?.font = StyleProvider.fontWith(type: .medium, size: 14)
        button.backgroundColor = StyleProvider.Color.highlightPrimary
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 8
        button.heightAnchor.constraint(equalToConstant: 44).isActive = true
        return button
    }
}
