import XCTest
import SnapshotTesting
@testable import GomaUI

final class MatchParticipantsInfoViewSnapshotTests: XCTestCase {

    // MARK: - Horizontal Variants

    func testMatchParticipantsInfoView_HorizontalVariants_Light() throws {
        let vc = MatchParticipantsInfoViewSnapshotViewController(category: .horizontalVariants)
        assertSnapshot(
            of: vc,
            as: .image(on: SnapshotTestConfig.device, size: SnapshotTestConfig.size, traits: SnapshotTestConfig.lightTraits),
            record: SnapshotTestConfig.record
        )
    }

    func testMatchParticipantsInfoView_HorizontalVariants_Dark() throws {
        let vc = MatchParticipantsInfoViewSnapshotViewController(category: .horizontalVariants)
        assertSnapshot(
            of: vc,
            as: .image(on: SnapshotTestConfig.device, size: SnapshotTestConfig.size, traits: SnapshotTestConfig.darkTraits),
            record: SnapshotTestConfig.record
        )
    }

    // MARK: - Vertical Variants

    func testMatchParticipantsInfoView_VerticalVariants_Light() throws {
        let vc = MatchParticipantsInfoViewSnapshotViewController(category: .verticalVariants)
        assertSnapshot(
            of: vc,
            as: .image(on: SnapshotTestConfig.device, size: SnapshotTestConfig.size, traits: SnapshotTestConfig.lightTraits),
            record: SnapshotTestConfig.record
        )
    }

    func testMatchParticipantsInfoView_VerticalVariants_Dark() throws {
        let vc = MatchParticipantsInfoViewSnapshotViewController(category: .verticalVariants)
        assertSnapshot(
            of: vc,
            as: .image(on: SnapshotTestConfig.device, size: SnapshotTestConfig.size, traits: SnapshotTestConfig.darkTraits),
            record: SnapshotTestConfig.record
        )
    }
}
