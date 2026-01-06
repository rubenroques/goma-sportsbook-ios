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

#Preview("QuickAddButtonView") {
    PreviewUIViewController {
        let vc = UIViewController()
        vc.view.backgroundColor = .backgroundTestColor

        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 16
        stackView.alignment = .center
        stackView.translatesAutoresizingMaskIntoConstraints = false

        // Title label
        let titleLabel = UILabel()
        titleLabel.text = "QuickAddButtonView"
        titleLabel.font = StyleProvider.fontWith(type: .bold, size: 18)
        titleLabel.textColor = StyleProvider.Color.textPrimary
        titleLabel.textAlignment = .center
        titleLabel.translatesAutoresizingMaskIntoConstraints = false

        // Amount 100
        let amount100View = QuickAddButtonView(viewModel: MockQuickAddButtonViewModel.amount100Mock())
        amount100View.translatesAutoresizingMaskIntoConstraints = false

        // Amount 250
        let amount250View = QuickAddButtonView(viewModel: MockQuickAddButtonViewModel.amount250Mock())
        amount250View.translatesAutoresizingMaskIntoConstraints = false

        // Amount 500
        let amount500View = QuickAddButtonView(viewModel: MockQuickAddButtonViewModel.amount500Mock())
        amount500View.translatesAutoresizingMaskIntoConstraints = false

        // Disabled
        let disabledView = QuickAddButtonView(viewModel: MockQuickAddButtonViewModel.disabledMock())
        disabledView.translatesAutoresizingMaskIntoConstraints = false

        stackView.addArrangedSubview(titleLabel)
        stackView.addArrangedSubview(amount100View)
        stackView.addArrangedSubview(amount250View)
        stackView.addArrangedSubview(amount500View)
        stackView.addArrangedSubview(disabledView)

        vc.view.addSubview(stackView)

        NSLayoutConstraint.activate([
            stackView.centerYAnchor.constraint(equalTo: vc.view.centerYAnchor),
            stackView.centerXAnchor.constraint(equalTo: vc.view.centerXAnchor),

            // Fixed size for buttons
            amount100View.widthAnchor.constraint(equalToConstant: 50),
            amount100View.heightAnchor.constraint(equalToConstant: 50),
            amount250View.widthAnchor.constraint(equalToConstant: 50),
            amount250View.heightAnchor.constraint(equalToConstant: 50),
            amount500View.widthAnchor.constraint(equalToConstant: 50),
            amount500View.heightAnchor.constraint(equalToConstant: 50),
            disabledView.widthAnchor.constraint(equalToConstant: 50),
            disabledView.heightAnchor.constraint(equalToConstant: 50)
        ])

        return vc
    }
}

#endif 