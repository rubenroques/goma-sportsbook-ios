import XCTest
import SnapshotTesting
@testable import GomaUI

final class SimpleOptionRowViewSnapshotTests: XCTestCase {

    // SimpleOptionRowView renders synchronously via configure() method.
    // No RunLoop workaround needed.

    // MARK: - Selection States

    func testSimpleOptionRowView_SelectionStates_Light() throws {
        let vc = SimpleOptionRowViewSnapshotViewController(category: .selectionStates)
        assertSnapshot(of: vc, as: .image(on: SnapshotTestConfig.device, size: SnapshotTestConfig.size, traits: SnapshotTestConfig.lightTraits), record: SnapshotTestConfig.record)
    }

    func testSimpleOptionRowView_SelectionStates_Dark() throws {
        let vc = SimpleOptionRowViewSnapshotViewController(category: .selectionStates)
        assertSnapshot(of: vc, as: .image(on: SnapshotTestConfig.device, size: SnapshotTestConfig.size, traits: SnapshotTestConfig.darkTraits), record: SnapshotTestConfig.record)
    }

    // MARK: - Content Variants

    func testSimpleOptionRowView_ContentVariants_Light() throws {
        let vc = SimpleOptionRowViewSnapshotViewController(category: .contentVariants)
        assertSnapshot(of: vc, as: .image(on: SnapshotTestConfig.device, size: SnapshotTestConfig.size, traits: SnapshotTestConfig.lightTraits), record: SnapshotTestConfig.record)
    }

    func testSimpleOptionRowView_ContentVariants_Dark() throws {
        let vc = SimpleOptionRowViewSnapshotViewController(category: .contentVariants)
        assertSnapshot(of: vc, as: .image(on: SnapshotTestConfig.device, size: SnapshotTestConfig.size, traits: SnapshotTestConfig.darkTraits), record: SnapshotTestConfig.record)
    }
}
