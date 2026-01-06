import XCTest
import SnapshotTesting
@testable import GomaUI

final class WalletWidgetViewSnapshotTests: XCTestCase {

    // MARK: - Widget Variants

    func testWalletWidgetView_WidgetVariants_Light() throws {
        let vc = WalletWidgetViewSnapshotViewController(category: .widgetVariants)
        assertSnapshot(
            of: vc,
            as: .image(on: SnapshotTestConfig.device, size: SnapshotTestConfig.size, traits: SnapshotTestConfig.lightTraits),
            record: SnapshotTestConfig.record
        )
    }

    func testWalletWidgetView_WidgetVariants_Dark() throws {
        let vc = WalletWidgetViewSnapshotViewController(category: .widgetVariants)
        assertSnapshot(
            of: vc,
            as: .image(on: SnapshotTestConfig.device, size: SnapshotTestConfig.size, traits: SnapshotTestConfig.darkTraits),
            record: SnapshotTestConfig.record
        )
    }
}
