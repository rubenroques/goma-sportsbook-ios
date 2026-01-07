import UIKit

/// Individual progress segment view with animated fill state transitions
final class ProgressSegmentView: UIView {

    // MARK: - Properties
    private var isFilled: Bool = false

    // MARK: - Initialization
    init() {
        super.init(frame: .zero)
        setupView()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Setup
    private func setupView() {
        translatesAutoresizingMaskIntoConstraints = false
        backgroundColor = StyleProvider.Color.backgroundBorder
        layer.cornerRadius = 4
    }

    // MARK: - Public API

    /// Updates the fill state of the segment with optional animation
    /// - Parameters:
    ///   - filled: Whether the segment should be filled (true) or empty (false)
    ///   - animated: Whether to animate the transition (default: true)
    func setFilled(_ filled: Bool, animated: Bool = true) {
        // Early return if state hasn't changed
        guard isFilled != filled else { return }
        isFilled = filled

        let targetColor = filled
            ? StyleProvider.Color.highlightSecondary
            : StyleProvider.Color.backgroundBorder

        if animated {
            UIView.animate(
                withDuration: 0.3,
                delay: 0,
                options: [.curveEaseInOut],
                animations: {
                    self.backgroundColor = targetColor
                }
            )
        } else {
            backgroundColor = targetColor
        }
    }
}
