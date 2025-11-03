
import UIKit
import Combine
import SwiftUI

final public class WalletDetailBalanceView: UIView {
    
    // MARK: Private properties
    private lazy var stackView: UIStackView = Self.createStackView()
    private lazy var totalBalanceContainer: UIView = Self.createTotalBalanceContainer()
    private lazy var totalBalanceIcon: UIImageView = Self.createTotalBalanceIcon()
    private lazy var totalBalanceLabel: UILabel = Self.createTotalBalanceLabel()
    private lazy var totalBalanceValue: UILabel = Self.createTotalBalanceValue()
    private lazy var topSeparatorView: UIView = Self.createSeparatorView()
    private lazy var balanceLinesStackView: UIStackView = Self.createBalanceLinesStackView()
    private lazy var currentBalanceLine: WalletDetailBalanceLineView = Self.createCurrentBalanceLine()
    private lazy var bonusBalanceLine: WalletDetailBalanceLineView = Self.createBonusBalanceLine()
    private lazy var cashbackBalanceLine: WalletDetailBalanceLineView = Self.createCashbackBalanceLine()
    private lazy var withdrawableLine: WalletDetailBalanceLineView = Self.createWithdrawableLine()
    private lazy var bottomSeparatorView: UIView = Self.createSeparatorView()
    
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Lifetime and Cycle
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.commonInit()
        self.setupWithTheme()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.commonInit()
        self.setupWithTheme()
    }
    
    func commonInit() {
        self.setupSubviews()
    }
    
    func setupWithTheme() {
        self.backgroundColor = UIColor.clear
        self.totalBalanceLabel.textColor = StyleProvider.Color.allWhite
        self.totalBalanceValue.textColor = StyleProvider.Color.allWhite
        self.topSeparatorView.backgroundColor = StyleProvider.Color.allWhite
        self.bottomSeparatorView.backgroundColor = StyleProvider.Color.allWhite
        self.totalBalanceIcon.tintColor = StyleProvider.Color.allWhite
    }
    
    // MARK: Functions
    public func configure(with viewModel: WalletDetailViewModelProtocol) {
        self.setupBindings(with: viewModel)
    }
    
    private func setupBindings(with viewModel: WalletDetailViewModelProtocol) {
        // Bind total balance
        viewModel.totalBalancePublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] balance in
                self?.totalBalanceValue.text = balance
            }
            .store(in: &cancellables)
        
        // Bind individual balance lines
        viewModel.currentBalancePublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] balance in
                self?.currentBalanceLine.updateValue(balance)
            }
            .store(in: &cancellables)
        
        viewModel.bonusBalancePublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] balance in
                self?.bonusBalanceLine.updateValue(balance)
            }
            .store(in: &cancellables)
        
        viewModel.cashbackBalancePublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] balance in
                self?.cashbackBalanceLine.updateValue(balance)
            }
            .store(in: &cancellables)
        
        viewModel.withdrawableAmountPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] amount in
                self?.withdrawableLine.updateValue(amount)
            }
            .store(in: &cancellables)
    }
}

// MARK: - Subviews Initialization and Setup
extension WalletDetailBalanceView {
    
    private static func createStackView() -> UIStackView {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.spacing = 12
        stackView.alignment = .fill
        stackView.distribution = .fill
        return stackView
    }
    
