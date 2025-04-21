//
//  PromotionLineTableViewCell.swift
//  Sportsbook
//
//  Created by André Lascas on 17/03/2025.
//

import UIKit
import Combine

class PromotionLineTableViewModel {
    
    var promotions: [PromotionInfo] = []
    var promotionsCacheCellViewModel: [Int: PromotionCellViewModel] = [:]
    
    var isLoadingPublisher: CurrentValueSubject<Bool, Never> = .init(false)
    
    var cancellables = Set<AnyCancellable>()
    
    init(promotions: [PromotionInfo]) {
        self.promotions = promotions
    }
    
    func viewModel(forIndex index: Int) -> PromotionCellViewModel? {
        guard
            let promotion = self.promotions[safe: index]
        else {
            return nil
        }

        if let promotionCellViewModel = self.promotionsCacheCellViewModel[promotion.id] {
            return promotionCellViewModel
        }
        else {
            
            let promotionCellViewModel = PromotionCellViewModel(promotionInfo: promotion)
            self.promotionsCacheCellViewModel[promotion.id] = promotionCellViewModel
            return promotionCellViewModel
        }
    }
}

class PromotionLineTableViewCell: UITableViewCell {

    // MARK: Private properties
    private lazy var containerView: UIView = Self.createContainerView()
    private lazy var collectionView: UICollectionView = Self.createCollectionView()
    
    private let cellHeight: CGFloat = 320.0
    
    var viewModel: PromotionLineTableViewModel?
    
    var didTapPromotionAction: ((PromotionInfo) -> Void)?

    // MARK: Lifetime and cycle
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        self.setupSubviews()
        self.setupWithTheme()
        
        self.collectionView.delegate = self
        self.collectionView.dataSource = self

        self.collectionView.register(
            PromotionCollectionViewCell.self,
            forCellWithReuseIdentifier: PromotionCollectionViewCell.identifier
        )
        
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func prepareForReuse() {
        super.prepareForReuse()

    }

    // MARK: Theme and layout
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        self.setupWithTheme()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
    }
    
    func setupWithTheme() {
        self.backgroundColor = .clear
        self.backgroundView?.backgroundColor = .clear
        self.contentView.backgroundColor = .clear

        self.containerView.backgroundColor = .clear
        
        self.collectionView.backgroundView?.backgroundColor = .clear
        self.collectionView.backgroundColor = .clear

    }
    
    // MARK: Functions
    func configure(withViewModel viewModel: PromotionLineTableViewModel) {
        
        self.viewModel = viewModel
        
        self.collectionView.reloadData()
    }
}

extension PromotionLineTableViewCell: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.viewModel?.promotions.count ?? 0
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        guard
            let cell = collectionView.dequeueCellType(PromotionCollectionViewCell.self, indexPath: indexPath),
            let viewModel = self.viewModel?.viewModel(forIndex: indexPath.row)
        else {
            fatalError()
        }
        
        cell.configure(viewModel: viewModel)
        
        cell.didTapPromotionAction = { [weak self] in
            self?.didTapPromotionAction?(viewModel.promotionInfo)
        }
        
        return cell
        
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let itemWidth = collectionView.frame.size.width * 0.9
        
        return CGSize(width: itemWidth,
                      height: collectionView.frame.size.height)
    }

}

extension PromotionLineTableViewCell {
    
    private static func createContainerView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }
    
    private static func createCollectionView() -> UICollectionView {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        let collectionView = UICollectionView.init(frame: .zero, collectionViewLayout: layout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.showsVerticalScrollIndicator = false
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.alwaysBounceHorizontal = true
        collectionView.contentInset = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10)
//        collectionView.isPagingEnabled = true
        return collectionView
    }
    
    private func setupSubviews() {

        self.contentView.addSubview(self.containerView)
                        
        self.containerView.addSubview(self.collectionView)

        self.initConstraints()
        
        self.setNeedsLayout()
        self.layoutIfNeeded()
    }
    
    private func initConstraints() {
        NSLayoutConstraint.activate([
            self.containerView.heightAnchor.constraint(equalToConstant: self.cellHeight),
            
            self.containerView.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor),
            self.containerView.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor),
            self.containerView.topAnchor.constraint(equalTo: self.contentView.topAnchor, constant: 10),
            self.containerView.bottomAnchor.constraint(equalTo: self.contentView.bottomAnchor, constant: -10),
            
            self.collectionView.leadingAnchor.constraint(equalTo: self.containerView.leadingAnchor),
            self.collectionView.trailingAnchor.constraint(equalTo: self.containerView.trailingAnchor),
            self.collectionView.topAnchor.constraint(equalTo: self.containerView.topAnchor),
            self.collectionView.bottomAnchor.constraint(equalTo: self.containerView.bottomAnchor)
        ])
        
    }
}
