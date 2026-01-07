import XCTest
import SnapshotTesting
@testable import GomaUI

final class CustomSliderViewSnapshotTests: XCTestCase {

    // MARK: - Basic States

    func testCustomSliderView_BasicStates_Light() throws {
        let vc = CustomSliderViewSnapshotViewController(category: .basicStates)
        assertSnapshot(
            of: vc,
            as: .image(on: SnapshotTestConfig.device, size: SnapshotTestConfig.size, traits: SnapshotTestConfig.lightTraits),
            record: SnapshotTestConfig.record
        )
    }

    func testCustomSliderView_BasicStates_Dark() throws {
        let vc = CustomSliderViewSnapshotViewController(category: .basicStates)
        assertSnapshot(
            of: vc,
            as: .image(on: SnapshotTestConfig.device, size: SnapshotTestConfig.size, traits: SnapshotTestConfig.darkTraits),
            record: SnapshotTestConfig.record
        )
    }

    // MARK: - Position Variants

    func testCustomSliderView_PositionVariants_Light() throws {
        let vc = CustomSliderViewSnapshotViewController(category: .positionVariants)
        assertSnapshot(
            of: vc,
            as: .image(on: SnapshotTestConfig.device, size: SnapshotTestConfig.size, traits: SnapshotTestConfig.lightTraits),
            record: SnapshotTestConfig.record
        )
    }

    func testCustomSliderView_PositionVariants_Dark() throws {
        let vc = CustomSliderViewSnapshotViewController(category: .positionVariants)
        assertSnapshot(
            of: vc,
            as: .image(on: SnapshotTestConfig.device, size: SnapshotTestConfig.size, traits: SnapshotTestConfig.darkTraits),
            record: SnapshotTestConfig.record
        )
    }

    // MARK: - Configuration Variants

    func testCustomSliderView_ConfigurationVariants_Light() throws {
        let vc = CustomSliderViewSnapshotViewController(category: .configurationVariants)
        assertSnapshot(
            of: vc,
            as: .image(on: SnapshotTestConfig.device, size: SnapshotTestConfig.size, traits: SnapshotTestConfig.lightTraits),
            record: SnapshotTestConfig.record
        )
    }

    func testCustomSliderView_ConfigurationVariants_Dark() throws {
        let vc = CustomSliderViewSnapshotViewController(category: .configurationVariants)
        assertSnapshot(
            of: vc,
            as: .image(on: SnapshotTestConfig.device, size: SnapshotTestConfig.size, traits: SnapshotTestConfig.darkTraits),
            record: SnapshotTestConfig.record
        )
    }
}
