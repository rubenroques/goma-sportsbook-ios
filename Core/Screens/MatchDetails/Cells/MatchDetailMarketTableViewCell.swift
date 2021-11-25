//
//  MatchDetailMarketTableViewCell.swift
//  Sportsbook
//
//  Created by André Lascas on 25/11/2021.
//

import UIKit

class MatchDetailMarketTableViewCell: UITableViewCell {


    @IBOutlet private var containerView: UIView!
    @IBOutlet private var titleLabel: UILabel!
    @IBOutlet private var collectionView: UICollectionView!

    override func awakeFromNib() {
        super.awakeFromNib()

        self.commonInit()
        self.setupWithTheme()

    }

    func commonInit() {

        self.containerView.layer.cornerRadius = CornerRadius.button

        self.titleLabel.text = "Market"
        self.titleLabel.font = AppFont.with(type: .bold, size: 14)

        self.collectionView.delegate = self
        self.collectionView.dataSource = self

        self.collectionView.register(MarketDetailCollectionViewCell.nib, forCellWithReuseIdentifier: MarketDetailCollectionViewCell.identifier)

        self.collectionView.showsVerticalScrollIndicator = false
        self.collectionView.showsHorizontalScrollIndicator = false

        //self.collectionView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    }

    override func prepareForReuse() {
        super.prepareForReuse()

        self.selectionStyle = .none

        //self.titleLabel.text = ""

    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)

        self.setupWithTheme()
    }

    func setupWithTheme() {
        self.backgroundColor = .clear

        self.contentView.backgroundColor = .clear

        self.containerView.backgroundColor = UIColor.App.secondaryBackground

        self.titleLabel.textColor = UIColor.App.headingMain

        self.collectionView.backgroundColor = .clear

    }
    
}

extension MatchDetailMarketTableViewCell: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 3
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "MarketDetailCollectionViewCell", for: indexPath) as! MarketDetailCollectionViewCell
        cell.setupDetails(marketType: "Market", marketOdd: "1.0")

        return cell
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {

    }

//    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
//        return 40
//    }
//
//    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
//        return -4
//    }

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {


        //let screenWidth = UIScreen.main.bounds.size.width
        let containerWidth = collectionView.bounds.size.width
        // 2 Columns
        // let width = (containerWidth/2) - 5
        // 3 Columns
        let width = (containerWidth/3) - 5

        return CGSize(width: width, height: 50) // design width: 331

    }
}
