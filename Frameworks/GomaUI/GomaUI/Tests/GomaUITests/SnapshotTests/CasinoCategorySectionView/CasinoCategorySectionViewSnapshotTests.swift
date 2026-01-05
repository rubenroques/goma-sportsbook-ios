import XCTest
import SnapshotTesting
@testable import GomaUI

final class CasinoCategorySectionViewSnapshotTests: XCTestCase {

    // MARK: - Basic States

    func testCasinoCategorySectionView_BasicStates_Light() throws {
        let vc = CasinoCategorySectionViewSnapshotViewController(category: .basicStates)
        assertSnapshot(of: vc, as: .image(on: SnapshotTestConfig.device, size: SnapshotTestConfig.size, traits: SnapshotTestConfig.lightTraits), record: SnapshotTestConfig.record)
    }

    func testCasinoCategorySectionView_BasicStates_Dark() throws {
        let vc = CasinoCategorySectionViewSnapshotViewController(category: .basicStates)
        assertSnapshot(of: vc, as: .image(on: SnapshotTestConfig.device, size: SnapshotTestConfig.size, traits: SnapshotTestConfig.darkTraits), record: SnapshotTestConfig.record)
    }

    // MARK: - Content Variants

    func testCasinoCategorySectionView_ContentVariants_Light() throws {
        let vc = CasinoCategorySectionViewSnapshotViewController(category: .contentVariants)
        assertSnapshot(of: vc, as: .image(on: SnapshotTestConfig.device, size: SnapshotTestConfig.size, traits: SnapshotTestConfig.lightTraits), record: SnapshotTestConfig.record)
    }

    func testCasinoCategorySectionView_ContentVariants_Dark() throws {
        let vc = CasinoCategorySectionViewSnapshotViewController(category: .contentVariants)
        assertSnapshot(of: vc, as: .image(on: SnapshotTestConfig.device, size: SnapshotTestConfig.size, traits: SnapshotTestConfig.darkTraits), record: SnapshotTestConfig.record)
    }
}
