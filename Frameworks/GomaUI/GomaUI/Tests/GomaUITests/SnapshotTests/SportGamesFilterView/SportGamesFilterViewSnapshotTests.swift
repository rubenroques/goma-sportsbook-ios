import XCTest
import SnapshotTesting
@testable import GomaUI

final class SportGamesFilterViewSnapshotTests: XCTestCase {

    // SportGamesFilterView uses CurrentValueSubject with synchronous binding in setupBindings().
    // The view configures data immediately in configureData() called from init.
    // No async rendering workaround needed.

    // MARK: - Expanded State

    func testSportGamesFilterView_ExpandedState_Light() throws {
        let vc = SportGamesFilterViewSnapshotViewController(category: .expandedState)
        assertSnapshot(of: vc, as: .image(on: SnapshotTestConfig.device, size: SnapshotTestConfig.size, traits: SnapshotTestConfig.lightTraits), record: SnapshotTestConfig.record)
    }

    func testSportGamesFilterView_ExpandedState_Dark() throws {
        let vc = SportGamesFilterViewSnapshotViewController(category: .expandedState)
        assertSnapshot(of: vc, as: .image(on: SnapshotTestConfig.device, size: SnapshotTestConfig.size, traits: SnapshotTestConfig.darkTraits), record: SnapshotTestConfig.record)
    }

    // MARK: - Collapsed State

    func testSportGamesFilterView_CollapsedState_Light() throws {
        let vc = SportGamesFilterViewSnapshotViewController(category: .collapsedState)
        assertSnapshot(of: vc, as: .image(on: SnapshotTestConfig.device, size: SnapshotTestConfig.size, traits: SnapshotTestConfig.lightTraits), record: SnapshotTestConfig.record)
    }

    func testSportGamesFilterView_CollapsedState_Dark() throws {
        let vc = SportGamesFilterViewSnapshotViewController(category: .collapsedState)
        assertSnapshot(of: vc, as: .image(on: SnapshotTestConfig.device, size: SnapshotTestConfig.size, traits: SnapshotTestConfig.darkTraits), record: SnapshotTestConfig.record)
    }

    // MARK: - Selection States

    func testSportGamesFilterView_SelectionStates_Light() throws {
        let vc = SportGamesFilterViewSnapshotViewController(category: .selectionStates)
        assertSnapshot(of: vc, as: .image(on: SnapshotTestConfig.device, size: SnapshotTestConfig.size, traits: SnapshotTestConfig.lightTraits), record: SnapshotTestConfig.record)
    }

    func testSportGamesFilterView_SelectionStates_Dark() throws {
        let vc = SportGamesFilterViewSnapshotViewController(category: .selectionStates)
        assertSnapshot(of: vc, as: .image(on: SnapshotTestConfig.device, size: SnapshotTestConfig.size, traits: SnapshotTestConfig.darkTraits), record: SnapshotTestConfig.record)
    }
}
