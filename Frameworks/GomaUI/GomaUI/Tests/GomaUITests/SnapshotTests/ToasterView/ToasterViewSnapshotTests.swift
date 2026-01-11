import XCTest
import SnapshotTesting
@testable import GomaUI

final class ToasterViewSnapshotTests: XCTestCase {

    // ToasterView uses scheduler injection - MockToasterViewModel defaults to ImmediateScheduler.
    // No RunLoop workaround needed.

    // MARK: - Toaster Variants

    func testToasterView_ToasterVariants_Light() throws {
        let vc = ToasterViewSnapshotViewController(category: .toasterVariants)
        assertSnapshot(
            of: vc,
            as: .image(on: SnapshotTestConfig.device, size: SnapshotTestConfig.size, traits: SnapshotTestConfig.lightTraits),
            record: SnapshotTestConfig.record
        )
    }

    func testToasterView_ToasterVariants_Dark() throws {
        let vc = ToasterViewSnapshotViewController(category: .toasterVariants)
        assertSnapshot(
            of: vc,
            as: .image(on: SnapshotTestConfig.device, size: SnapshotTestConfig.size, traits: SnapshotTestConfig.darkTraits),
            record: SnapshotTestConfig.record
        )
    }
}
