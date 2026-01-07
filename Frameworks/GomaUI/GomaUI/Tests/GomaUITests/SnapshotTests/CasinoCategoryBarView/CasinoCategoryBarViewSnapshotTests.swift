import XCTest
import SnapshotTesting
@testable import GomaUI

final class CasinoCategoryBarViewSnapshotTests: XCTestCase {

    // MARK: - Basic States

    func testCasinoCategoryBarView_BasicStates_Light() throws {
        let vc = CasinoCategoryBarViewSnapshotViewController(category: .basicStates)
        assertSnapshot(of: vc, as: .image(on: SnapshotTestConfig.device, size: SnapshotTestConfig.size, traits: SnapshotTestConfig.lightTraits), record: SnapshotTestConfig.record)
    }

    func testCasinoCategoryBarView_BasicStates_Dark() throws {
        let vc = CasinoCategoryBarViewSnapshotViewController(category: .basicStates)
        assertSnapshot(of: vc, as: .image(on: SnapshotTestConfig.device, size: SnapshotTestConfig.size, traits: SnapshotTestConfig.darkTraits), record: SnapshotTestConfig.record)
    }

    // MARK: - Category Variants

    func testCasinoCategoryBarView_CategoryVariants_Light() throws {
        let vc = CasinoCategoryBarViewSnapshotViewController(category: .categoryVariants)
        assertSnapshot(of: vc, as: .image(on: SnapshotTestConfig.device, size: SnapshotTestConfig.size, traits: SnapshotTestConfig.lightTraits), record: SnapshotTestConfig.record)
    }

    func testCasinoCategoryBarView_CategoryVariants_Dark() throws {
        let vc = CasinoCategoryBarViewSnapshotViewController(category: .categoryVariants)
        assertSnapshot(of: vc, as: .image(on: SnapshotTestConfig.device, size: SnapshotTestConfig.size, traits: SnapshotTestConfig.darkTraits), record: SnapshotTestConfig.record)
    }
}
