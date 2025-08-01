import UIKit
import Combine
import SwiftUI

/// A reusable button component for "Load More" functionality with loading states
final public class SeeMoreButtonView: UIView {
    
    // MARK: - UI Components
    
    private let containerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.cornerRadius = 8
        view.clipsToBounds = true
        return view
    }()
    
    private let button: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let loadingIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .medium)
        indicator.translatesAutoresizingMaskIntoConstraints = false
        indicator.hidesWhenStopped = true
        return indicator
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .center
        label.numberOfLines = 1
        return label
    }()
    
    // MARK: - Properties
    
    private let viewModel: SeeMoreButtonViewModelProtocol
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Public Callbacks
    
    /// Callback fired when the button is tapped
    public var onButtonTapped: (() -> Void) = { }
    
    // MARK: - Initialization
    
    public init(viewModel: SeeMoreButtonViewModelProtocol) {
        self.viewModel = viewModel
        super.init(frame: .zero)
        setupSubviews()
        setupBindings()
        setupActions()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Setup
    
    private func setupSubviews() {
        backgroundColor = .clear
        
        // Add container
        addSubview(containerView)
        
        // Add button to container
        containerView.addSubview(button)
        
        // Add label and loading indicator to button
        button.addSubview(titleLabel)
        button.addSubview(loadingIndicator)
        
        setupConstraints()
        applyInitialStyling()
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            // Container fills the view
            containerView.topAnchor.constraint(equalTo: topAnchor),
            containerView.leadingAnchor.constraint(equalTo: leadingAnchor),
            containerView.trailingAnchor.constraint(equalTo: trailingAnchor),
            containerView.bottomAnchor.constraint(equalTo: bottomAnchor),
            containerView.heightAnchor.constraint(equalToConstant: 44), // Standard button height
            
            // Button fills container
            button.topAnchor.constraint(equalTo: containerView.topAnchor),
            button.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            button.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            button.bottomAnchor.constraint(equalTo: containerView.bottomAnchor),
            
            // Title label centered
            titleLabel.centerXAnchor.constraint(equalTo: button.centerXAnchor),
            titleLabel.centerYAnchor.constraint(equalTo: button.centerYAnchor),
            titleLabel.leadingAnchor.constraint(greaterThanOrEqualTo: button.leadingAnchor, constant: 16),
            titleLabel.trailingAnchor.constraint(lessThanOrEqualTo: button.trailingAnchor, constant: -16),
            
            // Loading indicator centered
            loadingIndicator.centerXAnchor.constraint(equalTo: button.centerXAnchor),
            loadingIndicator.centerYAnchor.constraint(equalTo: button.centerYAnchor)
        ])
    }
    
    private func applyInitialStyling() {
        // Apply StyleProvider theming
        containerView.backgroundColor = StyleProvider.Color.highlightPrimary
        titleLabel.font = StyleProvider.fontWith(type: .medium, size: 13)
        titleLabel.textColor = StyleProvider.Color.buttonTextPrimary
        loadingIndicator.color = StyleProvider.Color.buttonTextPrimary
        
        // Set initial accessibility
        button.accessibilityTraits = .button
        isAccessibilityElement = true
    }
    
    private func setupBindings() {
        viewModel.displayStatePublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] displayState in
                self?.render(state: displayState)
            }
            .store(in: &cancellables)
    }
    
    private func setupActions() {
        button.addTarget(self, action: #selector(buttonTapped), for: .touchUpInside)
    }
    
    // MARK: - Rendering
    
    private func render(state: SeeMoreButtonDisplayState) {
        // Update loading state
        if state.isLoading {
            titleLabel.isHidden = true
            loadingIndicator.startAnimating()
        } else {
            titleLabel.isHidden = false
            loadingIndicator.stopAnimating()
        }
        
        // Update enabled state
        button.isEnabled = state.isEnabled
        containerView.alpha = state.isEnabled ? 1.0 : 0.6
        
        // Update title text
        updateTitleText(from: state.buttonData)
        
        // Update accessibility
        updateAccessibility(from: state)
    }
    
    private func updateTitleText(from buttonData: SeeMoreButtonData) {
        if let remainingCount = buttonData.remainingCount, remainingCount > 0 {
            titleLabel.text = "Load \(remainingCount) more games"
        } else {
            titleLabel.text = buttonData.title
        }
    }
    
    private func updateAccessibility(from state: SeeMoreButtonDisplayState) {
        if state.isLoading {
            accessibilityLabel = "Loading more games"
            accessibilityHint = "Please wait while more games are loaded"
            accessibilityTraits = .button
        } else if state.isEnabled {
            accessibilityLabel = titleLabel.text
            accessibilityHint = "Tap to load more games"
            accessibilityTraits = .button
        } else {
            accessibilityLabel = "Load more button unavailable"
            accessibilityHint = nil
            accessibilityTraits = [.button, .notEnabled]
        }
    }
    
    // MARK: - Actions
    
    @objc private func buttonTapped() {
        viewModel.buttonTapped()
        onButtonTapped()
    }
    
    // MARK: - Public Methods
    
    /// Manually configure the view with a ViewModel (useful for cell reuse)
    public func configure(with viewModel: SeeMoreButtonViewModelProtocol?) {
        // Clear existing bindings
        cancellables.removeAll()
        
        guard let viewModel = viewModel else {
            // Reset to placeholder state
            render(state: SeeMoreButtonDisplayState.disabled(
                buttonData: SeeMoreButtonData(id: "placeholder", title: "Load More")
            ))
            return
        }
        
        // Setup new bindings
        viewModel.displayStatePublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] displayState in
                self?.render(state: displayState)
            }
            .store(in: &cancellables)
    }
}

// MARK: - Preview Provider

#if DEBUG

@available(iOS 17.0, *)
#Preview("Default State") {
    PreviewUIView {
        SeeMoreButtonView(viewModel: MockSeeMoreButtonViewModel.defaultMock)
    }
    .frame(height: 44)
    .padding(.horizontal, 16)
}

@available(iOS 17.0, *)
#Preview("Loading State") {
    PreviewUIView {
        SeeMoreButtonView(viewModel: MockSeeMoreButtonViewModel.loadingMock)
    }
    .frame(height: 44)
    .padding(.horizontal, 16)
}

@available(iOS 17.0, *)
#Preview("With Count") {
    PreviewUIView {
        SeeMoreButtonView(viewModel: MockSeeMoreButtonViewModel.withCountMock)
    }
    .frame(height: 44)
    .padding(.horizontal, 16)
}

@available(iOS 17.0, *)
#Preview("Disabled State") {
    PreviewUIView {
        SeeMoreButtonView(viewModel: MockSeeMoreButtonViewModel.disabledMock)
    }
    .frame(height: 44)
    .padding(.horizontal, 16)
}

#endif
