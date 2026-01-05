//
//  CustomExpandableSectionView.swift
//  GomaUI
//
//  Created by André on 17/11/2025.
//

import Combine
import UIKit

public final class CustomExpandableSectionView: UIView {
    
    // MARK: - UI
    private lazy var containerView: UIView = Self.createContainerView()
    private lazy var headerContainerView: UIView = Self.createHeaderContainerView()
    private lazy var leadingIconImageView: UIImageView = Self.createLeadingIconImageView()
    private lazy var titleLabel: UILabel = Self.createTitleLabel()
    private lazy var toggleButton: UIButton = Self.createToggleButton()
    private lazy var contentStackView: UIStackView = Self.createContentStackView()
    private lazy var headerTapGesture: UITapGestureRecognizer = Self.createHeaderTapGesture()
    
    // MARK: - Properties
    private let viewModel: CustomExpandableSectionViewModelProtocol
    private var cancellables = Set<AnyCancellable>()
    private var expandedConstraints: [NSLayoutConstraint] = []
    private var collapsedConstraints: [NSLayoutConstraint] = []
    
    // MARK: - Init
    public init(viewModel: CustomExpandableSectionViewModelProtocol) {
        self.viewModel = viewModel
        super.init(frame: .zero)
        commonInit()
        bindViewModel()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle
    public override func layoutSubviews() {
        super.layoutSubviews()
        containerView.layer.cornerRadius = 8
    }
    
    // MARK: - Public
    public var contentContainer: UIStackView {
        contentStackView
    }
    
    // MARK: - Setup
    private func commonInit() {
        backgroundColor = .clear
        setupSubviews()
        setupTheme()
        configure()
    }
    
    private func setupTheme() {
        containerView.backgroundColor = StyleProvider.Color.backgroundTertiary
        titleLabel.textColor = StyleProvider.Color.textPrimary
        leadingIconImageView.tintColor = StyleProvider.Color.highlightPrimary
        toggleButton.tintColor = StyleProvider.Color.highlightPrimary
    }
    
    private func configure() {
        titleLabel.text = viewModel.title
        updateLeadingIcon()
    }
    
    private func bindViewModel() {
        viewModel.isExpandedPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isExpanded in
                self?.updateExpandedState(isExpanded)
            }
            .store(in: &cancellables)
    }
    
    private func updateExpandedState(_ isExpanded: Bool) {
        updateToggleIcon(isExpanded: isExpanded)
        
        if isExpanded {
            contentStackView.isHidden = false
            contentStackView.alpha = 0
        }
        
        if isExpanded {
            NSLayoutConstraint.deactivate(collapsedConstraints)
            NSLayoutConstraint.activate(expandedConstraints)
        } else {
            NSLayoutConstraint.deactivate(expandedConstraints)
            NSLayoutConstraint.activate(collapsedConstraints)
        }
        
        contentStackView.alpha = isExpanded ? 1 : 0
        if !isExpanded {
            contentStackView.isHidden = true
        }
    }
    
    private func updateLeadingIcon() {
        guard let iconName = viewModel.leadingIconName,
              let image = Self.iconImage(named: iconName) else {
            leadingIconImageView.isHidden = true
            return
        }
        leadingIconImageView.isHidden = false
        leadingIconImageView.image = image.withRenderingMode(.alwaysTemplate)
    }
    
    private func updateToggleIcon(isExpanded: Bool) {
        let iconName = isExpanded ? viewModel.expandedIconName : viewModel.collapsedIconName
        if let name = iconName,
           let image = Self.iconImage(named: name) {
            toggleButton.setImage(image.withRenderingMode(.alwaysTemplate), for: .normal)
            return
        }
        
        let fallbackName = isExpanded ? "chevron.up" : "chevron.down"
        let fallbackImage = UIImage(
            systemName: fallbackName,
            withConfiguration: UIImage.SymbolConfiguration(pointSize: 16, weight: .semibold)
        )
        toggleButton.setImage(fallbackImage, for: .normal)
    }
    
    @objc
    private func handleToggle() {
        viewModel.toggleExpanded()
    }
    
    @objc
    private func handleHeaderTap() {
        viewModel.toggleExpanded()
    }
}

// MARK: - Factory
private extension CustomExpandableSectionView {
    
