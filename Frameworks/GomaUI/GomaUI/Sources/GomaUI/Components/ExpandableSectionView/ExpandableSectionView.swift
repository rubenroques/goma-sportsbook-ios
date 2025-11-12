//
//  ExpandableSectionView.swift
//  GomaUI
//
//  An expandable section view with a header and collapsible content area
//

import UIKit
import Combine

/// A view that displays an expandable section with a title header and toggle button
public class ExpandableSectionView: UIView {
    
    // MARK: Private properties
    private lazy var containerView: UIView = Self.createContainerView()
    private lazy var headerContainerView: UIView = Self.createHeaderContainerView()
    private lazy var titleLabel: UILabel = Self.createTitleLabel()
    private lazy var toggleButton: UIButton = Self.createToggleButton()
    private lazy var toggleButtonBackground: UIView = Self.createToggleButtonBackground()
    private lazy var contentStackView: UIStackView = Self.createContentStackView()
    
    private let viewModel: ExpandableSectionViewModelProtocol
    private var cancellables = Set<AnyCancellable>()
    
    // Constraints for expanded/collapsed states
    private var expandedConstraints: [NSLayoutConstraint] = []
    private var collapsedConstraints: [NSLayoutConstraint] = []
    
    // MARK: - Lifetime and Cycle
    public init(viewModel: ExpandableSectionViewModelProtocol) {
        self.viewModel = viewModel
        super.init(frame: .zero)
        self.commonInit()
        self.setupWithTheme()
        self.setupBindings()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func commonInit() {
        self.setupSubviews()
        self.configure()
    }
    
    override public func layoutSubviews() {
        super.layoutSubviews()
        self.containerView.layer.cornerRadius = 8
        self.toggleButtonBackground.layer.cornerRadius = self.toggleButtonBackground.bounds.height / 2
    }
    
    func setupWithTheme() {
        self.backgroundColor = .clear
        self.containerView.backgroundColor = StyleProvider.Color.backgroundTertiary
        self.titleLabel.textColor = StyleProvider.Color.textPrimary
        self.toggleButtonBackground.backgroundColor = .clear
        self.toggleButton.tintColor = StyleProvider.Color.highlightPrimary
        
    }
    
    // MARK: Functions
    
    /// Access to the content stack view for adding custom views
    public var contentContainer: UIStackView {
        return contentStackView
    }
    
    private func configure() {
        self.titleLabel.text = viewModel.title
    }
    
    private func setupBindings() {
        var isFirstUpdate = true
        viewModel.isExpandedPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isExpanded in
                // Don't animate the first update (initial state)
                let shouldAnimate = !isFirstUpdate
                self?.updateExpandedState(isExpanded: isExpanded, animated: shouldAnimate)
                isFirstUpdate = false
            }
            .store(in: &cancellables)
    }
    
    private func updateExpandedState(isExpanded: Bool, animated: Bool) {
        // Try to load custom icon first, fall back to SF Symbols
        let buttonImage: UIImage?
        if isExpanded {
            // Expanded state - minus icon
            if let customImage = UIImage(named: "collapse_icon") {
                buttonImage = customImage.withRenderingMode(.alwaysTemplate)
            } else {
                buttonImage = UIImage(systemName: "minus")?.withConfiguration(
                    UIImage.SymbolConfiguration(pointSize: 16, weight: .semibold)
                )
            }
        } else {
            // Collapsed state - plus icon
            if let customImage = UIImage(named: "expand_icon") {
                buttonImage = customImage.withRenderingMode(.alwaysTemplate)
            } else {
                buttonImage = UIImage(systemName: "plus")?.withConfiguration(
                    UIImage.SymbolConfiguration(pointSize: 16, weight: .semibold)
                )
            }
        }
        
        toggleButton.setImage(buttonImage, for: .normal)
        
        if isExpanded {
            // Show content before animating
            self.contentStackView.isHidden = false
            self.contentStackView.alpha = 0.0
        }
        
        // Switch constraints immediately
        if isExpanded {
            NSLayoutConstraint.deactivate(self.collapsedConstraints)
            NSLayoutConstraint.activate(self.expandedConstraints)
        } else {
            NSLayoutConstraint.deactivate(self.expandedConstraints)
            NSLayoutConstraint.activate(self.collapsedConstraints)
        }
        
        // Commented out animation for now
        // let animations = {
        //     // Fade content
        //     self.contentStackView.alpha = isExpanded ? 1.0 : 0.0
        //
        //     // Force layout update
        //     self.superview?.layoutIfNeeded()
        // }
        
        self.contentStackView.alpha = isExpanded ? 1.0 : 0.0
        self.superview?.layoutIfNeeded()
        
        // if animated {
        //     UIView.animate(
        //         withDuration: 0.4,
        //         delay: 0,
        //         usingSpringWithDamping: 0.9,
        //         initialSpringVelocity: 0.5,
        //         options: [.curveEaseInOut, .allowUserInteraction],
        //         animations: animations,
        //         completion: { _ in
        //             if !isExpanded {
        //                 self.contentStackView.isHidden = true
        //             }
        //         }
        //     )
        // } else {
        //     animations()
        //     if !isExpanded {
        //         self.contentStackView.isHidden = true
        //     }
        // }
        
        if !isExpanded {
            self.contentStackView.isHidden = true
        }
    }
    
