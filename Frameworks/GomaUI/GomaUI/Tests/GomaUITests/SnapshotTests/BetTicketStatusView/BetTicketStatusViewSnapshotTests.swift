import XCTest
import SnapshotTesting
@testable import GomaUI

final class BetTicketStatusViewSnapshotTests: XCTestCase {

    // TODO: Migrate component to `currentDisplayState + dropFirst()` or scheduler injection for synchronous rendering.

    // MARK: - Status States

    func testBetTicketStatusView_StatusStates_Light() throws {
        let vc = BetTicketStatusViewSnapshotViewController(category: .statusStates)
        SnapshotTestConfig.waitForCombineRendering(vc)
        assertSnapshot(
            of: vc,
            as: .image(on: SnapshotTestConfig.device, size: SnapshotTestConfig.size, traits: SnapshotTestConfig.lightTraits),
            record: SnapshotTestConfig.record
        )
    }

    func testBetTicketStatusView_StatusStates_Dark() throws {
        let vc = BetTicketStatusViewSnapshotViewController(category: .statusStates)
        SnapshotTestConfig.waitForCombineRendering(vc)
        assertSnapshot(
            of: vc,
            as: .image(on: SnapshotTestConfig.device, size: SnapshotTestConfig.size, traits: SnapshotTestConfig.darkTraits),
            record: SnapshotTestConfig.record
        )
    }
}
