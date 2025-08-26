//
//  ThemeSwitcherViewModelProtocol.swift
//  GomaUI
//
//  Created by Ruben Roques Code on 25/08/2025.
//

import Foundation
import Combine

/// Protocol defining the interface for ThemeSwitcherView view model
public protocol ThemeSwitcherViewModelProtocol {
    
    /// Publisher that emits the currently selected theme
    var selectedThemePublisher: AnyPublisher<ThemeMode, Never> { get }
    
    /// Called when user selects a theme
    /// - Parameter theme: The selected theme mode
    func selectTheme(_ theme: ThemeMode)
}