    @objc private func toggleButtonTapped() {
        viewModel.toggleExpanded()
    }
}

// MARK: - Subviews Initialization and Setup
extension ExpandableSectionView {
    
    private static func createContainerView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }
    
    private static func createHeaderContainerView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }
    
    private static func createTitleLabel() -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = StyleProvider.fontWith(type: .semibold, size: 16)
        label.numberOfLines = 1
        return label
    }
    
    private static func createToggleButton() -> UIButton {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        
        let icon: UIImage?
        if let customImage = UIImage(named: "expand_icon") {
            icon = customImage.withRenderingMode(.alwaysTemplate)
        } else {
            icon = UIImage(systemName: "plus")?.withConfiguration(
                UIImage.SymbolConfiguration(pointSize: 16, weight: .semibold)
            )
        }
        
        button.setImage(icon, for: .normal)
        button.tintColor = StyleProvider.Color.highlightPrimary
        
        return button
    }
    
    private static func createToggleButtonBackground() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.isUserInteractionEnabled = false
        return view
    }
    
    private static func createContentStackView() -> UIStackView {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.spacing = 12
        stackView.alignment = .fill
        stackView.distribution = .fill
        stackView.isHidden = true
        stackView.alpha = 0
        return stackView
    }
    
    private func setupSubviews() {
        self.addSubview(self.containerView)
        
        self.containerView.addSubview(self.headerContainerView)
        self.headerContainerView.addSubview(self.titleLabel)
        self.headerContainerView.addSubview(self.toggleButtonBackground)
        self.headerContainerView.addSubview(self.toggleButton)
        
        self.containerView.addSubview(self.contentStackView)
        
        self.toggleButton.addTarget(self, action: #selector(toggleButtonTapped), for: .touchUpInside)
        
        self.initConstraints()
    }
    
    private func initConstraints() {
        // Always active constraints
        NSLayoutConstraint.activate([
            // Container
            self.containerView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            self.containerView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            self.containerView.topAnchor.constraint(equalTo: self.topAnchor),
            self.containerView.bottomAnchor.constraint(equalTo: self.bottomAnchor),
            
            // Header Container
            self.headerContainerView.leadingAnchor.constraint(equalTo: self.containerView.leadingAnchor),
            self.headerContainerView.trailingAnchor.constraint(equalTo: self.containerView.trailingAnchor),
            self.headerContainerView.topAnchor.constraint(equalTo: self.containerView.topAnchor),
            self.headerContainerView.heightAnchor.constraint(equalToConstant: 56),
            
            // Title Label
            self.titleLabel.leadingAnchor.constraint(equalTo: self.headerContainerView.leadingAnchor, constant: 16),
            self.titleLabel.centerYAnchor.constraint(equalTo: self.headerContainerView.centerYAnchor),
            self.titleLabel.trailingAnchor.constraint(lessThanOrEqualTo: self.toggleButtonBackground.leadingAnchor, constant: -12),
            
            // Toggle Button Background
            self.toggleButtonBackground.trailingAnchor.constraint(equalTo: self.headerContainerView.trailingAnchor, constant: -16),
            self.toggleButtonBackground.centerYAnchor.constraint(equalTo: self.headerContainerView.centerYAnchor),
            self.toggleButtonBackground.widthAnchor.constraint(equalToConstant: 32),
            self.toggleButtonBackground.heightAnchor.constraint(equalToConstant: 32),
            
            // Toggle Button
            self.toggleButton.centerXAnchor.constraint(equalTo: self.toggleButtonBackground.centerXAnchor),
            self.toggleButton.centerYAnchor.constraint(equalTo: self.toggleButtonBackground.centerYAnchor),
            self.toggleButton.widthAnchor.constraint(equalToConstant: 44),
            self.toggleButton.heightAnchor.constraint(equalToConstant: 44),
            
            // Content Stack View - positioning
            self.contentStackView.leadingAnchor.constraint(equalTo: self.containerView.leadingAnchor, constant: 16),
            self.contentStackView.trailingAnchor.constraint(equalTo: self.containerView.trailingAnchor, constant: -16),
            self.contentStackView.topAnchor.constraint(equalTo: self.headerContainerView.bottomAnchor, constant: 12)
        ])
        
        // Expanded state constraints
        self.expandedConstraints = [
            self.contentStackView.bottomAnchor.constraint(equalTo: self.containerView.bottomAnchor, constant: -16)
        ]
        
        // Collapsed state constraints
        self.collapsedConstraints = [
            self.containerView.bottomAnchor.constraint(equalTo: self.headerContainerView.bottomAnchor)
        ]
        
        // Start in collapsed state
        NSLayoutConstraint.activate(self.collapsedConstraints)
    }
}

