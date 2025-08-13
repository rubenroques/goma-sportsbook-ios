import Foundation
import UIKit
import Combine
import SwiftUI

/// A component for quick add amount buttons in bet submission
public final class QuickAddButtonView: UIView {
    
    // MARK: - Properties
    public let viewModel: QuickAddButtonViewModelProtocol
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - UI Components
    
    // Button
    private lazy var button: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(buttonTapped), for: .touchUpInside)
        return button
    }()
    
    // MARK: - Initialization
    public init(viewModel: QuickAddButtonViewModelProtocol) {
        self.viewModel = viewModel
        super.init(frame: .zero)
        setupSubviews()
        setupConstraints()
        setupBindings()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Setup
    private func setupSubviews() {
        addSubview(button)
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            button.topAnchor.constraint(equalTo: topAnchor),
            button.leadingAnchor.constraint(equalTo: leadingAnchor),
            button.trailingAnchor.constraint(equalTo: trailingAnchor),
            button.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }
    
    private func setupBindings() {
        viewModel.dataPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] data in
                self?.render(data: data)
            }
            .store(in: &cancellables)
    }
    
    // MARK: - Rendering
    private func render(data: QuickAddButtonData) {
        // Update button title
        button.setTitle("+\(data.amount)", for: .normal)
        
        // Update button styling
        button.setTitleColor(StyleProvider.Color.textPrimary, for: .normal)
        button.titleLabel?.font = StyleProvider.fontWith(type: .bold, size: 12)
        button.backgroundColor = StyleProvider.Color.inputBackground
        button.layer.cornerRadius = 4
        
        // Update enabled state
        button.isEnabled = data.isEnabled
        alpha = data.isEnabled ? 1.0 : 0.5
    }
    
    // MARK: - Actions
    @objc private func buttonTapped() {
        viewModel.onButtonTapped?()
    }
}

// MARK: - SwiftUI Preview
#if DEBUG

@available(iOS 17.0, *)
#Preview("Amount 100") {
    PreviewUIView {
        QuickAddButtonView(viewModel: MockQuickAddButtonViewModel.amount100Mock())
    }
    .frame(width: 50, height: 50)
    .padding()
}

@available(iOS 17.0, *)
#Preview("Amount 250") {
    PreviewUIView {
        QuickAddButtonView(viewModel: MockQuickAddButtonViewModel.amount250Mock())
    }
    .frame(width: 50, height: 50)
    .padding()
}

@available(iOS 17.0, *)
#Preview("Amount 500") {
    PreviewUIView {
        QuickAddButtonView(viewModel: MockQuickAddButtonViewModel.amount500Mock())
    }
    .frame(width: 50, height: 50)
    .padding()
}

@available(iOS 17.0, *)
#Preview("Disabled") {
    PreviewUIView {
        QuickAddButtonView(viewModel: MockQuickAddButtonViewModel.disabledMock())
    }
    .frame(width: 50, height: 50)
    .padding()
}

#endif 