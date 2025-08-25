//
//  MultiWidgetToolbarViewModelProtocol.swift
//  GomaUI

import Combine
import UIKit

// MARK: - Widget Models

/// Identifies different types of widgets that can be displayed in the toolbar
public enum WidgetType: String, Codable {
    case image
    case wallet
    case avatar
    case support
    case languageSwitcher
    case button
    case loginButton
    case signUpButton
    case space
}

/// Details for widgets that contain multiple interactive elements
public struct WidgetDetail: Codable, Equatable, Hashable {
    public let isButton: Bool
    public let container: String
    public let label: String?
    public let route: String?
    public let icon: String?
    
    public init(isButton: Bool, container: String, label: String? = nil, route: String? = nil, icon: String? = nil) {
        self.isButton = isButton
        self.container = container
        self.label = label
        self.route = route
        self.icon = icon
    }
}

/// Represents a widget that can be displayed in the toolbar
public struct Widget: Codable, Equatable, Hashable {
    public let id: String
    public let type: WidgetType
    public let src: String?
    public let alt: String?
    public let route: String?
    public let container: String?
    public let label: String?
    public let icon: String?
    public let details: [WidgetDetail]?
    
    public init(
        id: String,
        type: WidgetType,
        src: String? = nil,
        alt: String? = nil,
        route: String? = nil,
        container: String? = nil,
        label: String? = nil,
        icon: String? = nil,
        details: [WidgetDetail]? = nil
    ) {
        self.id = id
        self.type = type
        self.src = src
        self.alt = alt
        self.route = route
        self.container = container
        self.label = label
        self.icon = icon
        self.details = details
    }
}

// MARK: - Layout Models

/// Defines how widgets are arranged in a line
public enum LayoutMode: String, Codable, Equatable, Hashable {
    case flex   // Flexible spacing with some widgets taking more space
    case split  // Equal spacing for all widgets
}

/// Configuration for a single row/line in the toolbar
public struct LineConfig: Codable, Equatable, Hashable {
    public let mode: LayoutMode
    public let widgets: [String] // Widget IDs
    
    public init(mode: LayoutMode, widgets: [String]) {
        self.mode = mode
        self.widgets = widgets
    }
}

/// Defines the state of the toolbar based on login status
public enum LayoutState: String, Codable, Equatable {
    case loggedIn
    case loggedOut
}

// MARK: - Display State Models

/// Represents how a widget should be displayed
public struct WidgetDisplayData: Equatable, Hashable {
    public let widget: Widget
    
    public init(widget: Widget) {
        self.widget = widget
    }
}

/// Represents how a line of widgets should be displayed
public struct LineDisplayData: Equatable, Hashable {
    public let mode: LayoutMode
    public let widgets: [WidgetDisplayData]
    
    public init(mode: LayoutMode, widgets: [WidgetDisplayData]) {
        self.mode = mode
        self.widgets = widgets
    }
}

/// Represents the complete visual state for the MultiWidgetToolbarView
public struct MultiWidgetToolbarDisplayState: Equatable {
    public let lines: [LineDisplayData]
    public let currentState: LayoutState
    
    public init(lines: [LineDisplayData], currentState: LayoutState) {
        self.lines = lines
        self.currentState = currentState
    }
}

// MARK: - View Model Protocol

/// Protocol defining the essential requirements for a view model powering `MultiWidgetToolbarView`
public protocol MultiWidgetToolbarViewModelProtocol {
    /// Publisher for the current display state of the toolbar
    var displayStatePublisher: AnyPublisher<MultiWidgetToolbarDisplayState, Never> { get }
    
    var walletViewModel: MockWalletWidgetViewModel? { get set }
    
    /// Handles widget selection
    func selectWidget(id: String)
    
    /// Changes the layout state (e.g., logged in vs logged out)
    func setLayoutState(_ state: LayoutState)
    
    func setWalletBalance(balance: Double)
}

// MARK: - Configuration Models

/// Main configuration for the toolbar
public struct MultiWidgetToolbarConfig: Codable, Equatable {
    public let name: String
    public let widgets: [Widget]
    public let layouts: [String: LayoutConfig] // Key is LayoutState.rawValue
    
    public init(name: String, widgets: [Widget], layouts: [String: LayoutConfig]) {
        self.name = name
        self.widgets = widgets
        self.layouts = layouts
    }
}

/// Configuration for a specific layout
public struct LayoutConfig: Codable, Equatable {
    public let lines: [LineConfig]
    
    public init(lines: [LineConfig]) {
        self.lines = lines
    }
} 
