import UIKit

/// A dedicated column view that displays the serving indicator for tennis/volleyball matches
class ServingIndicatorView: UIView {

    // MARK: - Private Properties
    private lazy var homeIndicator: UIView = Self.createIndicator()
    private lazy var awayIndicator: UIView = Self.createIndicator()

    private let servingPlayer: ScoreDisplayData.ServingPlayer?

    // MARK: - Initialization
    init(servingPlayer: ScoreDisplayData.ServingPlayer?) {
        self.servingPlayer = servingPlayer
        super.init(frame: .zero)
        setupSubviews()
        setupConstraints()
        updateIndicators()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Private Methods
    private func setupSubviews() {
        translatesAutoresizingMaskIntoConstraints = false
        addSubview(homeIndicator)
        addSubview(awayIndicator)

        setContentHuggingPriority(.required, for: .horizontal)
        setContentHuggingPriority(.required, for: .vertical)
    }

    private func setupConstraints() {
        NSLayoutConstraint.activate([
            // Fixed width for indicator column
            widthAnchor.constraint(equalToConstant: 14),
            heightAnchor.constraint(equalToConstant: 42),

            // Home indicator (top half, vertically centered)
            homeIndicator.centerYAnchor.constraint(equalTo: topAnchor, constant: 10),
            homeIndicator.centerXAnchor.constraint(equalTo: centerXAnchor),
            homeIndicator.widthAnchor.constraint(equalToConstant: 6),
            homeIndicator.heightAnchor.constraint(equalToConstant: 6),

            // Away indicator (bottom half, vertically centered)
            awayIndicator.centerYAnchor.constraint(equalTo: bottomAnchor, constant: -10),
            awayIndicator.centerXAnchor.constraint(equalTo: centerXAnchor),
            awayIndicator.widthAnchor.constraint(equalToConstant: 6),
            awayIndicator.heightAnchor.constraint(equalToConstant: 6)
        ])
    }

    private func updateIndicators() {
        homeIndicator.isHidden = servingPlayer != .home
        awayIndicator.isHidden = servingPlayer != .away
    }

    // MARK: - Factory Methods
    private static func createIndicator() -> UIView {
        let indicator = UIView()
        indicator.translatesAutoresizingMaskIntoConstraints = false
        indicator.backgroundColor = StyleProvider.Color.highlightPrimary
        indicator.layer.cornerRadius = 3
        indicator.isHidden = true
        return indicator
    }
}
