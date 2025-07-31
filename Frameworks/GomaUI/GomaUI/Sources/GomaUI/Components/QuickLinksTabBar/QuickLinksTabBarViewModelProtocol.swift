//
//  QuickLinksTabBarViewModelProtocol.swift
//  GomaUI
//
//  Created by Ruben Roques on 19/05/2025.
//

import Combine
import UIKit

// MARK: - Quick Link Types

/// Identifies different types of quick links that can be displayed
public enum QuickLinkType: String, Hashable {
    // Gaming related links
    case aviator
    case virtual
    case slots 
    case crash
    case promos
    
    // Sports related links
    case football
    case basketball
    case tennis
    case golf
    
    // Account related links
    case deposit
    case withdraw
    case help
    case settings
    
    //Filter related links
    case mainFilter
}

/// Represents a single quick link to be displayed
public struct QuickLinkItem: Equatable, Hashable {
    public let type: QuickLinkType
    public let title: String
    public let icon: UIImage?
    
    public init(type: QuickLinkType, title: String, icon: UIImage? = nil) {
        self.type = type
        self.title = title
        self.icon = icon
    }
}

// MARK: - View Model Protocol

/// Protocol defining the essential requirements for a view model powering `QuickLinksTabBarView`.
public protocol QuickLinksTabBarViewModelProtocol {
    /// Publisher for the current quick links to be displayed
    var quickLinksPublisher: AnyPublisher<[QuickLinkItem], Never> { get }
    
    /// Callback for when a tab is selected
    var onTabSelected: ((String) -> Void) { get set }
    
    /// Optional method to handle when a quick link is tapped.
    /// Implementations may use this to track analytics or perform other actions.
    func didTapQuickLink(type: QuickLinkType)
} 
