import Foundation
import UIKit
import Combine
import SwiftUI

/// A code clipboard component with copy functionality and visual feedback
public final class CodeClipboardView: UIView {
    
    // MARK: - Properties
    private let viewModel: CodeClipboardViewModelProtocol
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - UI Components
    
    // Container view
    private lazy var containerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = StyleProvider.Color.backgroundSecondary
        view.layer.cornerRadius = 4
        return view
    }()
    
    // Left label
    private lazy var label: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = StyleProvider.fontWith(type: .medium, size: 16)
        label.textColor = StyleProvider.Color.textPrimary
        label.numberOfLines = 1
        return label
    }()
    
    // Right copy button container
    private lazy var copyButtonContainer: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = StyleProvider.Color.backgroundGradient2
        view.layer.cornerRadius = 12
        view.isUserInteractionEnabled = true
        return view
    }()
    
    // Code label inside copy button
    private lazy var codeLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = StyleProvider.fontWith(type: .bold, size: 18)
        label.textColor = StyleProvider.Color.highlightPrimary
        label.numberOfLines = 1
        label.textAlignment = .center
        return label
    }()
    
    // Copy icon
    private lazy var copyIconImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.image = UIImage(systemName: "doc.on.doc")
        imageView.tintColor = StyleProvider.Color.highlightPrimary
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    // Copied status label
    private lazy var copiedStatusLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = StyleProvider.fontWith(type: .bold, size: 12)
        label.textColor = StyleProvider.Color.highlightPrimary
        label.text = "Copied to Clipboard"
        label.numberOfLines = 1
        label.textAlignment = .center
        label.isHidden = true
        return label
    }()
    
    // Tap gesture recognizer
    private lazy var tapGesture: UITapGestureRecognizer = {
        let gesture = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        return gesture
    }()
    
    // MARK: - Initialization
    public init(viewModel: CodeClipboardViewModelProtocol) {
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
        containerView.addSubview(label)
        containerView.addSubview(copyButtonContainer)
        copyButtonContainer.addSubview(codeLabel)
        copyButtonContainer.addSubview(copyIconImageView)
        copyButtonContainer.addSubview(copiedStatusLabel)
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            // Container
            containerView.topAnchor.constraint(equalTo: topAnchor),
            containerView.leadingAnchor.constraint(equalTo: leadingAnchor),
            containerView.trailingAnchor.constraint(equalTo: trailingAnchor),
            containerView.bottomAnchor.constraint(equalTo: bottomAnchor),
            
            // Left label
            label.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
            label.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            label.trailingAnchor.constraint(lessThanOrEqualTo: copyButtonContainer.leadingAnchor, constant: -16),
            
            // Copy button container
            copyButtonContainer.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -16),
            copyButtonContainer.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 12),
            copyButtonContainer.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -12),
            
            // Code label (default state)
            codeLabel.leadingAnchor.constraint(equalTo: copyButtonContainer.leadingAnchor, constant: 12),
            codeLabel.topAnchor.constraint(equalTo: copyButtonContainer.topAnchor, constant: 8),
            codeLabel.bottomAnchor.constraint(equalTo: copyButtonContainer.bottomAnchor, constant: -8),
            codeLabel.trailingAnchor.constraint(equalTo: copyIconImageView.leadingAnchor, constant: -8),
            
            // Copy icon (default state)
            copyIconImageView.trailingAnchor.constraint(equalTo: copyButtonContainer.trailingAnchor, constant: -12),
            copyIconImageView.centerYAnchor.constraint(equalTo: copyButtonContainer.centerYAnchor),
            copyIconImageView.widthAnchor.constraint(equalToConstant: 24),
            copyIconImageView.heightAnchor.constraint(equalToConstant: 24),
            
            // Copied status label (copied state)
            copiedStatusLabel.leadingAnchor.constraint(equalTo: copyButtonContainer.leadingAnchor, constant: 12),
            copiedStatusLabel.trailingAnchor.constraint(equalTo: copyButtonContainer.trailingAnchor, constant: -12),
            copiedStatusLabel.centerYAnchor.constraint(equalTo: copyButtonContainer.centerYAnchor)
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
        copyButtonContainer.addGestureRecognizer(tapGesture)
    }
    
    // MARK: - Rendering
    private func render(data: CodeClipboardData) {
        // Update label
        label.text = data.labelText
        
        // Update code
        codeLabel.text = data.code
        
        // Handle different states
        switch data.state {
        case .default:
            renderDefaultState()
            
        case .copied:
            renderCopiedState()
        }
        
        // Update enabled state
        alpha = data.isEnabled ? 1.0 : 0.5
        isUserInteractionEnabled = data.isEnabled
        tapGesture.isEnabled = data.isEnabled
    }
    
    private func renderDefaultState() {
        codeLabel.isHidden = false
        copyIconImageView.isHidden = false
        copiedStatusLabel.isHidden = true
        
        // Animate transition
        UIView.animate(withDuration: 0.2) {
            self.codeLabel.alpha = 1.0
            self.copyIconImageView.alpha = 1.0
            self.copiedStatusLabel.alpha = 0.0
        }
    }
    
    private func renderCopiedState() {
        codeLabel.isHidden = true
        copyIconImageView.isHidden = true
        copiedStatusLabel.isHidden = false
        
        // Animate transition
        UIView.animate(withDuration: 0.2) {
            self.codeLabel.alpha = 0.0
            self.copyIconImageView.alpha = 0.0
            self.copiedStatusLabel.alpha = 1.0
        }
    }
    
    // MARK: - Actions
    @objc private func handleTap() {
        viewModel.onCopyTapped()
    }
}

