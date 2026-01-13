import XCTest
import SnapshotTesting
@testable import GomaUI

final class StackViewBlockViewSnapshotTests: XCTestCase {

    // StackViewBlockView renders synchronously - no RunLoop workaround needed.

    // MARK: - Default Configuration

    func testStackViewBlockView_DefaultConfiguration_Light() throws {
        let vc = StackViewBlockViewSnapshotViewController(category: .defaultConfiguration)
        assertSnapshot(
            of: vc,
            as: .image(on: SnapshotTestConfig.device, size: SnapshotTestConfig.size, traits: SnapshotTestConfig.lightTraits),
            record: SnapshotTestConfig.record
        )
    }

    func testStackViewBlockView_DefaultConfiguration_Dark() throws {
        let vc = StackViewBlockViewSnapshotViewController(category: .defaultConfiguration)
        assertSnapshot(
            of: vc,
            as: .image(on: SnapshotTestConfig.device, size: SnapshotTestConfig.size, traits: SnapshotTestConfig.darkTraits),
            record: SnapshotTestConfig.record
        )
    }

    // MARK: - Content Variants

    func testStackViewBlockView_ContentVariants_Light() throws {
        let vc = StackViewBlockViewSnapshotViewController(category: .contentVariants)
        assertSnapshot(
            of: vc,
            as: .image(on: SnapshotTestConfig.device, size: SnapshotTestConfig.size, traits: SnapshotTestConfig.lightTraits),
            record: SnapshotTestConfig.record
        )
    }

    func testStackViewBlockView_ContentVariants_Dark() throws {
        let vc = StackViewBlockViewSnapshotViewController(category: .contentVariants)
        assertSnapshot(
            of: vc,
            as: .image(on: SnapshotTestConfig.device, size: SnapshotTestConfig.size, traits: SnapshotTestConfig.darkTraits),
            record: SnapshotTestConfig.record
        )
    }

    // MARK: - Item Count Variants

    func testStackViewBlockView_ItemCountVariants_Light() throws {
        let vc = StackViewBlockViewSnapshotViewController(category: .itemCountVariants)
        assertSnapshot(
            of: vc,
            as: .image(on: SnapshotTestConfig.device, size: SnapshotTestConfig.size, traits: SnapshotTestConfig.lightTraits),
            record: SnapshotTestConfig.record
        )
    }

    func testStackViewBlockView_ItemCountVariants_Dark() throws {
        let vc = StackViewBlockViewSnapshotViewController(category: .itemCountVariants)
        assertSnapshot(
            of: vc,
            as: .image(on: SnapshotTestConfig.device, size: SnapshotTestConfig.size, traits: SnapshotTestConfig.darkTraits),
            record: SnapshotTestConfig.record
        )
    }
}
