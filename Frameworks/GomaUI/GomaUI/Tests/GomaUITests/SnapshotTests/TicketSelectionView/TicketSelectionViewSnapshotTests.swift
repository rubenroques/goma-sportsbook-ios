import XCTest
import SnapshotTesting
@testable import GomaUI

final class TicketSelectionViewSnapshotTests: XCTestCase {

    // TicketSelectionView has currentTicketData for synchronous access.
    // The view calls updateUI(with: viewModel.currentTicketData) in init before bindings.
    // No RunLoop workaround needed.

    // MARK: - PreLive States

    func testTicketSelectionView_PreLiveStates_Light() throws {
        let vc = TicketSelectionViewSnapshotViewController(category: .preLiveStates)
        assertSnapshot(
            of: vc,
            as: .image(on: SnapshotTestConfig.device, size: SnapshotTestConfig.size, traits: SnapshotTestConfig.lightTraits),
            record: SnapshotTestConfig.record
        )
    }

    func testTicketSelectionView_PreLiveStates_Dark() throws {
        let vc = TicketSelectionViewSnapshotViewController(category: .preLiveStates)
        assertSnapshot(
            of: vc,
            as: .image(on: SnapshotTestConfig.device, size: SnapshotTestConfig.size, traits: SnapshotTestConfig.darkTraits),
            record: SnapshotTestConfig.record
        )
    }

    // MARK: - Live States

    func testTicketSelectionView_LiveStates_Light() throws {
        let vc = TicketSelectionViewSnapshotViewController(category: .liveStates)
        assertSnapshot(
            of: vc,
            as: .image(on: SnapshotTestConfig.device, size: SnapshotTestConfig.size, traits: SnapshotTestConfig.lightTraits),
            record: SnapshotTestConfig.record
        )
    }

    func testTicketSelectionView_LiveStates_Dark() throws {
        let vc = TicketSelectionViewSnapshotViewController(category: .liveStates)
        assertSnapshot(
            of: vc,
            as: .image(on: SnapshotTestConfig.device, size: SnapshotTestConfig.size, traits: SnapshotTestConfig.darkTraits),
            record: SnapshotTestConfig.record
        )
    }

    // MARK: - Content Variants

    func testTicketSelectionView_ContentVariants_Light() throws {
        let vc = TicketSelectionViewSnapshotViewController(category: .contentVariants)
        assertSnapshot(
            of: vc,
            as: .image(on: SnapshotTestConfig.device, size: SnapshotTestConfig.size, traits: SnapshotTestConfig.lightTraits),
            record: SnapshotTestConfig.record
        )
    }

    func testTicketSelectionView_ContentVariants_Dark() throws {
        let vc = TicketSelectionViewSnapshotViewController(category: .contentVariants)
        assertSnapshot(
            of: vc,
            as: .image(on: SnapshotTestConfig.device, size: SnapshotTestConfig.size, traits: SnapshotTestConfig.darkTraits),
            record: SnapshotTestConfig.record
        )
    }

    // MARK: - Result Tags

    func testTicketSelectionView_ResultTags_Light() throws {
        let vc = TicketSelectionViewSnapshotViewController(category: .resultTags)
        assertSnapshot(
            of: vc,
            as: .image(on: SnapshotTestConfig.device, size: SnapshotTestConfig.size, traits: SnapshotTestConfig.lightTraits),
            record: SnapshotTestConfig.record
        )
    }

    func testTicketSelectionView_ResultTags_Dark() throws {
        let vc = TicketSelectionViewSnapshotViewController(category: .resultTags)
        assertSnapshot(
            of: vc,
            as: .image(on: SnapshotTestConfig.device, size: SnapshotTestConfig.size, traits: SnapshotTestConfig.darkTraits),
            record: SnapshotTestConfig.record
        )
    }
}
