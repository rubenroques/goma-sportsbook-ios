import Foundation
import Combine
import UIKit

/// Mock implementation of NotificationListViewModelProtocol for testing and preview purposes
final public class MockNotificationListViewModel: NotificationListViewModelProtocol {
    
    // MARK: - Private Properties
    private let notificationListStateSubject: CurrentValueSubject<NotificationListState, Never>
    private let notificationsSubject: CurrentValueSubject<[NotificationData], Never>
    private let isLoadingSubject: CurrentValueSubject<Bool, Never>
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Public Properties
    public var notificationListStatePublisher: AnyPublisher<NotificationListState, Never> {
        notificationListStateSubject.eraseToAnyPublisher()
    }
    
    public var notificationsPublisher: AnyPublisher<[NotificationData], Never> {
        notificationsSubject.eraseToAnyPublisher()
    }
    
    public var isLoadingPublisher: AnyPublisher<Bool, Never> {
        isLoadingSubject.eraseToAnyPublisher()
    }
    
    public var notifications: [NotificationData] {
        notificationsSubject.value
    }
    
    public var isLoading: Bool {
        isLoadingSubject.value
    }
    
    public var unreadCount: Int {
        notifications.filter { $0.isUnread }.count
    }
    
    // MARK: - Callbacks
    public var onActionPerformed: ((NotificationData) -> Void)?
    public var onNotificationRead: ((NotificationData) -> Void)?
    public var onRefreshCompleted: (() -> Void)?
    public var onError: ((Error) -> Void)?
    
    // MARK: - Initialization
    public init(initialNotifications: [NotificationData] = [], initialState: NotificationListState? = nil) {
        self.notificationsSubject = CurrentValueSubject(initialNotifications)
        self.isLoadingSubject = CurrentValueSubject(false)
        
        let state = initialState ?? (initialNotifications.isEmpty ? .empty : .loaded(initialNotifications))
        self.notificationListStateSubject = CurrentValueSubject(state)
        
        setupBindings()
    }
    
    private func setupBindings() {
        notificationsSubject
            .map { notifications in
                if notifications.isEmpty {
                    return NotificationListState.empty
                } else {
                    return NotificationListState.loaded(notifications)
                }
            }
            .sink { [weak self] state in
                self?.notificationListStateSubject.send(state)
            }
            .store(in: &cancellables)
    }
    
    // MARK: - NotificationListViewModelProtocol Implementation
    public func refresh() {
        simulateLoadingDelay {
            // In a real implementation, this would fetch from API
            print("MockNotificationListViewModel: Refresh completed")
            self.onRefreshCompleted?()
        }
    }
    
    public func loadMore() {
        // Simulate loading more notifications
        let additionalNotifications = Self.generateAdditionalNotifications()
        let currentNotifications = notificationsSubject.value
        let updatedNotifications = currentNotifications + additionalNotifications
        
        simulateLoadingDelay {
            self.notificationsSubject.send(updatedNotifications)
        }
    }
    
    public func markAsRead(notificationId: String) {
        var updatedNotifications = notificationsSubject.value
        
        if let index = updatedNotifications.firstIndex(where: { $0.id == notificationId }) {
            let originalNotification = updatedNotifications[index]
            let readNotification = NotificationData(
                id: originalNotification.id,
                timestamp: originalNotification.timestamp,
                title: originalNotification.title,
                description: originalNotification.description,
                state: .read,
                action: originalNotification.action
            )
            
            updatedNotifications[index] = readNotification
            notificationsSubject.send(updatedNotifications)
            onNotificationRead?(readNotification)
            
            print("MockNotificationListViewModel: Marked notification '\(originalNotification.title)' as read")
        }
    }
    
    public func markAllAsRead() {
        let updatedNotifications = notificationsSubject.value.map { notification in
            NotificationData(
                id: notification.id,
                timestamp: notification.timestamp,
                title: notification.title,
                description: notification.description,
                state: .read,
                action: notification.action
            )
        }
        
        notificationsSubject.send(updatedNotifications)
        print("MockNotificationListViewModel: Marked all notifications as read")
    }
    
