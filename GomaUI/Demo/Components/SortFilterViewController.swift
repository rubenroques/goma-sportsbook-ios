//
//  SortFilterViewController.swift
//  Demo
//
//  Created by André Lascas on 23/06/2025.
//

import Foundation
import UIKit
import GomaUI

class SortFilterViewController: UIViewController {
    private let sortFilterView: SortFilterView
    private let viewModel: SortFilterViewModelProtocol

    init() {
        self.viewModel = MockSortFilterViewModel(
            title: "Sort By",
            sortOptions: [
                SortOption(id: "1", icon: "flame.fill", title: "Popular", count: 25),
                SortOption(id: "2", icon: "clock.fill", title: "Upcoming", count: 15),
                SortOption(id: "3", icon: "heart.fill", title: "Favourites", count: 0)
            ],
            selectedId: "1"
        )
        self.sortFilterView = SortFilterView(viewModel: viewModel)
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        setupSortFilterView()
    }

    private func setupSortFilterView() {
        sortFilterView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(sortFilterView)
        NSLayoutConstraint.activate([
            sortFilterView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            sortFilterView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            sortFilterView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16)
        ])
    }
}
