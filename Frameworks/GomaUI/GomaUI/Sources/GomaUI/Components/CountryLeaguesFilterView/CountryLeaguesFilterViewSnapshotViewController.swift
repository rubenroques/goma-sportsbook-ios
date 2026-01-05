import UIKit
import SwiftUI

// MARK: - Snapshot Category
enum CountryLeaguesFilterSnapshotCategory: String, CaseIterable {
    case basicStates = "Basic States"
}

final class CountryLeaguesFilterViewSnapshotViewController: UIViewController {

    private let category: CountryLeaguesFilterSnapshotCategory

    init(category: CountryLeaguesFilterSnapshotCategory) {
        self.category = category
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .backgroundTestColor
        setupUI()
    }

    private func setupUI() {
        let titleLabel = UILabel()
        titleLabel.text = "CountryLeaguesFilterView - \(category.rawValue)"
        titleLabel.font = StyleProvider.fontWith(type: .bold, size: 16)
        titleLabel.textColor = StyleProvider.Color.textPrimary
        titleLabel.translatesAutoresizingMaskIntoConstraints = false

        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false

        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 24
        stackView.alignment = .fill
        stackView.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(titleLabel)
        view.addSubview(scrollView)
        scrollView.addSubview(stackView)

        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),

            scrollView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 16),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            stackView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            stackView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: 16),
            stackView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor, constant: -16),
            stackView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            stackView.widthAnchor.constraint(equalTo: scrollView.widthAnchor, constant: -32)
        ])

        addVariants(to: stackView)
    }

    private func addVariants(to stackView: UIStackView) {
        switch category {
        case .basicStates:
            addBasicStatesVariants(to: stackView)
        }
    }

    // MARK: - Category Variants

    private func addBasicStatesVariants(to stackView: UIStackView) {
        // Multiple countries
        let countryLeagueOptions = [
            CountryLeagueOptions(
                id: "1",
                icon: "england_flag",
                title: "England",
                leagues: [
                    LeagueOption(id: "1", icon: nil, title: "Premier League", count: 25),
                    LeagueOption(id: "2", icon: nil, title: "Championship", count: 24)
                ],
                isExpanded: true
            ),
            CountryLeagueOptions(
                id: "2",
                icon: "france_flag",
                title: "France",
                leagues: [
                    LeagueOption(id: "3", icon: nil, title: "Ligue 1", count: 20)
                ],
                isExpanded: false
            ),
            CountryLeagueOptions(
                id: "3",
                icon: "germany_flag",
                title: "Germany",
                leagues: [
                    LeagueOption(id: "4", icon: nil, title: "Bundesliga", count: 18)
                ],
                isExpanded: false
            )
        ]

        let viewModel = MockCountryLeaguesFilterViewModel(
            title: "Popular Countries",
            countryLeagueOptions: countryLeagueOptions
        )

        stackView.addArrangedSubview(createLabeledVariant(
            label: "Multiple Countries",
            view: CountryLeaguesFilterView(viewModel: viewModel)
        ))
    }

    // MARK: - Helper Methods

    private func createLabeledVariant(label: String, view: UIView) -> UIStackView {
        let labelView = UILabel()
        labelView.text = label
        labelView.font = StyleProvider.fontWith(type: .medium, size: 12)
        labelView.textColor = StyleProvider.Color.textSecondary

        let stack = UIStackView(arrangedSubviews: [labelView, view])
        stack.axis = .vertical
        stack.spacing = 6
        stack.alignment = .fill
        return stack
    }
}

// MARK: - Preview
#if DEBUG
@available(iOS 17.0, *)
#Preview("Basic States") {
    CountryLeaguesFilterViewSnapshotViewController(category: .basicStates)
}
#endif
