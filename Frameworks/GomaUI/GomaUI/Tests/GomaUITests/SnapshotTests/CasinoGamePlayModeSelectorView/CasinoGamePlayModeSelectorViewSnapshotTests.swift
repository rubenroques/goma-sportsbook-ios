import XCTest
import SnapshotTesting
@testable import GomaUI

final class CasinoGamePlayModeSelectorViewSnapshotTests: XCTestCase {

    // MARK: - Basic States

    func testCasinoGamePlayModeSelectorView_BasicStates_Light() throws {
        let vc = CasinoGamePlayModeSelectorViewSnapshotViewController(category: .basicStates)
        assertSnapshot(
            of: vc,
            as: .image(on: SnapshotTestConfig.device, size: SnapshotTestConfig.size, traits: SnapshotTestConfig.lightTraits),
            record: SnapshotTestConfig.record
        )
    }

    func testCasinoGamePlayModeSelectorView_BasicStates_Dark() throws {
        let vc = CasinoGamePlayModeSelectorViewSnapshotViewController(category: .basicStates)
        assertSnapshot(
            of: vc,
            as: .image(on: SnapshotTestConfig.device, size: SnapshotTestConfig.size, traits: SnapshotTestConfig.darkTraits),
            record: SnapshotTestConfig.record
        )
    }

    // MARK: - User States

    func testCasinoGamePlayModeSelectorView_UserStates_Light() throws {
        let vc = CasinoGamePlayModeSelectorViewSnapshotViewController(category: .userStates)
        assertSnapshot(
            of: vc,
            as: .image(on: SnapshotTestConfig.device, size: SnapshotTestConfig.size, traits: SnapshotTestConfig.lightTraits),
            record: SnapshotTestConfig.record
        )
    }

    func testCasinoGamePlayModeSelectorView_UserStates_Dark() throws {
        let vc = CasinoGamePlayModeSelectorViewSnapshotViewController(category: .userStates)
        assertSnapshot(
            of: vc,
            as: .image(on: SnapshotTestConfig.device, size: SnapshotTestConfig.size, traits: SnapshotTestConfig.darkTraits),
            record: SnapshotTestConfig.record
        )
    }
}
