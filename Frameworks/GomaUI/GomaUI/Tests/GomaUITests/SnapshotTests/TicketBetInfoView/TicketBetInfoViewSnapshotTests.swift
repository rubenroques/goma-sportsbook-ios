import XCTest
import SnapshotTesting
@testable import GomaUI

final class TicketBetInfoViewSnapshotTests: XCTestCase {

    // TicketBetInfoView calls updateUI() synchronously in configure() via currentBetInfo.
    // The async bindings use dropFirst() so initial state is rendered synchronously.
    // However, nested components may need time to render, so we use waitForCombineRendering.

    // MARK: - Pending States

    func testTicketBetInfoView_PendingStates_Light() throws {
        let vc = TicketBetInfoViewSnapshotViewController(category: .pendingStates)
        SnapshotTestConfig.waitForCombineRendering(vc)
        assertSnapshot(
            of: vc,
            as: .image(on: SnapshotTestConfig.device, size: SnapshotTestConfig.size, traits: SnapshotTestConfig.lightTraits),
            record: SnapshotTestConfig.record
        )
    }

    func testTicketBetInfoView_PendingStates_Dark() throws {
        let vc = TicketBetInfoViewSnapshotViewController(category: .pendingStates)
        SnapshotTestConfig.waitForCombineRendering(vc)
        assertSnapshot(
            of: vc,
            as: .image(on: SnapshotTestConfig.device, size: SnapshotTestConfig.size, traits: SnapshotTestConfig.darkTraits),
            record: SnapshotTestConfig.record
        )
    }

    // MARK: - Settled States

    func testTicketBetInfoView_SettledStates_Light() throws {
        let vc = TicketBetInfoViewSnapshotViewController(category: .settledStates)
        SnapshotTestConfig.waitForCombineRendering(vc)
        assertSnapshot(
            of: vc,
            as: .image(on: SnapshotTestConfig.device, size: SnapshotTestConfig.size, traits: SnapshotTestConfig.lightTraits),
            record: SnapshotTestConfig.record
        )
    }

    func testTicketBetInfoView_SettledStates_Dark() throws {
        let vc = TicketBetInfoViewSnapshotViewController(category: .settledStates)
        SnapshotTestConfig.waitForCombineRendering(vc)
        assertSnapshot(
            of: vc,
            as: .image(on: SnapshotTestConfig.device, size: SnapshotTestConfig.size, traits: SnapshotTestConfig.darkTraits),
            record: SnapshotTestConfig.record
        )
    }

    // MARK: - Cashout Components

    func testTicketBetInfoView_CashoutComponents_Light() throws {
        let vc = TicketBetInfoViewSnapshotViewController(category: .cashoutComponents)
        SnapshotTestConfig.waitForCombineRendering(vc)
        assertSnapshot(
            of: vc,
            as: .image(on: SnapshotTestConfig.device, size: SnapshotTestConfig.size, traits: SnapshotTestConfig.lightTraits),
            record: SnapshotTestConfig.record
        )
    }

    func testTicketBetInfoView_CashoutComponents_Dark() throws {
        let vc = TicketBetInfoViewSnapshotViewController(category: .cashoutComponents)
        SnapshotTestConfig.waitForCombineRendering(vc)
        assertSnapshot(
            of: vc,
            as: .image(on: SnapshotTestConfig.device, size: SnapshotTestConfig.size, traits: SnapshotTestConfig.darkTraits),
            record: SnapshotTestConfig.record
        )
    }

    // MARK: - Corner Radius Styles

    func testTicketBetInfoView_CornerRadiusStyles_Light() throws {
        let vc = TicketBetInfoViewSnapshotViewController(category: .cornerRadiusStyles)
        SnapshotTestConfig.waitForCombineRendering(vc)
        assertSnapshot(
            of: vc,
            as: .image(on: SnapshotTestConfig.device, size: SnapshotTestConfig.size, traits: SnapshotTestConfig.lightTraits),
            record: SnapshotTestConfig.record
        )
    }

    func testTicketBetInfoView_CornerRadiusStyles_Dark() throws {
        let vc = TicketBetInfoViewSnapshotViewController(category: .cornerRadiusStyles)
        SnapshotTestConfig.waitForCombineRendering(vc)
        assertSnapshot(
            of: vc,
            as: .image(on: SnapshotTestConfig.device, size: SnapshotTestConfig.size, traits: SnapshotTestConfig.darkTraits),
            record: SnapshotTestConfig.record
        )
    }
}
