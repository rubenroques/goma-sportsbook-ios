//
//  LanguageSelectorView.swift
//  GomaUI
//
//  Created by Claude Code on 26/08/2025.
//

import UIKit
import Combine
import SwiftUI

/// Main container view for language selection with radio button behavior
public final class LanguageSelectorView: UIView {
    
    // MARK: Private properties
    private lazy var containerView: UIView = Self.createContainerView()
    private lazy var stackView: UIStackView = Self.createStackView()
    
    // MARK: - Properties
    private let viewModel: LanguageSelectorViewModelProtocol
    private var cancellables = Set<AnyCancellable>()
    private var languageItemViews: [(view: LanguageItemView, language: LanguageModel)] = []
    private var currentLanguages: [LanguageModel] = []
    
    // MARK: - Lifetime and Cycle
    public init(viewModel: LanguageSelectorViewModelProtocol) {
        self.viewModel = viewModel
        super.init(frame: .zero)
        commonInit()
        setupWithTheme()
        setupBindings()
    }
    
    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented - use init(viewModel:) instead")
    }
    
    func commonInit() {
        setupSubviews()
        
        // Load languages initially
        viewModel.loadLanguages()
    }
    
    override public func layoutSubviews() {
        super.layoutSubviews()
        containerView.layer.cornerRadius = 16
        
        // Update corner radius for first and last items
        updateItemCornerRadius()
    }
    
    func setupWithTheme() {
        backgroundColor = .clear
        containerView.backgroundColor = StyleProvider.Color.backgroundPrimary
    }
    
    // MARK: Functions
    private func setupBindings() {
        // Bind languages list updates
        viewModel.languagesPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] languages in
                self?.updateLanguages(languages)
            }
            .store(in: &cancellables)
        
        // Bind selection changes
        viewModel.selectedLanguagePublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] selectedLanguage in
                self?.updateSelection(selectedLanguage)
            }
            .store(in: &cancellables)
    }
    
    private func updateLanguages(_ languages: [LanguageModel]) {
        // Store current languages
        currentLanguages = languages
        
        // Clear existing views
        clearLanguageItemViews()
        
        // Create new views with language references
        languageItemViews = languages.enumerated().map { (index, language) in
            let itemView = LanguageItemView()
            let isLastItem = index == languages.count - 1
            
            itemView.configure(with: language, isLastItem: isLastItem) { [weak self] selectedLanguage in
                self?.viewModel.selectLanguage(selectedLanguage)
            }
            
            return (view: itemView, language: language)
        }
        
        // Add views to stack
        languageItemViews.forEach { item in
            stackView.addArrangedSubview(item.view)
        }
        
        // Update corner radius for new items
        updateItemCornerRadius()
    }
    
    private func updateSelection(_ selectedLanguage: LanguageModel?) {
        // Update each item view to reflect the current selection
        for (itemView, language) in languageItemViews {
            let updatedLanguage = language.withSelection(language.id == selectedLanguage?.id)
            let isLastItem = languageItemViews.last?.language.id == language.id
            
            itemView.configure(with: updatedLanguage, isLastItem: isLastItem) { [weak self] selectedLang in
                self?.viewModel.selectLanguage(selectedLang)
            }
        }
    }
    
    private func updateItemCornerRadius() {
        guard !languageItemViews.isEmpty else { return }
        
        for (index, item) in languageItemViews.enumerated() {
            let position: LanguageItemView.CornerPosition
            
            if languageItemViews.count == 1 {
                position = .all
            } else if index == 0 {
                position = .top
            } else if index == languageItemViews.count - 1 {
                position = .bottom
            } else {
                position = .none
            }
            
            item.view.applyCornerRadius(position: position)
        }
    }
    
    private func clearLanguageItemViews() {
        languageItemViews.forEach { item in
            item.view.removeFromSuperview()
        }
        languageItemViews.removeAll()
    }
    
    // MARK: - Public API
    
    /// Refreshes the language list from the view model
    public func refresh() {
        viewModel.loadLanguages()
    }
    
    /// Gets the currently selected language
    /// - Returns: The selected language model, if any
    public func getSelectedLanguage() -> LanguageModel? {
        return viewModel.getCurrentSelection()
    }
}

// MARK: - Subviews Initialization and Setup
extension LanguageSelectorView {
    
    private static func createContainerView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }
    
    private static func createStackView() -> UIStackView {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.alignment = .fill
        stackView.distribution = .fill
        stackView.spacing = 0 // No spacing between items since they have borders
        return stackView
    }
    
    private func setupSubviews() {
        addSubview(containerView)
        containerView.addSubview(stackView)
        
        initConstraints()
    }
    
    private func initConstraints() {
        NSLayoutConstraint.activate([
            // Container
            containerView.leadingAnchor.constraint(equalTo: leadingAnchor),
            containerView.trailingAnchor.constraint(equalTo: trailingAnchor),
            containerView.topAnchor.constraint(equalTo: topAnchor),
            containerView.bottomAnchor.constraint(equalTo: bottomAnchor),
            
            // Stack view
            stackView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 8),
            stackView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -8),
            stackView.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 8),
            stackView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -8)
        ])
    }
}

// MARK: - SwiftUI Preview
#if DEBUG

@available(iOS 17.0, *)
#Preview("Language Selector") {
    PreviewUIViewController {
        let vc = UIViewController()
        let mockViewModel = MockLanguageSelectorViewModel.defaultMock
        let languageSelector = LanguageSelectorView(viewModel: mockViewModel)
        languageSelector.translatesAutoresizingMaskIntoConstraints = false
        
        vc.view.backgroundColor = StyleProvider.Color.backgroundTertiary
        vc.view.addSubview(languageSelector)
        
        NSLayoutConstraint.activate([
            languageSelector.leadingAnchor.constraint(equalTo: vc.view.leadingAnchor, constant: 16),
            languageSelector.trailingAnchor.constraint(equalTo: vc.view.trailingAnchor, constant: -16),
            languageSelector.centerYAnchor.constraint(equalTo: vc.view.centerYAnchor)
        ])
        
        return vc
    }
}

@available(iOS 17.0, *)
#Preview("Language Selector - Two Languages") {
    PreviewUIViewController {
        let vc = UIViewController()
        let mockViewModel = MockLanguageSelectorViewModel.twoLanguagesMock
        let languageSelector = LanguageSelectorView(viewModel: mockViewModel)
        languageSelector.translatesAutoresizingMaskIntoConstraints = false
        
        vc.view.backgroundColor = StyleProvider.Color.backgroundTertiary
        vc.view.addSubview(languageSelector)
        
        NSLayoutConstraint.activate([
            languageSelector.leadingAnchor.constraint(equalTo: vc.view.leadingAnchor, constant: 16),
            languageSelector.trailingAnchor.constraint(equalTo: vc.view.trailingAnchor, constant: -16),
            languageSelector.centerYAnchor.constraint(equalTo: vc.view.centerYAnchor)
        ])
        
        return vc
    }
}

@available(iOS 17.0, *)
#Preview("Language Selector - Many Languages") {
    VStack {
        Text("Language Selection")
            .font(.title2)
            .padding()
        
        PreviewUIView {
            let mockViewModel = MockLanguageSelectorViewModel.manyLanguagesMock
            return LanguageSelectorView(viewModel: mockViewModel)
        }
        .padding(.horizontal, 16)
        
        Spacer()
    }
}

#endif
