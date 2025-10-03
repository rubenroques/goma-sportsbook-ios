//
//  NotificationsViewModel.swift
//  BetssonCameroonApp
//
//  Created on 29/08/2025.
//

import Foundation
import Combine
import GomaUI
import ServicesProvider

// MARK: - Notifications Display State

struct NotificationsDisplayState: Equatable {
    let isLoading: Bool
    let error: String?
    
    init(isLoading: Bool = false, error: String? = nil) {
        self.isLoading = isLoading
        self.error = error
    }
}

// MARK: - Production Notifications ViewModel

final class NotificationsViewModel: ObservableObject {
    
    // MARK: - Published Properties
    
    @Published var displayState = NotificationsDisplayState()
    
    // MARK: - Private Properties
    
    private let servicesProvider: ServicesProvider.Client
    private var cancellables = Set<AnyCancellable>()
    
    // Integration with GomaUI component
    var notificationListViewModel: NotificationListViewModelProtocol
    
    // MARK: - Navigation Callbacks
    
    var onDismiss: (() -> Void)?
    var onNotificationActionTapped: ((NotificationData, NotificationAction) -> Void)?
    
    // MARK: - Initialization
    
    init(servicesProvider: ServicesProvider.Client) {
        self.servicesProvider = servicesProvider
        
        // Create NotificationListViewModel with mock data (since API endpoint doesn't exist yet)
        self.notificationListViewModel = Self.createNotificationListViewModelWithMockData()
        
        setupNotificationListCallbacks()
    }
    
    // MARK: - Public Methods
    
    func loadData() {
        displayState = NotificationsDisplayState(isLoading: true)
        
        // Simulate loading and refresh the notification list
        notificationListViewModel.refresh()
        
        // Complete loading after short delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
            self?.displayState = NotificationsDisplayState(isLoading: false)
        }
    }
    
    func refreshData() {
        notificationListViewModel.refresh()
    }
    
    func didTapClose() {
        onDismiss?()
    }
    
    func markAllAsRead() {
        notificationListViewModel.markAllAsRead()
    }
    
    // MARK: - Private Methods
    
    private static func createNotificationListViewModelWithMockData() -> NotificationListViewModelProtocol {
        // Use the same rich mock data as MockNotificationListViewModel.defaultMock
        // This provides realistic notification content for testing and development
        let mockNotifications = Self.createMockNotificationData()
        
        // Create a custom implementation that conforms to the protocol but uses our mock data
        return ProductionNotificationListViewModel(initialNotifications: mockNotifications)
    }
    
    private static func createMockNotificationData() -> [NotificationData] {
        // Same mock data as MockNotificationListViewModel for consistency
        return [
            NotificationData(
                id: "notif_1",
                timestamp: Calendar.current.date(byAdding: .hour, value: -2, to: Date()) ?? Date(),
                title: "Complete Onboarding",
                description: "You're almost there, Firstname. Complete your personal and account information, and start betting!",
                state: .unread
            ),
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
                id: "notif_3",
                timestamp: Calendar.current.date(byAdding: .day, value: -1, to: Date()) ?? Date(),
                title: "Account Verification Complete",
                description: "Your account has been successfully verified. You can now enjoy all features of our platform.",
                state: .read
            ),
            NotificationData(
                id: "promo_1",
                timestamp: Calendar.current.date(byAdding: .day, value: -1, to: Date()) ?? Date(),
                title: "Limited Time Offer",
                description: "Double your winnings on football matches today only! Don't miss out on this exclusive promotion.",
                state: .read
            ),
            NotificationData(
                id: "urgent_1",
                timestamp: Calendar.current.date(byAdding: .day, value: -2, to: Date()) ?? Date(),
                title: "Bonus Credit Added",
                description: "Congratulations! €50 bonus credit has been added to your account.",
                state: .read,
                action: NotificationAction(id: "view_bonus", title: "View Details", style: .primary)
            )
        ]
    }
    
    private func setupNotificationListCallbacks() {
        // Handle notification actions
        notificationListViewModel.onActionPerformed = { [weak self] notification in
            print("NotificationsViewModel: Action performed for notification - \(notification.title)")
            
            if let action = notification.action {
                self?.handleNotificationAction(notification: notification, action: action)
            }
        }
        
        // Handle notification read status
        notificationListViewModel.onNotificationRead = { notification in
            print("NotificationsViewModel: Notification marked as read - \(notification.title)")
        }
        
        // Handle refresh completion
        notificationListViewModel.onRefreshCompleted = { [weak self] in
            print("NotificationsViewModel: Refresh completed")
            self?.displayState = NotificationsDisplayState(isLoading: false)
        }
        
        // Handle errors
        notificationListViewModel.onError = { [weak self] error in
            print("NotificationsViewModel: Error - \(error.localizedDescription)")
            self?.displayState = NotificationsDisplayState(error: error.localizedDescription)
        }
    }
    
    private func handleNotificationAction(notification: NotificationData, action: NotificationAction) {
        // Handle different notification actions
        switch action.id {
        case "claim_bonus":
            print("NotificationsViewModel: Claim bonus action - should navigate to bonus screen")
        case "confirm_payment":
            print("NotificationsViewModel: Confirm payment action - should navigate to payment screen")
        case "view_bonus":
            print("NotificationsViewModel: View bonus details - should show bonus information")
        default:
            print("NotificationsViewModel: Unknown action - \(action.id)")
        }
        
        // Notify coordinator for further handling
        onNotificationActionTapped?(notification, action)
    }
}

