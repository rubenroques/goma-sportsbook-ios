
import UIKit
import Combine
import SwiftUI

final public class WalletDetailView: UIView {
    
    // MARK: Private properties
    private lazy var containerView: UIView = Self.createContainerView()
    private lazy var stackView: UIStackView = Self.createStackView()
    private lazy var headerView: WalletDetailHeaderView = Self.createHeaderView()
    private lazy var balanceView: WalletDetailBalanceView = Self.createBalanceView()
    private lazy var buttonsContainerView: UIView = Self.createButtonsContainerView()
    private var withdrawButton: ButtonView!
    private var depositButton: ButtonView!
    
    private let viewModel: WalletDetailViewModelProtocol
    private var cancellables = Set<AnyCancellable>()
    
    
    // MARK: - Initialization
    public init(viewModel: WalletDetailViewModelProtocol) {
        self.viewModel = viewModel
        super.init(frame: .zero)
        self.commonInit()
        self.setupWithTheme()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func commonInit() {
        self.createButtons()
        self.setupSubviews()
        self.setupBindings()
    }
    
    private func createButtons() {
        // Create buttons with view models
        self.withdrawButton = ButtonView(viewModel: viewModel.withdrawButtonViewModel)
        self.withdrawButton.translatesAutoresizingMaskIntoConstraints = false
        
        self.depositButton = ButtonView(viewModel: viewModel.depositButtonViewModel)
        self.depositButton.translatesAutoresizingMaskIntoConstraints = false
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        self.containerView.layer.cornerRadius = 8
    }
    
    func setupWithTheme() {
        self.backgroundColor = UIColor.clear
        self.containerView.backgroundColor = StyleProvider.Color.highlightPrimary
    }
    
    // Manual button styling removed - now handled by ButtonView's native color customization
    
    // MARK: Functions
    private func setupBindings() {
        // Configure sub-components with view model
        self.balanceView.configure(with: viewModel)
        
        // Bind display state for wallet title and phone number
        viewModel.displayStatePublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] displayState in
                self?.headerView.configure(
                    walletTitle: displayState.walletData.walletTitle,
                    phoneNumber: displayState.walletData.phoneNumber
                )
            }
            .store(in: &cancellables)
        
        // Handle button actions through ViewModels
        self.withdrawButton.onButtonTapped = { [weak self] in
            self?.viewModel.performWithdraw()
        }
        
        self.depositButton.onButtonTapped = { [weak self] in
            self?.viewModel.performDeposit()
        }
    }
}

// MARK: - Subviews Initialization and Setup
extension WalletDetailView {
    
    private static func createContainerView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }
    
    private static func createStackView() -> UIStackView {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.spacing = 12
        stackView.alignment = .fill
        stackView.distribution = .fill
        return stackView
    }
    
    private static func createHeaderView() -> WalletDetailHeaderView {
        let headerView = WalletDetailHeaderView()
        headerView.translatesAutoresizingMaskIntoConstraints = false
        return headerView
    }
    
    private static func createBalanceView() -> WalletDetailBalanceView {
        let balanceView = WalletDetailBalanceView()
        balanceView.translatesAutoresizingMaskIntoConstraints = false
        return balanceView
    }
    
    private static func createButtonsContainerView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }
    
    
    private func setupSubviews() {
        self.addSubview(self.containerView)
        
        self.containerView.addSubview(self.stackView)
        
        self.stackView.addArrangedSubview(self.headerView)
        self.stackView.addArrangedSubview(self.balanceView)
        self.stackView.addArrangedSubview(self.buttonsContainerView)
        
        self.buttonsContainerView.addSubview(self.withdrawButton)
        self.buttonsContainerView.addSubview(self.depositButton)
        
        self.initConstraints()
    }
    
    private func initConstraints() {
        NSLayoutConstraint.activate([
            // Container
            self.containerView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            self.containerView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            self.containerView.topAnchor.constraint(equalTo: self.topAnchor),
            self.containerView.bottomAnchor.constraint(equalTo: self.bottomAnchor),
            
            // Stack view
            self.stackView.leadingAnchor.constraint(equalTo: self.containerView.leadingAnchor, constant: 16),
            self.stackView.trailingAnchor.constraint(equalTo: self.containerView.trailingAnchor, constant: -16),
            self.stackView.topAnchor.constraint(equalTo: self.containerView.topAnchor, constant: 16),
            self.stackView.bottomAnchor.constraint(equalTo: self.containerView.bottomAnchor, constant: -16),
            
            // Buttons container
            self.buttonsContainerView.heightAnchor.constraint(equalToConstant: 40),
            
            // Withdraw button
            self.withdrawButton.leadingAnchor.constraint(equalTo: self.buttonsContainerView.leadingAnchor),
            self.withdrawButton.topAnchor.constraint(equalTo: self.buttonsContainerView.topAnchor),
            self.withdrawButton.bottomAnchor.constraint(equalTo: self.buttonsContainerView.bottomAnchor),
            
            // Deposit button
            self.depositButton.trailingAnchor.constraint(equalTo: self.buttonsContainerView.trailingAnchor),
            self.depositButton.topAnchor.constraint(equalTo: self.buttonsContainerView.topAnchor),
            self.depositButton.bottomAnchor.constraint(equalTo: self.buttonsContainerView.bottomAnchor),
            self.depositButton.leadingAnchor.constraint(equalTo: self.withdrawButton.trailingAnchor, constant: 12),
            
            // Equal width buttons
            self.withdrawButton.widthAnchor.constraint(equalTo: self.depositButton.widthAnchor)
        ])
    }
}

