import XCTest
import SnapshotTesting
@testable import GomaUI

final class BetslipHeaderViewSnapshotTests: XCTestCase {

    // TODO: Migrate component to `currentDisplayState + dropFirst()` or scheduler injection for synchronous rendering.

    // MARK: - Authentication States

    func testBetslipHeaderView_AuthStates_Light() throws {
        let vc = BetslipHeaderViewSnapshotViewController(category: .authStates)
        SnapshotTestConfig.waitForCombineRendering(vc)
        assertSnapshot(
            of: vc,
            as: .image(on: SnapshotTestConfig.device, size: SnapshotTestConfig.size, traits: SnapshotTestConfig.lightTraits),
            record: SnapshotTestConfig.record
        )
    }

    func testBetslipHeaderView_AuthStates_Dark() throws {
        let vc = BetslipHeaderViewSnapshotViewController(category: .authStates)
        SnapshotTestConfig.waitForCombineRendering(vc)
        assertSnapshot(
            of: vc,
            as: .image(on: SnapshotTestConfig.device, size: SnapshotTestConfig.size, traits: SnapshotTestConfig.darkTraits),
            record: SnapshotTestConfig.record
        )
    }
}
