import UIKit

/// A score view using @Observable + layoutSubviews() instead of Combine.
///
/// This demonstrates Apple's automatic observation tracking with protocol-based architecture:
/// - No Combine, no publishers, no setupBindings()
/// - Just read @Observable properties in layoutSubviews()
/// - UIKit automatically tracks and invalidates when properties change
/// - Protocol enables different implementations per client (GomaUI mock, BetssonCameroon production, etc.)
///
/// Requires: iOS 18+ with UIObservationTrackingEnabled=true in Info.plist
/// (or iOS 26+ for native support without Info.plist key)
///
/// Reference: https://steipete.me/posts/2025/automatic-observation-tracking-uikit-appkit
public final class ObservableScoreView: UIView {

    // MARK: - ViewModel

    /// The @Observable ViewModel via protocol - enables dependency injection
    public var viewModel: (any ObservableScoreViewModelProtocol)?

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

    /// Configure with an @Observable ViewModel (any implementation conforming to protocol)
    public func configure(with viewModel: any ObservableScoreViewModelProtocol) {
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
        scoreView.configure(with: MockObservableScoreViewModel.tennisMatch)

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
        scoreView.configure(with: MockObservableScoreViewModel.basketballMatch)

        vc.view.addSubview(scoreView)

        NSLayoutConstraint.activate([
            scoreView.centerXAnchor.constraint(equalTo: vc.view.centerXAnchor),
            scoreView.centerYAnchor.constraint(equalTo: vc.view.centerYAnchor)
        ])

        return vc
    }
}

/// Interactive preview to test @Observable automatic updates
/// Tap buttons to mutate ViewModel - view should update automatically!
#Preview("Interactive - Test @Observable Updates") {
    PreviewUIViewController {
        InteractiveObservableScoreViewController()
    }
}

private final class InteractiveObservableScoreViewController: UIViewController {

    private let viewModel = MockObservableScoreViewModel.tennisMatch
    private let scoreView = ObservableScoreView()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        setupUI()
        scoreView.configure(with: viewModel)
    }

    private func setupUI() {
        let titleLabel = UILabel()
        titleLabel.text = "@Observable Auto-Update Test"
        titleLabel.font = .boldSystemFont(ofSize: 17)
        titleLabel.textAlignment = .center

        let subtitleLabel = UILabel()
        subtitleLabel.text = "Tap buttons to mutate ViewModel.\nView updates automatically via layoutSubviews()!"
        subtitleLabel.font = .systemFont(ofSize: 12)
        subtitleLabel.textColor = .secondaryLabel
        subtitleLabel.textAlignment = .center
        subtitleLabel.numberOfLines = 0

        let scoreContainer = UIView()
        scoreContainer.backgroundColor = .secondarySystemBackground
        scoreContainer.layer.cornerRadius = 8

        scoreView.translatesAutoresizingMaskIntoConstraints = false
        scoreContainer.addSubview(scoreView)

        let sportLabel = UILabel()
        sportLabel.text = "Change Sport:"
        sportLabel.font = .systemFont(ofSize: 13, weight: .medium)
        sportLabel.textColor = .secondaryLabel

        let tennisButton = makeButton(title: "Tennis", action: #selector(setTennis))
        let footballButton = makeButton(title: "Football", action: #selector(setFootball))
        let basketballButton = makeButton(title: "Basketball", action: #selector(setBasketball))

        let sportStack = UIStackView(arrangedSubviews: [tennisButton, footballButton, basketballButton])
        sportStack.axis = .horizontal
        sportStack.spacing = 8
        sportStack.distribution = .fillEqually

        let stateLabel = UILabel()
        stateLabel.text = "Change State:"
        stateLabel.font = .systemFont(ofSize: 13, weight: .medium)
        stateLabel.textColor = .secondaryLabel

        let loadingButton = makeButton(title: "Loading", action: #selector(setLoading))
        let emptyButton = makeButton(title: "Empty", action: #selector(setEmpty))
        let randomButton = makeButton(title: "Random Score", action: #selector(setRandom))
        randomButton.configuration?.baseBackgroundColor = .systemBlue

        let stateStack = UIStackView(arrangedSubviews: [loadingButton, emptyButton, randomButton])
        stateStack.axis = .horizontal
        stateStack.spacing = 8
        stateStack.distribution = .fillEqually

        let mainStack = UIStackView(arrangedSubviews: [
            titleLabel, subtitleLabel, scoreContainer,
            sportLabel, sportStack, stateLabel, stateStack
        ])
        mainStack.axis = .vertical
        mainStack.spacing = 16
        mainStack.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(mainStack)

        NSLayoutConstraint.activate([
            mainStack.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            mainStack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            mainStack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),

            scoreContainer.heightAnchor.constraint(equalToConstant: 60),
            scoreView.centerXAnchor.constraint(equalTo: scoreContainer.centerXAnchor),
            scoreView.centerYAnchor.constraint(equalTo: scoreContainer.centerYAnchor)
        ])
    }

    private func makeButton(title: String, action: Selector) -> UIButton {
        var config = UIButton.Configuration.bordered()
        config.title = title
        config.buttonSize = .small
        let button = UIButton(configuration: config)
        button.addTarget(self, action: action, for: .touchUpInside)
        return button
    }

    @objc private func setTennis() {
        viewModel.visualState = .display
        viewModel.scoreCells = [
            ScoreDisplayData(id: "game", homeScore: "30", awayScore: "15", style: .background, servingPlayer: .home),
            ScoreDisplayData(id: "set1", homeScore: "6", awayScore: "4", style: .simple),
            ScoreDisplayData(id: "set2", homeScore: "3", awayScore: "5", style: .simple)
        ]
    }

    @objc private func setFootball() {
        viewModel.visualState = .display
        viewModel.scoreCells = [
            ScoreDisplayData(id: "score", homeScore: "2", awayScore: "1", style: .background)
        ]
    }

    @objc private func setBasketball() {
        viewModel.visualState = .display
        viewModel.scoreCells = [
            ScoreDisplayData(id: "q1", homeScore: "28", awayScore: "24", style: .simple),
            ScoreDisplayData(id: "q2", homeScore: "31", awayScore: "29", style: .simple),
            ScoreDisplayData(id: "total", homeScore: "59", awayScore: "53", style: .background)
        ]
    }

    @objc private func setLoading() {
        viewModel.setLoading()
    }

    @objc private func setEmpty() {
        viewModel.setEmpty()
    }

    @objc private func setRandom() {
        viewModel.visualState = .display
        viewModel.scoreCells = [
            ScoreDisplayData(
                id: "score",
                homeScore: "\(Int.random(in: 0...5))",
                awayScore: "\(Int.random(in: 0...5))",
                style: .background
            )
        ]
    }
}
#endif
