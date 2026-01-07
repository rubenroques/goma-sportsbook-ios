import XCTest
import SnapshotTesting
@testable import GomaUI

final class BetslipTicketViewSnapshotTests: XCTestCase {

    // MARK: - Odds States

    func testBetslipTicketView_OddsStates_Light() throws {
        let vc = BetslipTicketViewSnapshotViewController(category: .oddsStates)
        assertSnapshot(
            of: vc,
            as: .image(on: SnapshotTestConfig.device, size: SnapshotTestConfig.size, traits: SnapshotTestConfig.lightTraits),
            record: SnapshotTestConfig.record
        )
    }

    func testBetslipTicketView_OddsStates_Dark() throws {
        let vc = BetslipTicketViewSnapshotViewController(category: .oddsStates)
        assertSnapshot(
            of: vc,
            as: .image(on: SnapshotTestConfig.device, size: SnapshotTestConfig.size, traits: SnapshotTestConfig.darkTraits),
            record: SnapshotTestConfig.record
        )
    }

    // MARK: - Enabled States

    func testBetslipTicketView_EnabledStates_Light() throws {
        let vc = BetslipTicketViewSnapshotViewController(category: .enabledStates)
        assertSnapshot(
            of: vc,
            as: .image(on: SnapshotTestConfig.device, size: SnapshotTestConfig.size, traits: SnapshotTestConfig.lightTraits),
            record: SnapshotTestConfig.record
        )
    }

    func testBetslipTicketView_EnabledStates_Dark() throws {
        let vc = BetslipTicketViewSnapshotViewController(category: .enabledStates)
        assertSnapshot(
            of: vc,
            as: .image(on: SnapshotTestConfig.device, size: SnapshotTestConfig.size, traits: SnapshotTestConfig.darkTraits),
            record: SnapshotTestConfig.record
        )
    }
}
