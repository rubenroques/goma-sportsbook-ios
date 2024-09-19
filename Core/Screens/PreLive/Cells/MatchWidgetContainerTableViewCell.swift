//
//  MatchWidgetContainerTableViewCell.swift
//  Sportsbook
//
//  Created by Ruben Roques on 02/06/2023.
//

import Foundation
import UIKit

class MatchWidgetContainerTableViewModel {
    
    static let topMargin: CGFloat = 10.0
    static let leftMargin: CGFloat = 18.0
    
    var cardsViewModels: [MatchWidgetCellViewModel] = []
    
    init(cardsViewModels: [MatchWidgetCellViewModel]) {
        self.cardsViewModels = cardsViewModels
    }
    
    init(singleCardsViewModel: MatchWidgetCellViewModel) {
        self.cardsViewModels = [singleCardsViewModel]
    }
    
    var matchWidgetType: MatchWidgetType {
        return cardsViewModels.first?.matchWidgetType ?? MatchWidgetType.normal
    }
    
    var numberOfCells: Int {
        return self.cardsViewModels.count
    }
    
    var isScrollEnabled: Bool {
        return self.numberOfCells > 1
    }
    
    func maxHeightForInnerCards() -> CGFloat {
        var maxHeight = 0.0
        for type in cardsViewModels.map(\.matchWidgetType) {
            let newHeight = self.heightFor(matchWidgetType: type)
            if newHeight > maxHeight {
                maxHeight = newHeight
            }
        }
        return CGFloat(maxHeight)
    }
    
    func heightForItem(atIndex index: Int) -> CGFloat {
        guard 
            let type = self.cardsViewModels[safe: index]?.matchWidgetType
        else {
            return 0.0
        }
        return self.heightFor(matchWidgetType: type) - (Self.topMargin * 2)
    }
    
    private func heightFor(matchWidgetType type: MatchWidgetType) -> CGFloat {
        switch type {
        case .normal, .backgroundImage:
            return 152.0
        case .topImageOutright:
            return 270.0
        case .topImage, .topImageWithMixMatch:
            return 300.0
        case .boosted:
            return 190.0
        }
    }
    
}

class MatchWidgetContainerTableViewCell: UITableViewCell {

    var tappedMatchLineAction: ((Match) -> Void) = { _ in }
    var matchWentLive: ((Match) -> Void) = { _ in }
    var didTapFavoriteMatchAction: ((Match) -> Void) = { _ in }
    var didLongPressOdd: ((BettingTicket) -> Void) = { _ in }
    var tappedMatchOutrightLineAction: ((Competition) -> Void) = { _ in }
    var tappedMixMatchAction: ((Match) -> Void)?

    private lazy var baseView: UIView = Self.createBaseView()
    private lazy var collectionView: UICollectionView = Self.createCell()

    private var collectionViewHeightConstraint: NSLayoutConstraint?

    private var viewModel: MatchWidgetContainerTableViewModel?

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        self.collectionViewHeightConstraint = self.collectionView.heightAnchor.constraint(equalToConstant: 300)

        self.setupSubviews()
        self.setupWithTheme()

        self.collectionView.tag = 17
        self.collectionView.delegate = self
        self.collectionView.dataSource = self
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
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
        self.contentView.backgroundColor = .clear

        self.collectionView.backgroundColor = .clear
        self.collectionView.backgroundView?.backgroundColor = .clear
        
        self.baseView.backgroundColor = .clear
    }

    func setupWithViewModel(_ viewModel: MatchWidgetContainerTableViewModel) {

        self.viewModel = viewModel
        
        self.collectionViewHeightConstraint?.constant = viewModel.maxHeightForInnerCards()
        self.collectionView.isScrollEnabled = viewModel.isScrollEnabled
        
        self.setNeedsLayout()
        self.collectionView.reloadData()
    }
    
}

extension MatchWidgetContainerTableViewCell: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        guard let viewModel = self.viewModel else { return 0 }
        return viewModel.numberOfCells
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

        guard let viewModel = self.viewModel else {
            fatalError()
        }

        // Create the identifier based on the cell type
        let cellIdentifier = MatchWidgetCollectionViewCell.identifier + viewModel.matchWidgetType.rawValue

        guard
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellIdentifier, for: indexPath) as? MatchWidgetCollectionViewCell,
            let cardsViewModel = viewModel.cardsViewModels[safe: indexPath.row]
        else {
            fatalError()
        }

        cell.configure(withViewModel: cardsViewModel)

        cell.tappedMatchWidgetAction = { match in
            self.tappedMatchLineAction(match)
        }
        
        cell.tappedMatchOutrightWidgetAction = { competition in
            self.tappedMatchOutrightLineAction(competition)
        }

        cell.didLongPressOdd = { bettingTicket in
            self.didLongPressOdd(bettingTicket)
        }
        
        cell.tappedMixMatchAction = { [weak self] match in
            self?.tappedMixMatchAction?(match)
        }

        cell.shouldShowCountryFlag(true)
        return cell
    }

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {

        let heightForitem = self.viewModel?.heightForItem(atIndex: indexPath.row) ?? 0.0
        
        return CGSize(width: collectionView.frame.size.width - (MatchWidgetContainerTableViewModel.leftMargin * 2.0),
                      height: heightForitem)
    }

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: MatchWidgetContainerTableViewModel.topMargin,
                            left: MatchWidgetContainerTableViewModel.leftMargin,
                            bottom: MatchWidgetContainerTableViewModel.topMargin,
                            right: MatchWidgetContainerTableViewModel.leftMargin)
    }

}

extension MatchWidgetContainerTableViewCell {

    private static func createBaseView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }

    private static func createCell() -> UICollectionView {
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.scrollDirection = .horizontal

        let collectionView = UICollectionView(frame: CGRect.zero, collectionViewLayout: flowLayout)
        collectionView.showsVerticalScrollIndicator = false
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.isScrollEnabled = false
        collectionView.translatesAutoresizingMaskIntoConstraints = false

        collectionView.register(MatchWidgetCollectionViewCell.nib, 
                                forCellWithReuseIdentifier: MatchWidgetCollectionViewCell.identifier)

        for matchWidgetType in MatchWidgetType.allCases {
            // Register a cell for each cell type to avoid glitches in the redrawing
            collectionView.register(MatchWidgetCollectionViewCell.nib, 
                                    forCellWithReuseIdentifier: MatchWidgetCollectionViewCell.identifier+matchWidgetType.rawValue)
        }

        return collectionView
    }

    private func setupSubviews() {

        // Add subviews to self.view or each other
        self.contentView.addSubview(self.baseView)
        self.baseView.addSubview(self.collectionView)

        // Initialize constraints
        self.initConstraints()
    }

    private func initConstraints() {
        NSLayoutConstraint.activate([
            self.baseView.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor),
            self.baseView.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor),
            self.baseView.topAnchor.constraint(equalTo: self.contentView.topAnchor),
            self.baseView.bottomAnchor.constraint(equalTo: self.contentView.bottomAnchor),

            self.collectionView.leadingAnchor.constraint(equalTo: self.baseView.leadingAnchor),
            self.collectionView.trailingAnchor.constraint(equalTo: self.baseView.trailingAnchor),
            self.collectionView.topAnchor.constraint(equalTo: self.baseView.topAnchor),
            self.collectionView.bottomAnchor.constraint(equalTo: self.baseView.bottomAnchor),

            self.collectionViewHeightConstraint!
        ])
    }
}