    static func createContainerView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.masksToBounds = true
        return view
    }
    
    static func createHeaderContainerView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.isUserInteractionEnabled = true
        return view
    }
    
    static func createLeadingIconImageView() -> UIImageView {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.tintColor = StyleProvider.Color.highlightPrimary
        return imageView
    }
    
    static func createTitleLabel() -> UILabel {
        let label = UILabel()
        label.font = StyleProvider.fontWith(type: .bold, size: 12)
        label.numberOfLines = 1
        return label
    }
    
    static func createToggleButton() -> UIButton {
        let button = UIButton(type: .system)
        button.tintColor = StyleProvider.Color.highlightPrimary
        button.contentEdgeInsets = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)
        return button
    }
    
    static func createContentStackView() -> UIStackView {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 12
        stack.alignment = .fill
        stack.distribution = .fill
        stack.isHidden = true
        stack.alpha = 0
        return stack
    }
    
    static func createHeaderTapGesture() -> UITapGestureRecognizer {
        UITapGestureRecognizer()
    }
    
    static func iconImage(named name: String) -> UIImage? {
        if let assetImage = UIImage(named: name) {
            return assetImage
        }
        return UIImage(systemName: name)
    }
    
    private func setupSubviews() {
        addSubview(containerView)
        containerView.addSubview(headerContainerView)
        headerContainerView.addSubview(leadingIconImageView)
        headerContainerView.addSubview(titleLabel)
        headerContainerView.addSubview(toggleButton)
        containerView.addSubview(contentStackView)
        
        toggleButton.addTarget(self, action: #selector(handleToggle), for: .touchUpInside)
        headerTapGesture.addTarget(self, action: #selector(handleHeaderTap))
        headerContainerView.addGestureRecognizer(headerTapGesture)
        
        initConstraints()
    }
    
    private func initConstraints() {
        containerView.translatesAutoresizingMaskIntoConstraints = false
        headerContainerView.translatesAutoresizingMaskIntoConstraints = false
        leadingIconImageView.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        toggleButton.translatesAutoresizingMaskIntoConstraints = false
        contentStackView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            containerView.leadingAnchor.constraint(equalTo: leadingAnchor),
            containerView.trailingAnchor.constraint(equalTo: trailingAnchor),
            containerView.topAnchor.constraint(equalTo: topAnchor),
            containerView.bottomAnchor.constraint(equalTo: bottomAnchor),
            
            headerContainerView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            headerContainerView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            headerContainerView.topAnchor.constraint(equalTo: containerView.topAnchor),
            headerContainerView.heightAnchor.constraint(equalToConstant: 40),
            
            leadingIconImageView.leadingAnchor.constraint(equalTo: headerContainerView.leadingAnchor, constant: 8),
            leadingIconImageView.centerYAnchor.constraint(equalTo: headerContainerView.centerYAnchor),
            leadingIconImageView.widthAnchor.constraint(equalToConstant: 24),
            leadingIconImageView.heightAnchor.constraint(equalToConstant: 24),
            
            titleLabel.leadingAnchor.constraint(equalTo: leadingIconImageView.trailingAnchor, constant: 12),
            titleLabel.centerYAnchor.constraint(equalTo: headerContainerView.centerYAnchor),
            titleLabel.trailingAnchor.constraint(lessThanOrEqualTo: toggleButton.leadingAnchor, constant: -12),
            
            toggleButton.trailingAnchor.constraint(equalTo: headerContainerView.trailingAnchor, constant: 0),
            toggleButton.centerYAnchor.constraint(equalTo: headerContainerView.centerYAnchor),
            toggleButton.widthAnchor.constraint(equalToConstant: 40),
            toggleButton.heightAnchor.constraint(equalToConstant: 40),
            
            contentStackView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 8),
            contentStackView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -8),
            contentStackView.topAnchor.constraint(equalTo: headerContainerView.bottomAnchor, constant: 0)
        ])
        
        expandedConstraints = [
            contentStackView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -8)
        ]
        
        collapsedConstraints = [
            containerView.bottomAnchor.constraint(equalTo: headerContainerView.bottomAnchor)
        ]
        
        NSLayoutConstraint.activate(collapsedConstraints)
    }
}

// MARK: - Preview
#if DEBUG
import SwiftUI

@available(iOS 17.0, *)
#Preview("Collapsed") {
    PreviewUIViewController {
        let controller = UIViewController()
        controller.view.backgroundColor = StyleProvider.Color.backgroundSecondary
        let viewModel = MockCustomExpandableSectionViewModel.defaultCollapsed
        let sectionView = CustomExpandableSectionView(viewModel: viewModel)
        let label = UILabel()
        label.text = "Collapsed content placeholder"
        label.font = StyleProvider.fontWith(type: .regular, size: 13)
        label.numberOfLines = 0
        sectionView.contentContainer.addArrangedSubview(label)
        sectionView.translatesAutoresizingMaskIntoConstraints = false
        controller.view.addSubview(sectionView)
        NSLayoutConstraint.activate([
            sectionView.leadingAnchor.constraint(equalTo: controller.view.leadingAnchor, constant: 16),
            sectionView.trailingAnchor.constraint(equalTo: controller.view.trailingAnchor, constant: -16),
            sectionView.topAnchor.constraint(equalTo: controller.view.safeAreaLayoutGuide.topAnchor, constant: 32)
        ])
        return controller
    }
}

@available(iOS 17.0, *)
#Preview("Expanded") {
    PreviewUIViewController {
        let controller = UIViewController()
        controller.view.backgroundColor = StyleProvider.Color.backgroundSecondary
        let viewModel = MockCustomExpandableSectionViewModel.defaultExpanded
        let sectionView = CustomExpandableSectionView(viewModel: viewModel)
        sectionView.translatesAutoresizingMaskIntoConstraints = false
        let paragraph = UILabel()
        paragraph.text = "Expanded content with detailed description over multiple lines to demonstrate layout."
        paragraph.numberOfLines = 0
        paragraph.font = StyleProvider.fontWith(type: .regular, size: 13)
        paragraph.textColor = StyleProvider.Color.textSecondary
        sectionView.contentContainer.addArrangedSubview(paragraph)
        controller.view.addSubview(sectionView)
        NSLayoutConstraint.activate([
            sectionView.leadingAnchor.constraint(equalTo: controller.view.leadingAnchor, constant: 16),
            sectionView.trailingAnchor.constraint(equalTo: controller.view.trailingAnchor, constant: -16),
            sectionView.topAnchor.constraint(equalTo: controller.view.safeAreaLayoutGuide.topAnchor, constant: 32)
        ])
        return controller
    }
}
#endif

