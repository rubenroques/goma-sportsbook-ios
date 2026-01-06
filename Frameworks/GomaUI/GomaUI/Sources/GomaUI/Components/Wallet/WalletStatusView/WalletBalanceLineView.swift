import UIKit
import SwiftUI

final class WalletBalanceLineView: UIView {
    
    // MARK: - Private Properties
    private lazy var containerStackView = Self.createContainerStackView()
    private lazy var leftStackView = Self.createLeftStackView()
    private lazy var iconImageView = Self.createIconImageView()
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
    
    public var icon: UIImage? {
        get { iconImageView.image }
        set { 
            iconImageView.image = newValue?.withRenderingMode(.alwaysTemplate)
            iconImageView.isHidden = newValue == nil
        }
    }
    
    public var iconTintColor: UIColor? {
        get { iconImageView.tintColor }
        set { iconImageView.tintColor = newValue }
    }
    
    // MARK: - Initialization
    init(title: String, value: String = "", showIcon: Bool = false) {
        super.init(frame: .zero)
        setupSubviews()
        setupConstraints()
        applyTheme()
        
        // Configure initial state
        titleText = title
        valueText = value
        iconImageView.isHidden = !showIcon
    }
    
    convenience init(title: String, value: String = "", icon: UIImage?) {
        self.init(title: title, value: value, showIcon: icon != nil)
        self.icon = icon
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Setup
    private func setupSubviews() {
        translatesAutoresizingMaskIntoConstraints = false
        
        addSubview(containerStackView)
        
        // Build left side: icon (optional) + title
        leftStackView.addArrangedSubview(iconImageView)
        leftStackView.addArrangedSubview(titleLabel)
        
        // Build main container: left side + value
        containerStackView.addArrangedSubview(leftStackView)
        containerStackView.addArrangedSubview(valueLabel)
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            // Container fills the view
            containerStackView.topAnchor.constraint(equalTo: topAnchor),
            containerStackView.leadingAnchor.constraint(equalTo: leadingAnchor),
            containerStackView.trailingAnchor.constraint(equalTo: trailingAnchor),
            containerStackView.bottomAnchor.constraint(equalTo: bottomAnchor),
            
            // Icon size constraints
            iconImageView.widthAnchor.constraint(equalToConstant: 24),
            iconImageView.heightAnchor.constraint(equalToConstant: 24)
        ])
    }
    
    private func applyTheme() {
        titleLabel.textColor = StyleProvider.Color.textPrimary
        titleLabel.font = StyleProvider.fontWith(type: .regular, size: 12)
        
        valueLabel.textColor = StyleProvider.Color.highlightPrimary
        valueLabel.font = StyleProvider.fontWith(type: .bold, size: 14)
        
        iconImageView.tintColor = StyleProvider.Color.highlightPrimary
    }
    
    // MARK: - Public Methods
    public func updateValue(_ newValue: String) {
        valueText = newValue
    }
    
    public func setIconTintColor(_ color: UIColor) {
        iconTintColor = color
    }
}

// MARK: - Factory Methods
private extension WalletBalanceLineView {
    
    static func createContainerStackView() -> UIStackView {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .horizontal
        stackView.distribution = .equalSpacing
        stackView.alignment = .center
        return stackView
    }
    
    static func createLeftStackView() -> UIStackView {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.spacing = 3
        stackView.alignment = .center
        return stackView
    }
    
    static func createIconImageView() -> UIImageView {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        imageView.isHidden = true // Hidden by default
        return imageView
    }
    
    static func createTitleLabel() -> UILabel {
        let label = UILabel()
        return label
    }
    
    static func createValueLabel() -> UILabel {
        let label = UILabel()
        label.textAlignment = .right
        label.setContentCompressionResistancePriority(.required, for: .horizontal)
        label.setContentCompressionResistancePriority(.required, for: .vertical)
        return label
    }
}

// MARK: - Preview Provider
#if DEBUG