// MARK: - SwiftUI Preview
#if DEBUG
import SwiftUI

@available(iOS 17.0, *)
#Preview("Collapsed State") {
    PreviewUIViewController {
        let vc = UIViewController()
        vc.view.backgroundColor = StyleProvider.Color.backgroundPrimary
        
        let viewModel = MockExpandableSectionViewModel.defaultMock
        let sectionView = ExpandableSectionView(viewModel: viewModel)
        sectionView.translatesAutoresizingMaskIntoConstraints = false
        
        // Add sample content
        let label = UILabel()
        label.text = "This is the content area that appears when expanded."
        label.numberOfLines = 0
        label.font = StyleProvider.fontWith(type: .regular, size: 14)
        label.textColor = StyleProvider.Color.textSecondary
        sectionView.contentContainer.addArrangedSubview(label)
        
        vc.view.addSubview(sectionView)
        
        NSLayoutConstraint.activate([
            sectionView.leadingAnchor.constraint(equalTo: vc.view.leadingAnchor, constant: 16),
            sectionView.trailingAnchor.constraint(equalTo: vc.view.trailingAnchor, constant: -16),
            sectionView.topAnchor.constraint(equalTo: vc.view.safeAreaLayoutGuide.topAnchor, constant: 20)
        ])
        
        return vc
    }
}

