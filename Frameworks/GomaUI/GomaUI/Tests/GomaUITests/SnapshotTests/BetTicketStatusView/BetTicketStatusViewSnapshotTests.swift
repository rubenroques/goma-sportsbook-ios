import XCTest
import SnapshotTesting
@testable import GomaUI

final class BetTicketStatusViewSnapshotTests: XCTestCase {

    // MARK: - Status States

    func testBetTicketStatusView_StatusStates_Light() throws {
        let vc = BetTicketStatusViewSnapshotViewController(category: .statusStates)
        assertSnapshot(
            of: vc,
            as: .image(on: SnapshotTestConfig.device, size: SnapshotTestConfig.size, traits: SnapshotTestConfig.lightTraits),
            record: SnapshotTestConfig.record
        )
    }

    func testBetTicketStatusView_StatusStates_Dark() throws {
        let vc = BetTicketStatusViewSnapshotViewController(category: .statusStates)
        assertSnapshot(
            of: vc,
            as: .image(on: SnapshotTestConfig.device, size: SnapshotTestConfig.size, traits: SnapshotTestConfig.darkTraits),
            record: SnapshotTestConfig.record
        )
    }
}
