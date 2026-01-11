import SnapshotTesting
import UIKit

enum SnapshotTestConfig {
    static let device: ViewImageConfig = .iPhone8
    static let size: CGSize = CGSize(width: 414, height: 860)

    /// Set to `true` to record new reference images, `false` to compare against existing
    static let record: Bool = false

    /// Light mode traits
    static let lightTraits = UITraitCollection(userInterfaceStyle: .light)

    /// Dark mode traits
    static let darkTraits = UITraitCollection(userInterfaceStyle: .dark)

    // MARK: - Async Rendering Workaround

    /// Workaround for components that use `.receive(on: DispatchQueue.main)` without
    /// synchronous initial rendering via `currentDisplayState`.
    ///
    /// Call this before `assertSnapshot` to allow Combine publishers to emit.
    ///
    /// **Proper fix**: Migrate component to use `currentDisplayState + dropFirst()` pattern
    /// or scheduler injection (see ToasterView as reference).
    static func waitForCombineRendering(_ viewController: UIViewController) {
        viewController.loadViewIfNeeded()
        RunLoop.main.run(until: Date(timeIntervalSinceNow: 0.1))
    }
}
