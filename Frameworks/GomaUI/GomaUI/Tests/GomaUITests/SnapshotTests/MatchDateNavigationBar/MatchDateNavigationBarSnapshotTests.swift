import XCTest
import SnapshotTesting
@testable import GomaUI

final class MatchDateNavigationBarSnapshotTests: XCTestCase {

    // MatchDateNavigationBarView uses `.receive(on: DispatchQueue.main)` for Combine bindings.
    // We need the RunLoop workaround to allow async rendering.

    // MARK: - Match Status

    func testMatchDateNavigationBar_MatchStatus_Light() throws {
        let vc = MatchDateNavigationBarSnapshotViewController(category: .matchStatus)
        SnapshotTestConfig.waitForCombineRendering(vc)
        assertSnapshot(
            of: vc,
            as: .image(on: SnapshotTestConfig.device, size: SnapshotTestConfig.size, traits: SnapshotTestConfig.lightTraits),
            record: SnapshotTestConfig.record
        )
    }

    func testMatchDateNavigationBar_MatchStatus_Dark() throws {
        let vc = MatchDateNavigationBarSnapshotViewController(category: .matchStatus)
        SnapshotTestConfig.waitForCombineRendering(vc)
        assertSnapshot(
            of: vc,
            as: .image(on: SnapshotTestConfig.device, size: SnapshotTestConfig.size, traits: SnapshotTestConfig.darkTraits),
            record: SnapshotTestConfig.record
        )
    }

    // MARK: - Live Variants

    func testMatchDateNavigationBar_LiveVariants_Light() throws {
        let vc = MatchDateNavigationBarSnapshotViewController(category: .liveVariants)
        SnapshotTestConfig.waitForCombineRendering(vc)
        assertSnapshot(
            of: vc,
            as: .image(on: SnapshotTestConfig.device, size: SnapshotTestConfig.size, traits: SnapshotTestConfig.lightTraits),
            record: SnapshotTestConfig.record
        )
    }

    func testMatchDateNavigationBar_LiveVariants_Dark() throws {
        let vc = MatchDateNavigationBarSnapshotViewController(category: .liveVariants)
        SnapshotTestConfig.waitForCombineRendering(vc)
        assertSnapshot(
            of: vc,
            as: .image(on: SnapshotTestConfig.device, size: SnapshotTestConfig.size, traits: SnapshotTestConfig.darkTraits),
            record: SnapshotTestConfig.record
        )
    }

    // MARK: - Back Button Variants

    func testMatchDateNavigationBar_BackButtonVariants_Light() throws {
        let vc = MatchDateNavigationBarSnapshotViewController(category: .backButtonVariants)
        SnapshotTestConfig.waitForCombineRendering(vc)
        assertSnapshot(
            of: vc,
            as: .image(on: SnapshotTestConfig.device, size: SnapshotTestConfig.size, traits: SnapshotTestConfig.lightTraits),
            record: SnapshotTestConfig.record
        )
    }

    func testMatchDateNavigationBar_BackButtonVariants_Dark() throws {
        let vc = MatchDateNavigationBarSnapshotViewController(category: .backButtonVariants)
        SnapshotTestConfig.waitForCombineRendering(vc)
        assertSnapshot(
            of: vc,
            as: .image(on: SnapshotTestConfig.device, size: SnapshotTestConfig.size, traits: SnapshotTestConfig.darkTraits),
            record: SnapshotTestConfig.record
        )
    }
}
