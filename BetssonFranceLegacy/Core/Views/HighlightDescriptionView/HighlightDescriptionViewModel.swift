//
//  HighlightDescriptionViewModel.swift
//  Sportsbook
//
//  Created by André Lascas on 30/10/2025.
//

import Foundation
import UIKit

// MARK: - View Model Implementation

/// Concrete implementation of HighlightDescriptionViewModelProtocol
public class HighlightDescriptionViewModel: HighlightDescriptionViewModelProtocol {
    
    // MARK: - Properties
    
    public let texts: [HighlightedText]
    public let regularFont: UIFont?
    public let regularColor: UIColor?
    public let highlightColor: UIColor?
    public let spacing: CGFloat?
    
    // MARK: - Lifecycle
    
    public init(
        texts: [HighlightedText],
        regularFont: UIFont? = nil,
        regularColor: UIColor? = nil,
        highlightColor: UIColor? = nil,
        spacing: CGFloat? = nil
    ) {
        self.texts = texts
        self.regularFont = regularFont
        self.regularColor = regularColor
        self.highlightColor = highlightColor
        self.spacing = spacing
    }
}
