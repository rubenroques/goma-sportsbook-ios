import XCTest
import SnapshotTesting
@testable import GomaUI

final class RecentlyPlayedGamesViewSnapshotTests: XCTestCase {

    // RecentlyPlayedGamesView uses Combine with `.receive(on: DispatchQueue.main)`
    // without synchronous initial rendering. RunLoop workaround required.

    // MARK: - Content Variants

    func testRecentlyPlayedGamesView_ContentVariants_Light() throws {
        let vc = RecentlyPlayedGamesViewSnapshotViewController(category: .contentVariants)
        SnapshotTestConfig.waitForCombineRendering(vc)
        assertSnapshot(
            of: vc,
            as: .image(on: SnapshotTestConfig.device, size: SnapshotTestConfig.size, traits: SnapshotTestConfig.lightTraits),
            record: SnapshotTestConfig.record
        )
    }

    func testRecentlyPlayedGamesView_ContentVariants_Dark() throws {
        let vc = RecentlyPlayedGamesViewSnapshotViewController(category: .contentVariants)
        SnapshotTestConfig.waitForCombineRendering(vc)
        assertSnapshot(
            of: vc,
            as: .image(on: SnapshotTestConfig.device, size: SnapshotTestConfig.size, traits: SnapshotTestConfig.darkTraits),
            record: SnapshotTestConfig.record
        )
    }

    // MARK: - Display States

    func testRecentlyPlayedGamesView_DisplayStates_Light() throws {
        let vc = RecentlyPlayedGamesViewSnapshotViewController(category: .displayStates)
        SnapshotTestConfig.waitForCombineRendering(vc)
        assertSnapshot(
            of: vc,
            as: .image(on: SnapshotTestConfig.device, size: SnapshotTestConfig.size, traits: SnapshotTestConfig.lightTraits),
            record: SnapshotTestConfig.record
        )
    }

    func testRecentlyPlayedGamesView_DisplayStates_Dark() throws {
        let vc = RecentlyPlayedGamesViewSnapshotViewController(category: .displayStates)
        SnapshotTestConfig.waitForCombineRendering(vc)
        assertSnapshot(
            of: vc,
            as: .image(on: SnapshotTestConfig.device, size: SnapshotTestConfig.size, traits: SnapshotTestConfig.darkTraits),
            record: SnapshotTestConfig.record
        )
    }
}
