import Foundation
import UIKit
import Combine
import SwiftUI

/// A code input component with input field, button, and error handling
public final class CodeInputView: UIView {
    
    // MARK: - Properties
    private let viewModel: CodeInputViewModelProtocol
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - UI Components
    
    // Container view
    private lazy var containerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = StyleProvider.Color.backgroundSecondary
        return view
    }()
    
    // Main stack view for components
    private lazy var mainStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.spacing = 12
        stackView.alignment = .fill
        stackView.distribution = .fill
        return stackView
    }()
    
    // Input field
    private lazy var codeTextField: BorderedTextFieldView = {
        let textField = BorderedTextFieldView(viewModel: viewModel.codeTextFieldViewModel)
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()
    
    // Error view
    private lazy var errorView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = StyleProvider.Color.alertWarning
        view.layer.cornerRadius = 8
        view.isHidden = true
        return view
    }()
    
    private lazy var errorIconImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.image = UIImage(systemName: "exclamationmark.triangle.fill")
        imageView.tintColor = StyleProvider.Color.allWhite
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    private lazy var errorMessageLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = StyleProvider.fontWith(type: .bold, size: 14)
        label.textColor = StyleProvider.Color.allWhite
        label.numberOfLines = 0
        label.textAlignment = .left
        return label
    }()
    
    // Button
    private lazy var submitButton: ButtonView = {
        let button = ButtonView(viewModel: viewModel.submitButtonViewModel)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    // Loading indicator
    private lazy var loadingIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .medium)
        indicator.translatesAutoresizingMaskIntoConstraints = false
        indicator.color = .white
        indicator.hidesWhenStopped = true
        return indicator
    }()
    
    // MARK: - Initialization
    public init(viewModel: CodeInputViewModelProtocol) {
        self.viewModel = viewModel
        super.init(frame: .zero)
        setupSubviews()
        setupConstraints()
        setupBindings()
        setupActions()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Setup
    private func setupSubviews() {
        addSubview(containerView)
        containerView.addSubview(mainStackView)
        mainStackView.addArrangedSubview(codeTextField)
        mainStackView.addArrangedSubview(errorView)
        errorView.addSubview(errorIconImageView)
        errorView.addSubview(errorMessageLabel)
        mainStackView.addArrangedSubview(submitButton)
        submitButton.addSubview(loadingIndicator)
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            // Container
            containerView.topAnchor.constraint(equalTo: topAnchor),
            containerView.leadingAnchor.constraint(equalTo: leadingAnchor),
            containerView.trailingAnchor.constraint(equalTo: trailingAnchor),
            containerView.bottomAnchor.constraint(equalTo: bottomAnchor),
            
            // Main stack view
            mainStackView.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 16),
            mainStackView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
            mainStackView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -16),
            mainStackView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -16),
            
            // Code text field
            codeTextField.heightAnchor.constraint(equalToConstant: 52),
            
            // Error icon
            errorIconImageView.leadingAnchor.constraint(equalTo: errorView.leadingAnchor, constant: 16),
            errorIconImageView.centerYAnchor.constraint(equalTo: errorView.centerYAnchor),
            errorIconImageView.widthAnchor.constraint(equalToConstant: 24),
            errorIconImageView.heightAnchor.constraint(equalToConstant: 24),
            
            // Error message
            errorMessageLabel.leadingAnchor.constraint(equalTo: errorIconImageView.trailingAnchor, constant: 8),
            errorMessageLabel.trailingAnchor.constraint(equalTo: errorView.trailingAnchor, constant: -12),
            errorMessageLabel.topAnchor.constraint(equalTo: errorView.topAnchor, constant: 12),
            errorMessageLabel.bottomAnchor.constraint(equalTo: errorView.bottomAnchor, constant: -12),
            
            // Submit button
            submitButton.heightAnchor.constraint(equalToConstant: 50),
            
            // Loading indicator
            loadingIndicator.centerXAnchor.constraint(equalTo: submitButton.centerXAnchor),
            loadingIndicator.centerYAnchor.constraint(equalTo: submitButton.centerYAnchor)
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
    
    private func setupActions() {
        // Text field changes
        codeTextField.onTextChanged = { [weak self] text in
            self?.viewModel.updateCode(text)
        }
        
        // Button tap
        submitButton.onButtonTapped = { [weak self] in
            self?.viewModel.onButtonTapped()
        }
    }
    
    // MARK: - Rendering
    private func render(data: CodeInputData) {
        // Update text field
        viewModel.codeTextFieldViewModel.updateText(data.code)
        
        // Update button
        submitButton.viewModel.updateTitle(data.buttonTitle)
        
        // Handle different states
        switch data.state {
        case .default:
            renderDefaultState()
            
        case .loading:
            renderLoadingState()
            
        case .error(let message):
            renderErrorState(message: message)
        }
    }
    
    private func renderDefaultState() {
        errorView.isHidden = true
        loadingIndicator.stopAnimating()
        submitButton.isHidden = false
    }
    
    private func renderLoadingState() {
        errorView.isHidden = true
        loadingIndicator.startAnimating()
        submitButton.isHidden = false
        submitButton.viewModel.updateTitle("")
    }
    
    private func renderErrorState(message: String) {
        errorView.isHidden = false
        errorMessageLabel.text = message
        loadingIndicator.stopAnimating()
        submitButton.isHidden = false
    }
}

// MARK: - SwiftUI Preview
#if DEBUG

@available(iOS 17.0, *)
#Preview("CodeInputView") {
    PreviewUIViewController {
        let vc = UIViewController()
        vc.view.backgroundColor = StyleProvider.Color.backgroundPrimary

        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false

        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 16
        stackView.alignment = .fill
        stackView.translatesAutoresizingMaskIntoConstraints = false

        // Title label
        let titleLabel = UILabel()
        titleLabel.text = "CodeInputView"
        titleLabel.font = StyleProvider.fontWith(type: .bold, size: 18)
        titleLabel.textColor = StyleProvider.Color.textPrimary
        titleLabel.textAlignment = .center
        titleLabel.translatesAutoresizingMaskIntoConstraints = false

        // Default state
        let defaultView = CodeInputView(viewModel: MockCodeInputViewModel.defaultMock())
        defaultView.translatesAutoresizingMaskIntoConstraints = false

        // Loading state
        let loadingView = CodeInputView(viewModel: MockCodeInputViewModel.loadingMock())
        loadingView.translatesAutoresizingMaskIntoConstraints = false

        // Error state
        let errorView = CodeInputView(viewModel: MockCodeInputViewModel.errorMock())
        errorView.translatesAutoresizingMaskIntoConstraints = false

        // With code state
        let withCodeView = CodeInputView(viewModel: MockCodeInputViewModel.withCodeMock())
        withCodeView.translatesAutoresizingMaskIntoConstraints = false

        stackView.addArrangedSubview(titleLabel)
        stackView.addArrangedSubview(defaultView)
        stackView.addArrangedSubview(loadingView)
        stackView.addArrangedSubview(errorView)
        stackView.addArrangedSubview(withCodeView)

        scrollView.addSubview(stackView)
        vc.view.addSubview(scrollView)

        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: vc.view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: vc.view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: vc.view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: vc.view.bottomAnchor),

            stackView.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: 16),
            stackView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: 16),
            stackView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor, constant: -16),
            stackView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor, constant: -16),
            stackView.widthAnchor.constraint(equalTo: scrollView.widthAnchor, constant: -32)
        ])

        return vc
    }
}

#endif 
