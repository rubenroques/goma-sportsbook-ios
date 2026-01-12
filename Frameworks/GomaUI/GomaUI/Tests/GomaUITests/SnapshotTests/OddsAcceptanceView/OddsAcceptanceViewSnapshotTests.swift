import XCTest
import SnapshotTesting
@testable import GomaUI

final class OddsAcceptanceViewSnapshotTests: XCTestCase {

    // MARK: - Acceptance States

    func testOddsAcceptanceView_AcceptanceStates_Light() throws {
        let vc = OddsAcceptanceViewSnapshotViewController(category: .acceptanceStates)
        SnapshotTestConfig.waitForCombineRendering(vc)
        assertSnapshot(
            of: vc,
            as: .image(on: SnapshotTestConfig.device, size: SnapshotTestConfig.size, traits: SnapshotTestConfig.lightTraits),
            record: SnapshotTestConfig.record
        )
    }

    func testOddsAcceptanceView_AcceptanceStates_Dark() throws {
        let vc = OddsAcceptanceViewSnapshotViewController(category: .acceptanceStates)
        SnapshotTestConfig.waitForCombineRendering(vc)
        assertSnapshot(
            of: vc,
            as: .image(on: SnapshotTestConfig.device, size: SnapshotTestConfig.size, traits: SnapshotTestConfig.darkTraits),
            record: SnapshotTestConfig.record
        )
    }

    // MARK: - Link States

    func testOddsAcceptanceView_LinkStates_Light() throws {
        let vc = OddsAcceptanceViewSnapshotViewController(category: .linkStates)
        SnapshotTestConfig.waitForCombineRendering(vc)
        assertSnapshot(
            of: vc,
            as: .image(on: SnapshotTestConfig.device, size: SnapshotTestConfig.size, traits: SnapshotTestConfig.lightTraits),
            record: SnapshotTestConfig.record
        )
    }

    func testOddsAcceptanceView_LinkStates_Dark() throws {
        let vc = OddsAcceptanceViewSnapshotViewController(category: .linkStates)
        SnapshotTestConfig.waitForCombineRendering(vc)
        assertSnapshot(
            of: vc,
            as: .image(on: SnapshotTestConfig.device, size: SnapshotTestConfig.size, traits: SnapshotTestConfig.darkTraits),
            record: SnapshotTestConfig.record
        )
    }
}
