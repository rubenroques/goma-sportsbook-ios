//
//  ThemeSwitcherViewController.swift
//  GomaUIDemo
//
//  Created by Ruben Roques Code on 25/08/2025.
//

import UIKit
import Combine
import GomaUI

class ThemeSwitcherViewController: UIViewController {
    
    // MARK: Private properties
    private lazy var scrollView: UIScrollView = Self.createScrollView()
    private lazy var contentView: UIView = Self.createContentView()
    private lazy var titleLabel: UILabel = Self.createTitleLabel()
    private lazy var descriptionLabel: UILabel = Self.createDescriptionLabel()
    private lazy var themeSwitcherView: ThemeSwitcherView = Self.createThemeSwitcherView()
    private lazy var currentThemeLabel: UILabel = Self.createCurrentThemeLabel()
    private lazy var actionLogTextView: UITextView = Self.createActionLogTextView()
    
    // MARK: ViewModel
    private let viewModel = MockThemeSwitcherViewModel.interactiveMock
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        setupBindings()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupWithTheme()
    }
    
    // MARK: - Setup
    private func setupView() {
        title = "Theme Switcher"
        setupSubviews()
    }
    
    private func setupWithTheme() {
        view.backgroundColor = StyleProvider.Color.backgroundTertiary
        titleLabel.textColor = StyleProvider.Color.textPrimary
        descriptionLabel.textColor = StyleProvider.Color.textSecondary
        currentThemeLabel.textColor = StyleProvider.Color.textPrimary
        actionLogTextView.backgroundColor = StyleProvider.Color.backgroundSecondary
        actionLogTextView.textColor = StyleProvider.Color.textPrimary
    }
    
    private func setupBindings() {
        viewModel.selectedThemePublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] theme in
                self?.currentThemeLabel.text = "Current Theme: \(theme.rawValue)"
                self?.logAction("Selected theme: \(theme.rawValue)")
            }
            .store(in: &cancellables)
    }
    
    private func logAction(_ message: String) {
        let timestamp = DateFormatter.localizedString(from: Date(), dateStyle: .none, timeStyle: .medium)
        let logEntry = "[\(timestamp)] \(message)\n"
        actionLogTextView.text = logEntry + actionLogTextView.text
    }
}

// MARK: - Subviews Initialization and Setup
extension ThemeSwitcherViewController {
    
    private static func createScrollView() -> UIScrollView {
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.showsVerticalScrollIndicator = true
        scrollView.showsHorizontalScrollIndicator = false
        return scrollView
    }
    
    private static func createContentView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }
    
    private static func createTitleLabel() -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Theme Switcher Component"
        label.font = StyleProvider.fontWith(type: .bold, size: 20)
        label.numberOfLines = 0
        return label
    }
    
    private static func createDescriptionLabel() -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Super simple theme switcher with Light, System, and Dark options. The orange indicator shows the selected theme."
        label.font = StyleProvider.fontWith(type: .regular, size: 14)
        label.numberOfLines = 0
        return label
    }
    
    private static func createThemeSwitcherView() -> ThemeSwitcherView {
        let viewModel = MockThemeSwitcherViewModel.interactiveMock
        return ThemeSwitcherView(viewModel: viewModel)
    }
    
    private static func createCurrentThemeLabel() -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Current Theme: System"
        label.font = StyleProvider.fontWith(type: .semibold, size: 16)
        label.textAlignment = .center
        label.numberOfLines = 1
        return label
    }
    
    private static func createActionLogTextView() -> UITextView {
        let textView = UITextView()
        textView.translatesAutoresizingMaskIntoConstraints = false
        textView.font = StyleProvider.fontWith(type: .regular, size: 12)
        textView.isEditable = false
        textView.layer.cornerRadius = 8
        textView.text = "Theme selection log will appear here...\n"
        return textView
    }
    
    private func setupSubviews() {
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        
        contentView.addSubview(titleLabel)
        contentView.addSubview(descriptionLabel)
        contentView.addSubview(themeSwitcherView)
        contentView.addSubview(currentThemeLabel)
        contentView.addSubview(actionLogTextView)
        
        // Recreate theme switcher with the actual viewModel
        themeSwitcherView.removeFromSuperview()
        themeSwitcherView = ThemeSwitcherView(viewModel: viewModel)
        themeSwitcherView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(themeSwitcherView)
        
        initConstraints()
    }
    
    private func initConstraints() {
        NSLayoutConstraint.activate([
            // ScrollView
            scrollView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            
            // ContentView
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
            
            // Title
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 20),
            
            // Description
            descriptionLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            descriptionLabel.trailingAnchor.constraint(equalTo: titleLabel.trailingAnchor),
            descriptionLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8),
            
            // Theme Switcher
            themeSwitcherView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            themeSwitcherView.topAnchor.constraint(equalTo: descriptionLabel.bottomAnchor, constant: 32),
            
            // Current Theme Label
            currentThemeLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            currentThemeLabel.trailingAnchor.constraint(equalTo: titleLabel.trailingAnchor),
            currentThemeLabel.topAnchor.constraint(equalTo: themeSwitcherView.bottomAnchor, constant: 24),
            
            // Action Log
            actionLogTextView.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            actionLogTextView.trailingAnchor.constraint(equalTo: titleLabel.trailingAnchor),
            actionLogTextView.topAnchor.constraint(equalTo: currentThemeLabel.bottomAnchor, constant: 16),
            actionLogTextView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -20),
            actionLogTextView.heightAnchor.constraint(equalToConstant: 120)
        ])
    }
}
