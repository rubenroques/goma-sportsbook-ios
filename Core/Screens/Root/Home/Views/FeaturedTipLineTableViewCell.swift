//
//  FeaturedTipLineTableViewCell.swift
//  Sportsbook
//
//  Created by André Lascas on 30/08/2022.
//

import UIKit
import Combine

class FeaturedTipLineViewModel {

    var featuredTips: [FeaturedTip] = []
    var featuredTipCollectionCacheViewModel: [String: FeaturedTipCollectionViewModel] = [:]

    private var cancellables = Set<AnyCancellable>()

    init(featuredTips: [FeaturedTip]) {
        self.featuredTips = featuredTips

    }

    func numberOfItems() -> Int {
        return featuredTips.count
    }

    func viewModel(forIndex index: Int) -> FeaturedTipCollectionViewModel? {
        guard
            let featuredTip = self.featuredTips[safe: index]
        else {
            return nil
        }

        let tipId = featuredTip.betId

        if let featuredTipCollectionViewModel = featuredTipCollectionCacheViewModel[tipId] {
            return featuredTipCollectionViewModel
        }
        else {
            let featuredTipCollectionViewModel = FeaturedTipCollectionViewModel(featuredTip: featuredTip, sizeType: .small)
            self.featuredTipCollectionCacheViewModel[tipId] = featuredTipCollectionViewModel
            return featuredTipCollectionViewModel
        }
    }
}

class FeaturedTipLineTableViewCell: UITableViewCell {

    private lazy var collectionView: UICollectionView = Self.createCollectionView()

    private var viewModel: FeaturedTipLineViewModel?
    private var cancellables: Set<AnyCancellable> = []

    var openFeaturedTipDetailAction: ((FeaturedTip) -> Void)?
    var shouldShowBetslip: (() -> Void)?
    var shouldShowUserProfile: ((UserBasicInfo) -> Void)?

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
        self.contentView.backgroundColor = UIColor.App.backgroundPrimary

        self.collectionView.backgroundView?.backgroundColor = UIColor.App.backgroundPrimary
        self.collectionView.backgroundColor = UIColor.App.backgroundPrimary
    }

    func configure(withViewModel viewModel: FeaturedTipLineViewModel) {

        self.viewModel = viewModel

        Env.gomaSocialClient.followingUsersPublisher
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] _ in
                self?.reloadCollections()
            })
            .store(in: &cancellables)

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
            let cellViewModel = self.viewModel?.viewModel(forIndex: indexPath.row),
            let viewModel = self.viewModel
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

        return cell
    }

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: Double(collectionView.frame.size.width)*0.85, height: 400)
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
        NSLayoutConstraint.activate([
            self.collectionView.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor, constant: 0),
            self.collectionView.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor, constant: 0),
            self.collectionView.topAnchor.constraint(equalTo: self.contentView.topAnchor, constant: 8),
            self.collectionView.bottomAnchor.constraint(equalTo: self.contentView.bottomAnchor, constant: -8),
     ])
    }
}
