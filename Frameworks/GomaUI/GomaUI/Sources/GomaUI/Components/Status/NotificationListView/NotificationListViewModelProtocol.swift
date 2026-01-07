import Foundation
import Combine
import UIKit

/// Protocol defining the interface for NotificationListView's ViewModel
public protocol NotificationListViewModelProtocol {
    
    // MARK: - Publishers
    
    /// Publisher for reactive updates of notification list state
    var notificationListStatePublisher: AnyPublisher<NotificationListState, Never> { get }
    
    /// Publisher for reactive updates of notifications array
    var notificationsPublisher: AnyPublisher<[NotificationData], Never> { get }
    
    /// Publisher for loading state
    var isLoadingPublisher: AnyPublisher<Bool, Never> { get }
    
    // MARK: - Data Access
    
    /// Current notifications
    var notifications: [NotificationData] { get }
    
    /// Whether the list is currently loading
    var isLoading: Bool { get }
    
    /// Number of unread notifications
    var unreadCount: Int { get }
    
    // MARK: - Actions
    
    /// Refresh the notifications list
    func refresh()
    
    /// Load more notifications (for pagination)
    func loadMore()
    
    /// Mark a notification as read
    /// - Parameter notificationId: The ID of the notification to mark as read
    func markAsRead(notificationId: String)
    
    /// Mark all notifications as read
    func markAllAsRead()
    
    /// Perform the action associated with a notification
    /// - Parameter notification: The notification whose action should be performed
    func performAction(for notification: NotificationData)
    
    /// Delete a notification
    /// - Parameter notificationId: The ID of the notification to delete
    func deleteNotification(notificationId: String)
    
    /// Clear all notifications
    func clearAllNotifications()
    
    // MARK: - Callbacks
    
    /// Callback for when a notification action is performed
    var onActionPerformed: ((NotificationData) -> Void)? { get set }
    
    /// Callback for when a notification is marked as read
    var onNotificationRead: ((NotificationData) -> Void)? { get set }
    
    /// Callback for when refresh is completed
    var onRefreshCompleted: (() -> Void)? { get set }
    
    /// Callback for when an error occurs
    var onError: ((Error) -> Void)? { get set }
}