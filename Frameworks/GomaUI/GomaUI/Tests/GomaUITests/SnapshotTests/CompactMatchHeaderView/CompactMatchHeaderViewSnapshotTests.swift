import XCTest
import SnapshotTesting
@testable import GomaUI

final class CompactMatchHeaderViewSnapshotTests: XCTestCase {

    // TODO: Migrate component to `currentDisplayState + dropFirst()` or scheduler injection for synchronous rendering.

    // MARK: - Pre-Live States

    func testCompactMatchHeaderView_PreLiveStates_Light() throws {
        let vc = CompactMatchHeaderViewSnapshotViewController(category: .preLiveStates)
        SnapshotTestConfig.waitForCombineRendering(vc)
        assertSnapshot(
            of: vc,
            as: .image(on: SnapshotTestConfig.device, size: SnapshotTestConfig.size, traits: SnapshotTestConfig.lightTraits),
            record: SnapshotTestConfig.record
        )
    }

    func testCompactMatchHeaderView_PreLiveStates_Dark() throws {
        let vc = CompactMatchHeaderViewSnapshotViewController(category: .preLiveStates)
        SnapshotTestConfig.waitForCombineRendering(vc)
        assertSnapshot(
            of: vc,
            as: .image(on: SnapshotTestConfig.device, size: SnapshotTestConfig.size, traits: SnapshotTestConfig.darkTraits),
            record: SnapshotTestConfig.record
        )
    }

    // MARK: - Live States

    func testCompactMatchHeaderView_LiveStates_Light() throws {
        let vc = CompactMatchHeaderViewSnapshotViewController(category: .liveStates)
        SnapshotTestConfig.waitForCombineRendering(vc)
        assertSnapshot(
            of: vc,
            as: .image(on: SnapshotTestConfig.device, size: SnapshotTestConfig.size, traits: SnapshotTestConfig.lightTraits),
            record: SnapshotTestConfig.record
        )
    }

    func testCompactMatchHeaderView_LiveStates_Dark() throws {
        let vc = CompactMatchHeaderViewSnapshotViewController(category: .liveStates)
        SnapshotTestConfig.waitForCombineRendering(vc)
        assertSnapshot(
            of: vc,
            as: .image(on: SnapshotTestConfig.device, size: SnapshotTestConfig.size, traits: SnapshotTestConfig.darkTraits),
            record: SnapshotTestConfig.record
        )
    }
}
