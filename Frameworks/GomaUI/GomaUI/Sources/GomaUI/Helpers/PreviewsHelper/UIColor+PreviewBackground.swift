import UIKit

/// Extension providing a dedicated background color for SwiftUI previews
/// that provides good contrast and supports light/dark appearance
extension UIColor {

    /// A test background color specifically designed for SwiftUI previews.
    /// Provides good contrast with most components and adapts to light/dark mode.
    /// Has a subtle red tint to differentiate from component backgrounds.
    ///
    /// **Light mode**: Very light gray with red tint (#F8F6F6)
    /// **Dark mode**: Dark gray with red tint (#1E1C1C)
    ///
    /// **Usage in previews**:
    /// ```swift
    /// #Preview("MyComponent") {
    ///     PreviewUIViewController {
    ///         let vc = UIViewController()
    ///         vc.view.backgroundColor = .backgroundTestColor
    ///         // ... rest of preview setup
    ///     }
    /// }
    /// ```
    public static var backgroundTestColor: UIColor {
        return UIColor { traitCollection in
            switch traitCollection.userInterfaceStyle {
            case .dark:
                // Dark mode: Dark gray with subtle red tint
                return UIColor(red: 0.19, green: 0.11, blue: 0.11, alpha: 1.0)
            case .light, .unspecified:
                // Light mode: Very light gray with subtle red tint
                return UIColor(red: 0.99, green: 0.96, blue: 0.96, alpha: 1.0)
            @unknown default:
                return UIColor(red: 0.99, green: 0.96, blue: 0.96, alpha: 1.0)
            }
        }
    }
}
