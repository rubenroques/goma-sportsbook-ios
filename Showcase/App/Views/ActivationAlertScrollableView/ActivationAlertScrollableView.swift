//
//  ActivationAlertScrollableView.swift
//  Sportsbook
//
//  Created by André Lascas on 17/11/2021.
//

import UIKit

class ActivationAlertScrollableView: NibView {

    @IBOutlet private var collectionView: UICollectionView!
    @IBOutlet private var pageControl: UIPageControl!
    // Variables
    var alertDataArray: [ActivationAlert] = []
    var activationAlertCollectionViewCellLinkLabelAction: ((ActivationAlertType) -> Void)?

    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
        setupWithTheme()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
        setupWithTheme()
    }

    override func commonInit() {

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

        self.collectionView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)

    }

    func setupWithTheme() {
        self.backgroundColor = UIColor.clear
        self.collectionView.backgroundColor = UIColor.clear

        self.pageControl.pageIndicatorTintColor = UIColor.App.navBanner
        self.pageControl.currentPageIndicatorTintColor = UIColor.App.navBannerActive

    }

    func setAlertArrayData(arrayData: [ActivationAlert]) {
        self.alertDataArray = arrayData
        self.collectionView.reloadData()
    }

}

extension ActivationAlertScrollableView: UIScrollViewDelegate {

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let witdh = scrollView.frame.width - (scrollView.contentInset.left*2)
        let index = scrollView.contentOffset.x / witdh
        let roundedIndex = round(index)
        self.pageControl?.currentPage = Int(roundedIndex)
    }
}

extension ActivationAlertScrollableView: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

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

        if let title = alertDataArray[safe: indexPath.row]?.title,
           let description = alertDataArray[safe: indexPath.row]?.description,
           let linkLabel = alertDataArray[safe: indexPath.row]?.linkLabel,
           let alertAction = self.alertDataArray[safe: indexPath.row]?.alertType{

            cell.setText(title: title, info: description, linkText: linkLabel)
            
            cell.configure(alertType: alertAction)
            
            cell.linkLabelAction = { [weak self] in
                
                self?.activationAlertCollectionViewCellLinkLabelAction?(alertAction)
                
            }
        }

        return cell
    }

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 16
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
        var width = screenWidth*0.9
        if width > 390 {
            width = 390
        }
        return CGSize(width: width, height: 172)
    }

}
