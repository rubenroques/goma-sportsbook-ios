import UIKit
import GomaUI

class MatchBannerViewController: UIViewController {

    // MARK: - Private Properties
    private lazy var scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.showsVerticalScrollIndicator = true
        return scrollView
    }()

    private lazy var contentStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.spacing = 24
        stackView.alignment = .fill
        stackView.distribution = .fill
        return stackView
    }()

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        setupComponents()
    }

    // MARK: - Setup
    private func setupView() {
        title = "Match Banner"
        view.backgroundColor = StyleProvider.Color.backgroundTertiary

        view.addSubview(scrollView)
        scrollView.addSubview(contentStackView)

        NSLayoutConstraint.activate([
            // Scroll view
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            // Content stack view
            contentStackView.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: 16),
            contentStackView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: 16),
            contentStackView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor, constant: -16),
            contentStackView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor, constant: -16),
            contentStackView.widthAnchor.constraint(equalTo: scrollView.widthAnchor, constant: -32)
        ])
    }

    private func setupComponents() {
        // Section: Prelive Match
        addSectionHeader("Prelive Match")
        addMatchBanner(with: MockMatchBannerViewModel.preliveMatch)

        // Section: Live Match
        addSectionHeader("Live Match")
        addMatchBanner(with: MockMatchBannerViewModel.liveMatch)

        // Section: Interactive Match
        addSectionHeader("Interactive Match")
        addMatchBanner(with: MockMatchBannerViewModel.interactiveMatch)

        // Section: Empty State
        addSectionHeader("Empty State")
        addMatchBanner(with: MockMatchBannerViewModel.emptyState)

        // Section: Custom Match (El Clásico)
        addSectionHeader("Custom Match Example")
        addMatchBanner(with: createCustomMatch())
    }

    private func addSectionHeader(_ title: String) {
        let headerLabel = UILabel()
        headerLabel.translatesAutoresizingMaskIntoConstraints = false
        headerLabel.text = title
        headerLabel.font = StyleProvider.fontWith(type: .bold, size: 18)
        headerLabel.textColor = StyleProvider.Color.textPrimary
        headerLabel.numberOfLines = 1

        contentStackView.addArrangedSubview(headerLabel)
    }

    private func addMatchBanner(with viewModel: MockMatchBannerViewModel) {
        let bannerView = MatchBannerView()
        bannerView.configure(with: viewModel)
        bannerView.translatesAutoresizingMaskIntoConstraints = false

        // Container view for better visual separation
        let containerView = UIView()
        containerView.translatesAutoresizingMaskIntoConstraints = false
        containerView.backgroundColor = .clear
        containerView.layer.cornerRadius = 12
        containerView.clipsToBounds = true

        containerView.addSubview(bannerView)

        NSLayoutConstraint.activate([
            bannerView.topAnchor.constraint(equalTo: containerView.topAnchor),
            bannerView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            bannerView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            bannerView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor),
            bannerView.heightAnchor.constraint(equalToConstant: 136)
        ])

        contentStackView.addArrangedSubview(containerView)
    }

    private func createCustomMatch() -> MockMatchBannerViewModel {
        let outcomes = [
            MatchOutcome(id: "home", displayName: "Liverpool", odds: 1.75),
            MatchOutcome(id: "draw", displayName: "Draw", odds: 4.20),
            MatchOutcome(id: "away", displayName: "Chelsea", odds: 4.50)
        ]

        let matchData = MatchBannerModel(
            id: "match_custom",
            isLive: true,
            dateTime: Date(),
            leagueName: "Premier League",
            homeTeam: "Liverpool",
            awayTeam: "Chelsea",
            backgroundImageURL: "https://example.com/liverpool_chelsea_bg.jpg",
            matchTime: "2nd Half, 78 Min",
            homeScore: 2,
            awayScore: 0,
            outcomes: outcomes
        )

        return MockMatchBannerViewModel(
            matchData: matchData,
            onBannerTapped: { [weak self] in
                self?.showAlert(title: "Banner Tapped", message: "Liverpool vs Chelsea match opened!")
            },
            onOutcomeTapped: { [weak self] outcomeId, isSelected in
                let action = isSelected ? "selected" : "deselected"
                self?.showAlert(title: "Outcome \(action.capitalized)", message: "Outcome ID: \(outcomeId)")
            }
        )
    }

    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}

// MARK: - Preview Support
extension MatchBannerViewController {
    static func makePreview() -> MatchBannerViewController {
        return MatchBannerViewController()
    }
}