// MARK: - Preview
#if DEBUG

@available(iOS 17.0, *)
#Preview("1. Default State - Normal Case") {
    PreviewUIViewController {
        let vc = UIViewController()
        vc.view.backgroundColor = .backgroundTestColor
        
        let mockViewModel = MockWalletDetailViewModel.defaultMock
        let walletDetailView = WalletDetailView(viewModel: mockViewModel)
        walletDetailView.translatesAutoresizingMaskIntoConstraints = false
        
        vc.view.addSubview(walletDetailView)
        
        NSLayoutConstraint.activate([
            walletDetailView.centerXAnchor.constraint(equalTo: vc.view.centerXAnchor),
            walletDetailView.centerYAnchor.constraint(equalTo: vc.view.centerYAnchor),
            walletDetailView.leadingAnchor.constraint(greaterThanOrEqualTo: vc.view.leadingAnchor, constant: 20),
            walletDetailView.trailingAnchor.constraint(lessThanOrEqualTo: vc.view.trailingAnchor, constant: -20)
        ])
        
        
        return vc
    }
}

@available(iOS 17.0, *)
#Preview("2. Empty Wallet - Edge Case") {
    PreviewUIViewController {
        let vc = UIViewController()
        vc.view.backgroundColor = .backgroundTestColor
        
        // Create overlay effect
        let overlayView = UIView()
        overlayView.backgroundColor = UIColor.black.withAlphaComponent(0.3)
        overlayView.translatesAutoresizingMaskIntoConstraints = false
        vc.view.addSubview(overlayView)
        
        NSLayoutConstraint.activate([
            overlayView.topAnchor.constraint(equalTo: vc.view.topAnchor),
            overlayView.leadingAnchor.constraint(equalTo: vc.view.leadingAnchor),
            overlayView.trailingAnchor.constraint(equalTo: vc.view.trailingAnchor),
            overlayView.bottomAnchor.constraint(equalTo: vc.view.bottomAnchor)
        ])
        
        let mockViewModel = MockWalletDetailViewModel.emptyBalanceMock
        let walletDetailView = WalletDetailView(viewModel: mockViewModel)
        walletDetailView.translatesAutoresizingMaskIntoConstraints = false
        
        overlayView.addSubview(walletDetailView)
        
        NSLayoutConstraint.activate([
            walletDetailView.centerXAnchor.constraint(equalTo: overlayView.centerXAnchor),
            walletDetailView.centerYAnchor.constraint(equalTo: overlayView.centerYAnchor),
            walletDetailView.widthAnchor.constraint(equalToConstant: 350)
        ])
        
        // Add label showing this is empty state
        let label = UILabel()
        label.text = "Empty Wallet Scenario"
        label.textColor = .white
        label.font = StyleProvider.fontWith(type: .bold, size: 16)
        label.translatesAutoresizingMaskIntoConstraints = false
        overlayView.addSubview(label)
        
        NSLayoutConstraint.activate([
            label.centerXAnchor.constraint(equalTo: overlayView.centerXAnchor),
            label.bottomAnchor.constraint(equalTo: walletDetailView.topAnchor, constant: -20)
        ])
        
        return vc
    }
}

@available(iOS 17.0, *)
#Preview("3. High Balance - Stress Test") {
    PreviewUIViewController {
        let vc = UIViewController()
        vc.view.backgroundColor = .backgroundTestColor
        
        let mockViewModel = MockWalletDetailViewModel.highBalanceMock
        let walletDetailView = WalletDetailView(viewModel: mockViewModel)
        walletDetailView.translatesAutoresizingMaskIntoConstraints = false
        
        vc.view.addSubview(walletDetailView)
        
        // Test with different constraints to see layout behavior
        NSLayoutConstraint.activate([
            walletDetailView.centerXAnchor.constraint(equalTo: vc.view.centerXAnchor),
            walletDetailView.centerYAnchor.constraint(equalTo: vc.view.centerYAnchor),
            walletDetailView.widthAnchor.constraint(equalToConstant: 320) // Slightly narrower
        ])
        
        // Add description label
        let descLabel = UILabel()
        descLabel.text = "Large amounts: 150,000.50 XAF"
        descLabel.textColor = StyleProvider.Color.textSecondary
        descLabel.font = StyleProvider.fontWith(type: .regular, size: 12)
        descLabel.translatesAutoresizingMaskIntoConstraints = false
        vc.view.addSubview(descLabel)
        
        NSLayoutConstraint.activate([
            descLabel.centerXAnchor.constraint(equalTo: vc.view.centerXAnchor),
            descLabel.topAnchor.constraint(equalTo: walletDetailView.bottomAnchor, constant: 16)
        ])
        
        return vc
    }
}

