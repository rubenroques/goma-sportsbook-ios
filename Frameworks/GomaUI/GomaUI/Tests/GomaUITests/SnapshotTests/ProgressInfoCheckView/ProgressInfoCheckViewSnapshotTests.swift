import XCTest
import SnapshotTesting
@testable import GomaUI

final class ProgressInfoCheckViewSnapshotTests: XCTestCase {

    // TODO: Migrate component to `currentDisplayState + dropFirst()` or scheduler injection for synchronous rendering.

    // MARK: - Progress States

    func testProgressInfoCheckView_ProgressStates_Light() throws {
        let vc = ProgressInfoCheckViewSnapshotViewController(category: .progressStates)
        SnapshotTestConfig.waitForCombineRendering(vc)
        assertSnapshot(
            of: vc,
            as: .image(on: SnapshotTestConfig.device, size: SnapshotTestConfig.size, traits: SnapshotTestConfig.lightTraits),
            record: SnapshotTestConfig.record
        )
    }

    func testProgressInfoCheckView_ProgressStates_Dark() throws {
        let vc = ProgressInfoCheckViewSnapshotViewController(category: .progressStates)
        SnapshotTestConfig.waitForCombineRendering(vc)
        assertSnapshot(
            of: vc,
            as: .image(on: SnapshotTestConfig.device, size: SnapshotTestConfig.size, traits: SnapshotTestConfig.darkTraits),
            record: SnapshotTestConfig.record
        )
    }

    // MARK: - Enabled States

    func testProgressInfoCheckView_EnabledStates_Light() throws {
        let vc = ProgressInfoCheckViewSnapshotViewController(category: .enabledStates)
        SnapshotTestConfig.waitForCombineRendering(vc)
        assertSnapshot(
            of: vc,
            as: .image(on: SnapshotTestConfig.device, size: SnapshotTestConfig.size, traits: SnapshotTestConfig.lightTraits),
            record: SnapshotTestConfig.record
        )
    }

    func testProgressInfoCheckView_EnabledStates_Dark() throws {
        let vc = ProgressInfoCheckViewSnapshotViewController(category: .enabledStates)
        SnapshotTestConfig.waitForCombineRendering(vc)
        assertSnapshot(
            of: vc,
            as: .image(on: SnapshotTestConfig.device, size: SnapshotTestConfig.size, traits: SnapshotTestConfig.darkTraits),
            record: SnapshotTestConfig.record
        )
    }
}
