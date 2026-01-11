import XCTest
import SnapshotTesting
@testable import GomaUI

final class ThemeSwitcherViewSnapshotTests: XCTestCase {

    // TODO: Migrate component to `currentDisplayState + dropFirst()` or scheduler injection for synchronous rendering.

    // MARK: - Theme States

    func testThemeSwitcherView_ThemeStates_Light() throws {
        let vc = ThemeSwitcherViewSnapshotViewController(category: .themeStates)
        SnapshotTestConfig.waitForCombineRendering(vc)
        assertSnapshot(
            of: vc,
            as: .image(on: SnapshotTestConfig.device, size: SnapshotTestConfig.size, traits: SnapshotTestConfig.lightTraits),
            record: SnapshotTestConfig.record
        )
    }

    func testThemeSwitcherView_ThemeStates_Dark() throws {
        let vc = ThemeSwitcherViewSnapshotViewController(category: .themeStates)
        SnapshotTestConfig.waitForCombineRendering(vc)
        assertSnapshot(
            of: vc,
            as: .image(on: SnapshotTestConfig.device, size: SnapshotTestConfig.size, traits: SnapshotTestConfig.darkTraits),
            record: SnapshotTestConfig.record
        )
    }
}
