import XCTest
import SnapshotTesting
@testable import GomaUI

final class AmountPillViewSnapshotTests: XCTestCase {

    // MARK: - Selection States

    func testAmountPillView_SelectionStates_Light() throws {
        let vc = AmountPillViewSnapshotViewController(category: .selectionStates)
        assertSnapshot(
            of: vc,
            as: .image(on: SnapshotTestConfig.device, size: SnapshotTestConfig.size, traits: SnapshotTestConfig.lightTraits),
            record: SnapshotTestConfig.record
        )
    }

    func testAmountPillView_SelectionStates_Dark() throws {
        let vc = AmountPillViewSnapshotViewController(category: .selectionStates)
        assertSnapshot(
            of: vc,
            as: .image(on: SnapshotTestConfig.device, size: SnapshotTestConfig.size, traits: SnapshotTestConfig.darkTraits),
            record: SnapshotTestConfig.record
        )
    }

    // MARK: - Content Variants

    func testAmountPillView_ContentVariants_Light() throws {
        let vc = AmountPillViewSnapshotViewController(category: .contentVariants)
        assertSnapshot(
            of: vc,
            as: .image(on: SnapshotTestConfig.device, size: SnapshotTestConfig.size, traits: SnapshotTestConfig.lightTraits),
            record: SnapshotTestConfig.record
        )
    }

    func testAmountPillView_ContentVariants_Dark() throws {
        let vc = AmountPillViewSnapshotViewController(category: .contentVariants)
        assertSnapshot(
            of: vc,
            as: .image(on: SnapshotTestConfig.device, size: SnapshotTestConfig.size, traits: SnapshotTestConfig.darkTraits),
            record: SnapshotTestConfig.record
        )
    }
}
