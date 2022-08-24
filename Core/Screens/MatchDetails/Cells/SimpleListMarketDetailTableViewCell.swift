//
//  SimpleListMarketDetailTableViewCell.swift
//  Sportsbook
//
//  Created by André Lascas on 25/11/2021.
//

import UIKit

class SimpleListMarketDetailTableViewCell: UITableViewCell {

    @IBOutlet private var containerView: UIView!
    @IBOutlet private var titleLabel: UILabel!
    @IBOutlet private var collectionView: UICollectionView!
    @IBOutlet private var collectionViewHeightContraint: NSLayoutConstraint!

    enum ColumnType {
        case double
        case triple
    }

    var columnType = ColumnType.double

    var match: Match?
    var market: Market?
    var competitionName: String?

    var didLongPressOdd: ((BettingTicket) -> Void)?

    private let lineHeight: CGFloat = 56

    override func awakeFromNib() {
        super.awakeFromNib()

        self.containerView.layer.cornerRadius = CornerRadius.button

        self.titleLabel.text = localized("market")
        self.titleLabel.font = AppFont.with(type: .bold, size: 14)

        self.collectionView.delegate = self
        self.collectionView.dataSource = self

        self.collectionView.register(MarketDetailCollectionViewCell.nib, forCellWithReuseIdentifier: MarketDetailCollectionViewCell.identifier)

        self.collectionView.showsVerticalScrollIndicator = false
        self.collectionView.showsHorizontalScrollIndicator = false

        self.setupWithTheme()
    }

    override func prepareForReuse() {
        super.prepareForReuse()

        self.selectionStyle = .none
        self.collectionViewHeightContraint.constant = 48
        self.columnType = ColumnType.double

        self.match = nil
        self.market = nil
        self.competitionName = nil
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)

        self.setupWithTheme()
    }

    func setupWithTheme() {
        self.backgroundColor = .clear

        self.contentView.backgroundColor = .clear

        self.containerView.backgroundColor = UIColor.App.backgroundSecondary

        self.titleLabel.textColor = UIColor.App.textPrimary

        self.collectionView.backgroundColor = .clear
    }

    func configure(withMarket market: Market) {
        self.market = market

        self.titleLabel.text = market.name

        // calculate number of lines

        // calculate number of lines
        let outcomes = market.outcomes.count

        let useTriple = outcomes % 3 == 0

        if useTriple {
            let numberOfLines = Int(outcomes / 3)
            // numberOfLines = numberOfLines < 4 ? numberOfLines : 4

            self.columnType = ColumnType.triple
            self.collectionViewHeightContraint.constant = CGFloat(numberOfLines) * lineHeight
        }
        else {
            // Use double
            let numberOfLines = Int(outcomes / 2)
            // numberOfLines = numberOfLines < 3 ? numberOfLines : 3

            self.columnType = ColumnType.double
            self.collectionViewHeightContraint.constant = CGFloat(numberOfLines) * lineHeight
        }

        // each line is 50 including space
        self.setNeedsLayout()
        self.layoutIfNeeded()
        
        self.collectionView.reloadData()
    }

    func configure(withMarketGroupOrganizer market: MarketGroupOrganizer) {

        self.titleLabel.text = market.marketName

        // calculate number of lines

        // calculate number of lines
//        let outcomes = market.outcomes.count
//
//        let useTriple = outcomes % 3 == 0
//
//        if useTriple {
//            let numberOfLines = Int(outcomes / 3)
//            //numberOfLines = numberOfLines < 4 ? numberOfLines : 4
//
//            self.columnType = ColumnType.triple
//            self.collectionViewHeightContraint.constant = CGFloat(numberOfLines) * lineHeight
//        }
//        else {
//            //Use double
//            let numberOfLines = Int(outcomes / 2)
//            //numberOfLines = numberOfLines < 3 ? numberOfLines : 3
//
//            self.columnType = ColumnType.double
//            self.collectionViewHeightContraint.constant = CGFloat(numberOfLines) * lineHeight
//        }
//
//        // each line is 50 including space
//        self.setNeedsLayout()
//        self.layoutIfNeeded()
//
//        self.collectionView.reloadData()
    }

}

extension SimpleListMarketDetailTableViewCell: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.market?.outcomes.count ?? 0
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

        guard
            let cell = collectionView.dequeueCellType(MarketDetailCollectionViewCell.self, indexPath: indexPath),
            let market = self.market,
            let outcomeItem = market.outcomes[safe: indexPath.row]
        else {
            return UICollectionViewCell()
        }

        cell.match = self.match
        cell.market = self.market
        cell.configureWith(outcome: outcomeItem)

        cell.didLongPressOdd = { [weak self] bettingTicket in
            self?.didLongPressOdd?(bettingTicket)
        }

        return cell
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {

    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {

        // let screenWidth = UIScreen.main.bounds.size.width
        let containerWidth = collectionView.bounds.size.width

        var width: CGFloat = 0.0
        if self.columnType == .double {
            width  = (containerWidth/2) - 5
        }
        else {
            width  = (containerWidth/3) - 5
        }

        return CGSize(width: width, height: lineHeight) // design width: 331

    }
}
