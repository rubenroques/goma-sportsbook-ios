//
//  LogoDescriptionViewModel.swift
//  Sportsbook
//
//  Created by André Lascas on 30/10/2025.
//

import Foundation
import UIKit

// MARK: - View Model Implementation

/// Concrete implementation of LogoDescriptionViewModelProtocol
public class LogoDescriptionViewModel: LogoDescriptionViewModelProtocol {
    
    // MARK: - Properties
    
    public let logoImageName: String
    public let titleText: String
    public let titleFont: UIFont?
    public let titleColor: UIColor?
    public let descriptionText: String
    public let descriptionFont: UIFont?
    public let descriptionColor: UIColor?
    
    // MARK: - Lifecycle
    
    public init(
        logoImageName: String,
        titleText: String,
        titleFont: UIFont? = nil,
        titleColor: UIColor? = nil,
        descriptionText: String,
        descriptionFont: UIFont? = nil,
        descriptionColor: UIColor? = nil
    ) {
        self.logoImageName = logoImageName
        self.titleText = titleText
        self.titleFont = titleFont
        self.titleColor = titleColor
        self.descriptionText = descriptionText
        self.descriptionFont = descriptionFont
        self.descriptionColor = descriptionColor
    }
}
