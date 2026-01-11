import XCTest
import SnapshotTesting
@testable import GomaUI

final class ResendCodeViewSnapshotTests: XCTestCase {

    // TODO: Migrate component to `currentDisplayState + dropFirst()` or scheduler injection for synchronous rendering.

    // MARK: - Countdown States

    func testResendCodeView_CountdownStates_Light() throws {
        let vc = ResendCodeViewSnapshotViewController(category: .countdownStates)
        SnapshotTestConfig.waitForCombineRendering(vc)
        assertSnapshot(
            of: vc,
            as: .image(on: SnapshotTestConfig.device, size: SnapshotTestConfig.size, traits: SnapshotTestConfig.lightTraits),
            record: SnapshotTestConfig.record
        )
    }

    func testResendCodeView_CountdownStates_Dark() throws {
        let vc = ResendCodeViewSnapshotViewController(category: .countdownStates)
        SnapshotTestConfig.waitForCombineRendering(vc)
        assertSnapshot(
            of: vc,
            as: .image(on: SnapshotTestConfig.device, size: SnapshotTestConfig.size, traits: SnapshotTestConfig.darkTraits),
            record: SnapshotTestConfig.record
        )
    }
}
