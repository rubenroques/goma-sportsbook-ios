import XCTest
import SnapshotTesting
@testable import GomaUI

final class MatchHeaderCompactViewSnapshotTests: XCTestCase {

    // TODO: Migrate component to `currentDisplayState + dropFirst()` or scheduler injection for synchronous rendering.

    // MARK: - Basic Variants

    func testMatchHeaderCompactView_BasicVariants_Light() throws {
        let vc = MatchHeaderCompactViewSnapshotViewController(category: .basicVariants)
        SnapshotTestConfig.waitForCombineRendering(vc)
        assertSnapshot(
            of: vc,
            as: .image(on: SnapshotTestConfig.device, size: SnapshotTestConfig.size, traits: SnapshotTestConfig.lightTraits),
            record: SnapshotTestConfig.record
        )
    }

    func testMatchHeaderCompactView_BasicVariants_Dark() throws {
        let vc = MatchHeaderCompactViewSnapshotViewController(category: .basicVariants)
        SnapshotTestConfig.waitForCombineRendering(vc)
        assertSnapshot(
            of: vc,
            as: .image(on: SnapshotTestConfig.device, size: SnapshotTestConfig.size, traits: SnapshotTestConfig.darkTraits),
            record: SnapshotTestConfig.record
        )
    }

    // MARK: - Live Match Variants

    func testMatchHeaderCompactView_LiveMatchVariants_Light() throws {
        let vc = MatchHeaderCompactViewSnapshotViewController(category: .liveMatchVariants)
        SnapshotTestConfig.waitForCombineRendering(vc)
        assertSnapshot(
            of: vc,
            as: .image(on: SnapshotTestConfig.device, size: SnapshotTestConfig.size, traits: SnapshotTestConfig.lightTraits),
            record: SnapshotTestConfig.record
        )
    }

    func testMatchHeaderCompactView_LiveMatchVariants_Dark() throws {
        let vc = MatchHeaderCompactViewSnapshotViewController(category: .liveMatchVariants)
        SnapshotTestConfig.waitForCombineRendering(vc)
        assertSnapshot(
            of: vc,
            as: .image(on: SnapshotTestConfig.device, size: SnapshotTestConfig.size, traits: SnapshotTestConfig.darkTraits),
            record: SnapshotTestConfig.record
        )
    }
}
