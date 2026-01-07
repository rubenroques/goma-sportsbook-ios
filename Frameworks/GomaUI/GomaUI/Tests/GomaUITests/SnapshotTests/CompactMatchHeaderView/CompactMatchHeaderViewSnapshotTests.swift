import XCTest
import SnapshotTesting
@testable import GomaUI

final class CompactMatchHeaderViewSnapshotTests: XCTestCase {

    // MARK: - Pre-Live States

    func testCompactMatchHeaderView_PreLiveStates_Light() throws {
        let vc = CompactMatchHeaderViewSnapshotViewController(category: .preLiveStates)
        assertSnapshot(
            of: vc,
            as: .image(on: SnapshotTestConfig.device, size: SnapshotTestConfig.size, traits: SnapshotTestConfig.lightTraits),
            record: SnapshotTestConfig.record
        )
    }

    func testCompactMatchHeaderView_PreLiveStates_Dark() throws {
        let vc = CompactMatchHeaderViewSnapshotViewController(category: .preLiveStates)
        assertSnapshot(
            of: vc,
            as: .image(on: SnapshotTestConfig.device, size: SnapshotTestConfig.size, traits: SnapshotTestConfig.darkTraits),
            record: SnapshotTestConfig.record
        )
    }

    // MARK: - Live States

    func testCompactMatchHeaderView_LiveStates_Light() throws {
        let vc = CompactMatchHeaderViewSnapshotViewController(category: .liveStates)
        assertSnapshot(
            of: vc,
            as: .image(on: SnapshotTestConfig.device, size: SnapshotTestConfig.size, traits: SnapshotTestConfig.lightTraits),
            record: SnapshotTestConfig.record
        )
    }

    func testCompactMatchHeaderView_LiveStates_Dark() throws {
        let vc = CompactMatchHeaderViewSnapshotViewController(category: .liveStates)
        assertSnapshot(
            of: vc,
            as: .image(on: SnapshotTestConfig.device, size: SnapshotTestConfig.size, traits: SnapshotTestConfig.darkTraits),
            record: SnapshotTestConfig.record
        )
    }
}
