import XCTest
import SnapshotTesting
@testable import GomaUI

final class ShareChannelsGridViewSnapshotTests: XCTestCase {

    // ShareChannelsGridView uses `.receive(on: DispatchQueue.main)` for async rendering.
    // Must use waitForCombineRendering workaround.

    // MARK: - Channel Counts

    func testShareChannelsGridView_ChannelCounts_Light() throws {
        let vc = ShareChannelsGridViewSnapshotViewController(category: .channelCounts)
        SnapshotTestConfig.waitForCombineRendering(vc)
        assertSnapshot(
            of: vc,
            as: .image(on: SnapshotTestConfig.device, size: SnapshotTestConfig.size, traits: SnapshotTestConfig.lightTraits),
            record: SnapshotTestConfig.record
        )
    }

    func testShareChannelsGridView_ChannelCounts_Dark() throws {
        let vc = ShareChannelsGridViewSnapshotViewController(category: .channelCounts)
        SnapshotTestConfig.waitForCombineRendering(vc)
        assertSnapshot(
            of: vc,
            as: .image(on: SnapshotTestConfig.device, size: SnapshotTestConfig.size, traits: SnapshotTestConfig.darkTraits),
            record: SnapshotTestConfig.record
        )
    }

    // MARK: - Channel Types

    func testShareChannelsGridView_ChannelTypes_Light() throws {
        let vc = ShareChannelsGridViewSnapshotViewController(category: .channelTypes)
        SnapshotTestConfig.waitForCombineRendering(vc)
        assertSnapshot(
            of: vc,
            as: .image(on: SnapshotTestConfig.device, size: SnapshotTestConfig.size, traits: SnapshotTestConfig.lightTraits),
            record: SnapshotTestConfig.record
        )
    }

    func testShareChannelsGridView_ChannelTypes_Dark() throws {
        let vc = ShareChannelsGridViewSnapshotViewController(category: .channelTypes)
        SnapshotTestConfig.waitForCombineRendering(vc)
        assertSnapshot(
            of: vc,
            as: .image(on: SnapshotTestConfig.device, size: SnapshotTestConfig.size, traits: SnapshotTestConfig.darkTraits),
            record: SnapshotTestConfig.record
        )
    }

    // MARK: - Availability States

    func testShareChannelsGridView_AvailabilityStates_Light() throws {
        let vc = ShareChannelsGridViewSnapshotViewController(category: .availabilityStates)
        SnapshotTestConfig.waitForCombineRendering(vc)
        assertSnapshot(
            of: vc,
            as: .image(on: SnapshotTestConfig.device, size: SnapshotTestConfig.size, traits: SnapshotTestConfig.lightTraits),
            record: SnapshotTestConfig.record
        )
    }

    func testShareChannelsGridView_AvailabilityStates_Dark() throws {
        let vc = ShareChannelsGridViewSnapshotViewController(category: .availabilityStates)
        SnapshotTestConfig.waitForCombineRendering(vc)
        assertSnapshot(
            of: vc,
            as: .image(on: SnapshotTestConfig.device, size: SnapshotTestConfig.size, traits: SnapshotTestConfig.darkTraits),
            record: SnapshotTestConfig.record
        )
    }
}
