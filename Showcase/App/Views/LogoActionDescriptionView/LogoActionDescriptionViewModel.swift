//
//  LogoActionDescriptionViewModel.swift
//  Sportsbook
//
//  Created by André Lascas on 30/10/2025.
//

import Foundation

// MARK: - View Model Implementation

/// Concrete implementation of LogoActionDescriptionViewModelProtocol
public class LogoActionDescriptionViewModel: LogoActionDescriptionViewModelProtocol {
    
    // MARK: - Properties
    
    public let logoImageName: String
    public let descriptionText: String
    public let actionUrl: String?
    
    // MARK: - Lifecycle
    
    public init(logoImageName: String, descriptionText: String, actionUrl: String?) {
        self.logoImageName = logoImageName
        self.descriptionText = descriptionText
        self.actionUrl = actionUrl
    }
}
