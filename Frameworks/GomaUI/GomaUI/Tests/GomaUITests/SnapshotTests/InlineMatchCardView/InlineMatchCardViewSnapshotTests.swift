import XCTest
import SnapshotTesting
@testable import GomaUI

final class InlineMatchCardViewSnapshotTests: XCTestCase {

    // InlineMatchCardViewModelProtocol has currentDisplayState for synchronous access.
    // InlineMatchCardView calls configureImmediately() which renders synchronously before bindings.
    // No RunLoop workaround needed.

    // MARK: - Pre-Live Matches

    func testInlineMatchCardView_PreLiveMatches_Light() throws {
        let vc = InlineMatchCardViewSnapshotViewController(category: .preLiveMatches)
        assertSnapshot(of: vc, as: .image(on: SnapshotTestConfig.device, size: SnapshotTestConfig.size, traits: SnapshotTestConfig.lightTraits), record: SnapshotTestConfig.record)
    }

    func testInlineMatchCardView_PreLiveMatches_Dark() throws {
        let vc = InlineMatchCardViewSnapshotViewController(category: .preLiveMatches)
        assertSnapshot(of: vc, as: .image(on: SnapshotTestConfig.device, size: SnapshotTestConfig.size, traits: SnapshotTestConfig.darkTraits), record: SnapshotTestConfig.record)
    }

    // MARK: - Live Matches

    func testInlineMatchCardView_LiveMatches_Light() throws {
        let vc = InlineMatchCardViewSnapshotViewController(category: .liveMatches)
        assertSnapshot(of: vc, as: .image(on: SnapshotTestConfig.device, size: SnapshotTestConfig.size, traits: SnapshotTestConfig.lightTraits), record: SnapshotTestConfig.record)
    }

    func testInlineMatchCardView_LiveMatches_Dark() throws {
        let vc = InlineMatchCardViewSnapshotViewController(category: .liveMatches)
        assertSnapshot(of: vc, as: .image(on: SnapshotTestConfig.device, size: SnapshotTestConfig.size, traits: SnapshotTestConfig.darkTraits), record: SnapshotTestConfig.record)
    }

    // MARK: - Selection States

    func testInlineMatchCardView_SelectionStates_Light() throws {
        let vc = InlineMatchCardViewSnapshotViewController(category: .selectionStates)
        assertSnapshot(of: vc, as: .image(on: SnapshotTestConfig.device, size: SnapshotTestConfig.size, traits: SnapshotTestConfig.lightTraits), record: SnapshotTestConfig.record)
    }

    func testInlineMatchCardView_SelectionStates_Dark() throws {
        let vc = InlineMatchCardViewSnapshotViewController(category: .selectionStates)
        assertSnapshot(of: vc, as: .image(on: SnapshotTestConfig.device, size: SnapshotTestConfig.size, traits: SnapshotTestConfig.darkTraits), record: SnapshotTestConfig.record)
    }

    // MARK: - Special States

    func testInlineMatchCardView_SpecialStates_Light() throws {
        let vc = InlineMatchCardViewSnapshotViewController(category: .specialStates)
        assertSnapshot(of: vc, as: .image(on: SnapshotTestConfig.device, size: SnapshotTestConfig.size, traits: SnapshotTestConfig.lightTraits), record: SnapshotTestConfig.record)
    }

    func testInlineMatchCardView_SpecialStates_Dark() throws {
        let vc = InlineMatchCardViewSnapshotViewController(category: .specialStates)
        assertSnapshot(of: vc, as: .image(on: SnapshotTestConfig.device, size: SnapshotTestConfig.size, traits: SnapshotTestConfig.darkTraits), record: SnapshotTestConfig.record)
    }
}
