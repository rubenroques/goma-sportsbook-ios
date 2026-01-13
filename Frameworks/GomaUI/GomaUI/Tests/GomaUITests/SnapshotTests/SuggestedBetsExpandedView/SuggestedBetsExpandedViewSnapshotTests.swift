import XCTest
import SnapshotTesting
@testable import GomaUI

final class SuggestedBetsExpandedViewSnapshotTests: XCTestCase {

    // SuggestedBetsExpandedView uses `.receive(on: DispatchQueue.main)` for bindings.
    // Need to use waitForCombineRendering workaround.

    // MARK: - Expanded State

    func testSuggestedBetsExpandedView_ExpandedState_Light() throws {
        let vc = SuggestedBetsExpandedViewSnapshotViewController(category: .expandedState)
        SnapshotTestConfig.waitForCombineRendering(vc)
        assertSnapshot(
            of: vc,
            as: .image(on: SnapshotTestConfig.device, size: SnapshotTestConfig.size, traits: SnapshotTestConfig.lightTraits),
            record: SnapshotTestConfig.record
        )
    }

    func testSuggestedBetsExpandedView_ExpandedState_Dark() throws {
        let vc = SuggestedBetsExpandedViewSnapshotViewController(category: .expandedState)
        SnapshotTestConfig.waitForCombineRendering(vc)
        assertSnapshot(
            of: vc,
            as: .image(on: SnapshotTestConfig.device, size: SnapshotTestConfig.size, traits: SnapshotTestConfig.darkTraits),
            record: SnapshotTestConfig.record
        )
    }

    // MARK: - Collapsed State

    func testSuggestedBetsExpandedView_CollapsedState_Light() throws {
        let vc = SuggestedBetsExpandedViewSnapshotViewController(category: .collapsedState)
        SnapshotTestConfig.waitForCombineRendering(vc)
        assertSnapshot(
            of: vc,
            as: .image(on: SnapshotTestConfig.device, size: SnapshotTestConfig.size, traits: SnapshotTestConfig.lightTraits),
            record: SnapshotTestConfig.record
        )
    }

    func testSuggestedBetsExpandedView_CollapsedState_Dark() throws {
        let vc = SuggestedBetsExpandedViewSnapshotViewController(category: .collapsedState)
        SnapshotTestConfig.waitForCombineRendering(vc)
        assertSnapshot(
            of: vc,
            as: .image(on: SnapshotTestConfig.device, size: SnapshotTestConfig.size, traits: SnapshotTestConfig.darkTraits),
            record: SnapshotTestConfig.record
        )
    }

    // MARK: - Multiple Cards

    func testSuggestedBetsExpandedView_MultipleCards_Light() throws {
        let vc = SuggestedBetsExpandedViewSnapshotViewController(category: .multipleCards)
        SnapshotTestConfig.waitForCombineRendering(vc)
        assertSnapshot(
            of: vc,
            as: .image(on: SnapshotTestConfig.device, size: SnapshotTestConfig.size, traits: SnapshotTestConfig.lightTraits),
            record: SnapshotTestConfig.record
        )
    }

    func testSuggestedBetsExpandedView_MultipleCards_Dark() throws {
        let vc = SuggestedBetsExpandedViewSnapshotViewController(category: .multipleCards)
        SnapshotTestConfig.waitForCombineRendering(vc)
        assertSnapshot(
            of: vc,
            as: .image(on: SnapshotTestConfig.device, size: SnapshotTestConfig.size, traits: SnapshotTestConfig.darkTraits),
            record: SnapshotTestConfig.record
        )
    }
}
