//
//  FeaturedTipLineTableViewCell.swift
//  Sportsbook
//
//  Created by André Lascas on 30/08/2022.
//

import UIKit
import Combine

class FeaturedTipLineViewModel {

    static let maxTicketsBeforeExpand = 3
    
    enum DataType {
        case featuredTips([FeaturedTip])
        case suggestedBetslips([SuggestedBetslip])
    }
    
    var featuredTipCollectionCacheViewModel: [String: FeaturedTipCollectionViewModel] = [:]

    var dataType: DataType
    
    private var cancellables = Set<AnyCancellable>()

    init(featuredTips: [FeaturedTip]) {
        self.dataType = .featuredTips(featuredTips)
    }
    
    init(suggestedBetslip: [SuggestedBetslip]) {
        self.dataType = .suggestedBetslips(suggestedBetslip)
    }
    
    func indexForItem(withId id: String) -> Int? {
        switch self.dataType {
        case .featuredTips(let featuredTips):
            return featuredTips.firstIndex(where: { $0.betId == id })
        case .suggestedBetslips(let suggestedBetslips):
            return suggestedBetslips.firstIndex(where: { $0.id == id })
        }
    }

    func numberOfItems() -> Int {
        switch self.dataType {
        case .featuredTips(let featuredTips):
            featuredTips.count
        case .suggestedBetslips(let suggestedBetslips):
            suggestedBetslips.count
        }
    }
    
    func maxTicketsCount() -> Int {
        switch dataType {
        case .featuredTips(let featuredTips):
            featuredTips.map({ ($0.selections ?? []).count }).max() ?? 0
        case .suggestedBetslips(let suggestedBetslips):
            suggestedBetslips.map({ ($0.selections ?? []).count }).max() ?? 0
        }
    }

    func cellViewModel(forIndex index: Int) -> FeaturedTipCollectionViewModel? {
        switch dataType {
        case .featuredTips(let featuredTips):
            guard
                let featuredTip = featuredTips[safe: index]
            else {
                return nil
            }

            let tipId = featuredTip.betId

            if let featuredTipCollectionViewModel = featuredTipCollectionCacheViewModel[tipId] {
                return featuredTipCollectionViewModel
            }
            else {
                let featuredTipCollectionViewModel = FeaturedTipCollectionViewModel(featuredTip: featuredTip,
                                                                                    sizeType: .small)
                self.featuredTipCollectionCacheViewModel[tipId] = featuredTipCollectionViewModel
                return featuredTipCollectionViewModel
            }
        case .suggestedBetslips(let suggestedBetslips):
            guard
                let suggestedBetslip = suggestedBetslips[safe: index]
            else {
                return nil
            }

            if let featuredTipCollectionViewModel = featuredTipCollectionCacheViewModel[suggestedBetslip.id] {
                return featuredTipCollectionViewModel
            }
            else {
                let featuredTipCollectionViewModel = FeaturedTipCollectionViewModel(suggestedBetslip: suggestedBetslip,
                                                                                    sizeType: .small)
                self.featuredTipCollectionCacheViewModel[suggestedBetslip.id] = featuredTipCollectionViewModel
                return featuredTipCollectionViewModel
            }
        }
        
    }
}

class FeaturedTipLineTableViewCell: UITableViewCell {

    static var estimatedHeight: CGFloat = 378
    
    private lazy var collectionView: UICollectionView = Self.createCollectionView()

    private var collectionViewHeightConstraint: NSLayoutConstraint?

    private var viewModel: FeaturedTipLineViewModel?
    private var cancellables: Set<AnyCancellable> = []

    var openFeaturedTipDetailAction: ((FeaturedTipCollectionViewModel) -> Void)?
    
    var shouldShowBetslip: (() -> Void)?
    var shouldShowUserProfile: ((UserBasicInfo) -> Void)?

