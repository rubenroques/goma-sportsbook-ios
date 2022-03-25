//
//  ActivationAlertScrollableTableViewCell.swift
//  Sportsbook
//
//  Created by André Lascas on 17/11/2021.
//

import UIKit

class ActivationAlertScrollableTableViewCell: UITableViewCell {

    @IBOutlet private weak var collectionView: UICollectionView!
    @IBOutlet private weak var pageControl: UIPageControl!

    var alertDataArray: [ActivationAlert] = []
    var activationAlertCollectionViewCellLinkLabelAction: ((ActivationAlertType) -> Void)?

    override func awakeFromNib() {
        super.awakeFromNib()

        self.collectionView.delegate = self
        self.collectionView.dataSource = self

        self.collectionView.register(ActivationAlertCollectionViewCell.nib, forCellWithReuseIdentifier: ActivationAlertCollectionViewCell.identifier)

        self.collectionView.showsVerticalScrollIndicator = false
        self.collectionView.showsHorizontalScrollIndicator = false

        let flowLayout = FadeInCenterHorizontalFlowLayout()
        flowLayout.alpha = 0.0
        flowLayout.minimumScale = 1.0
        flowLayout.scrollDirection = .horizontal
        self.collectionView.collectionViewLayout = flowLayout

        self.collectionView.contentInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)

        self.setupWithTheme()
    }

    func setupWithTheme() {
        self.backgroundColor = UIColor.clear
        self.collectionView.backgroundColor = UIColor.clear
        self.pageControl.tintColor = UIColor.gray
    }

    func setAlertArrayData(arrayData: [ActivationAlert]) {
        self.alertDataArray = arrayData
        self.collectionView.reloadData()
    }

}

extension ActivationAlertScrollableTableViewCell: UIScrollViewDelegate {

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let witdh = scrollView.frame.width - (scrollView.contentInset.left*2)
        let index = scrollView.contentOffset.x / witdh
        let roundedIndex = round(index)
        self.pageControl?.currentPage = Int(roundedIndex)
    }
}

extension ActivationAlertScrollableTableViewCell: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let count = self.alertDataArray.count
        pageControl.numberOfPages = count
        pageControl.isHidden = !(count > 1)
        return count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard
            let cell = collectionView.dequeueCellType(ActivationAlertCollectionViewCell.self, indexPath: indexPath)
        else {
            fatalError()
        }
        if let title = alertDataArray[safe: indexPath.row]?.title, let description = alertDataArray[safe: indexPath.row]?.description, let linkLabel = alertDataArray[safe: indexPath.row]?.linkLabel {
            cell.setText(title: title, info: description, linkText: linkLabel)
            cell.linkLabelAction = {
                if let alertAction = self.alertDataArray[safe: indexPath.row]?.alertType {
                    self.activationAlertCollectionViewCellLinkLabelAction?(alertAction)
                }

            }
        }

        return cell
    }

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 32
    }

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 11
    }

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {

        let screenWidth = UIScreen.main.bounds.size.width
        var width = screenWidth - 32
        if width > 390 {
            width = 390
        }
        return CGSize(width: width, height: 110)
    }

}
