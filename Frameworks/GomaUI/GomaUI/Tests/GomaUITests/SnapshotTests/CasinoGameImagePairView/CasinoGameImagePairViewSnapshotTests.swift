import XCTest
import SnapshotTesting
@testable import GomaUI

final class CasinoGameImagePairViewSnapshotTests: XCTestCase {

    // MARK: - Basic States

    func testCasinoGameImagePairView_BasicStates_Light() throws {
        let vc = CasinoGameImagePairViewSnapshotViewController(category: .basicStates)
        assertSnapshot(
            of: vc,
            as: .image(on: SnapshotTestConfig.device, size: SnapshotTestConfig.size, traits: SnapshotTestConfig.lightTraits),
            record: SnapshotTestConfig.record
        )
    }

    func testCasinoGameImagePairView_BasicStates_Dark() throws {
        let vc = CasinoGameImagePairViewSnapshotViewController(category: .basicStates)
        assertSnapshot(
            of: vc,
            as: .image(on: SnapshotTestConfig.device, size: SnapshotTestConfig.size, traits: SnapshotTestConfig.darkTraits),
            record: SnapshotTestConfig.record
        )
    }

    // MARK: - Content Variants

    func testCasinoGameImagePairView_ContentVariants_Light() throws {
        let vc = CasinoGameImagePairViewSnapshotViewController(category: .contentVariants)
        assertSnapshot(
            of: vc,
            as: .image(on: SnapshotTestConfig.device, size: SnapshotTestConfig.size, traits: SnapshotTestConfig.lightTraits),
            record: SnapshotTestConfig.record
        )
    }

    func testCasinoGameImagePairView_ContentVariants_Dark() throws {
        let vc = CasinoGameImagePairViewSnapshotViewController(category: .contentVariants)
        assertSnapshot(
            of: vc,
            as: .image(on: SnapshotTestConfig.device, size: SnapshotTestConfig.size, traits: SnapshotTestConfig.darkTraits),
            record: SnapshotTestConfig.record
        )
    }
}
