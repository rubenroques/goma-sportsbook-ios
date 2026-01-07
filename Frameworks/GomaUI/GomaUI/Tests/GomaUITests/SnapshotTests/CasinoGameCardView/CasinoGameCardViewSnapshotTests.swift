import XCTest
import SnapshotTesting
@testable import GomaUI

final class CasinoGameCardViewSnapshotTests: XCTestCase {

    // MARK: - Basic States

    func testCasinoGameCardView_BasicStates_Light() throws {
        let vc = CasinoGameCardViewSnapshotViewController(category: .basicStates)
        assertSnapshot(
            of: vc,
            as: .image(on: SnapshotTestConfig.device, size: SnapshotTestConfig.size, traits: SnapshotTestConfig.lightTraits),
            record: SnapshotTestConfig.record
        )
    }

    func testCasinoGameCardView_BasicStates_Dark() throws {
        let vc = CasinoGameCardViewSnapshotViewController(category: .basicStates)
        assertSnapshot(
            of: vc,
            as: .image(on: SnapshotTestConfig.device, size: SnapshotTestConfig.size, traits: SnapshotTestConfig.darkTraits),
            record: SnapshotTestConfig.record
        )
    }

    // MARK: - Display States

    func testCasinoGameCardView_DisplayStates_Light() throws {
        let vc = CasinoGameCardViewSnapshotViewController(category: .displayStates)
        assertSnapshot(
            of: vc,
            as: .image(on: SnapshotTestConfig.device, size: SnapshotTestConfig.size, traits: SnapshotTestConfig.lightTraits),
            record: SnapshotTestConfig.record
        )
    }

    func testCasinoGameCardView_DisplayStates_Dark() throws {
        let vc = CasinoGameCardViewSnapshotViewController(category: .displayStates)
        assertSnapshot(
            of: vc,
            as: .image(on: SnapshotTestConfig.device, size: SnapshotTestConfig.size, traits: SnapshotTestConfig.darkTraits),
            record: SnapshotTestConfig.record
        )
    }

    // MARK: - Rating Variants

    func testCasinoGameCardView_RatingVariants_Light() throws {
        let vc = CasinoGameCardViewSnapshotViewController(category: .ratingVariants)
        assertSnapshot(
            of: vc,
            as: .image(on: SnapshotTestConfig.device, size: SnapshotTestConfig.size, traits: SnapshotTestConfig.lightTraits),
            record: SnapshotTestConfig.record
        )
    }

    func testCasinoGameCardView_RatingVariants_Dark() throws {
        let vc = CasinoGameCardViewSnapshotViewController(category: .ratingVariants)
        assertSnapshot(
            of: vc,
            as: .image(on: SnapshotTestConfig.device, size: SnapshotTestConfig.size, traits: SnapshotTestConfig.darkTraits),
            record: SnapshotTestConfig.record
        )
    }

    // MARK: - Content Variants

    func testCasinoGameCardView_ContentVariants_Light() throws {
        let vc = CasinoGameCardViewSnapshotViewController(category: .contentVariants)
        assertSnapshot(
            of: vc,
            as: .image(on: SnapshotTestConfig.device, size: SnapshotTestConfig.size, traits: SnapshotTestConfig.lightTraits),
            record: SnapshotTestConfig.record
        )
    }

    func testCasinoGameCardView_ContentVariants_Dark() throws {
        let vc = CasinoGameCardViewSnapshotViewController(category: .contentVariants)
        assertSnapshot(
            of: vc,
            as: .image(on: SnapshotTestConfig.device, size: SnapshotTestConfig.size, traits: SnapshotTestConfig.darkTraits),
            record: SnapshotTestConfig.record
        )
    }
}
