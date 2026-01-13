import XCTest
import SnapshotTesting
@testable import GomaUI

final class NotificationListViewSnapshotTests: XCTestCase {

    // NotificationListView uses `.receive(on: DispatchQueue.main)` without synchronous initial state.
    // waitForCombineRendering is required for proper rendering.

    // MARK: - List States

    func testNotificationListView_ListStates_Light() throws {
        let vc = NotificationListViewSnapshotViewController(category: .listStates)
        SnapshotTestConfig.waitForCombineRendering(vc)
        assertSnapshot(
            of: vc,
            as: .image(on: SnapshotTestConfig.device, size: SnapshotTestConfig.size, traits: SnapshotTestConfig.lightTraits),
            record: SnapshotTestConfig.record
        )
    }

    func testNotificationListView_ListStates_Dark() throws {
        let vc = NotificationListViewSnapshotViewController(category: .listStates)
        SnapshotTestConfig.waitForCombineRendering(vc)
        assertSnapshot(
            of: vc,
            as: .image(on: SnapshotTestConfig.device, size: SnapshotTestConfig.size, traits: SnapshotTestConfig.darkTraits),
            record: SnapshotTestConfig.record
        )
    }

    // MARK: - Notification States

    func testNotificationListView_NotificationStates_Light() throws {
        let vc = NotificationListViewSnapshotViewController(category: .notificationStates)
        SnapshotTestConfig.waitForCombineRendering(vc)
        assertSnapshot(
            of: vc,
            as: .image(on: SnapshotTestConfig.device, size: SnapshotTestConfig.size, traits: SnapshotTestConfig.lightTraits),
            record: SnapshotTestConfig.record
        )
    }

    func testNotificationListView_NotificationStates_Dark() throws {
        let vc = NotificationListViewSnapshotViewController(category: .notificationStates)
        SnapshotTestConfig.waitForCombineRendering(vc)
        assertSnapshot(
            of: vc,
            as: .image(on: SnapshotTestConfig.device, size: SnapshotTestConfig.size, traits: SnapshotTestConfig.darkTraits),
            record: SnapshotTestConfig.record
        )
    }

    // MARK: - Action Styles

    func testNotificationListView_ActionStyles_Light() throws {
        let vc = NotificationListViewSnapshotViewController(category: .actionStyles)
        SnapshotTestConfig.waitForCombineRendering(vc)
        assertSnapshot(
            of: vc,
            as: .image(on: SnapshotTestConfig.device, size: SnapshotTestConfig.size, traits: SnapshotTestConfig.lightTraits),
            record: SnapshotTestConfig.record
        )
    }

    func testNotificationListView_ActionStyles_Dark() throws {
        let vc = NotificationListViewSnapshotViewController(category: .actionStyles)
        SnapshotTestConfig.waitForCombineRendering(vc)
        assertSnapshot(
            of: vc,
            as: .image(on: SnapshotTestConfig.device, size: SnapshotTestConfig.size, traits: SnapshotTestConfig.darkTraits),
            record: SnapshotTestConfig.record
        )
    }

    // MARK: - Content Variants

    func testNotificationListView_ContentVariants_Light() throws {
        let vc = NotificationListViewSnapshotViewController(category: .contentVariants)
        SnapshotTestConfig.waitForCombineRendering(vc)
        assertSnapshot(
            of: vc,
            as: .image(on: SnapshotTestConfig.device, size: SnapshotTestConfig.size, traits: SnapshotTestConfig.lightTraits),
            record: SnapshotTestConfig.record
        )
    }

    func testNotificationListView_ContentVariants_Dark() throws {
        let vc = NotificationListViewSnapshotViewController(category: .contentVariants)
        SnapshotTestConfig.waitForCombineRendering(vc)
        assertSnapshot(
            of: vc,
            as: .image(on: SnapshotTestConfig.device, size: SnapshotTestConfig.size, traits: SnapshotTestConfig.darkTraits),
            record: SnapshotTestConfig.record
        )
    }
}
