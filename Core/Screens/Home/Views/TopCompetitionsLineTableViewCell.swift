//
//  File.swift
//  Sportsbook
//
//  Created by Ruben Roques on 05/06/2023.
//

import Foundation
import UIKit
import Combine
import ServicesProvider

class TopCompetitionsLineCellViewModel {

    var topCompetitions: [TopCompetitionItemCellViewModel] = []
    
    var isEmpty: Bool {
        self.topCompetitions.isEmpty
    }
    
    init(topCompetitions: [TopCompetitionItemCellViewModel]) {
        self.topCompetitions = topCompetitions
    }

}

class TopCompetitionsLineTableViewCell: UITableViewCell, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

    var selectedItemAction: (String) -> Void = { _ in }

    var viewModel: TopCompetitionsLineCellViewModel?
    var cachedCellViewModels: [String: TopCompetitionItemCellViewModel] = [:]

    private let cellHeight: CGFloat = 124
    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.sectionInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        layout.minimumLineSpacing = 14

        var collectionView = UICollectionView(frame: self.bounds, collectionViewLayout: layout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.showsHorizontalScrollIndicator = false
        return collectionView
    }()

    private lazy var loadingView: UIActivityIndicatorView = {
        let loadingView = UIActivityIndicatorView(style: .medium)
        loadingView.translatesAutoresizingMaskIntoConstraints = false
        loadingView.hidesWhenStopped = true
        return loadingView
    }()

    private var cancellables = Set<AnyCancellable>()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.setupSubviews()
        self.setupWithTheme()
    }

    @available(iOS, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        self.setupWithTheme()
    }

    func setupWithTheme() {
        self.backgroundColor = .clear
        self.backgroundView?.backgroundColor = .clear
        self.contentView.backgroundColor = .clear

        self.collectionView.backgroundView?.backgroundColor = .clear
        self.collectionView.backgroundColor = .clear

        self.loadingView.color = .gray
    }

    private func setupSubviews() {

        self.collectionView.dataSource = self
        self.collectionView.delegate = self
        self.collectionView.register(TopCompetitionItemCollectionViewCell.self,
                                     forCellWithReuseIdentifier: TopCompetitionItemCollectionViewCell.identifier)

        self.contentView.addSubview(self.collectionView)
        self.contentView.addSubview(self.loadingView)

        NSLayoutConstraint.activate([
            self.collectionView.heightAnchor.constraint(equalToConstant: self.cellHeight),
            self.collectionView.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor),
            self.collectionView.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor),
            self.collectionView.topAnchor.constraint(equalTo: self.contentView.topAnchor),
            self.collectionView.bottomAnchor.constraint(equalTo: self.contentView.bottomAnchor, constant: 0),

            self.loadingView.centerXAnchor.constraint(equalTo: self.collectionView.centerXAnchor),
            self.loadingView.centerYAnchor.constraint(equalTo: self.collectionView.centerYAnchor),
        ])
    }

    func reloadData() {
        self.collectionView.reloadData()
    }

    func configure(withViewModel viewModel: TopCompetitionsLineCellViewModel) {

        self.viewModel = viewModel

        self.collectionView.reloadData()
        
    }

    // MARK: - UICollectionViewDataSource

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // Return the number of items in your collection view
        return self.viewModel?.topCompetitions.count ?? 0
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard
            let cell = collectionView.dequeueCellType(TopCompetitionItemCollectionViewCell.self, indexPath: indexPath),
            let cellViewModel = self.viewModel?.topCompetitions[safe: indexPath.row]
        else {
            fatalError()
        }
        cell.configureWithViewModel(cellViewModel)
        cell.selectedItemAction = { [weak self] viewModel in
            self?.selectedItemAction(viewModel.id)
        }

        return cell
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        // Return the size of each item in your collection view
        return CGSize(width: 125, height: 80)
    }

}
