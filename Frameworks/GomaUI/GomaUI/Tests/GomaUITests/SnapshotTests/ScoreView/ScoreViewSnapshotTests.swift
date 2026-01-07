import XCTest
import SnapshotTesting
@testable import GomaUI

final class ScoreViewSnapshotTests: XCTestCase {

    // MARK: - Sport Variants

    func testScoreView_SportVariants_Light() throws {
        let vc = ScoreViewSnapshotViewController(category: .sportVariants)
        assertSnapshot(
            of: vc,
            as: .image(on: SnapshotTestConfig.device, size: SnapshotTestConfig.size, traits: SnapshotTestConfig.lightTraits),
            record: SnapshotTestConfig.record
        )
    }

    func testScoreView_SportVariants_Dark() throws {
        let vc = ScoreViewSnapshotViewController(category: .sportVariants)
        assertSnapshot(
            of: vc,
            as: .image(on: SnapshotTestConfig.device, size: SnapshotTestConfig.size, traits: SnapshotTestConfig.darkTraits),
            record: SnapshotTestConfig.record
        )
    }

    // MARK: - Visual States

    func testScoreView_VisualStates_Light() throws {
        let vc = ScoreViewSnapshotViewController(category: .visualStates)
        assertSnapshot(
            of: vc,
            as: .image(on: SnapshotTestConfig.device, size: SnapshotTestConfig.size, traits: SnapshotTestConfig.lightTraits),
            record: SnapshotTestConfig.record
        )
    }

    func testScoreView_VisualStates_Dark() throws {
        let vc = ScoreViewSnapshotViewController(category: .visualStates)
        assertSnapshot(
            of: vc,
            as: .image(on: SnapshotTestConfig.device, size: SnapshotTestConfig.size, traits: SnapshotTestConfig.darkTraits),
            record: SnapshotTestConfig.record
        )
    }

    // MARK: - Style Variants

    func testScoreView_StyleVariants_Light() throws {
        let vc = ScoreViewSnapshotViewController(category: .styleVariants)
        assertSnapshot(
            of: vc,
            as: .image(on: SnapshotTestConfig.device, size: SnapshotTestConfig.size, traits: SnapshotTestConfig.lightTraits),
            record: SnapshotTestConfig.record
        )
    }

    func testScoreView_StyleVariants_Dark() throws {
        let vc = ScoreViewSnapshotViewController(category: .styleVariants)
        assertSnapshot(
            of: vc,
            as: .image(on: SnapshotTestConfig.device, size: SnapshotTestConfig.size, traits: SnapshotTestConfig.darkTraits),
            record: SnapshotTestConfig.record
        )
    }
}
