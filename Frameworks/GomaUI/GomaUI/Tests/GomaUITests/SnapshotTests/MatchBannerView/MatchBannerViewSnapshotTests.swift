import XCTest
import SnapshotTesting
@testable import GomaUI

final class MatchBannerViewSnapshotTests: XCTestCase {

    // MatchBannerViewModelProtocol has currentMatchData for synchronous access.
    // MatchBannerView.configure(with:) calls updateUI(with: viewModel.currentMatchData) synchronously.
    // No RunLoop workaround needed.

    // MARK: - Match States

    func testMatchBannerView_MatchStates_Light() throws {
        let vc = MatchBannerViewSnapshotViewController(category: .matchStates)
        assertSnapshot(of: vc, as: .image(on: SnapshotTestConfig.device, size: SnapshotTestConfig.size, traits: SnapshotTestConfig.lightTraits), record: SnapshotTestConfig.record)
    }

    func testMatchBannerView_MatchStates_Dark() throws {
        let vc = MatchBannerViewSnapshotViewController(category: .matchStates)
        assertSnapshot(of: vc, as: .image(on: SnapshotTestConfig.device, size: SnapshotTestConfig.size, traits: SnapshotTestConfig.darkTraits), record: SnapshotTestConfig.record)
    }

    // MARK: - Empty State

    func testMatchBannerView_EmptyState_Light() throws {
        let vc = MatchBannerViewSnapshotViewController(category: .emptyState)
        assertSnapshot(of: vc, as: .image(on: SnapshotTestConfig.device, size: SnapshotTestConfig.size, traits: SnapshotTestConfig.lightTraits), record: SnapshotTestConfig.record)
    }

    func testMatchBannerView_EmptyState_Dark() throws {
        let vc = MatchBannerViewSnapshotViewController(category: .emptyState)
        assertSnapshot(of: vc, as: .image(on: SnapshotTestConfig.device, size: SnapshotTestConfig.size, traits: SnapshotTestConfig.darkTraits), record: SnapshotTestConfig.record)
    }
}
