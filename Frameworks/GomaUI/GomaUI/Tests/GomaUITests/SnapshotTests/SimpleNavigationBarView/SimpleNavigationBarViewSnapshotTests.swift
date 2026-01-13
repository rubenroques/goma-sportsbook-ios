import XCTest
import SnapshotTesting
@testable import GomaUI

final class SimpleNavigationBarViewSnapshotTests: XCTestCase {

    // SimpleNavigationBarView is immutable after init - no Combine reactivity.
    // Renders synchronously in configure(). No RunLoop workaround needed.

    // MARK: - Back Button Variants

    func testSimpleNavigationBarView_BackButtonVariants_Light() throws {
        let vc = SimpleNavigationBarViewSnapshotViewController(category: .backButtonVariants)
        assertSnapshot(of: vc, as: .image(on: SnapshotTestConfig.device, size: SnapshotTestConfig.size, traits: SnapshotTestConfig.lightTraits), record: SnapshotTestConfig.record)
    }

    func testSimpleNavigationBarView_BackButtonVariants_Dark() throws {
        let vc = SimpleNavigationBarViewSnapshotViewController(category: .backButtonVariants)
        assertSnapshot(of: vc, as: .image(on: SnapshotTestConfig.device, size: SnapshotTestConfig.size, traits: SnapshotTestConfig.darkTraits), record: SnapshotTestConfig.record)
    }

    // MARK: - Title Variants

    func testSimpleNavigationBarView_TitleVariants_Light() throws {
        let vc = SimpleNavigationBarViewSnapshotViewController(category: .titleVariants)
        assertSnapshot(of: vc, as: .image(on: SnapshotTestConfig.device, size: SnapshotTestConfig.size, traits: SnapshotTestConfig.lightTraits), record: SnapshotTestConfig.record)
    }

    func testSimpleNavigationBarView_TitleVariants_Dark() throws {
        let vc = SimpleNavigationBarViewSnapshotViewController(category: .titleVariants)
        assertSnapshot(of: vc, as: .image(on: SnapshotTestConfig.device, size: SnapshotTestConfig.size, traits: SnapshotTestConfig.darkTraits), record: SnapshotTestConfig.record)
    }

    // MARK: - Combined Layouts

    func testSimpleNavigationBarView_CombinedLayouts_Light() throws {
        let vc = SimpleNavigationBarViewSnapshotViewController(category: .combinedLayouts)
        assertSnapshot(of: vc, as: .image(on: SnapshotTestConfig.device, size: SnapshotTestConfig.size, traits: SnapshotTestConfig.lightTraits), record: SnapshotTestConfig.record)
    }

    func testSimpleNavigationBarView_CombinedLayouts_Dark() throws {
        let vc = SimpleNavigationBarViewSnapshotViewController(category: .combinedLayouts)
        assertSnapshot(of: vc, as: .image(on: SnapshotTestConfig.device, size: SnapshotTestConfig.size, traits: SnapshotTestConfig.darkTraits), record: SnapshotTestConfig.record)
    }

    // MARK: - Style Customization

    func testSimpleNavigationBarView_StyleCustomization_Light() throws {
        let vc = SimpleNavigationBarViewSnapshotViewController(category: .styleCustomization)
        assertSnapshot(of: vc, as: .image(on: SnapshotTestConfig.device, size: SnapshotTestConfig.size, traits: SnapshotTestConfig.lightTraits), record: SnapshotTestConfig.record)
    }

    func testSimpleNavigationBarView_StyleCustomization_Dark() throws {
        let vc = SimpleNavigationBarViewSnapshotViewController(category: .styleCustomization)
        assertSnapshot(of: vc, as: .image(on: SnapshotTestConfig.device, size: SnapshotTestConfig.size, traits: SnapshotTestConfig.darkTraits), record: SnapshotTestConfig.record)
    }
}
