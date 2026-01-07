import XCTest
import SnapshotTesting
@testable import GomaUI

final class AmountPillsViewSnapshotTests: XCTestCase {

    // MARK: - Selection States

    func testAmountPillsView_SelectionStates_Light() throws {
        let vc = AmountPillsViewSnapshotViewController(category: .selectionStates)
        assertSnapshot(
            of: vc,
            as: .image(on: SnapshotTestConfig.device, size: SnapshotTestConfig.size, traits: SnapshotTestConfig.lightTraits),
            record: SnapshotTestConfig.record
        )
    }

    func testAmountPillsView_SelectionStates_Dark() throws {
        let vc = AmountPillsViewSnapshotViewController(category: .selectionStates)
        assertSnapshot(
            of: vc,
            as: .image(on: SnapshotTestConfig.device, size: SnapshotTestConfig.size, traits: SnapshotTestConfig.darkTraits),
            record: SnapshotTestConfig.record
        )
    }

    // MARK: - Pill Counts

    func testAmountPillsView_PillCounts_Light() throws {
        let vc = AmountPillsViewSnapshotViewController(category: .pillCounts)
        assertSnapshot(
            of: vc,
            as: .image(on: SnapshotTestConfig.device, size: SnapshotTestConfig.size, traits: SnapshotTestConfig.lightTraits),
            record: SnapshotTestConfig.record
        )
    }

    func testAmountPillsView_PillCounts_Dark() throws {
        let vc = AmountPillsViewSnapshotViewController(category: .pillCounts)
        assertSnapshot(
            of: vc,
            as: .image(on: SnapshotTestConfig.device, size: SnapshotTestConfig.size, traits: SnapshotTestConfig.darkTraits),
            record: SnapshotTestConfig.record
        )
    }
}
