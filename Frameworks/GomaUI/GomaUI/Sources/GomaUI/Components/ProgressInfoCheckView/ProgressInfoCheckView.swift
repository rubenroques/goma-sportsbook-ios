import Foundation
import UIKit
import Combine
import SwiftUI

/// A view component that displays progress information with an icon, title, subtitle, and progress bar
public final class ProgressInfoCheckView: UIView {
    
    // MARK: - Properties
    private let viewModel: ProgressInfoCheckViewModelProtocol
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - UI Components
    
    // Container view
    private lazy var containerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = StyleProvider.Color.backgroundSecondary
        view.layer.cornerRadius = 8
        return view
    }()
    
    // Main stack view
    private lazy var mainStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.distribution = .fill
        stackView.alignment = .leading
        stackView.spacing = 16
        return stackView
    }()
    
    // Header label with highlight color
    private lazy var headerLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = StyleProvider.fontWith(type: .bold, size: 12)
        label.textColor = StyleProvider.Color.highlightPrimary
        label.textAlignment = .left
        label.numberOfLines = 0
        return label
    }()
    
    // Content stack view for icon, title, and subtitle
    private lazy var contentStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .horizontal
        stackView.distribution = .fill
        stackView.alignment = .top
        stackView.spacing = 12
        return stackView
    }()
    
    // Icon image view
    private lazy var iconImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        imageView.tintColor = StyleProvider.Color.highlightPrimary
        return imageView
    }()
    
    // Text stack view for title and subtitle
    private lazy var textStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.distribution = .fill
        stackView.alignment = .leading
        stackView.spacing = 4
        return stackView
    }()
    
    // Title label
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = StyleProvider.fontWith(type: .bold, size: 16)
        label.textColor = StyleProvider.Color.textPrimary
        label.textAlignment = .left
        label.numberOfLines = 0
        return label
    }()
    
    // Subtitle label
    private lazy var subtitleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = StyleProvider.fontWith(type: .regular, size: 12)
        label.textColor = StyleProvider.Color.textPrimary
        label.textAlignment = .left
        label.numberOfLines = 0
        return label
    }()
    
    // Progress bar container
    private lazy var progressBarContainer: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .clear
        return view
    }()
    
    // Progress segments stack view
    private lazy var progressSegmentsStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
        stackView.alignment = .center
        stackView.spacing = 4
        return stackView
    }()
    
    // Progress segments
    private var progressSegments: [UIView] = []
    
    // MARK: - Initialization
    public init(viewModel: ProgressInfoCheckViewModelProtocol) {
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
        addSubview(containerView)
        containerView.addSubview(mainStackView)
        
        // Add header label
        mainStackView.addArrangedSubview(headerLabel)
        
        // Add content stack view
        mainStackView.addArrangedSubview(contentStackView)
        
        // Add icon and text to content stack view
        contentStackView.addArrangedSubview(iconImageView)
        contentStackView.addArrangedSubview(textStackView)
        
        // Add title and subtitle to text stack view
        textStackView.addArrangedSubview(titleLabel)
        textStackView.addArrangedSubview(subtitleLabel)
        
        // Add progress bar
        mainStackView.addArrangedSubview(progressBarContainer)
        progressBarContainer.addSubview(progressSegmentsStackView)
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
            mainStackView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 12),
            mainStackView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -12),
            mainStackView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -16),
            
            // Icon image view
            iconImageView.widthAnchor.constraint(equalToConstant: 24),
            iconImageView.heightAnchor.constraint(equalToConstant: 24),
            
            // Progress bar container
            progressBarContainer.heightAnchor.constraint(equalToConstant: 8),
            progressBarContainer.leadingAnchor.constraint(equalTo: mainStackView.leadingAnchor),
            progressBarContainer.trailingAnchor.constraint(equalTo: mainStackView.trailingAnchor),
            
            // Progress segments stack view
            progressSegmentsStackView.topAnchor.constraint(equalTo: progressBarContainer.topAnchor),
            progressSegmentsStackView.leadingAnchor.constraint(equalTo: progressBarContainer.leadingAnchor),
            progressSegmentsStackView.trailingAnchor.constraint(equalTo: progressBarContainer.trailingAnchor),
            progressSegmentsStackView.bottomAnchor.constraint(equalTo: progressBarContainer.bottomAnchor),
            progressSegmentsStackView.heightAnchor.constraint(equalToConstant: 8)
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
    private func render(data: ProgressInfoCheckData) {
        // Update header text
        headerLabel.text = data.headerText
        
        // Update icon
        if let iconName = data.icon {
            if let customImage = UIImage(named: iconName) {
                iconImageView.image = customImage

            }
            else if let systemImage = UIImage(systemName: iconName) {
                iconImageView.image = systemImage

            }
        }
        
        // Update title
        titleLabel.text = data.title
        
        // Update subtitle
        subtitleLabel.text = data.subtitle
        
        // Update progress segments
        updateProgressSegments(for: data.state)
        
        // Update enabled state
        alpha = data.isEnabled ? 1.0 : 0.5
        isUserInteractionEnabled = data.isEnabled
    }
    
    private func updateProgressSegments(for state: ProgressInfoCheckState) {
        // Clear existing segments
        progressSegments.forEach { $0.removeFromSuperview() }
        progressSegments.removeAll()
        
        switch state {
        case .incomplete(let completedSegments, let totalSegments):
            // Create segments based on total
            for i in 0..<totalSegments {
                let segment = UIView()
                segment.translatesAutoresizingMaskIntoConstraints = false
                
                // Fill segments based on completion
                if i < completedSegments {
                    segment.backgroundColor = StyleProvider.Color.highlightSecondary
                } else {
                    segment.backgroundColor = StyleProvider.Color.backgroundPrimary
                }
                
                segment.layer.cornerRadius = 4
                
                progressSegments.append(segment)
                progressSegmentsStackView.addArrangedSubview(segment)
                
                // Add height constraint to ensure visibility
                NSLayoutConstraint.activate([
                    segment.heightAnchor.constraint(equalToConstant: 8)
                ])
            }
            
        case .complete:
            // All segments filled for complete state
            let totalSegments = 3 // Default for complete state
            for i in 0..<totalSegments {
                let segment = UIView()
                segment.translatesAutoresizingMaskIntoConstraints = false
                segment.backgroundColor = StyleProvider.Color.highlightSecondary
                segment.layer.cornerRadius = 4
                
                progressSegments.append(segment)
                progressSegmentsStackView.addArrangedSubview(segment)
                
                // Add height constraint to ensure visibility
                NSLayoutConstraint.activate([
                    segment.heightAnchor.constraint(equalToConstant: 8)
                ])
            }
        }
        
        // Force layout update
        progressSegmentsStackView.setNeedsLayout()
        progressSegmentsStackView.layoutIfNeeded()
    }
}