    private static func createTotalBalanceContainer() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }
    
    private static func createTotalBalanceIcon() -> UIImageView {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        imageView.image = UIImage(systemName: "banknote") // Placeholder - should use actual cash icon
        return imageView
    }
    
    private static func createTotalBalanceLabel() -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = StyleProvider.fontWith(type: .regular, size: 14)
        label.numberOfLines = 1
        label.text = "Total XAF Balance"
        return label
    }
    
    private static func createTotalBalanceValue() -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = StyleProvider.fontWith(type: .bold, size: 18)
        label.numberOfLines = 1
        label.textAlignment = .right
        label.text = "2,000.00"
        return label
    }
    
    private static func createSeparatorView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }
    
    private static func createBalanceLinesStackView() -> UIStackView {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.spacing = 6
        stackView.alignment = .fill
        stackView.distribution = .fill
        return stackView
    }
    
    private static func createCurrentBalanceLine() -> WalletDetailBalanceLineView {
        return WalletDetailBalanceLineView(title: "Current Balance", value: "1,000.24")
    }
    
    private static func createBonusBalanceLine() -> WalletDetailBalanceLineView {
        return WalletDetailBalanceLineView(title: "Bonus Balance", value: "1,000.24")
    }
    
    private static func createCashbackBalanceLine() -> WalletDetailBalanceLineView {
        return WalletDetailBalanceLineView(title: "Cashback Balance", value: "0.00")
    }
    
    private static func createWithdrawableLine() -> WalletDetailBalanceLineView {
        return WalletDetailBalanceLineView(title: "Withdrawable", value: "1,000.24")
    }
    
    private func setupSubviews() {
        self.addSubview(self.stackView)
        
        // Add total balance section
        self.stackView.addArrangedSubview(self.totalBalanceContainer)
        self.totalBalanceContainer.addSubview(self.totalBalanceIcon)
        self.totalBalanceContainer.addSubview(self.totalBalanceLabel)
        self.totalBalanceContainer.addSubview(self.totalBalanceValue)
        
        // Add top separator
        self.stackView.addArrangedSubview(self.topSeparatorView)
        
        // Add balance lines
        self.stackView.addArrangedSubview(self.balanceLinesStackView)
        self.balanceLinesStackView.addArrangedSubview(self.currentBalanceLine)
        self.balanceLinesStackView.addArrangedSubview(self.bonusBalanceLine)
        self.balanceLinesStackView.addArrangedSubview(self.cashbackBalanceLine)
        self.balanceLinesStackView.addArrangedSubview(self.withdrawableLine)
        
        // Add bottom separator
        self.stackView.addArrangedSubview(self.bottomSeparatorView)
        
        self.initConstraints()
    }
    
    private func initConstraints() {
        NSLayoutConstraint.activate([
            // Main stack view
            self.stackView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            self.stackView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            self.stackView.topAnchor.constraint(equalTo: self.topAnchor),
            self.stackView.bottomAnchor.constraint(equalTo: self.bottomAnchor),
            
            // Total balance container
            self.totalBalanceContainer.heightAnchor.constraint(greaterThanOrEqualToConstant: 30),
            
            // Total balance icon
            self.totalBalanceIcon.leadingAnchor.constraint(equalTo: self.totalBalanceContainer.leadingAnchor),
            self.totalBalanceIcon.centerYAnchor.constraint(equalTo: self.totalBalanceContainer.centerYAnchor),
            self.totalBalanceIcon.widthAnchor.constraint(equalToConstant: 24),
            self.totalBalanceIcon.heightAnchor.constraint(equalToConstant: 24),
            
            // Total balance label
            self.totalBalanceLabel.leadingAnchor.constraint(equalTo: self.totalBalanceIcon.trailingAnchor, constant: 9),
            self.totalBalanceLabel.centerYAnchor.constraint(equalTo: self.totalBalanceContainer.centerYAnchor),
            
            // Total balance value
            self.totalBalanceValue.trailingAnchor.constraint(equalTo: self.totalBalanceContainer.trailingAnchor),
            self.totalBalanceValue.centerYAnchor.constraint(equalTo: self.totalBalanceContainer.centerYAnchor),
            self.totalBalanceValue.leadingAnchor.constraint(greaterThanOrEqualTo: self.totalBalanceLabel.trailingAnchor, constant: 16),
            
            // Separators
            self.topSeparatorView.heightAnchor.constraint(equalToConstant: 1),
            self.bottomSeparatorView.heightAnchor.constraint(equalToConstant: 1)
        ])
    }
}

// MARK: - Preview
#if DEBUG

@available(iOS 17.0, *)
#Preview("Wallet Detail Balance View") {
    PreviewUIViewController {
        let vc = UIViewController()
        vc.view.backgroundColor = .backgroundTestColor
        
        let balanceView = WalletDetailBalanceView()
        balanceView.translatesAutoresizingMaskIntoConstraints = false
        
        vc.view.addSubview(balanceView)
        
        NSLayoutConstraint.activate([
            balanceView.leadingAnchor.constraint(equalTo: vc.view.leadingAnchor, constant: 16),
            balanceView.trailingAnchor.constraint(equalTo: vc.view.trailingAnchor, constant: -16),
            balanceView.centerYAnchor.constraint(equalTo: vc.view.centerYAnchor)
        ])
        
        return vc
    }
}

#endif
