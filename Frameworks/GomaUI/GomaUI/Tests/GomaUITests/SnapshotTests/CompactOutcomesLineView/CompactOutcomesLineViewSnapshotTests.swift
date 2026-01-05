import XCTest
import SnapshotTesting
@testable import GomaUI

final class CompactOutcomesLineViewSnapshotTests: XCTestCase {

    // MARK: - Basic States

    func testCompactOutcomesLineView_BasicStates_Light() throws {
        let vc = CompactOutcomesLineViewSnapshotViewController(category: .basicStates)
        assertSnapshot(
            of: vc,
            as: .image(on: SnapshotTestConfig.device, size: SnapshotTestConfig.size, traits: SnapshotTestConfig.lightTraits),
            record: SnapshotTestConfig.record
        )
    }

    func testCompactOutcomesLineView_BasicStates_Dark() throws {
        let vc = CompactOutcomesLineViewSnapshotViewController(category: .basicStates)
        assertSnapshot(
            of: vc,
            as: .image(on: SnapshotTestConfig.device, size: SnapshotTestConfig.size, traits: SnapshotTestConfig.darkTraits),
            record: SnapshotTestConfig.record
        )
    }

    // MARK: - Special States

    func testCompactOutcomesLineView_SpecialStates_Light() throws {
        let vc = CompactOutcomesLineViewSnapshotViewController(category: .specialStates)
        assertSnapshot(
            of: vc,
            as: .image(on: SnapshotTestConfig.device, size: SnapshotTestConfig.size, traits: SnapshotTestConfig.lightTraits),
            record: SnapshotTestConfig.record
        )
    }

    func testCompactOutcomesLineView_SpecialStates_Dark() throws {
        let vc = CompactOutcomesLineViewSnapshotViewController(category: .specialStates)
        assertSnapshot(
            of: vc,
            as: .image(on: SnapshotTestConfig.device, size: SnapshotTestConfig.size, traits: SnapshotTestConfig.darkTraits),
            record: SnapshotTestConfig.record
        )
    }
}
