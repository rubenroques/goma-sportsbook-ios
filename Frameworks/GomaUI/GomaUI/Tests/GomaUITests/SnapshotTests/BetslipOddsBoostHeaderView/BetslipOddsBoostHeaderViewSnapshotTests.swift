import XCTest
import SnapshotTesting
@testable import GomaUI

final class BetslipOddsBoostHeaderViewSnapshotTests: XCTestCase {

    // MARK: - Boost States

    func testBetslipOddsBoostHeaderView_BoostStates_Light() throws {
        let vc = BetslipOddsBoostHeaderViewSnapshotViewController(category: .boostStates)
        assertSnapshot(
            of: vc,
            as: .image(on: SnapshotTestConfig.device, size: SnapshotTestConfig.size, traits: SnapshotTestConfig.lightTraits),
            record: SnapshotTestConfig.record
        )
    }

    func testBetslipOddsBoostHeaderView_BoostStates_Dark() throws {
        let vc = BetslipOddsBoostHeaderViewSnapshotViewController(category: .boostStates)
        assertSnapshot(
            of: vc,
            as: .image(on: SnapshotTestConfig.device, size: SnapshotTestConfig.size, traits: SnapshotTestConfig.darkTraits),
            record: SnapshotTestConfig.record
        )
    }
}
