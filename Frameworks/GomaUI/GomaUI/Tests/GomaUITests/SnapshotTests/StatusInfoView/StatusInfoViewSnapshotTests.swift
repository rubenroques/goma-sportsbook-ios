import XCTest
import SnapshotTesting
@testable import GomaUI

final class StatusInfoViewSnapshotTests: XCTestCase {

    // MARK: - Basic States

    func testStatusInfoView_BasicStates_Light() throws {
        let vc = StatusInfoViewSnapshotViewController(category: .basicStates)
        assertSnapshot(
            of: vc,
            as: .image(on: SnapshotTestConfig.device, size: SnapshotTestConfig.size, traits: SnapshotTestConfig.lightTraits),
            record: SnapshotTestConfig.record
        )
    }

    func testStatusInfoView_BasicStates_Dark() throws {
        let vc = StatusInfoViewSnapshotViewController(category: .basicStates)
        assertSnapshot(
            of: vc,
            as: .image(on: SnapshotTestConfig.device, size: SnapshotTestConfig.size, traits: SnapshotTestConfig.darkTraits),
            record: SnapshotTestConfig.record
        )
    }
}
