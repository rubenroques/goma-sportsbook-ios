import UIKit
import SwiftUI

/// Internal balance line component specifically designed for WalletDetailView
/// with white text on orange background.
internal final class WalletDetailBalanceLineView: UIView {
    
    // MARK: - Private Properties
    private lazy var containerStackView = Self.createContainerStackView()
    private lazy var titleLabel = Self.createTitleLabel()
    private lazy var valueLabel = Self.createValueLabel()
    
    // MARK: - Public Properties
    public var titleText: String? {
        get { titleLabel.text }
        set { titleLabel.text = newValue }
    }
    
    public var valueText: String? {
        get { valueLabel.text }
        set { valueLabel.text = newValue }
    }
    
    // MARK: - Initialization
    init(title: String, value: String = "") {
        super.init(frame: .zero)
        setupSubviews()
        setupConstraints()
        applyTheme()
        
        // Configure initial state
        titleText = title
        valueText = value
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Setup
    private func setupSubviews() {
        translatesAutoresizingMaskIntoConstraints = false
        
        addSubview(containerStackView)
        
        // Build horizontal layout: title + value
        containerStackView.addArrangedSubview(titleLabel)
        containerStackView.addArrangedSubview(valueLabel)
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            // Container fills the view
            containerStackView.topAnchor.constraint(equalTo: topAnchor),
            containerStackView.leadingAnchor.constraint(equalTo: leadingAnchor),
            containerStackView.trailingAnchor.constraint(equalTo: trailingAnchor),
            containerStackView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }
    
    private func applyTheme() {
        // White text for both title and value on orange background
        titleLabel.textColor = StyleProvider.Color.allWhite
        titleLabel.font = StyleProvider.fontWith(type: .regular, size: 12)
        
        valueLabel.textColor = StyleProvider.Color.allWhite
        valueLabel.font = StyleProvider.fontWith(type: .bold, size: 14)
    }
    
    // MARK: - Public Methods
    public func updateValue(_ newValue: String) {
        valueText = newValue
    }
}

// MARK: - Factory Methods
private extension WalletDetailBalanceLineView {
    
    static func createContainerStackView() -> UIStackView {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .horizontal
        stackView.distribution = .equalSpacing
        stackView.alignment = .center
        return stackView
    }
    
    static func createTitleLabel() -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }
    
    static func createValueLabel() -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .right
        label.setContentCompressionResistancePriority(.required, for: .horizontal)
        label.setContentCompressionResistancePriority(.required, for: .vertical)
        return label
    }
}

// MARK: - Preview Provider
#if DEBUG

#Preview("White Balance Lines on Orange") {
    PreviewUIViewController {
        let vc = UIViewController()
        vc.view.backgroundColor = .backgroundTestColor
        
        // Create container stack view for all lines
        let containerStack = UIStackView()
        containerStack.axis = .vertical
        containerStack.spacing = 6
        containerStack.translatesAutoresizingMaskIntoConstraints = false
        
        // Create different balance lines
        let currentBalanceLine = WalletDetailBalanceLineView(title: "Current Balance", value: "1,000.24")
        let bonusBalanceLine = WalletDetailBalanceLineView(title: "Bonus Balance", value: "1,000.24")
        let cashbackBalanceLine = WalletDetailBalanceLineView(title: "Cashback Balance", value: "0.00")
        let withdrawableLine = WalletDetailBalanceLineView(title: "Withdrawable", value: "1,000.24")
        
        // Add all lines to stack
        containerStack.addArrangedSubview(currentBalanceLine)
        containerStack.addArrangedSubview(bonusBalanceLine)
        containerStack.addArrangedSubview(cashbackBalanceLine)
        containerStack.addArrangedSubview(withdrawableLine)
        
        vc.view.addSubview(containerStack)
        
        NSLayoutConstraint.activate([
            containerStack.centerXAnchor.constraint(equalTo: vc.view.centerXAnchor),
            containerStack.centerYAnchor.constraint(equalTo: vc.view.centerYAnchor),
            containerStack.leadingAnchor.constraint(equalTo: vc.view.leadingAnchor, constant: 20),
            containerStack.trailingAnchor.constraint(equalTo: vc.view.trailingAnchor, constant: -20)
        ])
        
        return vc
    }
}

#endif
