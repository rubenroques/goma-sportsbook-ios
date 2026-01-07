import XCTest
import SnapshotTesting
@testable import GomaUI

final class TermsAcceptanceViewSnapshotTests: XCTestCase {

    // MARK: - Acceptance States

    func testTermsAcceptanceView_AcceptanceStates_Light() throws {
        let vc = TermsAcceptanceViewSnapshotViewController(category: .acceptanceStates)
        assertSnapshot(
            of: vc,
            as: .image(on: SnapshotTestConfig.device, size: SnapshotTestConfig.size, traits: SnapshotTestConfig.lightTraits),
            record: SnapshotTestConfig.record
        )
    }

    func testTermsAcceptanceView_AcceptanceStates_Dark() throws {
        let vc = TermsAcceptanceViewSnapshotViewController(category: .acceptanceStates)
        assertSnapshot(
            of: vc,
            as: .image(on: SnapshotTestConfig.device, size: SnapshotTestConfig.size, traits: SnapshotTestConfig.darkTraits),
            record: SnapshotTestConfig.record
        )
    }
}
