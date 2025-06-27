//
//  StepInstructionView.swift
//  GomaUI
//
//  Created by André Lascas on 11/06/2025.
//

import Foundation
import UIKit
import Combine
import SwiftUI

public final class StepInstructionView: UIView {
    
    // MARK: - UI Components
    private lazy var stepIndicatorView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = StyleProvider.Color.highlightPrimary
        view.layer.cornerRadius = 16
        return view
    }()
    
    private lazy var stepNumberLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = StyleProvider.fontWith(type: .bold, size: 16)
        label.textColor = StyleProvider.Color.buttonTextPrimary
        label.textAlignment = .center
        return label
    }()
    
    private lazy var highlightedTextView: HighlightedTextView = {
        let textView = HighlightedTextView(viewModel: viewModel.highlightedTextViewModel)
        textView.translatesAutoresizingMaskIntoConstraints = false
        return textView
    }()
    
    private lazy var containerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    // MARK: - Properties
    private let viewModel: StepInstructionViewModelProtocol
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Initialization
    public init(viewModel: StepInstructionViewModelProtocol = MockStepInstructionViewModel.defaultMock) {
        self.viewModel = viewModel
        super.init(frame: .zero)
        setupViews()
        setupBindings()
    }
    
    required init?(coder: NSCoder) {
        self.viewModel = MockStepInstructionViewModel.defaultMock
        super.init(coder: coder)
        setupViews()
        setupBindings()
    }
    
    // MARK: - Private Methods
    private func setupViews() {
        backgroundColor = .clear
        
        // Setup step indicator
        stepIndicatorView.addSubview(stepNumberLabel)
        
        // Add to stack view
        containerView.addSubview(stepIndicatorView)
        containerView.addSubview(highlightedTextView)
        
        addSubview(containerView)
        
        setupConstraints()
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            // Container stack view
            containerView.topAnchor.constraint(equalTo: topAnchor),
            containerView.leadingAnchor.constraint(equalTo: leadingAnchor),
            containerView.trailingAnchor.constraint(equalTo: trailingAnchor),
            containerView.bottomAnchor.constraint(equalTo: bottomAnchor),
            
            // Step indicator
            stepIndicatorView.widthAnchor.constraint(equalToConstant: 32),
            stepIndicatorView.heightAnchor.constraint(equalToConstant: 32),
            stepIndicatorView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
            stepIndicatorView.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 8),
            stepIndicatorView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -8),
            
            // Step number label
            stepNumberLabel.centerXAnchor.constraint(equalTo: stepIndicatorView.centerXAnchor),
            stepNumberLabel.centerYAnchor.constraint(equalTo: stepIndicatorView.centerYAnchor),
            
            // Highlighted text view (flexible width)
            highlightedTextView.leadingAnchor.constraint(equalTo: stepIndicatorView.trailingAnchor, constant: 8),
            highlightedTextView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -16),
            highlightedTextView.centerYAnchor.constraint(equalTo: containerView.centerYAnchor)
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
    
    private func configure(with data: StepInstructionData) {
        stepNumberLabel.text = "\(data.stepNumber)"
        
        if let indicatorColor = data.indicatorColor {
            stepIndicatorView.backgroundColor = data.indicatorColor
        }
        
        if let numberTextColor = data.numberTextColor {
            stepNumberLabel.textColor = data.numberTextColor
        }
    }
}

// MARK: - SwiftUI Preview
#if DEBUG

@available(iOS 17.0, *)
struct StepInstructionView_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: 20) {
            PreviewUIView {
                StepInstructionView(viewModel: MockStepInstructionViewModel.defaultMock)
            }
            .previewDisplayName("Mobile Money Step")
            .frame(height: 48)
            
            PreviewUIView {
                StepInstructionView(viewModel: MockStepInstructionViewModel.customColorMock)
            }
            .previewDisplayName("Second Step")
            .frame(height: 48)

            PreviewUIView {
                StepInstructionView(viewModel: MockStepInstructionViewModel.multipleHighlightsMock)
            }
            .previewDisplayName("Custom Color")
            .frame(height: 48)

        }
        .padding()
    }
}
#endif
