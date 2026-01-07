import XCTest
import SnapshotTesting
@testable import GomaUI

final class EmptyStateActionViewSnapshotTests: XCTestCase {

    // MARK: - Basic States

    func testEmptyStateActionView_BasicStates_Light() throws {
        let vc = EmptyStateActionViewSnapshotViewController(category: .basicStates)
        assertSnapshot(
            of: vc,
            as: .image(on: SnapshotTestConfig.device, size: SnapshotTestConfig.size, traits: SnapshotTestConfig.lightTraits),
            record: SnapshotTestConfig.record
        )
    }

    func testEmptyStateActionView_BasicStates_Dark() throws {
        let vc = EmptyStateActionViewSnapshotViewController(category: .basicStates)
        assertSnapshot(
            of: vc,
            as: .image(on: SnapshotTestConfig.device, size: SnapshotTestConfig.size, traits: SnapshotTestConfig.darkTraits),
            record: SnapshotTestConfig.record
        )
    }
}