#Preview("All Balance Line States") {
    PreviewUIViewController {
        let vc = UIViewController()
        
        // Create container stack view for all states
        let containerStack = UIStackView()
        containerStack.axis = .vertical
        containerStack.spacing = 12
        containerStack.translatesAutoresizingMaskIntoConstraints = false
        
        // Total Balance with icon
        let totalBalanceLineView = WalletBalanceLineView(
            title: "Total Balance",
            value: "2,000.00",
            icon: UIImage(named: "banknote_cash_icon", in: Bundle.module, compatibleWith: nil)
        )
        totalBalanceLineView.backgroundColor = StyleProvider.Color.backgroundTertiary
        totalBalanceLineView.layer.cornerRadius = 4
        totalBalanceLineView.translatesAutoresizingMaskIntoConstraints = false
        
        // Current Balance
        let currentBalanceLineView = WalletBalanceLineView(title: "Current Balance Long Long Long Long Long Long Long String", value: "1,000,000,000.00")
        currentBalanceLineView.backgroundColor = StyleProvider.Color.backgroundTertiary
        currentBalanceLineView.layer.cornerRadius = 4
        currentBalanceLineView.translatesAutoresizingMaskIntoConstraints = false
        
        // Bonus
        let bonusLineView = WalletBalanceLineView(title: "Bonus", value: "965.00")
        bonusLineView.backgroundColor = StyleProvider.Color.backgroundTertiary
        bonusLineView.layer.cornerRadius = 4
        bonusLineView.translatesAutoresizingMaskIntoConstraints = false
        
        // Cashback balance
        let cashbackLineView = WalletBalanceLineView(title: "Cashback balance", value: "35.00")
        cashbackLineView.backgroundColor = StyleProvider.Color.backgroundTertiary
        cashbackLineView.layer.cornerRadius = 4
        cashbackLineView.translatesAutoresizingMaskIntoConstraints = false
        
        // Withdrawable
        let withdrawableLineView = WalletBalanceLineView(title: "Withdrawable", value: "1,000.00")
        withdrawableLineView.backgroundColor = StyleProvider.Color.backgroundTertiary
        withdrawableLineView.layer.cornerRadius = 4
        withdrawableLineView.translatesAutoresizingMaskIntoConstraints = false
        
        // Create labels for each section
        let createLabel: (String) -> UILabel = { text in
            let label = UILabel()
            label.text = text
            label.font = StyleProvider.fontWith(type: .medium, size: 14)
            label.textColor = StyleProvider.Color.textSecondary
            label.textAlignment = .center
            label.translatesAutoresizingMaskIntoConstraints = false
            return label
        }
        
        // Add all components to stack
        containerStack.addArrangedSubview(createLabel("With Icon"))
        containerStack.addArrangedSubview(totalBalanceLineView)
        containerStack.addArrangedSubview(createLabel("Without Icon"))
        containerStack.addArrangedSubview(currentBalanceLineView)
        containerStack.addArrangedSubview(bonusLineView)
        containerStack.addArrangedSubview(cashbackLineView)
        containerStack.addArrangedSubview(withdrawableLineView)
        
        vc.view.addSubview(containerStack)
        
        NSLayoutConstraint.activate([
            containerStack.centerXAnchor.constraint(equalTo: vc.view.centerXAnchor),
            containerStack.topAnchor.constraint(equalTo: vc.view.topAnchor, constant: 50),
            containerStack.leadingAnchor.constraint(equalTo: vc.view.leadingAnchor, constant: 20),
            containerStack.trailingAnchor.constraint(equalTo: vc.view.trailingAnchor, constant: -20),
            
            totalBalanceLineView.heightAnchor.constraint(equalToConstant: 40),
            currentBalanceLineView.heightAnchor.constraint(equalToConstant: 40),
            bonusLineView.heightAnchor.constraint(equalToConstant: 40),
            cashbackLineView.heightAnchor.constraint(equalToConstant: 40),
            withdrawableLineView.heightAnchor.constraint(equalToConstant: 40)
        ])
        
        vc.view.backgroundColor = StyleProvider.Color.backgroundPrimary
        return vc
    }
}

#endif
