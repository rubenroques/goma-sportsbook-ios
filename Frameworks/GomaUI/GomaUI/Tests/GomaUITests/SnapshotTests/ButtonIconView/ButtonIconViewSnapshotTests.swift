import XCTest
import SnapshotTesting
@testable import GomaUI

final class ButtonIconViewSnapshotTests: XCTestCase {

    // MARK: - Basic States

    func testButtonIconView_BasicStates_Light() throws {
        let vc = ButtonIconViewSnapshotViewController(category: .basicStates)
        assertSnapshot(of: vc, as: .image(on: SnapshotTestConfig.device, size: SnapshotTestConfig.size, traits: SnapshotTestConfig.lightTraits), record: SnapshotTestConfig.record)
    }

    func testButtonIconView_BasicStates_Dark() throws {
        let vc = ButtonIconViewSnapshotViewController(category: .basicStates)
        assertSnapshot(of: vc, as: .image(on: SnapshotTestConfig.device, size: SnapshotTestConfig.size, traits: SnapshotTestConfig.darkTraits), record: SnapshotTestConfig.record)
    }

    // MARK: - Layout Variants

    func testButtonIconView_LayoutVariants_Light() throws {
        let vc = ButtonIconViewSnapshotViewController(category: .layoutVariants)
        assertSnapshot(of: vc, as: .image(on: SnapshotTestConfig.device, size: SnapshotTestConfig.size, traits: SnapshotTestConfig.lightTraits), record: SnapshotTestConfig.record)
    }

    func testButtonIconView_LayoutVariants_Dark() throws {
        let vc = ButtonIconViewSnapshotViewController(category: .layoutVariants)
        assertSnapshot(of: vc, as: .image(on: SnapshotTestConfig.device, size: SnapshotTestConfig.size, traits: SnapshotTestConfig.darkTraits), record: SnapshotTestConfig.record)
    }

    // MARK: - Style Variants

    func testButtonIconView_StyleVariants_Light() throws {
        let vc = ButtonIconViewSnapshotViewController(category: .styleVariants)
        assertSnapshot(of: vc, as: .image(on: SnapshotTestConfig.device, size: SnapshotTestConfig.size, traits: SnapshotTestConfig.lightTraits), record: SnapshotTestConfig.record)
    }

    func testButtonIconView_StyleVariants_Dark() throws {
        let vc = ButtonIconViewSnapshotViewController(category: .styleVariants)
        assertSnapshot(of: vc, as: .image(on: SnapshotTestConfig.device, size: SnapshotTestConfig.size, traits: SnapshotTestConfig.darkTraits), record: SnapshotTestConfig.record)
    }
}
