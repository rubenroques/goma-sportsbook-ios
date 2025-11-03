
import UIKit
import SwiftUI

final public class WalletDetailHeaderView: UIView {
    
    // MARK: Private properties
    private lazy var containerView: UIView = Self.createContainerView()
    private lazy var walletIconView: UIView = Self.createWalletIconView()
    private lazy var mtnIconImageView: UIImageView = Self.createMtnIconImageView()
    private lazy var walletLabel: UILabel = Self.createWalletLabel()
    private lazy var phoneNumberLabel: UILabel = Self.createPhoneNumberLabel()
    
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
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        self.containerView.layer.cornerRadius = 8
        self.walletIconView.layer.cornerRadius = 4
    }
    
    func setupWithTheme() {
        self.backgroundColor = UIColor.clear
        self.containerView.backgroundColor = StyleProvider.Color.allWhite
        self.walletIconView.backgroundColor = StyleProvider.Color.highlightSecondary
        self.walletLabel.textColor = StyleProvider.Color.allDark
        self.phoneNumberLabel.textColor = StyleProvider.Color.allDark
        self.mtnIconImageView.tintColor = StyleProvider.Color.allWhite
    }
    
    // MARK: Functions
    func configure(walletTitle: String, phoneNumber: String) {
        self.walletLabel.text = walletTitle
        self.phoneNumberLabel.text = phoneNumber
    }
}

// MARK: - Subviews Initialization and Setup
extension WalletDetailHeaderView {
    
    private static func createContainerView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }
    
    private static func createWalletIconView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }
    
    private static func createMtnIconImageView() -> UIImageView {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        imageView.image = UIImage(systemName: "creditcard.fill") // Placeholder - should use actual MTN icon
        imageView.tintColor = StyleProvider.Color.textPrimary
        return imageView
    }
    
    private static func createWalletLabel() -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = StyleProvider.fontWith(type: .regular, size: 12)
        label.numberOfLines = 1
        label.text = "Wallet"
        return label
    }
    
    private static func createPhoneNumberLabel() -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = StyleProvider.fontWith(type: .regular, size: 12)
        label.numberOfLines = 1
        label.textAlignment = .right
        label.text = "+234 737 456789"
        return label
    }
    
    private func setupSubviews() {
        self.addSubview(self.containerView)
        
        self.containerView.addSubview(self.walletIconView)
        self.containerView.addSubview(self.walletLabel)
        self.containerView.addSubview(self.phoneNumberLabel)
        
        self.walletIconView.addSubview(self.mtnIconImageView)
        
        self.initConstraints()
    }
    
    private func initConstraints() {
        NSLayoutConstraint.activate([
            // Container
            self.containerView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            self.containerView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            self.containerView.topAnchor.constraint(equalTo: self.topAnchor),
            self.containerView.bottomAnchor.constraint(equalTo: self.bottomAnchor),
            self.containerView.heightAnchor.constraint(equalToConstant: 48),
            
            // Wallet icon container
            self.walletIconView.leadingAnchor.constraint(equalTo: self.containerView.leadingAnchor, constant: 8),
            self.walletIconView.centerYAnchor.constraint(equalTo: self.containerView.centerYAnchor),
            self.walletIconView.widthAnchor.constraint(equalToConstant: 32),
            self.walletIconView.heightAnchor.constraint(equalToConstant: 32),
            
            // MTN icon
            self.mtnIconImageView.centerXAnchor.constraint(equalTo: self.walletIconView.centerXAnchor),
            self.mtnIconImageView.centerYAnchor.constraint(equalTo: self.walletIconView.centerYAnchor),
            self.mtnIconImageView.widthAnchor.constraint(equalToConstant: 20),
            self.mtnIconImageView.heightAnchor.constraint(equalToConstant: 20),
            
            // Wallet label
            self.walletLabel.leadingAnchor.constraint(equalTo: self.walletIconView.trailingAnchor, constant: 8),
            self.walletLabel.centerYAnchor.constraint(equalTo: self.containerView.centerYAnchor),
            self.walletLabel.trailingAnchor.constraint(lessThanOrEqualTo: self.phoneNumberLabel.leadingAnchor, constant: -16),
            
            // Phone number label
            self.phoneNumberLabel.trailingAnchor.constraint(equalTo: self.containerView.trailingAnchor, constant: -8),
            self.phoneNumberLabel.centerYAnchor.constraint(equalTo: self.containerView.centerYAnchor)
        ])
    }
}

// MARK: - Preview
#if DEBUG

@available(iOS 17.0, *)
#Preview("Wallet Detail Header") {
    PreviewUIViewController {
        let vc = UIViewController()
        vc.view.backgroundColor = .backgroundTestColor
        
        let headerView = WalletDetailHeaderView()
        headerView.configure(walletTitle: "Wallet", phoneNumber: "+234 737 456789")
        headerView.translatesAutoresizingMaskIntoConstraints = false
        
        vc.view.addSubview(headerView)
        
        NSLayoutConstraint.activate([
            headerView.leadingAnchor.constraint(equalTo: vc.view.leadingAnchor, constant: 16),
            headerView.trailingAnchor.constraint(equalTo: vc.view.trailingAnchor, constant: -16),
            headerView.centerYAnchor.constraint(equalTo: vc.view.centerYAnchor)
        ])
        
        return vc
    }
}

#endif
