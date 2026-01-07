import Foundation
import UIKit
import Combine
import SwiftUI

public final class InfoRowView: UIView {
    
    // MARK: - UI Components
    private lazy var containerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = StyleProvider.Color.backgroundSecondary
        view.layer.cornerRadius = 4
        return view
    }()
    
    private lazy var leftLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = StyleProvider.fontWith(type: .semibold, size: 12)
        label.textColor = StyleProvider.Color.textPrimary
        label.numberOfLines = 0
        return label
    }()
    
    private lazy var rightLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = StyleProvider.fontWith(type: .bold, size: 12)
        label.textColor = StyleProvider.Color.highlightPrimary
        label.textAlignment = .right
        label.numberOfLines = 0
        return label
    }()
    
    private lazy var stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .horizontal
        stackView.alignment = .center
        stackView.distribution = .fill
        stackView.spacing = 12
        return stackView
    }()
    
    // MARK: - Properties
    private let viewModel: InfoRowViewModelProtocol
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Initialization
    public init(viewModel: InfoRowViewModelProtocol = MockInfoRowViewModel.defaultMock) {
        self.viewModel = viewModel
        super.init(frame: .zero)
        setupViews()
        setupBindings()
    }
    
    required init?(coder: NSCoder) {
        self.viewModel = MockInfoRowViewModel.defaultMock
        super.init(coder: coder)
        setupViews()
        setupBindings()
    }
    
    // MARK: - Private Methods
    private func setupViews() {
        backgroundColor = .clear
        
        addSubview(containerView)
        containerView.addSubview(stackView)
        
        // Set content priorities
        leftLabel.setContentHuggingPriority(.defaultLow, for: .horizontal)
        rightLabel.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        leftLabel.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        rightLabel.setContentCompressionResistancePriority(.defaultHigh, for: .horizontal)
        
        stackView.addArrangedSubview(leftLabel)
        stackView.addArrangedSubview(rightLabel)
        
        setupConstraints()
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            // Container view
            containerView.topAnchor.constraint(equalTo: topAnchor),
            containerView.leadingAnchor.constraint(equalTo: leadingAnchor),
            containerView.trailingAnchor.constraint(equalTo: trailingAnchor),
            containerView.bottomAnchor.constraint(equalTo: bottomAnchor),
            
            // Stack view
            stackView.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 16),
            stackView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
            stackView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -16),
            stackView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -16)
        ])
    }
    
    private func setupBindings() {
        viewModel.dataPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] data in
                self?.configure(with: data)
            }
            .store(in: &cancellables)
    }
    
    private func configure(with data: InfoRowData) {
        leftLabel.text = data.leftText
        rightLabel.text = data.rightText
        
        // Apply custom styling if provided
        if let leftColor = data.leftTextColor {
            leftLabel.textColor = leftColor
        }
        if let rightColor = data.rightTextColor {
            rightLabel.textColor = rightColor
        }
        if let backgroundColor = data.backgroundColor {
            containerView.backgroundColor = backgroundColor
        }
    }
}

// MARK: - SwiftUI Preview
#if DEBUG

#Preview("All States") {
    PreviewUIViewController {
        let vc = UIViewController()
        vc.view.backgroundColor = .backgroundTestColor

        // Title label
        let titleLabel = UILabel()
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.text = "InfoRowView"
        titleLabel.font = StyleProvider.fontWith(type: .bold, size: 18)
        titleLabel.textColor = StyleProvider.Color.textPrimary
        titleLabel.textAlignment = .center

        // Vertical stack with all states
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 16
        stackView.alignment = .fill
        stackView.distribution = .equalSpacing
        stackView.translatesAutoresizingMaskIntoConstraints = false

        // Default state - Your Deposit
        let defaultView = InfoRowView(viewModel: MockInfoRowViewModel.defaultMock)
        defaultView.translatesAutoresizingMaskIntoConstraints = false

        // Balance state - Account Balance
        let balanceView = InfoRowView(viewModel: MockInfoRowViewModel.balanceMock)
        balanceView.translatesAutoresizingMaskIntoConstraints = false

        // Custom colors state - Bonus Balance
        let customColorsView = InfoRowView(viewModel: MockInfoRowViewModel.customBackgroundMock)
        customColorsView.translatesAutoresizingMaskIntoConstraints = false

        stackView.addArrangedSubview(defaultView)
        stackView.addArrangedSubview(balanceView)
        stackView.addArrangedSubview(customColorsView)

        // Add to view hierarchy
        vc.view.addSubview(titleLabel)
        vc.view.addSubview(stackView)

        // Constraints
        NSLayoutConstraint.activate([
            titleLabel.centerXAnchor.constraint(equalTo: vc.view.centerXAnchor),
            titleLabel.bottomAnchor.constraint(equalTo: stackView.topAnchor, constant: -20),

            stackView.centerYAnchor.constraint(equalTo: vc.view.centerYAnchor),
            stackView.leadingAnchor.constraint(equalTo: vc.view.leadingAnchor, constant: 16),
            stackView.trailingAnchor.constraint(equalTo: vc.view.trailingAnchor, constant: -16)
        ])

        return vc
    }
}
#endif
