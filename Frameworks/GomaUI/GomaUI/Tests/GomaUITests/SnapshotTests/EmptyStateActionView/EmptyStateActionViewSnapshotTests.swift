import XCTest
import SnapshotTesting
@testable import GomaUI

final class EmptyStateActionViewSnapshotTests: XCTestCase {

    // TODO: Migrate component to `currentDisplayState + dropFirst()` or scheduler injection for synchronous rendering.

    // MARK: - Basic States

    func testEmptyStateActionView_BasicStates_Light() throws {
        let vc = EmptyStateActionViewSnapshotViewController(category: .basicStates)
        SnapshotTestConfig.waitForCombineRendering(vc)
        assertSnapshot(
            of: vc,
            as: .image(on: SnapshotTestConfig.device, size: SnapshotTestConfig.size, traits: SnapshotTestConfig.lightTraits),
            record: SnapshotTestConfig.record
        )
    }

    func testEmptyStateActionView_BasicStates_Dark() throws {
        let vc = EmptyStateActionViewSnapshotViewController(category: .basicStates)
        SnapshotTestConfig.waitForCombineRendering(vc)
        assertSnapshot(
            of: vc,
            as: .image(on: SnapshotTestConfig.device, size: SnapshotTestConfig.size, traits: SnapshotTestConfig.darkTraits),
            record: SnapshotTestConfig.record
        )
    }
}
