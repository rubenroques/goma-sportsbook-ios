import XCTest
import SnapshotTesting
@testable import GomaUI

final class BulletItemBlockViewSnapshotTests: XCTestCase {

    // MARK: - Basic States

    func testBulletItemBlockView_BasicStates_Light() throws {
        let vc = BulletItemBlockViewSnapshotViewController(category: .basicStates)
        assertSnapshot(of: vc, as: .image(on: SnapshotTestConfig.device, size: SnapshotTestConfig.size, traits: SnapshotTestConfig.lightTraits), record: SnapshotTestConfig.record)
    }

    func testBulletItemBlockView_BasicStates_Dark() throws {
        let vc = BulletItemBlockViewSnapshotViewController(category: .basicStates)
        assertSnapshot(of: vc, as: .image(on: SnapshotTestConfig.device, size: SnapshotTestConfig.size, traits: SnapshotTestConfig.darkTraits), record: SnapshotTestConfig.record)
    }

    // MARK: - Content Variants

    func testBulletItemBlockView_ContentVariants_Light() throws {
        let vc = BulletItemBlockViewSnapshotViewController(category: .contentVariants)
        assertSnapshot(of: vc, as: .image(on: SnapshotTestConfig.device, size: SnapshotTestConfig.size, traits: SnapshotTestConfig.lightTraits), record: SnapshotTestConfig.record)
    }

    func testBulletItemBlockView_ContentVariants_Dark() throws {
        let vc = BulletItemBlockViewSnapshotViewController(category: .contentVariants)
        assertSnapshot(of: vc, as: .image(on: SnapshotTestConfig.device, size: SnapshotTestConfig.size, traits: SnapshotTestConfig.darkTraits), record: SnapshotTestConfig.record)
    }
}
