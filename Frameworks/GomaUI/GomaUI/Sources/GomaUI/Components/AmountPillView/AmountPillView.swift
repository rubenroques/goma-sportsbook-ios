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
#Preview("Amount Pill - Diferent States") {
    PreviewUIView {
        AmountPillView(viewModel: MockAmountPillViewModel.defaultMock)
    }
    .frame(height: 32)
    .padding()
    
    PreviewUIView {
        AmountPillView(viewModel: MockAmountPillViewModel.selectedMock)
    }
    .frame(height: 32)
    .padding()
}

#endif
