//
//  HighlightDescriptionViewModelProtocol.swift
//  Sportsbook
//
//  Created by André Lascas on 30/10/2025.
//

import Foundation
import UIKit

// MARK: - Data Models

/// Data model for highlighted text
public struct HighlightedText {
    public let text: String
    public let isHighlighted: Bool
    
    public init(text: String, isHighlighted: Bool) {
        self.text = text
        self.isHighlighted = isHighlighted
    }
}

// MARK: - View Model Protocol

/// Protocol defining the interface for HighlightDescriptionView view model
public protocol HighlightDescriptionViewModelProtocol {
    /// Array of texts with highlight status
    var texts: [HighlightedText] { get }
    
    /// The font for regular text (optional, defaults set in view)
    var regularFont: UIFont? { get }
    
    /// The color for regular text (optional, defaults set in view)
    var regularColor: UIColor? { get }
    
    /// The color for highlighted text (optional, defaults set in view)
    var highlightColor: UIColor? { get }
    
    /// The spacing between text items (optional, defaults set in view)
    var spacing: CGFloat? { get }
}
