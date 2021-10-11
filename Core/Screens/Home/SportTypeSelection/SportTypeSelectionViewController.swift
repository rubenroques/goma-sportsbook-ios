//
//  SportTypeSelectionViewController.swift
//  Sportsbook
//
//  Created by Ruben Roques on 06/10/2021.
//

import UIKit

class SportTypeSelectionViewController: UIViewController {

    @IBOutlet private var searchBarBaseView: UIView!
    @IBOutlet private var collectionView: UICollectionView!

    var viewModel: SportTypeSelectorViewModel

    init(viewModel: SportTypeSelectorViewModel) {
        self.viewModel = viewModel
        super.init(nibName: "SportTypeSelectionViewController", bundle: nil)
    }

    @available(iOS, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        self.commonInit()
        self.setupWithTheme()
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)

        self.setupWithTheme()
    }

    func commonInit() {
        self.collectionView.delegate = self
        self.collectionView.dataSource = self

        self.collectionView.register(SportTypeCollectionViewCell.nib, forCellWithReuseIdentifier: SportTypeCollectionViewCell.identifier)
    }

    func setupWithTheme() {
        self.view.backgroundColor = UIColor.App.mainBackground

    }

}

extension SportTypeSelectionViewController: UICollectionViewDelegate, UICollectionViewDataSource {

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.viewModel.sports.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueCellType(SportTypeCollectionViewCell.self, indexPath: indexPath) else {
            fatalError("collectionView.dequeueCellType")
        }
        return cell
    }

}
