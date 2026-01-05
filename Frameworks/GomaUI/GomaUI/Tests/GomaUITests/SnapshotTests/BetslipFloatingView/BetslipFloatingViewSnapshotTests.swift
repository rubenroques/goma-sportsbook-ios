import XCTest
import SnapshotTesting
@testable import GomaUI

final class BetslipFloatingViewSnapshotTests: XCTestCase {

    // MARK: - Component States

    func testBetslipFloatingView_States_Light() throws {
        let vc = BetslipFloatingViewSnapshotViewController(category: .states)
        assertSnapshot(
            of: vc,
            as: .image(on: SnapshotTestConfig.device, size: SnapshotTestConfig.size, traits: SnapshotTestConfig.lightTraits),
            record: SnapshotTestConfig.record
        )
    }

    func testBetslipFloatingView_States_Dark() throws {
        let vc = BetslipFloatingViewSnapshotViewController(category: .states)
        assertSnapshot(
            of: vc,
            as: .image(on: SnapshotTestConfig.device, size: SnapshotTestConfig.size, traits: SnapshotTestConfig.darkTraits),
            record: SnapshotTestConfig.record
        )
    }
}