// MARK: - SwiftUI Preview
#if DEBUG

@available(iOS 17.0, *)
#Preview("ProgressInfoCheckView") {
    PreviewUIViewController {
        let vc = UIViewController()
        vc.view.backgroundColor = StyleProvider.Color.backgroundPrimary

        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 16
        stackView.alignment = .fill
        stackView.translatesAutoresizingMaskIntoConstraints = false

        // Title label
        let titleLabel = UILabel()
        titleLabel.text = "ProgressInfoCheckView"
        titleLabel.font = StyleProvider.fontWith(type: .bold, size: 18)
        titleLabel.textColor = StyleProvider.Color.textPrimary
        titleLabel.textAlignment = .center
        titleLabel.translatesAutoresizingMaskIntoConstraints = false

        // Win Boost Progress state
        let winBoostView = ProgressInfoCheckView(viewModel: MockProgressInfoCheckViewModel.winBoostMock())
        winBoostView.translatesAutoresizingMaskIntoConstraints = false

        // Complete state
        let completeView = ProgressInfoCheckView(viewModel: MockProgressInfoCheckViewModel.completeMock())
        completeView.translatesAutoresizingMaskIntoConstraints = false

        // Disabled state
        let disabledView = ProgressInfoCheckView(viewModel: MockProgressInfoCheckViewModel.disabledMock())
        disabledView.translatesAutoresizingMaskIntoConstraints = false

        stackView.addArrangedSubview(titleLabel)
        stackView.addArrangedSubview(winBoostView)
        stackView.addArrangedSubview(completeView)
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
