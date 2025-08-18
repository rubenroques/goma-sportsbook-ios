//
//  BetslipTypeTabItemView.swift
//  GomaUI
//
//  Created by André Lascas on 14/08/2025.
//

import UIKit
import SwiftUI

public class BetslipTypeTabItemView: UIView {
    
    // MARK: - Private Properties
    private var viewModel: BetslipTypeTabItemViewModelProtocol
    
    // MARK: - UI Components
    private let iconImageView = UIImageView()
    private let titleLabel = UILabel()
    private let indicatorView = UIView()
    private let contentContainerView = UIView()
    
    // MARK: - Layout Constants
    private struct Constants {
        static let iconSize: CGFloat = 16.0
        static let iconLeadingPadding: CGFloat = 16.0
        static let iconTitleSpacing: CGFloat = 4.0
        static let titleTrailingPadding: CGFloat = 16.0
        static let verticalPadding: CGFloat = 14.0
        static let indicatorHeight: CGFloat = 3.0
    }
    
    // MARK: - Initialization
    public init(viewModel: BetslipTypeTabItemViewModelProtocol) {
        self.viewModel = viewModel
        super.init(frame: .zero)
        setupSubviews()
        setupConstraints()
        setupBindings()
        updateSelectionState(isSelected: viewModel.isSelected)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Setup Methods
    private func setupSubviews() {
        addSubview(contentContainerView)
        addSubview(indicatorView)
        
        contentContainerView.addSubview(iconImageView)
        contentContainerView.addSubview(titleLabel)
        
        // Content container view setup
        contentContainerView.translatesAutoresizingMaskIntoConstraints = false
        
        // Icon image view setup
        iconImageView.translatesAutoresizingMaskIntoConstraints = false
        iconImageView.contentMode = .scaleAspectFit
        iconImageView.tintColor = StyleProvider.Color.textSecondary
        
        // Title label setup
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.font = StyleProvider.fontWith(type: .semibold, size: 16)
        titleLabel.textColor = StyleProvider.Color.textSecondary
        titleLabel.textAlignment = .left
        
        // Indicator view setup
        indicatorView.translatesAutoresizingMaskIntoConstraints = false
        indicatorView.backgroundColor = StyleProvider.Color.highlightPrimary
        
        // Set content
        titleLabel.text = viewModel.title
        loadIcon()
        
        // Add tap gesture
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        addGestureRecognizer(tapGesture)
        isUserInteractionEnabled = true
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            // Content container view - center horizontally when possible
            contentContainerView.centerXAnchor.constraint(equalTo: centerXAnchor),
            contentContainerView.leadingAnchor.constraint(greaterThanOrEqualTo: leadingAnchor, constant: Constants.iconLeadingPadding),
            contentContainerView.trailingAnchor.constraint(lessThanOrEqualTo: trailingAnchor, constant: -Constants.iconLeadingPadding),
            contentContainerView.topAnchor.constraint(equalTo: topAnchor, constant: Constants.verticalPadding),
            contentContainerView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -Constants.verticalPadding),
            
            // Icon image view - positioned within container
            iconImageView.leadingAnchor.constraint(equalTo: contentContainerView.leadingAnchor),
            iconImageView.topAnchor.constraint(equalTo: contentContainerView.topAnchor),
            iconImageView.bottomAnchor.constraint(equalTo: contentContainerView.bottomAnchor),
            iconImageView.widthAnchor.constraint(equalToConstant: Constants.iconSize),
            iconImageView.heightAnchor.constraint(equalToConstant: Constants.iconSize),
            
            // Title label - positioned next to icon
            titleLabel.leadingAnchor.constraint(equalTo: iconImageView.trailingAnchor, constant: Constants.iconTitleSpacing),
            titleLabel.centerYAnchor.constraint(equalTo: iconImageView.centerYAnchor),
            titleLabel.trailingAnchor.constraint(equalTo: contentContainerView.trailingAnchor),
            
            // Indicator view
            indicatorView.leadingAnchor.constraint(equalTo: leadingAnchor),
            indicatorView.trailingAnchor.constraint(equalTo: trailingAnchor),
            indicatorView.bottomAnchor.constraint(equalTo: bottomAnchor),
            indicatorView.heightAnchor.constraint(equalToConstant: Constants.indicatorHeight)
        ])
        
        // Set content hugging and compression resistance for better centering
        contentContainerView.setContentHuggingPriority(.required, for: .horizontal)
        iconImageView.setContentHuggingPriority(.required, for: .horizontal)
        titleLabel.setContentHuggingPriority(.required, for: .horizontal)
        
        // Allow the content to center when there's extra space
        contentContainerView.setContentCompressionResistancePriority(.defaultHigh, for: .horizontal)
        iconImageView.setContentCompressionResistancePriority(.defaultHigh, for: .horizontal)
        titleLabel.setContentCompressionResistancePriority(.defaultHigh, for: .horizontal)
    }
    
    private func setupBindings() {
        // No reactive bindings needed for this simple component
    }
    
    // MARK: - Private Methods
    private func loadIcon() {
        // Try to load custom image first, then fall back to SF Symbol
        if let customImage = UIImage(named: viewModel.icon) {
            iconImageView.image = customImage.withRenderingMode(.alwaysTemplate)
        } else {
            iconImageView.image = UIImage(systemName: viewModel.icon)
        }
    }
    
    @objc private func handleTap() {
        viewModel.onTabTapped?()
    }
    
    // MARK: - Public Methods
    public func updateSelectionState(isSelected: Bool) {
        let highlightColor = StyleProvider.Color.highlightPrimary
        let unselectedColor = StyleProvider.Color.textPrimary
        let indicatorColor = StyleProvider.Color.separatorLineSecondary
        
        UIView.animate(withDuration: 0.3) {
            self.iconImageView.tintColor = isSelected ? highlightColor : unselectedColor
            self.titleLabel.textColor = isSelected ? highlightColor : unselectedColor
            self.indicatorView.backgroundColor = isSelected ? highlightColor : indicatorColor
        }
    }
    
    public func updateViewModel(_ newViewModel: BetslipTypeTabItemViewModelProtocol) {
        self.viewModel = newViewModel
        titleLabel.text = newViewModel.title
        loadIcon()
        updateSelectionState(isSelected: newViewModel.isSelected)
    }
}

// MARK: - SwiftUI Preview
#if DEBUG

@available(iOS 17.0, *)
#Preview("Sports Selected") {
    PreviewUIView {
        BetslipTypeTabItemView(viewModel: MockBetslipTypeTabItemViewModel.sportsSelectedMock())
    }
    .frame(height: 50)
    .padding()
}

@available(iOS 17.0, *)
#Preview("Sports Unselected") {
    PreviewUIView {
        BetslipTypeTabItemView(viewModel: MockBetslipTypeTabItemViewModel.sportsUnselectedMock())
    }
    .frame(height: 50)
    .padding()
}

@available(iOS 17.0, *)
#Preview("Virtuals Selected") {
    PreviewUIView {
        BetslipTypeTabItemView(viewModel: MockBetslipTypeTabItemViewModel.virtualsSelectedMock())
    }
    .frame(height: 50)
    .padding()
}

@available(iOS 17.0, *)
#Preview("Virtuals Unselected") {
    PreviewUIView {
        BetslipTypeTabItemView(viewModel: MockBetslipTypeTabItemViewModel.virtualsUnselectedMock())
    }
    .frame(height: 50)
    .padding()
}

#endif 
