//
//  BannerScrollTableViewCell.swift
//  Sportsbook
//
//  Created by Ruben Roques on 11/10/2021.
//

import UIKit

class BannerScrollTableViewCell: UITableViewCell {

    let cellWidth: CGFloat = 331

    @IBOutlet private var pageControl: UIPageControl!
    @IBOutlet private var collectionBaseView: UIView!
    @IBOutlet private var collectionView: UICollectionView!

    var viewModel: BannerLineCellViewModel?
    var tappedBannerMatchAction: ((Match) -> Void)?
    var carouselCounter: Int = 0

    override func awakeFromNib() {
        super.awakeFromNib()

        AnalyticsClient.sendEvent(event: .promoBannerClicked)

        self.backgroundView?.backgroundColor = .clear
        self.backgroundColor = .clear
        self.contentView.backgroundColor = .clear

        self.collectionView.delegate = self
        self.collectionView.dataSource = self

        self.collectionView.register(BannerMatchCollectionViewCell.nib, forCellWithReuseIdentifier: BannerMatchCollectionViewCell.identifier)

        self.collectionView.showsVerticalScrollIndicator = false
        self.collectionView.showsHorizontalScrollIndicator = false

        let flowLayout = FadeInCenterHorizontalFlowLayout()
        flowLayout.alpha = 0.0
        flowLayout.minimumScale = 1.0
        // flowLayout.estimatedItemSize = UICollectionViewFlowLayout.automaticSize
        flowLayout.scrollDirection = .horizontal
        self.collectionView.collectionViewLayout = flowLayout

        // let screenWidth = UIScreen.main.bounds.size.width
        // let inset = (screenWidth - cellWidth) / 2
        self.collectionView.contentInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)

        self.setupWithTheme()

        self.startCollectionViewTimer()

    }

    override func prepareForReuse() {
        super.prepareForReuse()

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

    func configure(withViewModel viewModel: BannerLineCellViewModel) {
        self.viewModel = viewModel
        self.collectionView.reloadData()
    }

    func startCollectionViewTimer() {
        Timer.scheduledTimer(timeInterval: 4.0, target: self, selector: #selector(self.autoScrollCollectionView), userInfo: nil, repeats: true)
    }

    @objc func autoScrollCollectionView(_ timer1: Timer) {
        if let banners = self.viewModel?.banners {
            if self.carouselCounter < (banners.count - 1) {
                self.carouselCounter += 1
                let indexPath = IndexPath(item: self.carouselCounter, section: 0)
                self.collectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
            }
            else {
                self.carouselCounter = 0
                self.collectionView.scrollToItem(at: IndexPath(item: 0, section: 0), at: .centeredHorizontally, animated: true)
            }
        }
    }
}

extension BannerScrollTableViewCell: UIScrollViewDelegate {

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let witdh = scrollView.frame.width - (scrollView.contentInset.left*2)
        let index = scrollView.contentOffset.x / witdh
        let roundedIndex = round(index)
        self.pageControl?.currentPage = Int(roundedIndex)
        self.carouselCounter = Int(roundedIndex)
    }
}

extension BannerScrollTableViewCell: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let count = self.viewModel?.banners.count ?? 0
        pageControl.numberOfPages = count
        pageControl.isHidden = !(count > 1)
        return count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard
            let cell = collectionView.dequeueCellType(BannerMatchCollectionViewCell.self, indexPath: indexPath),
            let cellViewModel = self.viewModel?.banners[safe: indexPath.row]
        else {
            fatalError()
        }
        
        cell.setupWithViewModel(cellViewModel)
        cell.tappedMatchBaseViewAction = { match in
            self.tappedBannerMatchAction?(match)
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
        return CGSize(width: width, height: 158) // design width: 331
    }

}