// MARK: - SwiftUI Preview
#if DEBUG

@available(iOS 17.0, *)
#Preview("CodeClipboardView") {
    PreviewUIViewController {
        let vc = UIViewController()
        vc.view.backgroundColor = .backgroundTestColor

        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 16
        stackView.alignment = .fill
        stackView.translatesAutoresizingMaskIntoConstraints = false

        // Title label
        let titleLabel = UILabel()
        titleLabel.text = "CodeClipboardView"
        titleLabel.font = StyleProvider.fontWith(type: .bold, size: 18)
        titleLabel.textColor = StyleProvider.Color.textPrimary
        titleLabel.textAlignment = .center
        titleLabel.translatesAutoresizingMaskIntoConstraints = false

        // Default state
        let defaultView = CodeClipboardView(viewModel: MockCodeClipboardViewModel.defaultMock())
        defaultView.translatesAutoresizingMaskIntoConstraints = false

        // Copied state
        let copiedView = CodeClipboardView(viewModel: MockCodeClipboardViewModel.copiedMock())
        copiedView.translatesAutoresizingMaskIntoConstraints = false

        // Custom code
        let customCodeView = CodeClipboardView(viewModel: MockCodeClipboardViewModel.withCustomCodeMock())
        customCodeView.translatesAutoresizingMaskIntoConstraints = false

        // Disabled state
        let disabledView = CodeClipboardView(viewModel: MockCodeClipboardViewModel.disabledMock())
        disabledView.translatesAutoresizingMaskIntoConstraints = false

        stackView.addArrangedSubview(titleLabel)
        stackView.addArrangedSubview(defaultView)
        stackView.addArrangedSubview(copiedView)
        stackView.addArrangedSubview(customCodeView)
        stackView.addArrangedSubview(disabledView)

        vc.view.addSubview(stackView)

        NSLayoutConstraint.activate([
            stackView.centerYAnchor.constraint(equalTo: vc.view.centerYAnchor),
            stackView.leadingAnchor.constraint(equalTo: vc.view.leadingAnchor, constant: 16),
            stackView.trailingAnchor.constraint(equalTo: vc.view.trailingAnchor, constant: -16)
        ])

        return vc
    }
}

#endif 
