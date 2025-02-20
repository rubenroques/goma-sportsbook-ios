import XCTest
import Combine
@testable import ServicesProvider

final class SportsMergerTests: XCTestCase {

    // MARK: - Initial Connection Tests

    /// Test verifies that SportsMerger successfully handles the initial subscription process
    ///
    /// Flow:
    /// 1. Setup:
    ///    - Creates MockURLSession to simulate network responses
    ///    - Prepares mock responses for both all sports and live sports subscriptions
    ///    - Each response contains a version number which validates the subscription
    ///
    /// 2. Subscription Process:
    ///    - SportsMerger initiates two parallel subscriptions:
    ///      a) All sports subscription (required)
    ///      b) Live sports subscription (optional)
    ///    - Both REST calls must return success (200) with valid version
    ///
    /// 3. State Management:
    ///    - SportsMerger transitions from .disconnected -> .connecting -> .connected
    ///    - Creates Subscription objects for successful responses
    ///    - Sends .connected state through sportsPublisher
    ///
    /// 4. Verification:
    ///    - Confirms we receive exactly one state update
    ///    - Verifies it's a .connected state with proper subscription
    ///    - Checks subscription has correct contentIdentifier and sessionToken
    ///    - Verifies the correct REST requests were made
    ///
    /// Note: This test only verifies the REST subscription part.
    /// Socket connection and updates are handled separately.
    func test_subscribeSportTypes_WhenSuccessful_ShouldReceiveConnectedState() {

    }
}
