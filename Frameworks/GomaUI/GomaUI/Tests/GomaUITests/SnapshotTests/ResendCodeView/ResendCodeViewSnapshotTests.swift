import XCTest
import SnapshotTesting
@testable import GomaUI

final class ResendCodeViewSnapshotTests: XCTestCase {

    // MARK: - Countdown States

    func testResendCodeView_CountdownStates_Light() throws {
        let vc = ResendCodeViewSnapshotViewController(category: .countdownStates)
        assertSnapshot(
            of: vc,
            as: .image(on: SnapshotTestConfig.device, size: SnapshotTestConfig.size, traits: SnapshotTestConfig.lightTraits),
            record: SnapshotTestConfig.record
        )
    }

    func testResendCodeView_CountdownStates_Dark() throws {
        let vc = ResendCodeViewSnapshotViewController(category: .countdownStates)
        assertSnapshot(
            of: vc,
            as: .image(on: SnapshotTestConfig.device, size: SnapshotTestConfig.size, traits: SnapshotTestConfig.darkTraits),
            record: SnapshotTestConfig.record
        )
    }
}
