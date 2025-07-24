import Foundation
@testable import ServicesProvider

class TestableSubscription: ServicesProvider.Subscription {
    // MARK: - Properties
    private(set) var isActive: Bool = false
    private(set) var wasUnsubscribed: Bool = false
    private(set) var receivedUpdates: [(sports: [SportType], timestamp: Date)] = []

    // MARK: - Lifecycle
    override init(contentIdentifier: ContentIdentifier, sessionToken: String = "test_session_token", unsubscriber: UnsubscriptionController) {
        super.init(contentIdentifier: contentIdentifier, sessionToken: sessionToken, unsubscriber: unsubscriber)
        self.isActive = true
    }

    // MARK: - Update Tracking
    func recordUpdate(sports: [SportType]) {
        receivedUpdates.append((sports: sports, timestamp: Date()))
    }

    func markAsUnsubscribed() {
        isActive = false
        wasUnsubscribed = true
    }

    // MARK: - Test Helper Methods
    func reset() {
        isActive = true
        wasUnsubscribed = false
        receivedUpdates.removeAll()
    }

    var lastUpdate: [SportType]? {
        receivedUpdates.last?.sports
    }

    var updateCount: Int {
        receivedUpdates.count
    }

    // MARK: - Associated Subscriptions
    func addAssociatedSubscription(_ subscription: ServicesProvider.Subscription) {
        associateSubscription(subscription)
    }

    var associatedSubscriptionCount: Int {
        associatedSubscriptions.count
    }
}
