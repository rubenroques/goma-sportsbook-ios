import Foundation
import UIKit
import Combine
import SwiftUI

final public class DepositBonusInfoView: UIView {
    // MARK: - Private Properties
    private let containerView: GradientView = {
        let view = GradientView.customGradient(colors: [
            (StyleProvider.Color.liveBorder1, 0.0),
            (StyleProvider.Color.liveBorder2, 1.0),
        ], gradientDirection: .diagonal)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.cornerRadius = 8
        view.clipsToBounds = true
        return view
    }()
    
    private let iconImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    private let balanceLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = StyleProvider.fontWith(type: .medium, size: 12)
        label.textColor = StyleProvider.Color.buttonTextPrimary
        label.numberOfLines = 1
        return label
    }()
    
    private let currencyLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = StyleProvider.fontWith(type: .bold, size: 12)
        label.textColor = StyleProvider.Color.buttonTextPrimary
        label.numberOfLines = 1
        label.textAlignment = .right
        label.setContentCompressionResistancePriority(.required, for: .horizontal)
        return label
    }()
    
    private let mainStackView: UIStackView = {
        let stack = UIStackView()
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .horizontal
        stack.spacing = 12
        stack.alignment = .center
        stack.distribution = .fill
        return stack
    }()
    
    private let leftContentStackView: UIStackView = {
        let stack = UIStackView()
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .horizontal
        stack.spacing = 12
        stack.alignment = .center
        return stack
    }()
    
    private var cancellables = Set<AnyCancellable>()
    private let viewModel: DepositBonusBalanceViewModelProtocol
    
    // MARK: - Initialization
    public init(viewModel: DepositBonusBalanceViewModelProtocol) {
        self.viewModel = viewModel
        super.init(frame: .zero)
        setupSubviews()
        setupBindings()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Setup
    private func setupSubviews() {
        backgroundColor = .clear
        
        addSubview(containerView)
        containerView.addSubview(mainStackView)
        
        leftContentStackView.addArrangedSubview(iconImageView)
        leftContentStackView.addArrangedSubview(balanceLabel)
        
        mainStackView.addArrangedSubview(leftContentStackView)
        mainStackView.addArrangedSubview(currencyLabel)
        
        NSLayoutConstraint.activate([
            containerView.topAnchor.constraint(equalTo: topAnchor),
            containerView.leadingAnchor.constraint(equalTo: leadingAnchor),
            containerView.trailingAnchor.constraint(equalTo: trailingAnchor),
            containerView.bottomAnchor.constraint(equalTo: bottomAnchor),
            
            iconImageView.widthAnchor.constraint(equalToConstant: 24),
            iconImageView.heightAnchor.constraint(equalToConstant: 24),
            
            mainStackView.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 16),
            mainStackView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
            mainStackView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -16),
            mainStackView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -16)
        ])
        
    }
    
    override public func layoutSubviews() {
        super.layoutSubviews()
    }
    
    private func setupBindings() {
        viewModel.depositBonusInfoPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] depositBonusInfo in
                self?.configure(depositBonusInfo: depositBonusInfo)
            }
            .store(in: &cancellables)
    }
    
    // MARK: - Configuration
    private func configure(depositBonusInfo: DepositBonusInfoData) {
        // Update icon
        if let iconImage = UIImage(named: depositBonusInfo.icon) {
            iconImageView.image = iconImage.withRenderingMode(.alwaysTemplate)
            iconImageView.tintColor = StyleProvider.Color.allWhite
        }
        else if let iconImage = UIImage(systemName: depositBonusInfo.icon) {
            iconImageView.image = iconImage
            iconImageView.tintColor = StyleProvider.Color.allWhite
        }
        
        // Update balance text
        balanceLabel.text = depositBonusInfo.balanceText
        
        // Update currency amount
        currencyLabel.text = depositBonusInfo.currencyAmount
    }
    
}

// MARK: - Preview Provider
#if DEBUG

@available(iOS 17.0, *)
#Preview("Default Deposit Bonus Balance") {
    PreviewUIView {
        let viewModel = MockDepositBonusInfoViewModel.defaultMock
        
        return DepositBonusInfoView(viewModel: viewModel)
    }
    .frame(height: 60)
    .padding()
}

@available(iOS 17.0, *)
#Preview("Different Currency Balance") {
    PreviewUIView {
        DepositBonusInfoView(viewModel: MockDepositBonusInfoViewModel.usdMock)
    }
    .frame(height: 60)
    .padding()
}

#endif
