import Foundation
import UIKit
import Combine
import SwiftUI

final public class AmountPillView: UIView {
    // MARK: - Private Properties
    private let containerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = StyleProvider.Color.navPills
        view.layer.cornerRadius = 16
        view.clipsToBounds = true
        return view
    }()
    
    private let amountLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = StyleProvider.fontWith(type: .bold, size: 12)
        label.textColor = StyleProvider.Color.textPrimary
        label.textAlignment = .center
        label.numberOfLines = 1
        return label
    }()
    
    private var cancellables = Set<AnyCancellable>()
    let viewModel: AmountPillViewModelProtocol
    
    // MARK: - Initialization
    public init(viewModel: AmountPillViewModelProtocol) {
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
        containerView.addSubview(amountLabel)
        
        NSLayoutConstraint.activate([
            containerView.topAnchor.constraint(equalTo: topAnchor),
            containerView.leadingAnchor.constraint(equalTo: leadingAnchor),
            containerView.trailingAnchor.constraint(equalTo: trailingAnchor),
            containerView.bottomAnchor.constraint(equalTo: bottomAnchor),
            containerView.heightAnchor.constraint(equalToConstant: 32),
            
            amountLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 8),
            amountLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
            amountLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -16),
            amountLabel.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -8)
        ])
    }
    
    private func setupBindings() {
        viewModel.pillDataPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] pillData in
                self?.configure(pillData: pillData)
            }
            .store(in: &cancellables)
    }
    
    // MARK: - Configuration
    private func configure(pillData: AmountPillData) {
        // Update amount text with "+" prefix
        amountLabel.text = "+ \(pillData.amount)"
        
        // Update appearance based on selection state
        if pillData.isSelected {
            containerView.backgroundColor = StyleProvider.Color.highlightPrimary
            amountLabel.textColor = StyleProvider.Color.buttonTextPrimary
        } else {
            containerView.backgroundColor = StyleProvider.Color.navPills
            amountLabel.textColor = StyleProvider.Color.textPrimary
        }
    }
}

// MARK: - Preview Provider
#if DEBUG

@available(iOS 17.0, *)
#Preview("All States") {
    PreviewUIViewController {
        let vc = UIViewController()
        vc.view.backgroundColor = StyleProvider.Color.backgroundPrimary

        // 1. TITLE LABEL
        let titleLabel = UILabel()
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.text = "AmountPillView"
        titleLabel.font = StyleProvider.fontWith(type: .bold, size: 18)
        titleLabel.textColor = StyleProvider.Color.textPrimary
        titleLabel.textAlignment = .center

        // 2. VERTICAL STACK with ALL states
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 16
        stackView.alignment = .center
        stackView.distribution = .equalSpacing
        stackView.translatesAutoresizingMaskIntoConstraints = false

        // 3. ADD ALL COMPONENT INSTANCES
        // Unselected state
        let unselectedPillData = AmountPillData(id: "500", amount: "500", isSelected: false)
        let unselectedPill = AmountPillView(viewModel: MockAmountPillViewModel(pillData: unselectedPillData))
        unselectedPill.translatesAutoresizingMaskIntoConstraints = false

        // Selected state
        let selectedPillData = AmountPillData(id: "1000", amount: "1000", isSelected: true)
        let selectedPill = AmountPillView(viewModel: MockAmountPillViewModel(pillData: selectedPillData))
        selectedPill.translatesAutoresizingMaskIntoConstraints = false

        // Large amount
        let largePillData = AmountPillData(id: "50000", amount: "50000", isSelected: false)
        let largePill = AmountPillView(viewModel: MockAmountPillViewModel(pillData: largePillData))
        largePill.translatesAutoresizingMaskIntoConstraints = false

        // Add all states to stack
        stackView.addArrangedSubview(unselectedPill)
        stackView.addArrangedSubview(selectedPill)
        stackView.addArrangedSubview(largePill)

        // 4. ADD TO VIEW HIERARCHY
        vc.view.addSubview(titleLabel)
        vc.view.addSubview(stackView)

        // 5. CONSTRAINTS
        NSLayoutConstraint.activate([
            titleLabel.centerXAnchor.constraint(equalTo: vc.view.centerXAnchor),
            titleLabel.bottomAnchor.constraint(equalTo: stackView.topAnchor, constant: -20),

            stackView.centerYAnchor.constraint(equalTo: vc.view.centerYAnchor),
            stackView.leadingAnchor.constraint(equalTo: vc.view.leadingAnchor, constant: 16),
            stackView.trailingAnchor.constraint(equalTo: vc.view.trailingAnchor, constant: -16),

            unselectedPill.heightAnchor.constraint(equalToConstant: 32),
            selectedPill.heightAnchor.constraint(equalToConstant: 32),
            largePill.heightAnchor.constraint(equalToConstant: 32)
        ])

        return vc
    }
}

#endif
