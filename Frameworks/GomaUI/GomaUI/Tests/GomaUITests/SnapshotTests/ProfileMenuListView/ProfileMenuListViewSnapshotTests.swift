import XCTest
import SnapshotTesting
@testable import GomaUI

final class ProfileMenuListViewSnapshotTests: XCTestCase {

    // ProfileMenuListView uses Combine with `.receive(on: DispatchQueue.main)`
    // without synchronous initial rendering. Need RunLoop workaround.

    // MARK: - Default Configuration

    func testProfileMenuListView_DefaultConfiguration_Light() throws {
        let vc = ProfileMenuListViewSnapshotViewController(category: .defaultConfiguration)
        SnapshotTestConfig.waitForCombineRendering(vc)
        assertSnapshot(
            of: vc,
            as: .image(on: SnapshotTestConfig.device, size: SnapshotTestConfig.size, traits: SnapshotTestConfig.lightTraits),
            record: SnapshotTestConfig.record
        )
    }

    func testProfileMenuListView_DefaultConfiguration_Dark() throws {
        let vc = ProfileMenuListViewSnapshotViewController(category: .defaultConfiguration)
        SnapshotTestConfig.waitForCombineRendering(vc)
        assertSnapshot(
            of: vc,
            as: .image(on: SnapshotTestConfig.device, size: SnapshotTestConfig.size, traits: SnapshotTestConfig.darkTraits),
            record: SnapshotTestConfig.record
        )
    }

    // MARK: - Language Variants

    func testProfileMenuListView_LanguageVariants_Light() throws {
        let vc = ProfileMenuListViewSnapshotViewController(category: .languageVariants)
        SnapshotTestConfig.waitForCombineRendering(vc)
        assertSnapshot(
            of: vc,
            as: .image(on: SnapshotTestConfig.device, size: SnapshotTestConfig.size, traits: SnapshotTestConfig.lightTraits),
            record: SnapshotTestConfig.record
        )
    }

    func testProfileMenuListView_LanguageVariants_Dark() throws {
        let vc = ProfileMenuListViewSnapshotViewController(category: .languageVariants)
        SnapshotTestConfig.waitForCombineRendering(vc)
        assertSnapshot(
            of: vc,
            as: .image(on: SnapshotTestConfig.device, size: SnapshotTestConfig.size, traits: SnapshotTestConfig.darkTraits),
            record: SnapshotTestConfig.record
        )
    }

    // MARK: - Item Count Variants

    func testProfileMenuListView_ItemCountVariants_Light() throws {
        let vc = ProfileMenuListViewSnapshotViewController(category: .itemCountVariants)
        SnapshotTestConfig.waitForCombineRendering(vc)
        assertSnapshot(
            of: vc,
            as: .image(on: SnapshotTestConfig.device, size: SnapshotTestConfig.size, traits: SnapshotTestConfig.lightTraits),
            record: SnapshotTestConfig.record
        )
    }

    func testProfileMenuListView_ItemCountVariants_Dark() throws {
        let vc = ProfileMenuListViewSnapshotViewController(category: .itemCountVariants)
        SnapshotTestConfig.waitForCombineRendering(vc)
        assertSnapshot(
            of: vc,
            as: .image(on: SnapshotTestConfig.device, size: SnapshotTestConfig.size, traits: SnapshotTestConfig.darkTraits),
            record: SnapshotTestConfig.record
        )
    }
}