    var currentIndex = -1
    var currentIndexChangedAction: ((Int) -> Void) = { _ in }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        self.setupSubviews()
        self.setupWithTheme()

        self.collectionView.delegate = self
        self.collectionView.dataSource = self

        self.collectionView.register(FeaturedTipCollectionViewCell.self,
                                        forCellWithReuseIdentifier: FeaturedTipCollectionViewCell.identifier)

    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func prepareForReuse() {
        super.prepareForReuse()

        self.viewModel = nil
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

    func configure(withViewModel viewModel: FeaturedTipLineViewModel) {

        self.viewModel = viewModel

        if viewModel.maxTicketsCount() > FeaturedTipLineViewModel.maxTicketsBeforeExpand {
            self.collectionViewHeightConstraint?.constant = Self.estimatedHeight
        }
        else {
            self.collectionViewHeightConstraint?.constant = Self.estimatedHeight - 20
        }
                
        self.reloadCollections()
    }

    func reloadCollections() {
        self.collectionView.reloadData()

    }

}

extension FeaturedTipLineTableViewCell: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.viewModel?.numberOfItems() ?? 0
    }

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 16
    }

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 16
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard
            let cell = collectionView.dequeueCellType(FeaturedTipCollectionViewCell.self, indexPath: indexPath),
            let cellViewModel = self.viewModel?.cellViewModel(forIndex: indexPath.row)
        else {
            fatalError()
        }

        cell.configure(viewModel: cellViewModel, hasCounter: false, followingUsers: Env.gomaSocialClient.followingUsersPublisher.value)

        cell.openFeaturedTipDetailAction = { [weak self] featuredTip in
            self?.openFeaturedTipDetailAction?(featuredTip)
        }

        cell.shouldShowBetslip = { [weak self] in
            self?.shouldShowBetslip?()
        }

        cell.shouldShowUserProfile = { [weak self] userBasicInfo in
            self?.shouldShowUserProfile?(userBasicInfo)
        }

        cell.configureAnimationId("FeaturedTipCell\(indexPath.row)")

        return cell
    }

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: Double(collectionView.frame.size.width)*0.87, height: collectionView.frame.size.height - 2.0)
    }

}

extension FeaturedTipLineTableViewCell: UIScrollViewDelegate {
    
    func calculteCenterCell() {
        let centerPoint = CGPoint(x: self.collectionView.center.x + self.collectionView.contentOffset.x,
                                  y: self.collectionView.center.y + self.collectionView.contentOffset.y)

        let index = collectionView.indexPathForItem(at: centerPoint)?.row ?? 0
        self.currentIndexChangedAction(index)
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        self.calculteCenterCell()
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        self.calculteCenterCell()
    }
    
}

extension FeaturedTipLineTableViewCell {

    private static func createCollectionView() -> UICollectionView {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        let collectionView = UICollectionView.init(frame: .zero, collectionViewLayout: layout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.showsVerticalScrollIndicator = false
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.alwaysBounceHorizontal = true
        collectionView.contentInset = UIEdgeInsets(top: 0, left: 18, bottom: 0, right: 18)

        return collectionView
    }

    private func setupSubviews() {
        // Add subviews to self.view or each other
        self.contentView.addSubview(self.collectionView)

        // Initialize constraints
        self.initConstraints()
    }

    private func initConstraints() {
        
        let spacing: CGFloat = 16
        self.collectionViewHeightConstraint = self.collectionView.heightAnchor.constraint(equalToConstant: Self.estimatedHeight - spacing)
        
        NSLayoutConstraint.activate([
            self.collectionView.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor, constant: 0),
            self.collectionView.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor, constant: 0),
            self.collectionView.topAnchor.constraint(equalTo: self.contentView.topAnchor, constant: spacing/2),
            self.collectionView.bottomAnchor.constraint(equalTo: self.contentView.bottomAnchor, constant: -(spacing/2)),
            
            self.collectionViewHeightConstraint!
     ])
    }
}