@available(iOS 17.0, *)
#Preview("4. Bonus Only - No Withdrawable") {
    PreviewUIViewController {
        let vc = UIViewController()
        
        // Create gradient background
        let gradientLayer = CAGradientLayer()
        gradientLayer.colors = [
            UIColor.systemGray6.cgColor,
            UIColor.systemGray5.cgColor
        ]
        gradientLayer.locations = [0.0, 1.0]
        gradientLayer.frame = vc.view.bounds
        vc.view.layer.insertSublayer(gradientLayer, at: 0)
        
        let mockViewModel = MockWalletDetailViewModel.bonusOnlyMock
        let walletDetailView = WalletDetailView(viewModel: mockViewModel)
        walletDetailView.translatesAutoresizingMaskIntoConstraints = false
        
        // Add shadow for depth
        walletDetailView.layer.shadowColor = UIColor.black.cgColor
        walletDetailView.layer.shadowOpacity = 0.2
        walletDetailView.layer.shadowOffset = CGSize(width: 0, height: 4)
        walletDetailView.layer.shadowRadius = 8
        
        vc.view.addSubview(walletDetailView)
        
        NSLayoutConstraint.activate([
            walletDetailView.centerXAnchor.constraint(equalTo: vc.view.centerXAnchor),
            walletDetailView.centerYAnchor.constraint(equalTo: vc.view.centerYAnchor),
            walletDetailView.leadingAnchor.constraint(greaterThanOrEqualTo: vc.view.leadingAnchor, constant: 30),
            walletDetailView.trailingAnchor.constraint(lessThanOrEqualTo: vc.view.trailingAnchor, constant: -30)
        ])
        
        // Add warning label
        let warningLabel = UILabel()
        warningLabel.text = "⚠️ Bonus funds cannot be withdrawn"
        warningLabel.textColor = StyleProvider.Color.highlightPrimary
        warningLabel.font = StyleProvider.fontWith(type: .medium, size: 13)
        warningLabel.translatesAutoresizingMaskIntoConstraints = false
        vc.view.addSubview(warningLabel)
        
        NSLayoutConstraint.activate([
            warningLabel.centerXAnchor.constraint(equalTo: vc.view.centerXAnchor),
            warningLabel.topAnchor.constraint(equalTo: walletDetailView.bottomAnchor, constant: 20)
        ])
        
        return vc
    }
}

@available(iOS 17.0, *)
#Preview("5. All States Grid") {
    PreviewUIViewController {
        let vc = UIViewController()
        vc.view.backgroundColor = .backgroundTestColor
        
        // Create a scroll view for multiple components
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        vc.view.addSubview(scrollView)
        
        let containerView = UIView()
        containerView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(containerView)
        
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: vc.view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: vc.view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: vc.view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: vc.view.bottomAnchor),
            
            containerView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            containerView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            containerView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            containerView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            containerView.widthAnchor.constraint(equalTo: scrollView.widthAnchor)
        ])
        
        // Create stack for vertical layout
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 24
        stackView.alignment = .center
        stackView.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(stackView)
        
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 20),
            stackView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 20),
            stackView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -20),
            stackView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -20)
        ])
        
        // Add all mock states
        let mockStates: [(String, MockWalletDetailViewModel)] = [
            ("Default", MockWalletDetailViewModel.defaultMock),
            ("Cashback Focus", MockWalletDetailViewModel.cashbackFocusMock),
            ("Empty", MockWalletDetailViewModel.emptyBalanceMock),
            ("High Balance", MockWalletDetailViewModel.highBalanceMock),
            ("Bonus Only", MockWalletDetailViewModel.bonusOnlyMock)
        ]
        
        for (title, viewModel) in mockStates {
            // Create container for each wallet
            let walletContainer = UIView()
            walletContainer.translatesAutoresizingMaskIntoConstraints = false
            
            // Add title
            let titleLabel = UILabel()
            titleLabel.text = title
            titleLabel.font = StyleProvider.fontWith(type: .bold, size: 14)
            titleLabel.textColor = StyleProvider.Color.textPrimary
            titleLabel.translatesAutoresizingMaskIntoConstraints = false
            walletContainer.addSubview(titleLabel)
            
            // Add wallet view
            let walletView = WalletDetailView(viewModel: viewModel)
            walletView.translatesAutoresizingMaskIntoConstraints = false
            walletContainer.addSubview(walletView)
            
            NSLayoutConstraint.activate([
                titleLabel.topAnchor.constraint(equalTo: walletContainer.topAnchor),
                titleLabel.centerXAnchor.constraint(equalTo: walletContainer.centerXAnchor),
                
                walletView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8),
                walletView.leadingAnchor.constraint(equalTo: walletContainer.leadingAnchor),
                walletView.trailingAnchor.constraint(equalTo: walletContainer.trailingAnchor),
                walletView.bottomAnchor.constraint(equalTo: walletContainer.bottomAnchor),
                walletView.widthAnchor.constraint(equalToConstant: 320)
            ])
            
            stackView.addArrangedSubview(walletContainer)
        }
        
        return vc
    }
}

#endif
