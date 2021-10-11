//
//  MatchLineTableViewCell.swift
//  Sportsbook
//
//  Created by Ruben Roques on 30/09/2021.
//

import UIKit

class MatchLineTableViewCell: UITableViewCell {

    let cellWidth: CGFloat = 331

    @IBOutlet private var collectionBaseView: UIView!
    @IBOutlet private var collectionView: UICollectionView!

    var viewModel: MatchLineCellViewModel? {
        didSet {
            self.collectionView.reloadData()
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()

        self.collectionView.delegate = self
        self.collectionView.dataSource = self

        self.collectionView.register(MatchWidgetCollectionViewCell.nib, forCellWithReuseIdentifier: MatchWidgetCollectionViewCell.identifier)
        self.collectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "UICollectionViewCell")

        self.collectionView.showsVerticalScrollIndicator = false
        self.collectionView.showsHorizontalScrollIndicator = false

        let flowLayout = FadeInCenterHorizontalFlowLayout()
        //flowLayout.estimatedItemSize = UICollectionViewFlowLayout.automaticSize
        flowLayout.scrollDirection = .horizontal
        self.collectionView.collectionViewLayout = flowLayout

        let screenWidth = UIScreen.main.bounds.size.width
        let inset = (screenWidth - cellWidth) / 2
        self.collectionView.contentInset = UIEdgeInsets(top: 0, left: inset, bottom: 0, right: inset)

        self.setupWithTheme()
    }

    override func prepareForReuse() {
        self.collectionView.layoutIfNeeded()
        self.collectionView.contentOffset = .zero
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)

        self.setupWithTheme()
    }

    func setupWithTheme() {

        self.backgroundColor = .clear
        self.backgroundView?.backgroundColor = .clear

        self.collectionBaseView.backgroundColor = .clear
        self.collectionView.backgroundColor = .clear
        self.collectionView.backgroundView?.backgroundColor = .clear
    }

}

extension MatchLineTableViewCell: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 5
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

        if indexPath.row == 0 {
            guard
                let cell = collectionView.dequeueCellType(MatchWidgetCollectionViewCell.self, indexPath: indexPath)
            else {
                fatalError()
            }

            return cell
        }
        else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "UICollectionViewCell", for: indexPath)
            cell.backgroundView?.backgroundColor = .red
            cell.backgroundColor = .red

            return cell
        }
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {

    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 16
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return -9
    }

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 331, height: 133)
    }
}

