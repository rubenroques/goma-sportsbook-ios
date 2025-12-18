import XCTest
import SnapshotTesting
@testable import GomaUI

final class CapsuleViewSnapshotTests: XCTestCase {

    func testCapsuleView() throws {
        let vc = CapsuleViewSnapshotViewController()

        // No RunLoop workaround needed!
        // CapsuleViewModelProtocol has `data` property for synchronous access
        // CapsuleView calls configure() immediately on initialization which reads the data synchronously
        // This allows immediate rendering without waiting for Combine dispatch.

        assertSnapshot(of: vc, as: .image(on: SnapshotTestConfig.device, size: SnapshotTestConfig.size), record: SnapshotTestConfig.record)
    }
}
