import UIKit
import GomaUI

final class PendingWithdrawViewController: UIViewController {
    
    // MARK: - Properties
    private var pendingWithdrawView: PendingWithdrawView!
    private var statusButton: UIButton!
    private var feedbackLabel: UILabel!
    private var mockViewModel: MockPendingWithdrawViewModel!
    private var isCompletedState = false
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = StyleProvider.Color.backgroundSecondary
        configureViewModel()
        setupSubviews()
        setupConstraints()
    }
    
    // MARK: - Setup
    private func configureViewModel() {
        mockViewModel = MockPendingWithdrawViewModel()
        mockViewModel.onCopyRequested = { [weak self] transactionId in
            UIPasteboard.general.string = transactionId
            DispatchQueue.main.async {
                self?.feedbackLabel.text = "Copied \(transactionId) to pasteboard"
            }
        }
        
        pendingWithdrawView = PendingWithdrawView(viewModel: mockViewModel)
        pendingWithdrawView.translatesAutoresizingMaskIntoConstraints = false
    }
    
    private func setupSubviews() {
        feedbackLabel = UILabel()
        feedbackLabel.text = "Tap the icon to copy the transaction ID"
        feedbackLabel.textColor = StyleProvider.Color.textSecondary
        feedbackLabel.font = StyleProvider.fontWith(type: .regular, size: 13)
        feedbackLabel.numberOfLines = 0
        feedbackLabel.translatesAutoresizingMaskIntoConstraints = false
        
        statusButton = UIButton(type: .system)
        statusButton.setTitle("Mark as Completed", for: .normal)
        statusButton.titleLabel?.font = StyleProvider.fontWith(type: .bold, size: 15)
        statusButton.backgroundColor = StyleProvider.Color.highlightPrimary
        statusButton.setTitleColor(StyleProvider.Color.highlightPrimaryContrast, for: .normal)
        statusButton.layer.cornerRadius = 10
        statusButton.translatesAutoresizingMaskIntoConstraints = false
        statusButton.addTarget(self, action: #selector(toggleStatus), for: .touchUpInside)
        
        view.addSubview(pendingWithdrawView)
        view.addSubview(feedbackLabel)
        view.addSubview(statusButton)
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            pendingWithdrawView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            pendingWithdrawView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            pendingWithdrawView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 30),
            
            feedbackLabel.leadingAnchor.constraint(equalTo: pendingWithdrawView.leadingAnchor),
            feedbackLabel.trailingAnchor.constraint(equalTo: pendingWithdrawView.trailingAnchor),
            feedbackLabel.topAnchor.constraint(equalTo: pendingWithdrawView.bottomAnchor, constant: 16),
            
            statusButton.topAnchor.constraint(equalTo: feedbackLabel.bottomAnchor, constant: 24),
            statusButton.leadingAnchor.constraint(equalTo: pendingWithdrawView.leadingAnchor),
            statusButton.trailingAnchor.constraint(equalTo: pendingWithdrawView.trailingAnchor),
            statusButton.heightAnchor.constraint(equalToConstant: 48)
        ])
    }
    
    // MARK: - Actions
    @objc
    private func toggleStatus() {
        isCompletedState.toggle()
        if isCompletedState {
            mockViewModel.update(
                displayState: PendingWithdrawViewDisplayState(
                    dateText: "05/08/2025, 11:17",
                    statusText: "Completed",
                    statusStyle: PendingWithdrawStatusStyle(
                        textColor: StyleProvider.Color.highlightSecondaryContrast,
                        backgroundColor: StyleProvider.Color.highlightSecondary,
                        borderColor: nil
                    ),
                    amountTitleText: "Amount",
                    amountValueText: "XAF 200,000",
                    transactionIdTitleText: "Transaction ID",
                    transactionIdValueText: "HFD90230NRF"
                )
            )
            statusButton.setTitle("Revert to Pending", for: .normal)
        } else {
            mockViewModel.update(displayState: .samplePending)
            statusButton.setTitle("Mark as Completed", for: .normal)
        }
    }
}

