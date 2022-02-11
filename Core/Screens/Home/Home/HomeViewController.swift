//
//  HomeViewController.swift
//  Sportsbook
//
//  Created by Ruben Roques on 07/02/2022.
//

import UIKit
import Combine
import Nuke

class HomeViewController: UIViewController {

    // MARK: - Private Properties
    private lazy var topSliderBaseView: UIView = {
        var view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private lazy var topSliderCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal

        var collectionView = UICollectionView.init(frame: .zero, collectionViewLayout: layout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.showsVerticalScrollIndicator = false
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.alwaysBounceHorizontal = true
        return collectionView
    }()

    private lazy var tableView: UITableView = {
        var tableView = UITableView.init(frame: .zero, style: .grouped)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.separatorStyle = .none
        return tableView
    }()

    private lazy var loadingBaseView: UIView = {
        var view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private lazy var loadingActivityIndicatorView: UIActivityIndicatorView = {
        var activityIndicatorView = UIActivityIndicatorView.init(style: .large)
        activityIndicatorView.translatesAutoresizingMaskIntoConstraints = false
        activityIndicatorView.hidesWhenStopped = true
        activityIndicatorView.stopAnimating()
        return activityIndicatorView
    }()

    private var cancellables: Set<AnyCancellable> = []
    private let viewModel: HomeViewModel

    // MARK: - Lifetime and Cycle
    init(viewModel: HomeViewModel = HomeViewModel()) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    @available(iOS, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        self.setupSubviews()
        self.setupWithTheme()
        self.bind(toViewModel: self.viewModel)
    }

    // MARK: - Layout and Theme
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)

        self.setupWithTheme()
    }

    private func setupWithTheme() {
        self.topSliderBaseView.backgroundColor = UIColor.App.backgroundSecondary
        self.loadingBaseView.backgroundColor = UIColor.black.withAlphaComponent(0.7)
        self.loadingActivityIndicatorView.tintColor = UIColor.gray

        self.topSliderCollectionView.backgroundView?.backgroundColor = .clear
        self.topSliderCollectionView.backgroundColor = .clear
    }

    // MARK: - Bindings
    private func bind(toViewModel viewModel: HomeViewModel) {
        viewModel.title
            .sink(receiveValue: { _ in
                // Do something with the new title
            })
            .store(in: &self.cancellables)

        viewModel.dataChangedPublisher
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] in
                self?.tableView.reloadData()
            })
            .store(in: &self.cancellables)

    }

}

// MARK: - CollectionView Protocols
//
extension HomeViewController: UICollectionViewDelegate, UICollectionViewDataSource {

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 0
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        fatalError()
    }

}

// MARK: - TableView Protocols
//
extension HomeViewController: UITableViewDelegate, UITableViewDataSource {

    func numberOfSections(in tableView: UITableView) -> Int {
        return self.viewModel.numberOfSections()
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.viewModel.numberOfRows(forSectionIndex: section)
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        guard
            let contentType = self.viewModel.contentType(forSection: indexPath.section)
        else {
            fatalError()
        }

        switch contentType {
        case .userMessage:
            return UITableViewCell()
        case .bannerLine:
            return UITableViewCell()
        case .userFavorites:
            return UITableViewCell()
        case .sport:
            guard
                let cell = tableView.dequeueReusableCell(withIdentifier: SportLineTableViewCell.identifier)
            else {
                fatalError()
            }
            return cell
        }
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }

    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 356
    }

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return self.viewModel.title(forSection: section)
    }
}

// MARK: - Subviews Initialization and Setup
//
extension HomeViewController {

    private func setupSubviews() {
        // Add subviews to self.view or each other
        self.view.addSubview(self.topSliderBaseView)
        self.topSliderBaseView.addSubview(self.topSliderCollectionView)

        self.view.addSubview(self.tableView)

        self.view.addSubview(self.loadingBaseView)
        self.loadingBaseView.addSubview(self.loadingActivityIndicatorView)

        // Configure post-loading and self-dependent properties
        self.tableView.delegate = self
        self.tableView.dataSource = self

        self.tableView.register(SportLineTableViewCell.self, forCellReuseIdentifier: SportLineTableViewCell.identifier)

        self.loadingBaseView.isHidden = true

        // Initialize constraints
        self.initConstraints()
    }

    private func initConstraints() {

        NSLayoutConstraint.activate([
            self.topSliderBaseView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            self.topSliderBaseView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            self.topSliderBaseView.topAnchor.constraint(equalTo: self.view.topAnchor),
            self.topSliderBaseView.heightAnchor.constraint(equalToConstant: 70),

            self.topSliderCollectionView.leadingAnchor.constraint(equalTo: self.topSliderBaseView.leadingAnchor),
            self.topSliderCollectionView.trailingAnchor.constraint(equalTo: self.topSliderBaseView.trailingAnchor),
            self.topSliderCollectionView.topAnchor.constraint(equalTo: self.topSliderBaseView.topAnchor),
            self.topSliderCollectionView.bottomAnchor.constraint(equalTo: self.topSliderBaseView.bottomAnchor),
        ])

        NSLayoutConstraint.activate([
            self.tableView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            self.tableView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            self.tableView.topAnchor.constraint(equalTo: self.topSliderBaseView.bottomAnchor),
            self.tableView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor)
        ])

        NSLayoutConstraint.activate([
            self.loadingBaseView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            self.loadingBaseView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            self.loadingBaseView.topAnchor.constraint(equalTo: self.view.topAnchor),
            self.loadingBaseView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor),

            self.loadingActivityIndicatorView.centerXAnchor.constraint(equalTo: self.loadingBaseView.centerXAnchor),
            self.loadingActivityIndicatorView.centerYAnchor.constraint(equalTo: self.loadingBaseView.centerYAnchor),
        ])
    }

}
