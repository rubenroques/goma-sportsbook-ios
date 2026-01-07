import XCTest
import SnapshotTesting
@testable import GomaUI

final class BetDetailResultSummaryViewSnapshotTests: XCTestCase {

    // MARK: - Result States

    func testBetDetailResultSummaryView_ResultStates_Light() throws {
        let vc = BetDetailResultSummaryViewSnapshotViewController(category: .resultStates)
        assertSnapshot(
            of: vc,
            as: .image(on: SnapshotTestConfig.device, size: SnapshotTestConfig.size, traits: SnapshotTestConfig.lightTraits),
            record: SnapshotTestConfig.record
        )
    }

    func testBetDetailResultSummaryView_ResultStates_Dark() throws {
        let vc = BetDetailResultSummaryViewSnapshotViewController(category: .resultStates)
        assertSnapshot(
            of: vc,
            as: .image(on: SnapshotTestConfig.device, size: SnapshotTestConfig.size, traits: SnapshotTestConfig.darkTraits),
            record: SnapshotTestConfig.record
        )
    }
}