// MARK: - Production NotificationListViewModel

/// Production implementation of NotificationListViewModelProtocol that uses mock data
/// This will be replaced with real API integration when endpoints are available
private final class ProductionNotificationListViewModel: NotificationListViewModelProtocol {
    
    // MARK: - Private Properties
    
    private let notificationListStateSubject: CurrentValueSubject<NotificationListState, Never>
    private let notificationsSubject: CurrentValueSubject<[NotificationData], Never>
    private let isLoadingSubject: CurrentValueSubject<Bool, Never>
    
    // MARK: - Public Properties
    
    var notificationListStatePublisher: AnyPublisher<NotificationListState, Never> {
        notificationListStateSubject.eraseToAnyPublisher()
    }
    
    var notificationsPublisher: AnyPublisher<[NotificationData], Never> {
        notificationsSubject.eraseToAnyPublisher()
    }
    
    var isLoadingPublisher: AnyPublisher<Bool, Never> {
        isLoadingSubject.eraseToAnyPublisher()
    }
    
    var notifications: [NotificationData] {
        notificationsSubject.value
    }
    
    var isLoading: Bool {
        isLoadingSubject.value
    }
    
    var unreadCount: Int {
        notifications.filter { $0.isUnread }.count
    }
    
    // MARK: - Callbacks
    
    var onActionPerformed: ((NotificationData) -> Void)?
    var onNotificationRead: ((NotificationData) -> Void)?
    var onRefreshCompleted: (() -> Void)?
    var onError: ((Error) -> Void)?
    
    // MARK: - Initialization
    
    init(initialNotifications: [NotificationData]) {
        self.notificationsSubject = CurrentValueSubject(initialNotifications)
        self.isLoadingSubject = CurrentValueSubject(false)
        
        let state: NotificationListState = initialNotifications.isEmpty ? .empty : .loaded(initialNotifications)
        self.notificationListStateSubject = CurrentValueSubject(state)
    }
    
    // MARK: - Protocol Implementation
    
    func refresh() {
        isLoadingSubject.send(true)
        
        // Simulate API call delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            self?.isLoadingSubject.send(false)
            self?.onRefreshCompleted?()
        }
    }
    
    func loadMore() {
        // For mock implementation, we don't add more notifications
        print("ProductionNotificationListViewModel: Load more called (no-op in mock)")
    }
    
    func markAsRead(notificationId: String) {
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
            notificationListStateSubject.send(.loaded(updatedNotifications))
            onNotificationRead?(readNotification)
        }
    }
    
    func markAllAsRead() {
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
        notificationListStateSubject.send(.loaded(updatedNotifications))
    }
    
    func performAction(for notification: NotificationData) {
        onActionPerformed?(notification)
        
        // Automatically mark as read when action is performed
        markAsRead(notificationId: notification.id)
    }
    
    func deleteNotification(notificationId: String) {
        let updatedNotifications = notificationsSubject.value.filter { $0.id != notificationId }
        notificationsSubject.send(updatedNotifications)
        
        let newState: NotificationListState = updatedNotifications.isEmpty ? .empty : .loaded(updatedNotifications)
        notificationListStateSubject.send(newState)
    }
    
    func clearAllNotifications() {
        notificationsSubject.send([])
        notificationListStateSubject.send(.empty)
    }
}
