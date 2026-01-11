import XCTest
import SnapshotTesting
@testable import GomaUI

final class BetslipOddsBoostHeaderViewSnapshotTests: XCTestCase {

    // TODO: Migrate component to `currentDisplayState + dropFirst()` or scheduler injection for synchronous rendering.

    // MARK: - Boost States

    func testBetslipOddsBoostHeaderView_BoostStates_Light() throws {
        let vc = BetslipOddsBoostHeaderViewSnapshotViewController(category: .boostStates)
        SnapshotTestConfig.waitForCombineRendering(vc)
        assertSnapshot(
            of: vc,
            as: .image(on: SnapshotTestConfig.device, size: SnapshotTestConfig.size, traits: SnapshotTestConfig.lightTraits),
            record: SnapshotTestConfig.record
        )
    }

    func testBetslipOddsBoostHeaderView_BoostStates_Dark() throws {
        let vc = BetslipOddsBoostHeaderViewSnapshotViewController(category: .boostStates)
        SnapshotTestConfig.waitForCombineRendering(vc)
        assertSnapshot(
            of: vc,
            as: .image(on: SnapshotTestConfig.device, size: SnapshotTestConfig.size, traits: SnapshotTestConfig.darkTraits),
            record: SnapshotTestConfig.record
        )
    }
}
