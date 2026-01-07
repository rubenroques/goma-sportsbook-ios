import XCTest
import SnapshotTesting
@testable import GomaUI

final class CustomNavigationViewSnapshotTests: XCTestCase {

    // MARK: - Basic Styles

    func testCustomNavigationView_BasicStyles_Light() throws {
        let vc = CustomNavigationViewSnapshotViewController(category: .basicStyles)
        assertSnapshot(
            of: vc,
            as: .image(on: SnapshotTestConfig.device, size: SnapshotTestConfig.size, traits: SnapshotTestConfig.lightTraits),
            record: SnapshotTestConfig.record
        )
    }

    func testCustomNavigationView_BasicStyles_Dark() throws {
        let vc = CustomNavigationViewSnapshotViewController(category: .basicStyles)
        assertSnapshot(
            of: vc,
            as: .image(on: SnapshotTestConfig.device, size: SnapshotTestConfig.size, traits: SnapshotTestConfig.darkTraits),
            record: SnapshotTestConfig.record
        )
    }
}
