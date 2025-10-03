//
//  ThemeSwitcherViewModel.swift
//  BetssonCameroonApp
//
//  Created on 2025
//

import Foundation
import Combine
import UIKit
import GomaUI

/// Real implementation of ThemeSwitcherViewModelProtocol that handles actual theme switching
final class ThemeSwitcherViewModel: ThemeSwitcherViewModelProtocol {
    
    // MARK: - Publishers
    @Published private var selectedTheme: ThemeMode
    
    public var selectedThemePublisher: AnyPublisher<ThemeMode, Never> {
        $selectedTheme.eraseToAnyPublisher()
    }
    
    // MARK: - Private Properties
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Initialization
    init() {
        // Load saved theme preference and convert to ThemeMode
        let savedAppearanceMode = UserDefaults.standard.appearanceMode
        self.selectedTheme = ThemeSwitcherViewModel.convertAppearanceModeToThemeMode(savedAppearanceMode)
        
        // Apply the saved theme immediately
        applyThemeToApp(selectedTheme)
    }
    
    // MARK: - ThemeSwitcherViewModelProtocol
    func selectTheme(_ theme: ThemeMode) {
        // Update the selected theme
        selectedTheme = theme
        
        // Convert ThemeMode to AppearanceMode and save
        let appearanceMode = ThemeSwitcherViewModel.convertThemeModeToAppearanceMode(theme)
        UserDefaults.standard.appearanceMode = appearanceMode
        
        // Apply the theme to the app
        applyThemeToApp(theme)
        
        // Post notification for other screens to update if needed
        NotificationCenter.default.post(
            name: .themeDidChange,
            object: nil,
            userInfo: ["theme": theme, "appearanceMode": appearanceMode]
        )
    }
    
    // MARK: - Private Methods
    private func applyThemeToApp(_ theme: ThemeMode) {
        DispatchQueue.main.async {
            // Get all windows and apply theme
            if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
                windowScene.windows.forEach { window in
                    switch theme {
                    case .light:
                        window.overrideUserInterfaceStyle = .light
                    case .dark:
                        window.overrideUserInterfaceStyle = .dark
                    case .system:
                        window.overrideUserInterfaceStyle = .unspecified
                    }
                    
                    // Force UI refresh
                    window.subviews.forEach { view in
                        view.setNeedsDisplay()
                        view.setNeedsLayout()
                    }
                }
            }
            
            // Also apply to legacy keyWindow for compatibility
            UIApplication.shared.keyWindow?.overrideUserInterfaceStyle = self.convertToUIUserInterfaceStyle(theme)
        }
    }
    
    private func convertToUIUserInterfaceStyle(_ theme: ThemeMode) -> UIUserInterfaceStyle {
        switch theme {
        case .light:
            return .light
        case .dark:
            return .dark
        case .system:
            return .unspecified
        }
    }
    
    // MARK: - Static Conversion Methods
    
    /// Convert BetssonCameroonApp's AppearanceMode to GomaUI's ThemeMode
    static func convertAppearanceModeToThemeMode(_ appearanceMode: AppearanceMode) -> ThemeMode {
        switch appearanceMode {
        case .light:
            return .light
        case .dark:
            return .dark
        case .device:
            return .system
        }
    }
    
    /// Convert GomaUI's ThemeMode to BetssonCameroonApp's AppearanceMode
    static func convertThemeModeToAppearanceMode(_ themeMode: ThemeMode) -> AppearanceMode {
        switch themeMode {
        case .light:
            return .light
        case .dark:
            return .dark
        case .system:
            return .device
        }
    }
}
