import XCTest
import SnapshotTesting
@testable import GomaUI

final class HighlightedTextViewSnapshotTests: XCTestCase {

    // MARK: - Alignment States

    func testHighlightedTextView_AlignmentStates_Light() throws {
        let vc = HighlightedTextViewSnapshotViewController(category: .alignmentStates)
        assertSnapshot(
            of: vc,
            as: .image(on: SnapshotTestConfig.device, size: SnapshotTestConfig.size, traits: SnapshotTestConfig.lightTraits),
            record: SnapshotTestConfig.record
        )
    }

    func testHighlightedTextView_AlignmentStates_Dark() throws {
        let vc = HighlightedTextViewSnapshotViewController(category: .alignmentStates)
        assertSnapshot(
            of: vc,
            as: .image(on: SnapshotTestConfig.device, size: SnapshotTestConfig.size, traits: SnapshotTestConfig.darkTraits),
            record: SnapshotTestConfig.record
        )
    }

    // MARK: - Highlight Variants

    func testHighlightedTextView_HighlightVariants_Light() throws {
        let vc = HighlightedTextViewSnapshotViewController(category: .highlightVariants)
        assertSnapshot(
            of: vc,
            as: .image(on: SnapshotTestConfig.device, size: SnapshotTestConfig.size, traits: SnapshotTestConfig.lightTraits),
            record: SnapshotTestConfig.record
        )
    }

    func testHighlightedTextView_HighlightVariants_Dark() throws {
        let vc = HighlightedTextViewSnapshotViewController(category: .highlightVariants)
        assertSnapshot(
            of: vc,
            as: .image(on: SnapshotTestConfig.device, size: SnapshotTestConfig.size, traits: SnapshotTestConfig.darkTraits),
            record: SnapshotTestConfig.record
        )
    }
}
