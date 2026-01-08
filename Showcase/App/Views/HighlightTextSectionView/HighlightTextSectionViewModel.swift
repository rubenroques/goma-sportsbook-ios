//
//  HighlightTextSectionViewModel.swift
//  Sportsbook
//
//  Created by André Lascas on 30/10/2025.
//

import Foundation
import UIKit

// MARK: - View Model Implementation

/// Concrete implementation of HighlightTextSectionViewModelProtocol
public class HighlightTextSectionViewModel: HighlightTextSectionViewModelProtocol {
    
    // MARK: - Properties
    
    public let title: String
    public let titleFont: UIFont?
    public let titleColor: UIColor?
    public let description: String
    public let descriptionFont: UIFont?
    public let descriptionColor: UIColor?
    
    // MARK: - Lifecycle
    
    public init(
        title: String,
        titleFont: UIFont? = nil,
        titleColor: UIColor? = nil,
        description: String,
        descriptionFont: UIFont? = nil,
        descriptionColor: UIColor? = nil
    ) {
        self.title = title
        self.titleFont = titleFont
        self.titleColor = titleColor
        self.description = description
        self.descriptionFont = descriptionFont
        self.descriptionColor = descriptionColor
    }
}
