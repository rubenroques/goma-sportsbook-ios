import XCTest
import SnapshotTesting
@testable import GomaUI

final class CasinoGameImageGridSectionViewSnapshotTests: XCTestCase {

    // MARK: - Basic States

    func testCasinoGameImageGridSectionView_BasicStates_Light() throws {
        let vc = CasinoGameImageGridSectionViewSnapshotViewController(category: .basicStates)
        assertSnapshot(
            of: vc,
            as: .image(on: SnapshotTestConfig.device, size: SnapshotTestConfig.size, traits: SnapshotTestConfig.lightTraits),
            record: SnapshotTestConfig.record
        )
    }

    func testCasinoGameImageGridSectionView_BasicStates_Dark() throws {
        let vc = CasinoGameImageGridSectionViewSnapshotViewController(category: .basicStates)
        assertSnapshot(
            of: vc,
            as: .image(on: SnapshotTestConfig.device, size: SnapshotTestConfig.size, traits: SnapshotTestConfig.darkTraits),
            record: SnapshotTestConfig.record
        )
    }

    // MARK: - Content Variants

    func testCasinoGameImageGridSectionView_ContentVariants_Light() throws {
        let vc = CasinoGameImageGridSectionViewSnapshotViewController(category: .contentVariants)
        assertSnapshot(
            of: vc,
            as: .image(on: SnapshotTestConfig.device, size: SnapshotTestConfig.size, traits: SnapshotTestConfig.lightTraits),
            record: SnapshotTestConfig.record
        )
    }

    func testCasinoGameImageGridSectionView_ContentVariants_Dark() throws {
        let vc = CasinoGameImageGridSectionViewSnapshotViewController(category: .contentVariants)
        assertSnapshot(
            of: vc,
            as: .image(on: SnapshotTestConfig.device, size: SnapshotTestConfig.size, traits: SnapshotTestConfig.darkTraits),
            record: SnapshotTestConfig.record
        )
    }
}
