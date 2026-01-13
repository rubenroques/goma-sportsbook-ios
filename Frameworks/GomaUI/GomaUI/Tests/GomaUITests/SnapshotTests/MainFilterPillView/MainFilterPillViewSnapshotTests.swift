import XCTest
import SnapshotTesting
@testable import GomaUI

final class MainFilterPillViewSnapshotTests: XCTestCase {

    // MainFilterPillViewModel uses CurrentValueSubject which delivers initial value synchronously.
    // No RunLoop workaround needed.

    // MARK: - Selection States

    func testMainFilterPillView_SelectionStates_Light() throws {
        let vc = MainFilterPillViewSnapshotViewController(category: .selectionStates)
        assertSnapshot(
            of: vc,
            as: .image(on: SnapshotTestConfig.device, size: SnapshotTestConfig.size, traits: SnapshotTestConfig.lightTraits),
            record: SnapshotTestConfig.record
        )
    }

    func testMainFilterPillView_SelectionStates_Dark() throws {
        let vc = MainFilterPillViewSnapshotViewController(category: .selectionStates)
        assertSnapshot(
            of: vc,
            as: .image(on: SnapshotTestConfig.device, size: SnapshotTestConfig.size, traits: SnapshotTestConfig.darkTraits),
            record: SnapshotTestConfig.record
        )
    }

    // MARK: - Counter Variants

    func testMainFilterPillView_CounterVariants_Light() throws {
        let vc = MainFilterPillViewSnapshotViewController(category: .counterVariants)
        assertSnapshot(
            of: vc,
            as: .image(on: SnapshotTestConfig.device, size: SnapshotTestConfig.size, traits: SnapshotTestConfig.lightTraits),
            record: SnapshotTestConfig.record
        )
    }

    func testMainFilterPillView_CounterVariants_Dark() throws {
        let vc = MainFilterPillViewSnapshotViewController(category: .counterVariants)
        assertSnapshot(
            of: vc,
            as: .image(on: SnapshotTestConfig.device, size: SnapshotTestConfig.size, traits: SnapshotTestConfig.darkTraits),
            record: SnapshotTestConfig.record
        )
    }
}
