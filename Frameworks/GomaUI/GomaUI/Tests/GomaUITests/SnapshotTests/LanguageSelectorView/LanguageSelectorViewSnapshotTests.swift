import XCTest
import SnapshotTesting
@testable import GomaUI

final class LanguageSelectorViewSnapshotTests: XCTestCase {

    // LanguageSelectorView uses Combine with .receive(on: DispatchQueue.main) and
    // MockLanguageSelectorViewModel.loadLanguages() has an asyncAfter delay.
    // RunLoop workaround is required for proper rendering.

    // MARK: - Item Count Variants

    func testLanguageSelectorView_ItemCountVariants_Light() throws {
        let vc = LanguageSelectorViewSnapshotViewController(category: .itemCountVariants)
        SnapshotTestConfig.waitForCombineRendering(vc)
        assertSnapshot(
            of: vc,
            as: .image(on: SnapshotTestConfig.device, size: SnapshotTestConfig.size, traits: SnapshotTestConfig.lightTraits),
            record: SnapshotTestConfig.record
        )
    }

    func testLanguageSelectorView_ItemCountVariants_Dark() throws {
        let vc = LanguageSelectorViewSnapshotViewController(category: .itemCountVariants)
        SnapshotTestConfig.waitForCombineRendering(vc)
        assertSnapshot(
            of: vc,
            as: .image(on: SnapshotTestConfig.device, size: SnapshotTestConfig.size, traits: SnapshotTestConfig.darkTraits),
            record: SnapshotTestConfig.record
        )
    }

    // MARK: - Selection States

    func testLanguageSelectorView_SelectionStates_Light() throws {
        let vc = LanguageSelectorViewSnapshotViewController(category: .selectionStates)
        SnapshotTestConfig.waitForCombineRendering(vc)
        assertSnapshot(
            of: vc,
            as: .image(on: SnapshotTestConfig.device, size: SnapshotTestConfig.size, traits: SnapshotTestConfig.lightTraits),
            record: SnapshotTestConfig.record
        )
    }

    func testLanguageSelectorView_SelectionStates_Dark() throws {
        let vc = LanguageSelectorViewSnapshotViewController(category: .selectionStates)
        SnapshotTestConfig.waitForCombineRendering(vc)
        assertSnapshot(
            of: vc,
            as: .image(on: SnapshotTestConfig.device, size: SnapshotTestConfig.size, traits: SnapshotTestConfig.darkTraits),
            record: SnapshotTestConfig.record
        )
    }
}
