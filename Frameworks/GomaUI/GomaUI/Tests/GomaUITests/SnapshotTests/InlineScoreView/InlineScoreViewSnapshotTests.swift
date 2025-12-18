import XCTest
import SnapshotTesting
@testable import GomaUI

final class InlineScoreViewSnapshotTests: XCTestCase {

    func testInlineScoreView() {
        let vc = InlineScoreViewSnapshotViewController()

        // No RunLoop workaround needed here!
        // InlineScoreView follows the proper pattern:
        // - Protocol has `currentDisplayState` for synchronous access
        // - View calls synchronous render in configure() before setupBindings()
        // This allows immediate rendering without waiting for Combine dispatch.

        assertSnapshot(of: vc, as: .image(on: SnapshotTestConfig.device, size: SnapshotTestConfig.size), record: SnapshotTestConfig.record)
    }
}
