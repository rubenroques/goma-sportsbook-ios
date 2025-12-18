import SnapshotTesting
import UIKit

enum SnapshotTestConfig {
    static let device: ViewImageConfig = .iPhone8
    static let size: CGSize = CGSize(width: 414, height: 860)

    /// Set to `true` to record new reference images, `false` to compare against existing
    static let record: Bool = true

    /// Light mode traits
    static let lightTraits = UITraitCollection(userInterfaceStyle: .light)

    /// Dark mode traits
    static let darkTraits = UITraitCollection(userInterfaceStyle: .dark)
}
