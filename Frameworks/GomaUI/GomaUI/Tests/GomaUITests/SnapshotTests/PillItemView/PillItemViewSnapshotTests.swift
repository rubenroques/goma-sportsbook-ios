import XCTest
import SnapshotTesting
@testable import GomaUI

final class PillItemViewSnapshotTests: XCTestCase {

    func testPillItemView() {
        let vc = PillItemViewSnapshotViewController()

        // WORKAROUND: PillItemView relies solely on async Combine bindings
        // (.receive(on: DispatchQueue.main)) without synchronous initial rendering.
        // This RunLoop delay allows Combine publishers to dispatch before snapshot.
        //
        // The proper fix is to refactor PillItemView to follow the pattern used by
        // components like InlineScoreView, CompactOutcomesLineView, etc:
        // 1. Add `currentDisplayState` to PillItemViewModelProtocol
        // 2. Call a synchronous render method in init/configure before setupBindings()
        //
        // See InlineScoreViewSnapshotTests for an example without this workaround.
        vc.loadViewIfNeeded()
        RunLoop.main.run(until: Date(timeIntervalSinceNow: 0.1))

        assertSnapshot(of: vc, as: .image(on: SnapshotTestConfig.device, size: SnapshotTestConfig.size), record: SnapshotTestConfig.record)
    }
}
