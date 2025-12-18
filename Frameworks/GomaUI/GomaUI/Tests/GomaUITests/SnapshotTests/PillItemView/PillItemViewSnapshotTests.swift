import XCTest
import SnapshotTesting
@testable import GomaUI

final class PillItemViewSnapshotTests: XCTestCase {

    func testPillItemView() throws {
        let vc = PillItemViewSnapshotViewController()

        // No RunLoop workaround needed!
        // PillItemView now follows the proper pattern:
        // - Protocol has `currentDisplayState` for synchronous access
        // - View calls configureImmediately() before setupBindings()
        // This allows immediate rendering without waiting for Combine dispatch.

        assertSnapshot(of: vc, as: .image(on: SnapshotTestConfig.device, size: SnapshotTestConfig.size), record: SnapshotTestConfig.record)
    }
}
