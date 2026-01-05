import XCTest
import SnapshotTesting
@testable import GomaUI

final class BetslipHeaderViewSnapshotTests: XCTestCase {

    // MARK: - Authentication States

    func testBetslipHeaderView_AuthStates_Light() throws {
        let vc = BetslipHeaderViewSnapshotViewController(category: .authStates)
        assertSnapshot(
            of: vc,
            as: .image(on: SnapshotTestConfig.device, size: SnapshotTestConfig.size, traits: SnapshotTestConfig.lightTraits),
            record: SnapshotTestConfig.record
        )
    }

    func testBetslipHeaderView_AuthStates_Dark() throws {
        let vc = BetslipHeaderViewSnapshotViewController(category: .authStates)
        assertSnapshot(
            of: vc,
            as: .image(on: SnapshotTestConfig.device, size: SnapshotTestConfig.size, traits: SnapshotTestConfig.darkTraits),
            record: SnapshotTestConfig.record
        )
    }
}
