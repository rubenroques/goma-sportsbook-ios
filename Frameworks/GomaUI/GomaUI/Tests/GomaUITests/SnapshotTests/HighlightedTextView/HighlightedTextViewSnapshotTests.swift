import XCTest
import SnapshotTesting
@testable import GomaUI

final class HighlightedTextViewSnapshotTests: XCTestCase {

    // TODO: Migrate component to `currentDisplayState + dropFirst()` or scheduler injection for synchronous rendering.

    // MARK: - Alignment States

    func testHighlightedTextView_AlignmentStates_Light() throws {
        let vc = HighlightedTextViewSnapshotViewController(category: .alignmentStates)
        SnapshotTestConfig.waitForCombineRendering(vc)
        assertSnapshot(
            of: vc,
            as: .image(on: SnapshotTestConfig.device, size: SnapshotTestConfig.size, traits: SnapshotTestConfig.lightTraits),
            record: SnapshotTestConfig.record
        )
    }

    func testHighlightedTextView_AlignmentStates_Dark() throws {
        let vc = HighlightedTextViewSnapshotViewController(category: .alignmentStates)
        SnapshotTestConfig.waitForCombineRendering(vc)
        assertSnapshot(
            of: vc,
            as: .image(on: SnapshotTestConfig.device, size: SnapshotTestConfig.size, traits: SnapshotTestConfig.darkTraits),
            record: SnapshotTestConfig.record
        )
    }

    // MARK: - Highlight Variants

    func testHighlightedTextView_HighlightVariants_Light() throws {
        let vc = HighlightedTextViewSnapshotViewController(category: .highlightVariants)
        SnapshotTestConfig.waitForCombineRendering(vc)
        assertSnapshot(
            of: vc,
            as: .image(on: SnapshotTestConfig.device, size: SnapshotTestConfig.size, traits: SnapshotTestConfig.lightTraits),
            record: SnapshotTestConfig.record
        )
    }

    func testHighlightedTextView_HighlightVariants_Dark() throws {
        let vc = HighlightedTextViewSnapshotViewController(category: .highlightVariants)
        SnapshotTestConfig.waitForCombineRendering(vc)
        assertSnapshot(
            of: vc,
            as: .image(on: SnapshotTestConfig.device, size: SnapshotTestConfig.size, traits: SnapshotTestConfig.darkTraits),
            record: SnapshotTestConfig.record
        )
    }
}
