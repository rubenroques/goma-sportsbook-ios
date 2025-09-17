//
//  SearchHeaderInfoView.swift
//  GomaUI
//
//  Created by Assistant on 2024-12-19.
//

import UIKit

public class SearchHeaderInfoView: UIView {
    
    // MARK: Private properties
    private lazy var containerView: UIView = Self.createContainerView()
    private lazy var stackView: UIStackView = Self.createStackView()
    private lazy var iconImageView: UIImageView = Self.createIconImageView()
    private lazy var messageLabel: UILabel = Self.createMessageLabel()
    
    // MARK: ViewModel
    private let viewModel: SearchHeaderInfoViewModelProtocol
    
    // MARK: - Lifetime and Cycle
    public init(viewModel: SearchHeaderInfoViewModelProtocol) {
        self.viewModel = viewModel
        super.init(frame: .zero)
        self.commonInit()
        self.setupWithTheme()
    }
    
    override init(frame: CGRect) {
        fatalError("init(frame:) has not been implemented. Use init(viewModel:) instead.")
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented. Use init(viewModel:) instead.")
    }
    
    func commonInit() {
        self.setupSubviews()
        self.configure()
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
    }
    
    func setupWithTheme() {
        self.messageLabel.textColor = StyleProvider.Color.textPrimary
        self.iconImageView.tintColor = StyleProvider.Color.highlightPrimary
    }
    
    private func updateBackgroundColor(for state: SearchState) {
        switch state {
        case .noResults:
            self.containerView.backgroundColor = StyleProvider.Color.backgroundSecondary
        case .loading, .results:
            self.containerView.backgroundColor = StyleProvider.Color.backgroundTertiary
        }
    }
    
    // MARK: Functions
    public func configure() {
        // Don't configure if search term is empty
        guard !viewModel.searchTerm.isEmpty else {
            self.isHidden = true
            return
        }
        
        // Show the view and configure based on view model state
        self.isHidden = false
        self.updateVisibility(for: viewModel.state)
        self.updateBackgroundColor(for: viewModel.state)
        
        switch viewModel.state {
        case .loading:
            self.messageLabel.attributedText = self.createAttributedText(
                prefix: "Searching for \"",
                searchTerm: viewModel.searchTerm,
                suffix: "\" in \(viewModel.category)..."
            )
            self.iconImageView.isHidden = true
            self.startLoadingAnimation()
            
        case .results:
            if let count = viewModel.count {
                self.messageLabel.attributedText = self.createAttributedTextWithCount(
                    prefix: "Showing Results for \"",
                    searchTerm: viewModel.searchTerm,
                    middle: "\" in \(viewModel.category) ",
                    count: "(\(count))"
                )
            } else {
                self.messageLabel.attributedText = self.createAttributedText(
                    prefix: "Showing Results for \"",
                    searchTerm: viewModel.searchTerm,
                    suffix: "\" in \(viewModel.category)"
                )
            }
            self.iconImageView.isHidden = true
            self.stopLoadingAnimation()
            
        case .noResults:
            self.messageLabel.attributedText = self.createAttributedText(
                prefix: "No Results for \"",
                searchTerm: viewModel.searchTerm,
                suffix: "\" in \(viewModel.category)"
            )
            self.iconImageView.isHidden = false
            self.stopLoadingAnimation()
        }
    }
    
    public func refreshConfiguration() {
        configure()
    }
    
    private func createAttributedText(prefix: String, searchTerm: String, suffix: String) -> NSAttributedString {
        let regularFont = StyleProvider.fontWith(type: .regular, size: 16)
        let boldFont = StyleProvider.fontWith(type: .semibold, size: 16)
        let textColor = StyleProvider.Color.textPrimary
        
        let attributedString = NSMutableAttributedString()
        
        // Add prefix with regular font
        attributedString.append(NSAttributedString(
            string: prefix,
            attributes: [
                .font: regularFont,
                .foregroundColor: textColor
            ]
        ))
        
        // Add search term with bold font
        attributedString.append(NSAttributedString(
            string: searchTerm,
            attributes: [
                .font: boldFont,
                .foregroundColor: textColor
            ]
        ))
        
        // Add suffix with regular font
        attributedString.append(NSAttributedString(
            string: suffix,
            attributes: [
                .font: regularFont,
                .foregroundColor: textColor
            ]
        ))
        
        return attributedString
    }
    
    private func createAttributedTextWithCount(prefix: String, searchTerm: String, middle: String, count: String) -> NSAttributedString {
        let regularFont = StyleProvider.fontWith(type: .regular, size: 16)
        let boldFont = StyleProvider.fontWith(type: .semibold, size: 16)
        let textColor = StyleProvider.Color.textPrimary
        
        let attributedString = NSMutableAttributedString()
        
        // Add prefix with regular font
        attributedString.append(NSAttributedString(
            string: prefix,
            attributes: [
                .font: regularFont,
                .foregroundColor: textColor
            ]
        ))
        
        // Add search term with bold font
        attributedString.append(NSAttributedString(
            string: searchTerm,
            attributes: [
                .font: boldFont,
                .foregroundColor: textColor
            ]
        ))
        
        // Add middle part with regular font
        attributedString.append(NSAttributedString(
            string: middle,
            attributes: [
                .font: regularFont,
                .foregroundColor: textColor
            ]
        ))
        
        // Add count (including parentheses) with bold font
        attributedString.append(NSAttributedString(
            string: count,
            attributes: [
                .font: boldFont,
                .foregroundColor: textColor
            ]
        ))
        
        return attributedString
    }
    
