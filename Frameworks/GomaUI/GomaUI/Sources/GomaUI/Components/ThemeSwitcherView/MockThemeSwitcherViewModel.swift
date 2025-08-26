//
//  MockThemeSwitcherViewModel.swift
//  GomaUI
//
//  Created by Ruben Roques Code on 25/08/2025.
//

import Foundation
import Combine

/// Mock implementation of ThemeSwitcherViewModelProtocol for testing and previews
public final class MockThemeSwitcherViewModel: ThemeSwitcherViewModelProtocol {
    
    // MARK: - Publishers
    @Published private var selectedTheme: ThemeMode = .system
    
    public var selectedThemePublisher: AnyPublisher<ThemeMode, Never> {
        $selectedTheme.eraseToAnyPublisher()
    }
    
    // MARK: - Properties
    private var onThemeSelectedCallback: ((ThemeMode) -> Void)?
    
    // MARK: - Initialization
    public init(initialTheme: ThemeMode = .system, onThemeSelected: ((ThemeMode) -> Void)? = nil) {
        self.selectedTheme = initialTheme
        self.onThemeSelectedCallback = onThemeSelected
    }
    
    // MARK: - ThemeSwitcherViewModelProtocol
    public func selectTheme(_ theme: ThemeMode) {
        selectedTheme = theme
        print("🎨 Mock: Theme selected: \(theme.rawValue)")
        
        // Simulate theme feedback
        switch theme {
        case .light:
            print("☀️ Mock: Switching to light theme")
        case .system:
            print("💡 Mock: Following system theme")
        case .dark:
            print("🌙 Mock: Switching to dark theme")
        }
        
        onThemeSelectedCallback?(theme)
    }
    
    // MARK: - Public Methods for Testing
    public func setInitialTheme(_ theme: ThemeMode) {
        selectedTheme = theme
    }
}

// MARK: - Static Factory Methods
extension MockThemeSwitcherViewModel {
    
    /// Default mock instance starting with system theme
    public static var defaultMock: MockThemeSwitcherViewModel {
        MockThemeSwitcherViewModel { theme in
            print("🎯 Default Mock: Selected \(theme.rawValue)")
        }
    }
    
    /// Mock instance starting with light theme
    public static var lightThemeMock: MockThemeSwitcherViewModel {
        MockThemeSwitcherViewModel(initialTheme: .light) { theme in
            print("🎯 Light Mock: Selected \(theme.rawValue)")
        }
    }
    
    /// Mock instance starting with dark theme
    public static var darkThemeMock: MockThemeSwitcherViewModel {
        MockThemeSwitcherViewModel(initialTheme: .dark) { theme in
            print("🎯 Dark Mock: Selected \(theme.rawValue)")
        }
    }
    
    /// Mock instance with custom callback
    public static func customCallbackMock(
        initialTheme: ThemeMode = .system,
        onThemeSelected: @escaping (ThemeMode) -> Void
    ) -> MockThemeSwitcherViewModel {
        MockThemeSwitcherViewModel(initialTheme: initialTheme, onThemeSelected: onThemeSelected)
    }
    
    /// Mock instance for interactive demo with cycling behavior
    public static var interactiveMock: MockThemeSwitcherViewModel {
        MockThemeSwitcherViewModel { theme in
            print("🎯 Interactive Mock: Selected \(theme.rawValue)")
            
            // Additional interactive feedback
            switch theme {
            case .light:
                print("🌅 Interface will be bright and clean")
            case .system:
                print("🔄 Interface will follow system settings")
            case .dark:
                print("🌃 Interface will be dark and easy on the eyes")
            }
        }
    }
}
