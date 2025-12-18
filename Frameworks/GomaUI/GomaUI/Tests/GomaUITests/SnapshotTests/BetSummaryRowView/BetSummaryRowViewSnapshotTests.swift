import XCTest
import SnapshotTesting
@testable import GomaUI

final class BetSummaryRowViewSnapshotTests: XCTestCase {

    func testBetSummaryRowView() throws {
        let vc = BetSummaryRowViewSnapshotViewController()

        // No RunLoop workaround needed!
        // BetSummaryRowView follows the proper pattern:
        // - Protocol has `currentData` for synchronous access
        // - View uses dataPublisher with Combine for reactive updates
        // This allows immediate rendering without waiting for Combine dispatch.

        assertSnapshot(of: vc, as: .image(on: SnapshotTestConfig.device, size: SnapshotTestConfig.size), record: SnapshotTestConfig.record)
    }
}
