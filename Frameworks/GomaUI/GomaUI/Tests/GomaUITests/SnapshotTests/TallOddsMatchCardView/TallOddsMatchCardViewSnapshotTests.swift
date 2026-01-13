import XCTest
import SnapshotTesting
@testable import GomaUI

final class TallOddsMatchCardViewSnapshotTests: XCTestCase {

    // TallOddsMatchCardViewModelProtocol has currentDisplayState for synchronous access.
    // TallOddsMatchCardView calls configureImmediately() which renders synchronously before bindings.
    // No RunLoop workaround needed.

    // MARK: - Pre-Live Matches

    func testTallOddsMatchCardView_PreLiveMatches_Light() throws {
        let vc = TallOddsMatchCardViewSnapshotViewController(category: .preLiveMatches)
        assertSnapshot(of: vc, as: .image(on: SnapshotTestConfig.device, size: SnapshotTestConfig.size, traits: SnapshotTestConfig.lightTraits), record: SnapshotTestConfig.record)
    }

    func testTallOddsMatchCardView_PreLiveMatches_Dark() throws {
        let vc = TallOddsMatchCardViewSnapshotViewController(category: .preLiveMatches)
        assertSnapshot(of: vc, as: .image(on: SnapshotTestConfig.device, size: SnapshotTestConfig.size, traits: SnapshotTestConfig.darkTraits), record: SnapshotTestConfig.record)
    }

    // MARK: - Live Match States

    func testTallOddsMatchCardView_LiveMatchStates_Light() throws {
        let vc = TallOddsMatchCardViewSnapshotViewController(category: .liveMatchStates)
        assertSnapshot(of: vc, as: .image(on: SnapshotTestConfig.device, size: SnapshotTestConfig.size, traits: SnapshotTestConfig.lightTraits), record: SnapshotTestConfig.record)
    }

    func testTallOddsMatchCardView_LiveMatchStates_Dark() throws {
        let vc = TallOddsMatchCardViewSnapshotViewController(category: .liveMatchStates)
        assertSnapshot(of: vc, as: .image(on: SnapshotTestConfig.device, size: SnapshotTestConfig.size, traits: SnapshotTestConfig.darkTraits), record: SnapshotTestConfig.record)
    }

    // MARK: - League Variants

    func testTallOddsMatchCardView_LeagueVariants_Light() throws {
        let vc = TallOddsMatchCardViewSnapshotViewController(category: .leagueVariants)
        assertSnapshot(of: vc, as: .image(on: SnapshotTestConfig.device, size: SnapshotTestConfig.size, traits: SnapshotTestConfig.lightTraits), record: SnapshotTestConfig.record)
    }

    func testTallOddsMatchCardView_LeagueVariants_Dark() throws {
        let vc = TallOddsMatchCardViewSnapshotViewController(category: .leagueVariants)
        assertSnapshot(of: vc, as: .image(on: SnapshotTestConfig.device, size: SnapshotTestConfig.size, traits: SnapshotTestConfig.darkTraits), record: SnapshotTestConfig.record)
    }

    // MARK: - Outcomes Configurations

    func testTallOddsMatchCardView_OutcomesConfigurations_Light() throws {
        let vc = TallOddsMatchCardViewSnapshotViewController(category: .outcomesConfigurations)
        assertSnapshot(of: vc, as: .image(on: SnapshotTestConfig.device, size: SnapshotTestConfig.size, traits: SnapshotTestConfig.lightTraits), record: SnapshotTestConfig.record)
    }

    func testTallOddsMatchCardView_OutcomesConfigurations_Dark() throws {
        let vc = TallOddsMatchCardViewSnapshotViewController(category: .outcomesConfigurations)
        assertSnapshot(of: vc, as: .image(on: SnapshotTestConfig.device, size: SnapshotTestConfig.size, traits: SnapshotTestConfig.darkTraits), record: SnapshotTestConfig.record)
    }
}
