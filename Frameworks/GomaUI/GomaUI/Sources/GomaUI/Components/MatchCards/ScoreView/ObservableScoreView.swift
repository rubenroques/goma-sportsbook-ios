import UIKit

/// A score view using @Observable + layoutSubviews() instead of Combine.
///
/// This is a proof of concept demonstrating Apple's automatic observation tracking:
/// - No Combine, no publishers, no setupBindings()
/// - Just read @Observable properties in layoutSubviews()
/// - UIKit automatically tracks and invalidates when properties change
///
/// Requires: iOS 18+ with UIObservationTrackingEnabled=true in Info.plist
/// (or iOS 26+ for native support without Info.plist key)
///
/// Reference: https://steipete.me/posts/2025/automatic-observation-tracking-uikit-appkit
public final class ObservableScoreView: UIView {

    // MARK: - ViewModel

    /// The @Observable ViewModel - no protocol needed!
    public var viewModel: ObservableScoreViewModel?

    // MARK: - UI Components (same as ScoreView)

    private lazy var containerStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .horizontal
        stackView.spacing = 4
        stackView.distribution = .fill
        stackView.alignment = .center
        stackView.backgroundColor = .clear
        stackView.setContentHuggingPriority(.required, for: .horizontal)
        stackView.setContentCompressionResistancePriority(.required, for: .horizontal)
        return stackView
    }()

    private lazy var loadingIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .medium)
        indicator.translatesAutoresizingMaskIntoConstraints = false
        indicator.color = StyleProvider.Color.highlightPrimary
        indicator.hidesWhenStopped = true
        return indicator
    }()

    private lazy var emptyLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = LocalizationProvider.string("no_scores")
        label.font = StyleProvider.fontWith(type: .regular, size: 14)
        label.textAlignment = .center
        label.numberOfLines = 1
        label.textColor = StyleProvider.Color.highlightSecondary
        return label
    }()

    private var emptyLabelConstraints: [NSLayoutConstraint] = []

    // MARK: - Initialization

    public override init(frame: CGRect) {
        super.init(frame: frame)
        setupSubviews()
        setupConstraints()
    }

    public required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupSubviews()
        setupConstraints()
    }

    // MARK: - Intrinsic Content Size

    public override var intrinsicContentSize: CGSize {
        let stackIntrinsicSize = containerStackView.intrinsicContentSize
        return CGSize(width: stackIntrinsicSize.width, height: 42)
    }

    // MARK: - Configuration

    /// Configure with an @Observable ViewModel
    public func configure(with viewModel: ObservableScoreViewModel) {
        self.viewModel = viewModel
        setNeedsLayout()  // Trigger initial render via layoutSubviews()
    }

    // MARK: - The Magic: layoutSubviews()

    /// UIKit automatically tracks @Observable property accesses here!
    /// When viewModel.visualState or viewModel.scoreCells change,
    /// UIKit will call setNeedsLayout() automatically.
    public override func layoutSubviews() {
        super.layoutSubviews()

        guard let viewModel = viewModel else { return }

        // Just read the properties - UIKit tracks these automatically!
        updateVisualState(viewModel.visualState)
        updateScoreCells(viewModel.scoreCells)
    }

    // MARK: - Setup

    private func setupSubviews() {
        translatesAutoresizingMaskIntoConstraints = false
        backgroundColor = .clear

        addSubview(containerStackView)
        addSubview(loadingIndicator)
        addSubview(emptyLabel)

        loadingIndicator.isHidden = true
        emptyLabel.isHidden = true

        setContentHuggingPriority(.required, for: .horizontal)
        setContentCompressionResistancePriority(.required, for: .horizontal)
    }

    private func setupConstraints() {
        NSLayoutConstraint.activate([
            containerStackView.topAnchor.constraint(equalTo: topAnchor),
            containerStackView.trailingAnchor.constraint(equalTo: trailingAnchor),
            containerStackView.bottomAnchor.constraint(equalTo: bottomAnchor),
            containerStackView.leadingAnchor.constraint(greaterThanOrEqualTo: leadingAnchor),

            loadingIndicator.centerXAnchor.constraint(equalTo: centerXAnchor),
            loadingIndicator.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])

        emptyLabelConstraints = [
            emptyLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
            emptyLabel.centerYAnchor.constraint(equalTo: centerYAnchor),
            emptyLabel.leadingAnchor.constraint(greaterThanOrEqualTo: leadingAnchor, constant: 8),
            emptyLabel.trailingAnchor.constraint(lessThanOrEqualTo: trailingAnchor, constant: -8)
        ]
    }

    // MARK: - Rendering (same as ScoreView)

    private func updateVisualState(_ state: ScoreDisplayData.VisualState) {
        NSLayoutConstraint.deactivate(emptyLabelConstraints)

        switch state {
        case .idle:
            containerStackView.isHidden = false
            loadingIndicator.isHidden = true
            loadingIndicator.stopAnimating()
            emptyLabel.isHidden = true

        case .loading:
            containerStackView.isHidden = true
            loadingIndicator.isHidden = false
            loadingIndicator.startAnimating()
            emptyLabel.isHidden = true

        case .display:
            containerStackView.isHidden = false
            loadingIndicator.isHidden = true
            loadingIndicator.stopAnimating()
            emptyLabel.isHidden = true

        case .empty:
            containerStackView.isHidden = true
            loadingIndicator.isHidden = true
            loadingIndicator.stopAnimating()
            emptyLabel.isHidden = false
            NSLayoutConstraint.activate(emptyLabelConstraints)
        }

        invalidateIntrinsicContentSize()
    }

    private func updateScoreCells(_ scoreCells: [ScoreDisplayData]) {
        clearScoreCells()

        for (index, scoreData) in scoreCells.enumerated() {
            // Add serving indicator column as FIRST element
            if index == 0 && scoreData.servingPlayer != nil {
                let servingIndicator = ServingIndicatorView(servingPlayer: scoreData.servingPlayer)
                containerStackView.addArrangedSubview(servingIndicator)
            }

            // Add score cell
            let cellView = ScoreCellView(data: scoreData)
            containerStackView.addArrangedSubview(cellView)

            // Add separator line if needed
            if scoreData.showsTrailingSeparator {
                let separator = createSeparatorLine()
                containerStackView.addArrangedSubview(separator)
            }
        }

        invalidateIntrinsicContentSize()
    }

    private func clearScoreCells() {
        containerStackView.arrangedSubviews.forEach { view in
            containerStackView.removeArrangedSubview(view)
            view.removeFromSuperview()
        }
    }

    private func createSeparatorLine() -> UIView {
        let separator = UIView()
        separator.translatesAutoresizingMaskIntoConstraints = false
        separator.backgroundColor = StyleProvider.Color.separatorLine
        separator.widthAnchor.constraint(equalToConstant: 1).isActive = true
        return separator
    }
}

// MARK: - SwiftUI Preview

#if DEBUG
import SwiftUI

#Preview("ObservableScoreView - Tennis") {
    PreviewUIViewController {
        let vc = UIViewController()
        vc.view.backgroundColor = .systemGray6

        let scoreView = ObservableScoreView()
        scoreView.configure(with: .tennisMatch)

        vc.view.addSubview(scoreView)

        NSLayoutConstraint.activate([
            scoreView.centerXAnchor.constraint(equalTo: vc.view.centerXAnchor),
            scoreView.centerYAnchor.constraint(equalTo: vc.view.centerYAnchor)
        ])

        return vc
    }
}

#Preview("ObservableScoreView - Basketball") {
    PreviewUIViewController {
        let vc = UIViewController()
        vc.view.backgroundColor = .systemGray6

        let scoreView = ObservableScoreView()
        scoreView.configure(with: .basketballMatch)

        vc.view.addSubview(scoreView)

        NSLayoutConstraint.activate([
            scoreView.centerXAnchor.constraint(equalTo: vc.view.centerXAnchor),
            scoreView.centerYAnchor.constraint(equalTo: vc.view.centerYAnchor)
        ])

        return vc
    }
}
#endif
