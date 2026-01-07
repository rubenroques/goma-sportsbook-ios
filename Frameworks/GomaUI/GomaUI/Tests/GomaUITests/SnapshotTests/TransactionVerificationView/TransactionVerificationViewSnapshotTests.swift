import XCTest
import SnapshotTesting
@testable import GomaUI

final class TransactionVerificationViewSnapshotTests: XCTestCase {

    // MARK: - Verification Variants

    func testTransactionVerificationView_VerificationVariants_Light() throws {
        let vc = TransactionVerificationViewSnapshotViewController(category: .verificationVariants)
        assertSnapshot(
            of: vc,
            as: .image(on: SnapshotTestConfig.device, size: SnapshotTestConfig.size, traits: SnapshotTestConfig.lightTraits),
            record: SnapshotTestConfig.record
        )
    }

    func testTransactionVerificationView_VerificationVariants_Dark() throws {
        let vc = TransactionVerificationViewSnapshotViewController(category: .verificationVariants)
        assertSnapshot(
            of: vc,
            as: .image(on: SnapshotTestConfig.device, size: SnapshotTestConfig.size, traits: SnapshotTestConfig.darkTraits),
            record: SnapshotTestConfig.record
        )
    }
}