    private func updateVisibility(for state: SearchState) {
        self.isHidden = false
    }
    
    private func startLoadingAnimation() {
        // Simple ellipsis animation using attributed text updates
        self.animateEllipsis()
    }
    
    private func stopLoadingAnimation() {
        self.layer.removeAllAnimations()
    }
    
    private func animateEllipsis() {
        guard let currentText = self.messageLabel.attributedText else { return }
        
        let ellipsisValues = ["", ".", "..", "..."]
        var animationStep = 0
        
        Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { [weak self] timer in
            guard let self = self else {
                timer.invalidate()
                return
            }
            
            let ellipsis = ellipsisValues[animationStep % ellipsisValues.count]
            let mutableText = NSMutableAttributedString(attributedString: currentText)
            
            // Replace the last part (which should be "...") with current ellipsis
            let range = NSRange(location: mutableText.length - 3, length: 3)
            if range.location >= 0 && range.location + range.length <= mutableText.length {
                mutableText.replaceCharacters(in: range, with: ellipsis)
            }
            
            self.messageLabel.attributedText = mutableText
            animationStep += 1
        }
    }
}

// MARK: - Subviews Initialization and Setup
extension SearchHeaderInfoView {
    
    private static func createContainerView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }
    
    private static func createStackView() -> UIStackView {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .horizontal
        stackView.spacing = 8
        stackView.alignment = .center
        stackView.distribution = .fill
        return stackView
    }
    
    private static func createIconImageView() -> UIImageView {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        imageView.image = UIImage(systemName: "exclamationmark.triangle.fill")
        imageView.isHidden = true
        return imageView
    }
    
    private static func createMessageLabel() -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = StyleProvider.fontWith(type: .regular, size: 16)
        label.numberOfLines = 1
        label.textAlignment = .left
        return label
    }
    
    private func setupSubviews() {
        self.addSubview(self.containerView)
        self.containerView.addSubview(self.stackView)
        
        self.stackView.addArrangedSubview(self.iconImageView)
        self.stackView.addArrangedSubview(self.messageLabel)
        
        self.initConstraints()
    }
    
    private func initConstraints() {
        NSLayoutConstraint.activate([
            // Container
            self.containerView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            self.containerView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            self.containerView.topAnchor.constraint(equalTo: self.topAnchor),
            self.containerView.bottomAnchor.constraint(equalTo: self.bottomAnchor),
            
            // StackView
            self.stackView.leadingAnchor.constraint(equalTo: self.containerView.leadingAnchor, constant: 16),
            self.stackView.trailingAnchor.constraint(equalTo: self.containerView.trailingAnchor, constant: -16),
            self.stackView.topAnchor.constraint(equalTo: self.containerView.topAnchor, constant: 12),
            self.stackView.bottomAnchor.constraint(equalTo: self.containerView.bottomAnchor, constant: -12),
            
            // Icon
            self.iconImageView.widthAnchor.constraint(equalToConstant: 20),
            self.iconImageView.heightAnchor.constraint(equalTo: self.iconImageView.widthAnchor)
        ])
    }
}

#if DEBUG
import SwiftUI

@available(iOS 17.0, *)
#Preview("SearchHeaderInfoView States") {
    PreviewUIViewController {
        let vc = UIViewController()
        vc.view.backgroundColor = UIColor.systemBackground
        
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.spacing = 20
        stackView.alignment = .fill
        stackView.distribution = .fillEqually
        
        // Loading state
        let loadingViewModel = MockSearchHeaderInfoViewModel()
        loadingViewModel.updateSearch(term: "Liverpool", category: "Sports", state: .loading, count: nil)
        let loadingView = SearchHeaderInfoView(viewModel: loadingViewModel)
        loadingView.configure()
        
        // Results state
        let resultsViewModel = MockSearchHeaderInfoViewModel()
        resultsViewModel.updateSearch(term: "Liverpool", category: "Sports", state: .results, count: 3)
        let resultsView = SearchHeaderInfoView(viewModel: resultsViewModel)
        resultsView.configure()
        
        // No results state
        let noResultsViewModel = MockSearchHeaderInfoViewModel()
        noResultsViewModel.updateSearch(term: "Liverpool", category: "Sports", state: .noResults, count: nil)
        let noResultsView = SearchHeaderInfoView(viewModel: noResultsViewModel)
        noResultsView.configure()
        
        stackView.addArrangedSubview(loadingView)
        stackView.addArrangedSubview(resultsView)
        stackView.addArrangedSubview(noResultsView)
        
        vc.view.addSubview(stackView)
        
        NSLayoutConstraint.activate([
            stackView.leadingAnchor.constraint(equalTo: vc.view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            stackView.trailingAnchor.constraint(equalTo: vc.view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
            stackView.topAnchor.constraint(equalTo: vc.view.safeAreaLayoutGuide.topAnchor, constant: 20),
            stackView.heightAnchor.constraint(equalToConstant: 180)
        ])
        
        return vc
    }
}
#endif
