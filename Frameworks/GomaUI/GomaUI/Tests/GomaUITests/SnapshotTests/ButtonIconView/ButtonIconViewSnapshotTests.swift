import XCTest
import SnapshotTesting
@testable import GomaUI

final class ButtonIconViewSnapshotTests: XCTestCase {

    // TODO: Migrate component to `currentDisplayState + dropFirst()` or scheduler injection for synchronous rendering.

    // MARK: - Basic States

    func testButtonIconView_BasicStates_Light() throws {
        let vc = ButtonIconViewSnapshotViewController(category: .basicStates)
        SnapshotTestConfig.waitForCombineRendering(vc)
        assertSnapshot(of: vc, as: .image(on: SnapshotTestConfig.device, size: SnapshotTestConfig.size, traits: SnapshotTestConfig.lightTraits), record: SnapshotTestConfig.record)
    }

    func testButtonIconView_BasicStates_Dark() throws {
        let vc = ButtonIconViewSnapshotViewController(category: .basicStates)
        SnapshotTestConfig.waitForCombineRendering(vc)
        assertSnapshot(of: vc, as: .image(on: SnapshotTestConfig.device, size: SnapshotTestConfig.size, traits: SnapshotTestConfig.darkTraits), record: SnapshotTestConfig.record)
    }

    // MARK: - Layout Variants

    func testButtonIconView_LayoutVariants_Light() throws {
        let vc = ButtonIconViewSnapshotViewController(category: .layoutVariants)
        SnapshotTestConfig.waitForCombineRendering(vc)
        assertSnapshot(of: vc, as: .image(on: SnapshotTestConfig.device, size: SnapshotTestConfig.size, traits: SnapshotTestConfig.lightTraits), record: SnapshotTestConfig.record)
    }

    func testButtonIconView_LayoutVariants_Dark() throws {
        let vc = ButtonIconViewSnapshotViewController(category: .layoutVariants)
        SnapshotTestConfig.waitForCombineRendering(vc)
        assertSnapshot(of: vc, as: .image(on: SnapshotTestConfig.device, size: SnapshotTestConfig.size, traits: SnapshotTestConfig.darkTraits), record: SnapshotTestConfig.record)
    }

    // MARK: - Style Variants

    func testButtonIconView_StyleVariants_Light() throws {
        let vc = ButtonIconViewSnapshotViewController(category: .styleVariants)
        SnapshotTestConfig.waitForCombineRendering(vc)
        assertSnapshot(of: vc, as: .image(on: SnapshotTestConfig.device, size: SnapshotTestConfig.size, traits: SnapshotTestConfig.lightTraits), record: SnapshotTestConfig.record)
    }

    func testButtonIconView_StyleVariants_Dark() throws {
        let vc = ButtonIconViewSnapshotViewController(category: .styleVariants)
        SnapshotTestConfig.waitForCombineRendering(vc)
        assertSnapshot(of: vc, as: .image(on: SnapshotTestConfig.device, size: SnapshotTestConfig.size, traits: SnapshotTestConfig.darkTraits), record: SnapshotTestConfig.record)
    }
}
