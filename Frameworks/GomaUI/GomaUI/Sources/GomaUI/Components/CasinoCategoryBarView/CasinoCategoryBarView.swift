import UIKit
import Combine
import SwiftUI

final public class CasinoCategoryBarView: UIView {
    
    // MARK: - Constants
    private enum Constants {
        static let horizontalPadding: CGFloat = 16.0
        static let verticalPadding: CGFloat = 12.0
        static let buttonHorizontalPadding: CGFloat = 10.0
        static let buttonVerticalPadding: CGFloat = 4.0
        static let buttonCornerRadius: CGFloat = 6.0
        static let iconSize: CGFloat = 12.0
        static let buttonSpacing: CGFloat = 8.0
    }
    
    // MARK: - UI Elements
    private let containerView = UIView()
    private let stackView = UIStackView()
    private let titleLabel = UILabel()
    private let actionButton = UIButton(type: .system)
    private let buttonStackView = UIStackView()
    private let buttonLabel = UILabel()
    private let chevronImageView = UIImageView()
    
    // MARK: - Properties
    private var viewModel: CasinoCategoryBarViewModelProtocol?
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Callbacks
    public var onButtonTapped: ((String) -> Void) = { _ in }
    
    // MARK: - Initialization
    public init(viewModel: CasinoCategoryBarViewModelProtocol? = nil) {
        self.viewModel = viewModel
        super.init(frame: .zero)
        setupSubviews()
        configure(with: viewModel)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Public Configuration
    public func configure(with viewModel: CasinoCategoryBarViewModelProtocol?) {
        // Clear existing bindings
        cancellables.removeAll()
        self.viewModel = viewModel
        
        if let viewModel = viewModel {
            setupBindings(with: viewModel)
        } else {
            renderPlaceholderState()
        }
    }
    
    // MARK: - Setup
    private func setupSubviews() {
        translatesAutoresizingMaskIntoConstraints = false
        backgroundColor = StyleProvider.Color.backgroundSecondary
        
        // Container setup
        containerView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(containerView)
        
        // Main stack view
        stackView.axis = .horizontal
        stackView.alignment = .center
        stackView.distribution = .equalSpacing
        stackView.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(stackView)
        
        setupTitleLabel()
        setupActionButton()
        setupConstraints()
    }
    
    private func setupTitleLabel() {
        titleLabel.font = StyleProvider.fontWith(type: .bold, size: 16)
        titleLabel.textColor = StyleProvider.Color.textPrimary
        titleLabel.numberOfLines = 1
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        stackView.addArrangedSubview(titleLabel)
    }
    
    private func setupActionButton() {
        // Action button container
        actionButton.backgroundColor = StyleProvider.Color.highlightPrimary
        actionButton.layer.cornerRadius = Constants.buttonCornerRadius
        actionButton.translatesAutoresizingMaskIntoConstraints = false
        
        // Button stack view for text + icon
        buttonStackView.axis = .horizontal
        buttonStackView.alignment = .center
        buttonStackView.spacing = Constants.buttonSpacing
        buttonStackView.translatesAutoresizingMaskIntoConstraints = false
        buttonStackView.isUserInteractionEnabled = false
        actionButton.addSubview(buttonStackView)
        
        // Button text
        buttonLabel.font = StyleProvider.fontWith(type: .semibold, size: 14)
        buttonLabel.textColor = StyleProvider.Color.buttonTextPrimary
        buttonLabel.numberOfLines = 1
        buttonLabel.translatesAutoresizingMaskIntoConstraints = false
        buttonStackView.addArrangedSubview(buttonLabel)
        
        // Chevron icon
        chevronImageView.contentMode = .scaleAspectFit
        chevronImageView.tintColor = StyleProvider.Color.buttonTextPrimary
        chevronImageView.image = UIImage(systemName: "chevron.right")
        chevronImageView.translatesAutoresizingMaskIntoConstraints = false
        buttonStackView.addArrangedSubview(chevronImageView)
        
        stackView.addArrangedSubview(actionButton)
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            // Container
            containerView.topAnchor.constraint(equalTo: topAnchor),
            containerView.leadingAnchor.constraint(equalTo: leadingAnchor),
            containerView.trailingAnchor.constraint(equalTo: trailingAnchor),
            containerView.bottomAnchor.constraint(equalTo: bottomAnchor),
            
            // Stack view
            stackView.topAnchor.constraint(equalTo: containerView.topAnchor, constant: Constants.verticalPadding),
            stackView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: Constants.horizontalPadding),
            stackView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -Constants.horizontalPadding),
            stackView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -Constants.verticalPadding),
            
            // Button constraints
            actionButton.heightAnchor.constraint(greaterThanOrEqualToConstant: 34),
            
            // Button stack view
            buttonStackView.topAnchor.constraint(equalTo: actionButton.topAnchor, constant: Constants.buttonVerticalPadding),
            buttonStackView.leadingAnchor.constraint(equalTo: actionButton.leadingAnchor, constant: Constants.buttonHorizontalPadding),
            buttonStackView.trailingAnchor.constraint(equalTo: actionButton.trailingAnchor, constant: -Constants.buttonHorizontalPadding),
            buttonStackView.bottomAnchor.constraint(equalTo: actionButton.bottomAnchor, constant: -Constants.buttonVerticalPadding),
            
            // Chevron size
            chevronImageView.widthAnchor.constraint(equalToConstant: Constants.iconSize),
            chevronImageView.heightAnchor.constraint(equalToConstant: Constants.iconSize)
        ])
        
        // Add button action
        actionButton.addTarget(self, action: #selector(buttonTapped), for: .touchUpInside)
    }
    
    // MARK: - Bindings
    private func setupBindings(with viewModel: CasinoCategoryBarViewModelProtocol) {
        // Title
        viewModel.titlePublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] title in
                self?.titleLabel.text = title
            }
            .store(in: &cancellables)
        
        // Button text
        viewModel.buttonTextPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] buttonText in
                self?.buttonLabel.text = buttonText
            }
            .store(in: &cancellables)
    }
    
    // MARK: - Rendering
    private func renderPlaceholderState() {
        titleLabel.text = "Category Title"
        buttonLabel.text = "All 0"
    }
    
    // MARK: - Actions
    @objc private func buttonTapped() {
        guard let viewModel = viewModel else { return }
        viewModel.buttonTapped()
        onButtonTapped(viewModel.categoryId)
    }
}

// MARK: - Preview Provider
#if DEBUG

@available(iOS 17.0, *)
#Preview("Casino Category Bar - Placeholder") {
    PreviewUIViewController {
        let vc = UIViewController()
        vc.view.backgroundColor = StyleProvider.Color.backgroundPrimary
        
        let categoryBarView = CasinoCategoryBarView() // No viewModel - placeholder state
        categoryBarView.translatesAutoresizingMaskIntoConstraints = false
        vc.view.addSubview(categoryBarView)
        
        NSLayoutConstraint.activate([
            categoryBarView.topAnchor.constraint(equalTo: vc.view.safeAreaLayoutGuide.topAnchor, constant: 20),
            categoryBarView.leadingAnchor.constraint(equalTo: vc.view.leadingAnchor),
            categoryBarView.trailingAnchor.constraint(equalTo: vc.view.trailingAnchor)
        ])
        
        return vc
    }
}

#endif
