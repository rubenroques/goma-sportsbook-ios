import XCTest
import SnapshotTesting
@testable import GomaUI

final class MultiWidgetToolbarViewSnapshotTests: XCTestCase {

    // MultiWidgetToolbarView uses `.receive(on: DispatchQueue.main)` without
    // synchronous initial rendering, so we need the async rendering workaround.

    // MARK: - Logged In State

    func testMultiWidgetToolbarView_LoggedInState_Light() throws {
        let vc = MultiWidgetToolbarViewSnapshotViewController(category: .loggedInState)
        SnapshotTestConfig.waitForCombineRendering(vc)
        assertSnapshot(of: vc, as: .image(on: SnapshotTestConfig.device, size: SnapshotTestConfig.size, traits: SnapshotTestConfig.lightTraits), record: SnapshotTestConfig.record)
    }

    func testMultiWidgetToolbarView_LoggedInState_Dark() throws {
        let vc = MultiWidgetToolbarViewSnapshotViewController(category: .loggedInState)
        SnapshotTestConfig.waitForCombineRendering(vc)
        assertSnapshot(of: vc, as: .image(on: SnapshotTestConfig.device, size: SnapshotTestConfig.size, traits: SnapshotTestConfig.darkTraits), record: SnapshotTestConfig.record)
    }

    // MARK: - Logged Out State

    func testMultiWidgetToolbarView_LoggedOutState_Light() throws {
        let vc = MultiWidgetToolbarViewSnapshotViewController(category: .loggedOutState)
        SnapshotTestConfig.waitForCombineRendering(vc)
        assertSnapshot(of: vc, as: .image(on: SnapshotTestConfig.device, size: SnapshotTestConfig.size, traits: SnapshotTestConfig.lightTraits), record: SnapshotTestConfig.record)
    }

    func testMultiWidgetToolbarView_LoggedOutState_Dark() throws {
        let vc = MultiWidgetToolbarViewSnapshotViewController(category: .loggedOutState)
        SnapshotTestConfig.waitForCombineRendering(vc)
        assertSnapshot(of: vc, as: .image(on: SnapshotTestConfig.device, size: SnapshotTestConfig.size, traits: SnapshotTestConfig.darkTraits), record: SnapshotTestConfig.record)
    }
}
