import Foundation

/// Protocol defining the interface for ObservableScoreView's ViewModel.
///
/// Implementations MUST be `@Observable` classes for UIKit's automatic
/// observation tracking to work in `layoutSubviews()`.
///
/// This protocol enables:
/// - GomaUI to provide MockObservableScoreViewModel for previews/tests
/// - Clients (BetssonCameroon, BetssonFrance) to provide production implementations
/// - Dependency inversion - View depends on abstraction, not concrete type
@MainActor
public protocol ObservableScoreViewModelProtocol: AnyObject {

    /// Current visual state of the score view
    var visualState: ScoreDisplayData.VisualState { get }

    /// Score cells to display
    var scoreCells: [ScoreDisplayData] { get }
}
