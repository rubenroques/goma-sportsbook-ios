import XCTest
import SnapshotTesting
@testable import GomaUI

final class BetInfoSubmissionViewSnapshotTests: XCTestCase {

    // MARK: - Component States

    func testBetInfoSubmissionView_States_Light() throws {
        let vc = BetInfoSubmissionViewSnapshotViewController(category: .states)
        assertSnapshot(
            of: vc,
            as: .image(on: SnapshotTestConfig.device, size: SnapshotTestConfig.size, traits: SnapshotTestConfig.lightTraits),
            record: SnapshotTestConfig.record
        )
    }

    func testBetInfoSubmissionView_States_Dark() throws {
        let vc = BetInfoSubmissionViewSnapshotViewController(category: .states)
        assertSnapshot(
            of: vc,
            as: .image(on: SnapshotTestConfig.device, size: SnapshotTestConfig.size, traits: SnapshotTestConfig.darkTraits),
            record: SnapshotTestConfig.record
        )
    }
}
