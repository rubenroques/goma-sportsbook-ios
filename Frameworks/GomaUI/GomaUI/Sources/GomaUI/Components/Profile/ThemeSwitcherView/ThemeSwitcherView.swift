
//
//  ThemeSwitcherView.swift
//  GomaUI
//
//  Created by Ruben Roques Code on 25/08/2025.
//

import UIKit
import Combine
import SwiftUI


/// Super simple theme switcher component with 3 options
public final class ThemeSwitcherView: UIView {
    
    // MARK: Private properties
    private lazy var containerView: UIView = Self.createContainerView()
    private lazy var stackView: UIStackView = Self.createStackView()
    private lazy var selectionIndicator: UIView = Self.createSelectionIndicator()
    
    private var segmentViews: [ThemeSegmentView] = []
    
    // MARK: - Properties
    private let viewModel: ThemeSwitcherViewModelProtocol
    private var cancellables = Set<AnyCancellable>()
    private var currentSelectedIndex: Int = 0
    
    // MARK: - Lifetime and Cycle
    public init(viewModel: ThemeSwitcherViewModelProtocol) {
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
        setupActions()
    }
    
    override public func layoutSubviews() {
        super.layoutSubviews()
        containerView.layer.cornerRadius = 8
        updateSelectionIndicatorPosition()
    }
    
    func setupWithTheme() {
        backgroundColor = .clear
        containerView.backgroundColor = StyleProvider.Color.backgroundPrimary
        selectionIndicator.backgroundColor = StyleProvider.Color.highlightPrimary
    }
    
    // MARK: Functions
    private func setupBindings() {
        viewModel.selectedThemePublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] selectedTheme in
                self?.updateSelection(for: selectedTheme)
            }
            .store(in: &cancellables)
    }
    
    private func updateSelection(for theme: ThemeMode) {
        let themes = ThemeMode.allCases
        if let index = themes.firstIndex(of: theme) {
            currentSelectedIndex = index
            
            // Update segment appearances
            for (segmentIndex, segmentView) in segmentViews.enumerated() {
                segmentView.setSelected(segmentIndex == index)
            }
            
            // Animate indicator
            UIView.animate(withDuration: 0.2) {
                self.updateSelectionIndicatorPosition()
            }
        }
    }
    
    private func updateSelectionIndicatorPosition() {
        guard currentSelectedIndex < segmentViews.count else { return }
        
        let segmentView = segmentViews[currentSelectedIndex]
        selectionIndicator.frame = segmentView.frame
    }
}


// MARK: - Subviews Initialization and Setup
extension ThemeSwitcherView {
    
    private static func createContainerView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }
    
    private static func createStackView() -> UIStackView {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .horizontal
        stackView.alignment = .fill
        stackView.distribution = .fill
        stackView.spacing = 0
        return stackView
    }
    
    private static func createSelectionIndicator() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }
    
    private func setupSubviews() {
        addSubview(containerView)
        containerView.addSubview(selectionIndicator)
        containerView.addSubview(stackView)
        
        // Create segment views
        let themes = ThemeMode.allCases
        segmentViews = themes.map { theme in
            let segmentView = ThemeSegmentView(theme: theme)
            segmentView.setOnTapCallback { [weak self] selectedTheme in
                self?.viewModel.selectTheme(selectedTheme)
            }
            return segmentView
        }
        
        // Add segments to stack
        segmentViews.forEach { segmentView in
            stackView.addArrangedSubview(segmentView)
        }
        
        self.clipsToBounds = true
        self.containerView.clipsToBounds = true
        
        initConstraints()
    }
    
    private func initConstraints() {
        NSLayoutConstraint.activate([
            // Container
            containerView.leadingAnchor.constraint(equalTo: leadingAnchor),
            containerView.trailingAnchor.constraint(equalTo: trailingAnchor),
            containerView.topAnchor.constraint(equalTo: topAnchor),
            containerView.bottomAnchor.constraint(equalTo: bottomAnchor),
            containerView.heightAnchor.constraint(equalToConstant: 31),
            
            // Stack view
            stackView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            stackView.topAnchor.constraint(equalTo: containerView.topAnchor),
            stackView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor)
        ])
    }
    
    private func setupActions() {
        // Actions are handled by individual segment views
    }
}

// MARK: - SwiftUI Preview
#if DEBUG

#Preview("Theme Switcher") {
    PreviewUIViewController {
        let vc = UIViewController()
        let mockViewModel = MockThemeSwitcherViewModel.defaultMock
        let themeSwitcher = ThemeSwitcherView(viewModel: mockViewModel)
        themeSwitcher.translatesAutoresizingMaskIntoConstraints = false
        
        vc.view.backgroundColor = UIColor.systemGray6
        vc.view.addSubview(themeSwitcher)
        
        NSLayoutConstraint.activate([
            themeSwitcher.centerXAnchor.constraint(equalTo: vc.view.centerXAnchor),
            themeSwitcher.centerYAnchor.constraint(equalTo: vc.view.centerYAnchor)
        ])
        
        return vc
    }
}

#Preview("Theme Switcher - Dark") {
    PreviewUIViewController {
        let vc = UIViewController()
        let mockViewModel = MockThemeSwitcherViewModel.defaultMock
        let themeSwitcher = ThemeSwitcherView(viewModel: mockViewModel)
        themeSwitcher.translatesAutoresizingMaskIntoConstraints = false
        
        vc.view.backgroundColor = StyleProvider.Color.backgroundTertiary
        vc.view.addSubview(themeSwitcher)
        
        NSLayoutConstraint.activate([
            themeSwitcher.centerXAnchor.constraint(equalTo: vc.view.centerXAnchor),
            themeSwitcher.centerYAnchor.constraint(equalTo: vc.view.centerYAnchor)
        ])
        
        return vc
    }
    .environment(\.colorScheme, .dark)
}

#Preview("Theme Switcher - Both Modes") {
    VStack(spacing: 40) {
        VStack(spacing: 8) {
            Text(LocalizationProvider.string("light_mode"))
                .font(.caption)
                .foregroundColor(.secondary)
            
            PreviewUIView {
                let mockViewModel = MockThemeSwitcherViewModel.lightThemeMock
                let themeSwitcher = ThemeSwitcherView(viewModel: mockViewModel)
                return themeSwitcher
            }
            .frame(height: 60)
            .padding(.horizontal, 20)
            .environment(\.colorScheme, .light)
        }
        
        VStack(spacing: 8) {
            Text(LocalizationProvider.string("dark_mode"))
                .font(.caption)
                .foregroundColor(.secondary)
            
            PreviewUIView {
                let mockViewModel = MockThemeSwitcherViewModel.darkThemeMock
                let themeSwitcher = ThemeSwitcherView(viewModel: mockViewModel)
                return themeSwitcher
            }
            .frame(height: 60)
            .padding(.horizontal, 20)
            .environment(\.colorScheme, .dark)
        }
        
        VStack(spacing: 8) {
            Text("System Mode (Interactive)")
                .font(.caption)
                .foregroundColor(.secondary)
            
            PreviewUIView {
                let mockViewModel = MockThemeSwitcherViewModel.interactiveMock
                let themeSwitcher = ThemeSwitcherView(viewModel: mockViewModel)
                return themeSwitcher
            }
            .frame(height: 60)
            .padding(.horizontal, 20)
        }
    }
    .padding()
}

#endif
