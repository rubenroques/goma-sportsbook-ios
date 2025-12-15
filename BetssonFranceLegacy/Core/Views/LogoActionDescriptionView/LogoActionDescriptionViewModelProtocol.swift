//
//  LogoActionDescriptionViewModelProtocol.swift
//  Sportsbook
//
//  Created by André Lascas on 30/10/2025.
//

import Foundation

// MARK: - View Model Protocol

/// Protocol defining the interface for LogoActionDescriptionView view model
public protocol LogoActionDescriptionViewModelProtocol {
    /// The name of the logo image
    var logoImageName: String { get }
    
    /// The description text to display
    var descriptionText: String { get }
    
    /// The URL to open when the logo is tapped (optional)
    var actionUrl: String? { get }
}
