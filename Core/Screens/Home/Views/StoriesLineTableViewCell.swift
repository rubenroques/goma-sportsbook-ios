//
//  File.swift
//  Sportsbook
//
//  Created by Ruben Roques on 05/06/2023.
//

import Foundation
import UIKit

class StoriesLineCellViewModel {

    var storiesViewModels: [StoriesItemCellViewModel]

    init(storiesViewModels: [StoriesItemCellViewModel]) {
        self.storiesViewModels = storiesViewModels
    }
}

class StoriesLineTableViewCell: UITableViewCell, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

    var selectedItemAction: (String) -> Void = { _ in }

    private let cellHeight: CGFloat = 122

    private var collectionView: UICollectionView!

    var viewModel: StoriesLineCellViewModel?

    var cachedCellViewModels: [String: StoriesItemCellViewModel] = [:]

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.setupCollectionView()
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
    }

    private func setupCollectionView() {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.sectionInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        layout.minimumLineSpacing = 14

        self.collectionView = UICollectionView(frame: bounds, collectionViewLayout: layout)
        self.collectionView.translatesAutoresizingMaskIntoConstraints = false
        self.collectionView.backgroundColor = .clear
        self.collectionView.showsHorizontalScrollIndicator = false
        self.collectionView.dataSource = self
        self.collectionView.delegate = self
        self.collectionView.register(StoriesItemCollectionViewCell.self,
                                     forCellWithReuseIdentifier: StoriesItemCollectionViewCell.identifier)

        self.contentView.addSubview(self.collectionView)

        NSLayoutConstraint.activate([
            self.collectionView.heightAnchor.constraint(equalToConstant: self.cellHeight - 4),
            self.collectionView.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor),
            self.collectionView.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor),
            self.collectionView.topAnchor.constraint(equalTo: self.contentView.topAnchor, constant: 1),
            self.collectionView.bottomAnchor.constraint(equalTo: self.contentView.bottomAnchor, constant: -3)
        ])
    }

    func reloadData() {
        self.collectionView.reloadData()
    }

    func configure(withViewModel viewModel: StoriesLineCellViewModel) {

        self.viewModel = viewModel

        for cellViewModel in viewModel.storiesViewModels {
            self.cachedCellViewModels[cellViewModel.id] = cellViewModel
        }
        
        self.collectionView.reloadData()

    }

    // MARK: - UICollectionViewDataSource

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // Return the number of items in your collection view
        // return 10
        return self.viewModel?.storiesViewModels.count ?? 0
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard
            let cell = collectionView.dequeueCellType(StoriesItemCollectionViewCell.self, indexPath: indexPath),
            let cellViewModel = self.viewModel?.storiesViewModels[safe: indexPath.row]
        else {
            fatalError()
        }

        cell.configureWithViewModel(viewModel: cellViewModel)

        cell.selectedItemAction = { [weak self] viewModel in
            self?.selectedItemAction(viewModel.id)
        }

        return cell
    }

    // MARK: - UICollectionViewDelegateFlowLayout

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        // Return the size of each item in your collection view
        return CGSize(width: 82, height: 102)
    }

}
