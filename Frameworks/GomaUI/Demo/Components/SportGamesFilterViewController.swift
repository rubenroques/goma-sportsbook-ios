import Foundation
import UIKit
import GomaUI
import SharedModels

class SportGamesFilterViewController: UIViewController {
    private let sportGamesFilterView: SportGamesFilterView
    private let viewModel: SportGamesFilterViewModelProtocol

    init() {
        // Use a mock or real view model as needed
        self.viewModel = MockSportGamesFilterViewModel(
            title: "Sports",
            sportFilters: [
                SportFilter(id: "1", title: "Football", icon: "sport_icon"),
                SportFilter(id: "2", title: "Basketball", icon: "sport_icon"),
                SportFilter(id: "3", title: "Tennis", icon: "sport_icon"),
                SportFilter(id: "4", title: "Voleyball", icon: "sport_icon")
            ],
            selectedSport: .singleSport(id: "1")
        )
        self.sportGamesFilterView = SportGamesFilterView(viewModel: viewModel)
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        setupSportGamesFilterView()
    }

    private func setupSportGamesFilterView() {
        sportGamesFilterView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(sportGamesFilterView)
        NSLayoutConstraint.activate([
            sportGamesFilterView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            sportGamesFilterView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            sportGamesFilterView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16)
        ])
    }
}
