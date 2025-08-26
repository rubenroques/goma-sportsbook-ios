import Foundation
import UIKit

// MARK: - Notification State
public enum NotificationState: String, CaseIterable {
    case unread
    case read
}

// MARK: - Notification Action
public struct NotificationAction: Equatable, Hashable {
    public let id: String
    public let title: String
    public let style: NotificationActionStyle
    
    public init(id: String, title: String, style: NotificationActionStyle) {
        self.id = id
        self.title = title
        self.style = style
    }
}

// MARK: - Notification Action Style
public enum NotificationActionStyle: String, CaseIterable {
    case primary
    case secondary
}

// MARK: - Notification Data
public struct NotificationData: Equatable, Hashable, Identifiable {
    public let id: String
    public let timestamp: Date
    public let title: String
    public let description: String
    public let state: NotificationState
    public let action: NotificationAction?
    
    public init(
        id: String,
        timestamp: Date,
        title: String,
        description: String,
        state: NotificationState,
        action: NotificationAction? = nil
    ) {
        self.id = id
        self.timestamp = timestamp
        self.title = title
        self.description = description
        self.state = state
        self.action = action
    }
    
    // MARK: - Computed Properties
    public var isRead: Bool {
        return state == .read
    }
    
    public var isUnread: Bool {
        return state == .unread
    }
    
    public var hasAction: Bool {
        return action != nil
    }
}

// MARK: - Notification List State
public enum NotificationListState {
    case loading
    case loaded([NotificationData])
    case empty
    case error(Error)
}