    public func performAction(for notification: NotificationData) {
        print("MockNotificationListViewModel: Performing action for notification: \(notification.title)")
        
        if let action = notification.action {
            print("Action: \(action.title) (\(action.style))")
            
            // Simulate different action behaviors based on action title
            switch action.title.lowercased() {
            case "do something":
                simulateCompletionAction(for: notification)
            case "claim bonus":
                simulateClaimBonusAction(for: notification)
            case "confirm payment":
                simulatePaymentAction(for: notification)
            default:
                break
            }
        }
        
        onActionPerformed?(notification)
    }
    
    public func deleteNotification(notificationId: String) {
        var updatedNotifications = notificationsSubject.value
        updatedNotifications.removeAll { $0.id == notificationId }
        notificationsSubject.send(updatedNotifications)
        
        print("MockNotificationListViewModel: Deleted notification with ID: \(notificationId)")
    }
    
    public func clearAllNotifications() {
        notificationsSubject.send([])
        print("MockNotificationListViewModel: Cleared all notifications")
    }
    
    // MARK: - Private Helper Methods
    private func simulateLoadingDelay(completion: @escaping () -> Void) {
        isLoadingSubject.send(true)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            self.isLoadingSubject.send(false)
            completion()
        }
    }
    
    private func simulateCompletionAction(for notification: NotificationData) {
        // Mark as read and remove action button
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.markAsRead(notificationId: notification.id)
        }
    }
    
    private func simulateClaimBonusAction(for notification: NotificationData) {
        // Simulate bonus claiming process
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            self.markAsRead(notificationId: notification.id)
        }
    }
    
    private func simulatePaymentAction(for notification: NotificationData) {
        // Simulate payment confirmation
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            self.markAsRead(notificationId: notification.id)
        }
    }
}

// MARK: - Mock Factories
extension MockNotificationListViewModel {
    
    /// Default mock with various notification states
    public static var defaultMock: MockNotificationListViewModel {
        let notifications = [
            NotificationData(
                id: "notif_1",
                timestamp: Calendar.current.date(byAdding: .hour, value: -2, to: Date()) ?? Date(),
                title: "Complete Onboarding",
                description: "You're almost there, Firstname. Complete your personal and account information, and start betting!",
                state: .unread
            ),
            NotificationData(
                id: "notif_2",
                timestamp: Calendar.current.date(byAdding: .hour, value: -2, to: Date()) ?? Date(),
                title: "Complete Onboarding",
                description: "You're almost there, Firstname. Complete your personal and account information, and start betting!",
                state: .unread,
                action: NotificationAction(id: "action_2", title: "Do something", style: .primary)
            ),
            NotificationData(
                id: "notif_3",
                timestamp: Calendar.current.date(byAdding: .day, value: -1, to: Date()) ?? Date(),
                title: "Complete Onboarding",
                description: "You're almost there, Firstname. Complete your personal and account information, and start betting!",
                state: .read
            ),
            NotificationData(
                id: "notif_4",
                timestamp: Calendar.current.date(byAdding: .day, value: -1, to: Date()) ?? Date(),
                title: "Complete Onboarding",
                description: "You're almost there, Firstname. Complete your personal and account information, and start betting!",
                state: .read,
                action: NotificationAction(id: "action_4", title: "Do Something", style: .primary)
            )
        ]
        
        return MockNotificationListViewModel(initialNotifications: notifications)
    }
    
