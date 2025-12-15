import Foundation
import UIKit
import GomaUI

class CountryLeaguesFilterViewController: UIViewController {
    private let countryLeaguesFilterView: CountryLeaguesFilterView
    private let viewModel: CountryLeaguesFilterViewModelProtocol

    init() {
        self.viewModel = MockCountryLeaguesFilterViewModel(
            title: "Country Leagues",
            countryLeagueOptions: [
                CountryLeagueOptions(
                    id: "us",
                    icon: "us",
                    title: "United States",
                    leagues: [
                        LeagueOption(id: "nba", icon: nil, title: "NBA", count: 30),
                        LeagueOption(id: "wnba", icon: nil, title: "WNBA", count: 12)
                    ],
                    isExpanded: true
                ),
                CountryLeagueOptions(
                    id: "es",
                    icon: "es",
                    title: "Spain",
                    leagues: [
                        LeagueOption(id: "acb", icon: nil, title: "ACB", count: 18),
                        LeagueOption(id: "leb", icon: nil, title: "LEB Oro", count: 18)
                    ],
                    isExpanded: false
                )
            ],
            selectedId: "nba"
        )
        self.countryLeaguesFilterView = CountryLeaguesFilterView(viewModel: viewModel)
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        setupCountryLeaguesFilterView()
    }

    private func setupCountryLeaguesFilterView() {
        countryLeaguesFilterView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(countryLeaguesFilterView)
        NSLayoutConstraint.activate([
            countryLeaguesFilterView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            countryLeaguesFilterView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            countryLeaguesFilterView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16)
        ])
    }
}
