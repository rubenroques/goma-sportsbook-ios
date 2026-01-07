import XCTest
import SnapshotTesting
@testable import GomaUI

final class TimeSliderViewSnapshotTests: XCTestCase {

    // MARK: - Slider States

    func testTimeSliderView_SliderStates_Light() throws {
        let vc = TimeSliderViewSnapshotViewController(category: .sliderStates)
        assertSnapshot(
            of: vc,
            as: .image(on: SnapshotTestConfig.device, size: SnapshotTestConfig.size, traits: SnapshotTestConfig.lightTraits),
            record: SnapshotTestConfig.record
        )
    }

    func testTimeSliderView_SliderStates_Dark() throws {
        let vc = TimeSliderViewSnapshotViewController(category: .sliderStates)
        assertSnapshot(
            of: vc,
            as: .image(on: SnapshotTestConfig.device, size: SnapshotTestConfig.size, traits: SnapshotTestConfig.darkTraits),
            record: SnapshotTestConfig.record
        )
    }
}