    /// Mock with mixed notification types
    public static var mixedNotificationsMock: MockNotificationListViewModel {
        let notifications = [
            NotificationData(
                id: "welcome_1",
                timestamp: Calendar.current.date(byAdding: .minute, value: -30, to: Date()) ?? Date(),
                title: "Welcome to Betsson!",
                description: "Thanks for joining us. Get started with your first bet and claim your welcome bonus!",
                state: .unread,
                action: NotificationAction(id: "claim_bonus", title: "Claim Bonus", style: .secondary)
            ),
            NotificationData(
                id: "payment_1",
                timestamp: Calendar.current.date(byAdding: .hour, value: -1, to: Date()) ?? Date(),
                title: "Payment Confirmation Required",
                description: "Please confirm your payment method to complete your deposit.",
                state: .unread,
                action: NotificationAction(id: "confirm_payment", title: "Confirm Payment", style: .primary)
            ),
            NotificationData(
                id: "promo_1",
                timestamp: Calendar.current.date(byAdding: .day, value: -1, to: Date()) ?? Date(),
                title: "Limited Time Offer",
                description: "Double your winnings on football matches today only! Don't miss out on this exclusive promotion.",
                state: .read
            ),
            NotificationData(
                id: "verification_1",
                timestamp: Calendar.current.date(byAdding: .day, value: -2, to: Date()) ?? Date(),
                title: "Account Verification Complete",
                description: "Your account has been successfully verified. You can now enjoy all features of our platform.",
                state: .read
            )
        ]
        
        return MockNotificationListViewModel(initialNotifications: notifications)
    }
    
    /// Mock with empty state
    public static var emptyMock: MockNotificationListViewModel {
        return MockNotificationListViewModel(initialNotifications: [])
    }
    
    /// Mock with loading state
    public static var loadingMock: MockNotificationListViewModel {
        let mock = MockNotificationListViewModel(initialNotifications: [], initialState: .loading)
        return mock
    }
    
    /// Mock with only unread notifications
    public static var unreadOnlyMock: MockNotificationListViewModel {
        let notifications = [
            NotificationData(
                id: "urgent_1",
                timestamp: Date(),
                title: "Urgent: Action Required",
                description: "Your account requires immediate attention. Please verify your identity to continue using our services.",
                state: .unread,
                action: NotificationAction(id: "verify_now", title: "Verify Now", style: .secondary)
            ),
            NotificationData(
                id: "bonus_1",
                timestamp: Calendar.current.date(byAdding: .minute, value: -15, to: Date()) ?? Date(),
                title: "Bonus Credit Added",
                description: "Congratulations! €50 bonus credit has been added to your account.",
                state: .unread,
                action: NotificationAction(id: "view_bonus", title: "View Details", style: .primary)
            )
        ]
        
        return MockNotificationListViewModel(initialNotifications: notifications)
    }
    
    /// Mock with only read notifications
    public static var readOnlyMock: MockNotificationListViewModel {
        let notifications = [
            NotificationData(
                id: "old_1",
                timestamp: Calendar.current.date(byAdding: .day, value: -7, to: Date()) ?? Date(),
                title: "Weekly Summary",
                description: "Here's your betting summary for the past week. You made 5 successful bets!",
                state: .read
            ),
            NotificationData(
                id: "old_2",
                timestamp: Calendar.current.date(byAdding: .day, value: -14, to: Date()) ?? Date(),
                title: "New Feature Available",
                description: "Check out our new live streaming feature for major sports events.",
                state: .read
            )
        ]
        
        return MockNotificationListViewModel(initialNotifications: notifications)
    }
    
    // MARK: - Helper Methods
    private static func generateAdditionalNotifications() -> [NotificationData] {
        let titles = ["Special Offer", "Match Update", "Payment Processed", "New Feature"]
        let descriptions = [
            "Take advantage of this limited time offer.",
            "Your favorite team is playing now!",
            "Your withdrawal has been processed successfully.",
            "Discover exciting new features in the app."
        ]
        
        return (0..<3).map { index in
            NotificationData(
                id: "additional_\(index)_\(UUID().uuidString)",
                timestamp: Calendar.current.date(byAdding: .hour, value: -(index + 1), to: Date()) ?? Date(),
                title: titles[index % titles.count],
                description: descriptions[index % descriptions.count],
                state: Bool.random() ? .read : .unread
            )
        }
    }
}