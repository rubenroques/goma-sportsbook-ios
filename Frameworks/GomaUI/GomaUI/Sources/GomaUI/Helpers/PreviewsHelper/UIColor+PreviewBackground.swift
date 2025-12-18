import UIKit

/// Extension providing a dedicated background color for SwiftUI previews
/// that provides good contrast and supports light/dark appearance
extension UIColor {

    /// A test background color specifically designed for SwiftUI previews.
    /// Provides good contrast with most components and adapts to light/dark mode.
    /// Neutral gray to differentiate from component backgrounds.
    ///
    /// **Light mode**: Medium light gray (#E0E0E0)
    /// **Dark mode**: Dark gray (#1C1C1C)
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
                // Dark mode: Neutral dark gray
                return UIColor(red: 0.11, green: 0.11, blue: 0.11, alpha: 1.0)
            case .light, .unspecified:
                // Light mode: Medium light gray
                return UIColor(red: 0.88, green: 0.88, blue: 0.88, alpha: 1.0)
            @unknown default:
                return UIColor(red: 0.88, green: 0.88, blue: 0.88, alpha: 1.0)
            }
        }
    }
}
