import XCTest
import SnapshotTesting
@testable import GomaUI

final class LeaguesFilterViewSnapshotTests: XCTestCase {

    // LeaguesFilterView uses Combine with CurrentValueSubject for selectedFilter and isCollapsed.
    // The view setup is synchronous but state changes happen through Combine.
    // Using waitForCombineRendering to ensure publishers emit their initial values.

    // MARK: - Expanded State

    func testLeaguesFilterView_ExpandedState_Light() throws {
        let vc = LeaguesFilterViewSnapshotViewController(category: .expanded)
        SnapshotTestConfig.waitForCombineRendering(vc)
        assertSnapshot(of: vc, as: .image(on: SnapshotTestConfig.device, size: SnapshotTestConfig.size, traits: SnapshotTestConfig.lightTraits), record: SnapshotTestConfig.record)
    }

    func testLeaguesFilterView_ExpandedState_Dark() throws {
        let vc = LeaguesFilterViewSnapshotViewController(category: .expanded)
        SnapshotTestConfig.waitForCombineRendering(vc)
        assertSnapshot(of: vc, as: .image(on: SnapshotTestConfig.device, size: SnapshotTestConfig.size, traits: SnapshotTestConfig.darkTraits), record: SnapshotTestConfig.record)
    }

    // MARK: - Collapsed State

    func testLeaguesFilterView_CollapsedState_Light() throws {
        let vc = LeaguesFilterViewSnapshotViewController(category: .collapsed)
        SnapshotTestConfig.waitForCombineRendering(vc)
        assertSnapshot(of: vc, as: .image(on: SnapshotTestConfig.device, size: SnapshotTestConfig.size, traits: SnapshotTestConfig.lightTraits), record: SnapshotTestConfig.record)
    }

    func testLeaguesFilterView_CollapsedState_Dark() throws {
        let vc = LeaguesFilterViewSnapshotViewController(category: .collapsed)
        SnapshotTestConfig.waitForCombineRendering(vc)
        assertSnapshot(of: vc, as: .image(on: SnapshotTestConfig.device, size: SnapshotTestConfig.size, traits: SnapshotTestConfig.darkTraits), record: SnapshotTestConfig.record)
    }

    // MARK: - Selection States

    func testLeaguesFilterView_SelectionStates_Light() throws {
        let vc = LeaguesFilterViewSnapshotViewController(category: .selectionStates)
        SnapshotTestConfig.waitForCombineRendering(vc)
        assertSnapshot(of: vc, as: .image(on: SnapshotTestConfig.device, size: SnapshotTestConfig.size, traits: SnapshotTestConfig.lightTraits), record: SnapshotTestConfig.record)
    }

    func testLeaguesFilterView_SelectionStates_Dark() throws {
        let vc = LeaguesFilterViewSnapshotViewController(category: .selectionStates)
        SnapshotTestConfig.waitForCombineRendering(vc)
        assertSnapshot(of: vc, as: .image(on: SnapshotTestConfig.device, size: SnapshotTestConfig.size, traits: SnapshotTestConfig.darkTraits), record: SnapshotTestConfig.record)
    }

    // MARK: - Content Variants

    func testLeaguesFilterView_ContentVariants_Light() throws {
        let vc = LeaguesFilterViewSnapshotViewController(category: .contentVariants)
        SnapshotTestConfig.waitForCombineRendering(vc)
        assertSnapshot(of: vc, as: .image(on: SnapshotTestConfig.device, size: SnapshotTestConfig.size, traits: SnapshotTestConfig.lightTraits), record: SnapshotTestConfig.record)
    }

    func testLeaguesFilterView_ContentVariants_Dark() throws {
        let vc = LeaguesFilterViewSnapshotViewController(category: .contentVariants)
        SnapshotTestConfig.waitForCombineRendering(vc)
        assertSnapshot(of: vc, as: .image(on: SnapshotTestConfig.device, size: SnapshotTestConfig.size, traits: SnapshotTestConfig.darkTraits), record: SnapshotTestConfig.record)
    }
}
