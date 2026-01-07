import XCTest
import SnapshotTesting
@testable import GomaUI

final class StatusNotificationViewSnapshotTests: XCTestCase {

    // MARK: - Notification Types

    func testStatusNotificationView_NotificationTypes_Light() throws {
        let vc = StatusNotificationViewSnapshotViewController(category: .notificationTypes)
        assertSnapshot(
            of: vc,
            as: .image(on: SnapshotTestConfig.device, size: SnapshotTestConfig.size, traits: SnapshotTestConfig.lightTraits),
            record: SnapshotTestConfig.record
        )
    }

    func testStatusNotificationView_NotificationTypes_Dark() throws {
        let vc = StatusNotificationViewSnapshotViewController(category: .notificationTypes)
        assertSnapshot(
            of: vc,
            as: .image(on: SnapshotTestConfig.device, size: SnapshotTestConfig.size, traits: SnapshotTestConfig.darkTraits),
            record: SnapshotTestConfig.record
        )
    }
}
