import XCTest
import SnapshotTesting
@testable import GomaUI

final class ListBlockViewSnapshotTests: XCTestCase {

    // ListBlockView renders synchronously with viewModel data.
    // No RunLoop workaround needed.

    // MARK: - Icon Variants

    func testListBlockView_IconVariants_Light() throws {
        let vc = ListBlockViewSnapshotViewController(category: .iconVariants)
        assertSnapshot(of: vc, as: .image(on: SnapshotTestConfig.device, size: SnapshotTestConfig.size, traits: SnapshotTestConfig.lightTraits), record: SnapshotTestConfig.record)
    }

    func testListBlockView_IconVariants_Dark() throws {
        let vc = ListBlockViewSnapshotViewController(category: .iconVariants)
        assertSnapshot(of: vc, as: .image(on: SnapshotTestConfig.device, size: SnapshotTestConfig.size, traits: SnapshotTestConfig.darkTraits), record: SnapshotTestConfig.record)
    }

    // MARK: - Content Variants

    func testListBlockView_ContentVariants_Light() throws {
        let vc = ListBlockViewSnapshotViewController(category: .contentVariants)
        assertSnapshot(of: vc, as: .image(on: SnapshotTestConfig.device, size: SnapshotTestConfig.size, traits: SnapshotTestConfig.lightTraits), record: SnapshotTestConfig.record)
    }

    func testListBlockView_ContentVariants_Dark() throws {
        let vc = ListBlockViewSnapshotViewController(category: .contentVariants)
        assertSnapshot(of: vc, as: .image(on: SnapshotTestConfig.device, size: SnapshotTestConfig.size, traits: SnapshotTestConfig.darkTraits), record: SnapshotTestConfig.record)
    }
}
