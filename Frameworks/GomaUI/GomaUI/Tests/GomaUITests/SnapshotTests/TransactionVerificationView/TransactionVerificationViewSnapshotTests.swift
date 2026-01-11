import XCTest
import SnapshotTesting
@testable import GomaUI

final class TransactionVerificationViewSnapshotTests: XCTestCase {

    // TODO: Migrate component to `currentDisplayState + dropFirst()` or scheduler injection for synchronous rendering.

    // MARK: - Verification Variants

    func testTransactionVerificationView_VerificationVariants_Light() throws {
        let vc = TransactionVerificationViewSnapshotViewController(category: .verificationVariants)
        SnapshotTestConfig.waitForCombineRendering(vc)
        assertSnapshot(
            of: vc,
            as: .image(on: SnapshotTestConfig.device, size: SnapshotTestConfig.size, traits: SnapshotTestConfig.lightTraits),
            record: SnapshotTestConfig.record
        )
    }

    func testTransactionVerificationView_VerificationVariants_Dark() throws {
        let vc = TransactionVerificationViewSnapshotViewController(category: .verificationVariants)
        SnapshotTestConfig.waitForCombineRendering(vc)
        assertSnapshot(
            of: vc,
            as: .image(on: SnapshotTestConfig.device, size: SnapshotTestConfig.size, traits: SnapshotTestConfig.darkTraits),
            record: SnapshotTestConfig.record
        )
    }
}
