import XCTest
import SnapshotTesting
@testable import GomaUI

final class SquareSeeMoreViewSnapshotTests: XCTestCase {

    // SquareSeeMoreView is a simple static component with no reactive bindings.
    // No RunLoop workaround needed.

    // MARK: - Default State

    func testSquareSeeMoreView_DefaultState_Light() throws {
        let vc = SquareSeeMoreViewSnapshotViewController(category: .defaultState)
        assertSnapshot(
            of: vc,
            as: .image(on: SnapshotTestConfig.device, size: SnapshotTestConfig.size, traits: SnapshotTestConfig.lightTraits),
            record: SnapshotTestConfig.record
        )
    }

    func testSquareSeeMoreView_DefaultState_Dark() throws {
        let vc = SquareSeeMoreViewSnapshotViewController(category: .defaultState)
        assertSnapshot(
            of: vc,
            as: .image(on: SnapshotTestConfig.device, size: SnapshotTestConfig.size, traits: SnapshotTestConfig.darkTraits),
            record: SnapshotTestConfig.record
        )
    }
}
