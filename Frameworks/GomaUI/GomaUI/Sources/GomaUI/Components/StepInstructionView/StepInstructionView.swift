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
#Preview("All States") {
    PreviewUIViewController {
        let vc = UIViewController()
        vc.view.backgroundColor = .backgroundTestColor

        let titleLabel = UILabel()
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.text  = "StepInstructionView"
        titleLabel.textAlignment = .center
        
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 20
        stackView.alignment = .fill
        stackView.distribution = .equalSpacing
        stackView.translatesAutoresizingMaskIntoConstraints = false

        // Default mock - Mobile Money Step
        let defaultView = StepInstructionView(viewModel: MockStepInstructionViewModel.defaultMock)
        defaultView.translatesAutoresizingMaskIntoConstraints = false

        // Custom color mock - Second Step
        let customColorView = StepInstructionView(viewModel: MockStepInstructionViewModel.customColorMock)
        customColorView.translatesAutoresizingMaskIntoConstraints = false

        // Multiple highlights mock
        let multipleHighlightsView = StepInstructionView(viewModel: MockStepInstructionViewModel.multipleHighlightsMock)
        multipleHighlightsView.translatesAutoresizingMaskIntoConstraints = false

        stackView.addArrangedSubview(defaultView)
        stackView.addArrangedSubview(customColorView)
        stackView.addArrangedSubview(multipleHighlightsView)

        vc.view.addSubview(titleLabel)
        vc.view.addSubview(stackView)

        NSLayoutConstraint.activate([
            titleLabel.centerXAnchor.constraint(equalTo: stackView.centerXAnchor),
            
            titleLabel.bottomAnchor.constraint(equalTo: stackView.topAnchor, constant: -40),
            
            stackView.centerYAnchor.constraint(equalTo: vc.view.centerYAnchor),
            
            stackView.centerYAnchor.constraint(equalTo: vc.view.centerYAnchor),
            stackView.leadingAnchor.constraint(equalTo: vc.view.leadingAnchor, constant: 16),
            stackView.trailingAnchor.constraint(equalTo: vc.view.trailingAnchor, constant: -16)
        ])

        return vc
    }
}
#endif
