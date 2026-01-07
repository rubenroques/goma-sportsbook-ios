import Foundation

/// Protocol defining the interface for SimpleNavigationBarView.
///
/// This protocol provides a simple, callback-based navigation bar suitable for
/// basic screens that need a back button and optional title.
///
/// ## Usage
/// Implement this protocol in your ViewModel or use `MockSimpleNavigationBarViewModel`
/// for testing and previews.
///
/// ## Example
/// ```swift
/// final class MyNavigationViewModel: SimpleNavigationBarViewModelProtocol {
///     let backButtonText: String? = "Back"
///     let title: String? = "Settings"
///     let showBackButton: Bool = true
///     let onBackTapped: () -> Void
///
///     init(onBackTapped: @escaping () -> Void) {
///         self.onBackTapped = onBackTapped
///     }
/// }
/// ```
public protocol SimpleNavigationBarViewModelProtocol {
    /// Optional text to display next to the back icon.
    ///
    /// - If `nil`: Only the back icon (chevron.left) is displayed
    /// - If set: Icon + text are displayed (e.g., "← Back")
    ///
    /// Common values: `nil` (icon only), `"Back"`, or localized("back")
    var backButtonText: String? { get }

    /// Optional centered title text for the navigation bar.
    ///
    /// - If `nil`: No title is displayed
    /// - If set: Title appears centered in the navigation bar
    ///
    /// The title respects the back button space and will not overlap it.
    var title: String? { get }

    /// Controls whether the back button is visible.
    ///
    /// Set to `false` for title-only navigation bars (e.g., root screens).
    ///
    /// Default: `true`
    var showBackButton: Bool { get }

    /// Callback executed when the back button is tapped.
    ///
    /// Typically used to trigger coordinator-based navigation:
    /// ```swift
    /// onBackTapped: { [weak self] in
    ///     self?.coordinator?.popViewController()
    /// }
    /// ```
    var onBackTapped: () -> Void { get }
}
