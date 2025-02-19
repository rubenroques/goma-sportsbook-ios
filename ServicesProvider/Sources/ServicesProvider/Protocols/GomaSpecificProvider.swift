import Foundation
import Combine
import SharedModels

/// Protocol defining GOMA-specific functionality that extends beyond the standard provider protocols
public protocol GomaSpecificProvider {

    /// Indicates whether the provider is currently enabled
    var providerEnabled: Bool { get }

    /// Publisher for the current access token
    var accessToken: String? { get }

    /// Performs an anonymous login using device identifier
    /// - Returns: A publisher that emits the authentication token on success
    func anonymousLogin() -> AnyPublisher<String, ServiceProviderError>

    /// Logs out the current user
    /// - Returns: A publisher that emits a success message
    func logoutUser() -> AnyPublisher<String, ServiceProviderError>

    /// Enables or disables the promotions provider functionality
    /// - Parameter isEnabled: Boolean indicating whether to enable promotions
    /// - Returns: A publisher that emits the new enabled state
    func isPromotionsProviderEnabled(isEnabled: Bool) -> AnyPublisher<Bool, ServiceProviderError>

    /// Performs basic sign up with minimal required information
    /// - Parameter form: The basic sign up form containing name, email, username, password, and avatar
    /// - Returns: A publisher that emits the basic sign up response
    func basicSignUp(form: BasicSignUpForm) -> AnyPublisher<BasicSignUpResponse, ServiceProviderError>

    // MARK: - Chat & Support Methods

    /// Retrieves the list of available chat categories
    func getChatCategories() -> AnyPublisher<[ChatCategory], ServiceProviderError>

    /// Creates a new chat ticket
    /// - Parameters:
    ///   - category: The category of the chat ticket
    ///   - message: Initial message for the ticket
    /// - Returns: A publisher that emits the created ticket information
    func createChatTicket(category: String, message: String) -> AnyPublisher<ChatTicket, ServiceProviderError>

    /// Retrieves the chat history for a specific ticket
    /// - Parameter ticketId: The ID of the ticket to get history for
    /// - Returns: A publisher that emits the chat history
    func getChatHistory(ticketId: String) -> AnyPublisher<[ChatMessage], ServiceProviderError>

    /// Sends a message in an existing chat ticket
    /// - Parameters:
    ///   - ticketId: The ID of the ticket to send message to
    ///   - message: The message content to send
    /// - Returns: A publisher that emits the sent message information
    func sendChatMessage(ticketId: String, message: String) -> AnyPublisher<ChatMessage, ServiceProviderError>

    /// Retrieves the list of active chat tickets
    /// - Returns: A publisher that emits the list of active tickets
    func getActiveChatTickets() -> AnyPublisher<[ChatTicket], ServiceProviderError>

    // MARK: - Events & Notifications Methods

    /// Retrieves the list of notifications for the current user
    /// - Returns: A publisher that emits the list of notifications
    func getNotifications() -> AnyPublisher<[Notification], ServiceProviderError>

    /// Marks a notification as read
    /// - Parameter notificationId: The ID of the notification to mark as read
    /// - Returns: A publisher that emits a success indicator
    func markNotificationAsRead(notificationId: String) -> AnyPublisher<Bool, ServiceProviderError>

    /// Retrieves the list of events with pagination support
    /// - Parameters:
    ///   - page: The page number to retrieve
    ///   - pageSize: Number of items per page
    /// - Returns: A publisher that emits the paginated events
    func getEvents(page: Int, pageSize: Int) -> AnyPublisher<PaginatedResponse<Event>, ServiceProviderError>

    // MARK: - User Preferences & Settings

    /// Updates the user's notification preferences
    /// - Parameter preferences: The new notification preferences
    /// - Returns: A publisher that emits a success indicator
    func updateNotificationPreferences(preferences: NotificationPreferences) -> AnyPublisher<Bool, ServiceProviderError>

    /// Retrieves the current notification preferences for the user
    /// - Returns: A publisher that emits the current notification preferences
    func getNotificationPreferences() -> AnyPublisher<NotificationPreferences, ServiceProviderError>
}

// MARK: - Supporting Types

public struct ChatCategory {
    public let id: String
    public let name: String
    public let description: String
}

public struct ChatTicket {
    public let id: String
    public let category: String
    public let status: String
    public let createdAt: Date
    public let lastMessageAt: Date?
}

public struct ChatMessage {
    public let id: String
    public let ticketId: String
    public let sender: String
    public let content: String
    public let timestamp: Date
}

public struct Notification {
    public let id: String
    public let title: String
    public let message: String
    public let type: String
    public let isRead: Bool
    public let createdAt: Date
}

public struct NotificationPreferences {
    public let pushEnabled: Bool
    public let emailEnabled: Bool
    public let marketingEnabled: Bool
    public let promotionsEnabled: Bool
}

public struct PaginatedResponse<T> {
    public let items: [T]
    public let totalItems: Int
    public let currentPage: Int
    public let totalPages: Int
}