@available(iOS 17.0, *)
#Preview("Expanded State") {
    PreviewUIViewController {
        let vc = UIViewController()
        vc.view.backgroundColor = StyleProvider.Color.backgroundPrimary
        
        let viewModel = MockExpandableSectionViewModel.expandedMock
        let sectionView = ExpandableSectionView(viewModel: viewModel)
        sectionView.translatesAutoresizingMaskIntoConstraints = false
        
        // Add sample content with multiple elements
        let subtitleLabel = UILabel()
        subtitleLabel.text = "Sub title"
        subtitleLabel.font = StyleProvider.fontWith(type: .semibold, size: 14)
        subtitleLabel.textColor = StyleProvider.Color.textPrimary
        sectionView.contentContainer.addArrangedSubview(subtitleLabel)
        
        let heading1 = UILabel()
        heading1.text = "One bet too many?"
        heading1.font = StyleProvider.fontWith(type: .semibold, size: 14)
        heading1.textColor = StyleProvider.Color.textPrimary
        sectionView.contentContainer.addArrangedSubview(heading1)
        
        let paragraph1 = UILabel()
        paragraph1.text = "Responsible gaming at Betsson means never borrowing money or spending more than you can afford. We're committed to player safety and providing a safe gaming environment."
        paragraph1.numberOfLines = 0
        paragraph1.font = StyleProvider.fontWith(type: .regular, size: 13)
        paragraph1.textColor = StyleProvider.Color.textSecondary
        sectionView.contentContainer.addArrangedSubview(paragraph1)
        
        let heading2 = UILabel()
        heading2.text = "We help you set the limits!"
        heading2.font = StyleProvider.fontWith(type: .semibold, size: 14)
        heading2.textColor = StyleProvider.Color.textPrimary
        sectionView.contentContainer.addArrangedSubview(heading2)
        
        let paragraph2 = UILabel()
        paragraph2.text = "You have the opportunity to set your own gaming limits, budget, and boundaries. We partner with Global Gambling Guidance Group (G4) to help prevent unhealthy gaming behavior."
        paragraph2.numberOfLines = 0
        paragraph2.font = StyleProvider.fontWith(type: .regular, size: 13)
        paragraph2.textColor = StyleProvider.Color.textSecondary
        sectionView.contentContainer.addArrangedSubview(paragraph2)
        
        let paragraph3 = UILabel()
        paragraph3.text = "You can set limits via 'Responsible Gambling' area, 'My Account', or contact Customer Service at support-en@betsson.com or +356 2260 3000. Available 24 hours a day, 7 days a week."
        paragraph3.numberOfLines = 0
        paragraph3.font = StyleProvider.fontWith(type: .regular, size: 13)
        paragraph3.textColor = StyleProvider.Color.textSecondary
        sectionView.contentContainer.addArrangedSubview(paragraph3)
        
        vc.view.addSubview(sectionView)
        
        NSLayoutConstraint.activate([
            sectionView.leadingAnchor.constraint(equalTo: vc.view.leadingAnchor, constant: 16),
            sectionView.trailingAnchor.constraint(equalTo: vc.view.trailingAnchor, constant: -16),
            sectionView.topAnchor.constraint(equalTo: vc.view.safeAreaLayoutGuide.topAnchor, constant: 20)
        ])
        
        return vc
    }
}

@available(iOS 17.0, *)
#Preview("Multiple Sections") {
    PreviewUIViewController {
        let vc = UIViewController()
        vc.view.backgroundColor = StyleProvider.Color.backgroundPrimary
        
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.spacing = 12
        
        // Section 1
        let viewModel1 = MockExpandableSectionViewModel.customMock(title: "Information", isExpanded: false)
        let section1 = ExpandableSectionView(viewModel: viewModel1)
        let label1 = UILabel()
        label1.text = "Important information about your account and services."
        label1.numberOfLines = 0
        label1.font = StyleProvider.fontWith(type: .regular, size: 14)
        label1.textColor = StyleProvider.Color.textSecondary
        section1.contentContainer.addArrangedSubview(label1)
        stackView.addArrangedSubview(section1)
        
        // Section 2
        let viewModel2 = MockExpandableSectionViewModel.customMock(title: "Terms & Conditions", isExpanded: false)
        let section2 = ExpandableSectionView(viewModel: viewModel2)
        let label2 = UILabel()
        label2.text = "By using our services, you agree to these terms and conditions."
        label2.numberOfLines = 0
        label2.font = StyleProvider.fontWith(type: .regular, size: 14)
        label2.textColor = StyleProvider.Color.textSecondary
        section2.contentContainer.addArrangedSubview(label2)
        stackView.addArrangedSubview(section2)
        
        // Section 3
        let viewModel3 = MockExpandableSectionViewModel.customMock(title: "Help & Support", isExpanded: false)
        let section3 = ExpandableSectionView(viewModel: viewModel3)
        let label3 = UILabel()
        label3.text = "Contact our support team 24/7 for assistance."
        label3.numberOfLines = 0
        label3.font = StyleProvider.fontWith(type: .regular, size: 14)
        label3.textColor = StyleProvider.Color.textSecondary
        section3.contentContainer.addArrangedSubview(label3)
        stackView.addArrangedSubview(section3)
        
        vc.view.addSubview(stackView)
        
        NSLayoutConstraint.activate([
            stackView.leadingAnchor.constraint(equalTo: vc.view.leadingAnchor, constant: 16),
            stackView.trailingAnchor.constraint(equalTo: vc.view.trailingAnchor, constant: -16),
            stackView.topAnchor.constraint(equalTo: vc.view.safeAreaLayoutGuide.topAnchor, constant: 20)
        ])

        return vc
    }
}
#endif
