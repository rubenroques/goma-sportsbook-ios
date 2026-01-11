import XCTest
import SnapshotTesting
@testable import GomaUI

final class QuickLinksTabBarSnapshotTests: XCTestCase {

    // TODO: Migrate component to `currentDisplayState + dropFirst()` or scheduler injection for synchronous rendering.

    // MARK: - Link Types

    func testQuickLinksTabBar_LinkTypes_Light() throws {
        let vc = QuickLinksTabBarSnapshotViewController(category: .linkTypes)
        SnapshotTestConfig.waitForCombineRendering(vc)
        assertSnapshot(
            of: vc,
            as: .image(on: SnapshotTestConfig.device, size: SnapshotTestConfig.size, traits: SnapshotTestConfig.lightTraits),
            record: SnapshotTestConfig.record
        )
    }

    func testQuickLinksTabBar_LinkTypes_Dark() throws {
        let vc = QuickLinksTabBarSnapshotViewController(category: .linkTypes)
        SnapshotTestConfig.waitForCombineRendering(vc)
        assertSnapshot(
            of: vc,
            as: .image(on: SnapshotTestConfig.device, size: SnapshotTestConfig.size, traits: SnapshotTestConfig.darkTraits),
            record: SnapshotTestConfig.record
        )
    }
}
