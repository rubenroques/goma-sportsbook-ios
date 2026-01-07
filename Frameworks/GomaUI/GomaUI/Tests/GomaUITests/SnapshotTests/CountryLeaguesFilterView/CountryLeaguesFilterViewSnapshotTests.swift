import XCTest
import SnapshotTesting
@testable import GomaUI

final class CountryLeaguesFilterViewSnapshotTests: XCTestCase {

    // MARK: - Basic States

    func testCountryLeaguesFilterView_BasicStates_Light() throws {
        let vc = CountryLeaguesFilterViewSnapshotViewController(category: .basicStates)
        assertSnapshot(
            of: vc,
            as: .image(on: SnapshotTestConfig.device, size: SnapshotTestConfig.size, traits: SnapshotTestConfig.lightTraits),
            record: SnapshotTestConfig.record
        )
    }

    func testCountryLeaguesFilterView_BasicStates_Dark() throws {
        let vc = CountryLeaguesFilterViewSnapshotViewController(category: .basicStates)
        assertSnapshot(
            of: vc,
            as: .image(on: SnapshotTestConfig.device, size: SnapshotTestConfig.size, traits: SnapshotTestConfig.darkTraits),
            record: SnapshotTestConfig.record
        )
    }
}
