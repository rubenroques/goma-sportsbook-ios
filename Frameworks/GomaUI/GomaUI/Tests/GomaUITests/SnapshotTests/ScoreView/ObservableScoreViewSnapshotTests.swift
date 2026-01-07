import XCTest
import SnapshotTesting
@testable import GomaUI

/// Snapshot tests for ObservableScoreView (@Observable + layoutSubviews pattern)
///
/// Key test: These tests should pass WITHOUT any RunLoop workaround!
/// If the @Observable pattern works correctly, the view renders synchronously.
///
/// Mirrors ScoreViewSnapshotTests for direct comparison.
final class ObservableScoreViewSnapshotTests: XCTestCase {

    // MARK: - Sport Variants

    func testObservableScoreView_SportVariants_Light() throws {
        let vc = ObservableScoreViewSnapshotViewController(category: .sportVariants)

        // NO RunLoop.main.run() needed!
        // @Observable renders synchronously in layoutSubviews()

        assertSnapshot(
            of: vc,
            as: .image(on: SnapshotTestConfig.device, size: SnapshotTestConfig.size, traits: SnapshotTestConfig.lightTraits),
            record: SnapshotTestConfig.record
        )
    }

    func testObservableScoreView_SportVariants_Dark() throws {
        let vc = ObservableScoreViewSnapshotViewController(category: .sportVariants)

        assertSnapshot(
            of: vc,
            as: .image(on: SnapshotTestConfig.device, size: SnapshotTestConfig.size, traits: SnapshotTestConfig.darkTraits),
            record: SnapshotTestConfig.record
        )
    }

    // MARK: - Visual States

    func testObservableScoreView_VisualStates_Light() throws {
        let vc = ObservableScoreViewSnapshotViewController(category: .visualStates)

        assertSnapshot(
            of: vc,
            as: .image(on: SnapshotTestConfig.device, size: SnapshotTestConfig.size, traits: SnapshotTestConfig.lightTraits),
            record: SnapshotTestConfig.record
        )
    }

    func testObservableScoreView_VisualStates_Dark() throws {
        let vc = ObservableScoreViewSnapshotViewController(category: .visualStates)

        assertSnapshot(
            of: vc,
            as: .image(on: SnapshotTestConfig.device, size: SnapshotTestConfig.size, traits: SnapshotTestConfig.darkTraits),
            record: SnapshotTestConfig.record
        )
    }

    // MARK: - Style Variants

    func testObservableScoreView_StyleVariants_Light() throws {
        let vc = ObservableScoreViewSnapshotViewController(category: .styleVariants)

        assertSnapshot(
            of: vc,
            as: .image(on: SnapshotTestConfig.device, size: SnapshotTestConfig.size, traits: SnapshotTestConfig.lightTraits),
            record: SnapshotTestConfig.record
        )
    }

    func testObservableScoreView_StyleVariants_Dark() throws {
        let vc = ObservableScoreViewSnapshotViewController(category: .styleVariants)

        assertSnapshot(
            of: vc,
            as: .image(on: SnapshotTestConfig.device, size: SnapshotTestConfig.size, traits: SnapshotTestConfig.darkTraits),
            record: SnapshotTestConfig.record
        )
    }
}
