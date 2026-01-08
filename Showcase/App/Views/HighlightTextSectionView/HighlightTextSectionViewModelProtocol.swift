//
//  HighlightTextSectionViewModelProtocol.swift
//  Sportsbook
//
//  Created by André Lascas on 30/10/2025.
//

import Foundation
import UIKit

// MARK: - View Model Protocol

/// Protocol defining the interface for HighlightTextSectionView view model
public protocol HighlightTextSectionViewModelProtocol {
    /// The title text to display
    var title: String { get }
    
    /// The font for the title label (optional, defaults set in view)
    var titleFont: UIFont? { get }
    
    /// The color for the title label (optional, defaults set in view)
    var titleColor: UIColor? { get }
    
    /// The description text to display
    var description: String { get }
    
    /// The font for the description label (optional, defaults set in view)
    var descriptionFont: UIFont? { get }
    
    /// The color for the description label (optional, defaults set in view)
    var descriptionColor: UIColor? { get }
}
