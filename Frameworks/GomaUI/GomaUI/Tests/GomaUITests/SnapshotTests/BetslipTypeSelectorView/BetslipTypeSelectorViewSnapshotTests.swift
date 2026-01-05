import XCTest
import SnapshotTesting
@testable import GomaUI

final class BetslipTypeSelectorViewSnapshotTests: XCTestCase {

    // MARK: - Selection States

    func testBetslipTypeSelectorView_SelectionStates_Light() throws {
        let vc = BetslipTypeSelectorViewSnapshotViewController(category: .selectionStates)
        assertSnapshot(
            of: vc,
            as: .image(on: SnapshotTestConfig.device, size: SnapshotTestConfig.size, traits: SnapshotTestConfig.lightTraits),
            record: SnapshotTestConfig.record
        )
    }

    func testBetslipTypeSelectorView_SelectionStates_Dark() throws {
        let vc = BetslipTypeSelectorViewSnapshotViewController(category: .selectionStates)
        assertSnapshot(
            of: vc,
            as: .image(on: SnapshotTestConfig.device, size: SnapshotTestConfig.size, traits: SnapshotTestConfig.darkTraits),
            record: SnapshotTestConfig.record
        )
    }
}
