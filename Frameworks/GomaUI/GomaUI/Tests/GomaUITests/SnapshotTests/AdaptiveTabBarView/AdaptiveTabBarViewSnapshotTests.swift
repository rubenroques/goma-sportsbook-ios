import XCTest
import SnapshotTesting
@testable import GomaUI

final class AdaptiveTabBarViewSnapshotTests: XCTestCase {

    // TODO: Migrate component to `currentDisplayState + dropFirst()` or scheduler injection for synchronous rendering.

    // MARK: - Background Modes

    func testAdaptiveTabBarView_BackgroundModes_Light() throws {
        let vc = AdaptiveTabBarViewSnapshotViewController(category: .backgroundModes)
        SnapshotTestConfig.waitForCombineRendering(vc)
        assertSnapshot(
            of: vc,
            as: .image(on: SnapshotTestConfig.device, size: SnapshotTestConfig.size, traits: SnapshotTestConfig.lightTraits),
            record: SnapshotTestConfig.record
        )
    }

    func testAdaptiveTabBarView_BackgroundModes_Dark() throws {
        let vc = AdaptiveTabBarViewSnapshotViewController(category: .backgroundModes)
        SnapshotTestConfig.waitForCombineRendering(vc)
        assertSnapshot(
            of: vc,
            as: .image(on: SnapshotTestConfig.device, size: SnapshotTestConfig.size, traits: SnapshotTestConfig.darkTraits),
            record: SnapshotTestConfig.record
        )
    }
}
