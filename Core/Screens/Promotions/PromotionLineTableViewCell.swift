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
    
    init() {
        self.getPromotions()
    }
    
    private func getPromotions() {
        
        self.isLoadingPublisher.send(true)
        
        Env.servicesProvider.getPromotions()
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { [weak self] completion in
                
                switch completion {
                case .finished:
                    print("FINISHED GET PROMOTIONS")
                case .failure(let error):
                    print("ERROR GET PROMOTIONS: \(error)")
                }
                
                self?.isLoadingPublisher.send(false)

            }, receiveValue: { [weak self] promotionsInfo in
                
                let mappedPromotionsInfo = promotionsInfo.map({
                    ServiceProviderModelMapper.promotionInfo(fromInternalPromotionInfo: $0)
                })
                
                self?.promotions = mappedPromotionsInfo
            })
            .store(in: &cancellables)
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
    
    private let cellHeight: CGFloat = 300.0
    
    var viewModel: PromotionLineTableViewModel?

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

        self.containerView.backgroundColor = UIColor.App.backgroundPrimary
        
        self.collectionView.backgroundView?.backgroundColor = .clear
        self.collectionView.backgroundColor = .clear

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
        
        return cell
        
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let topMargin: CGFloat = 5.0
        let leftMargin: CGFloat = 10.0
        return CGSize(width: collectionView.frame.size.width - (leftMargin * 2),
                      height: collectionView.frame.size.height + (topMargin * 2))
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
            
            self.containerView.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor, constant: 15),
            self.containerView.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor, constant: -15),
            self.containerView.topAnchor.constraint(equalTo: self.contentView.topAnchor, constant: 5),
            self.containerView.bottomAnchor.constraint(equalTo: self.contentView.bottomAnchor, constant: -5),
            
            self.collectionView.leadingAnchor.constraint(equalTo: self.containerView.leadingAnchor, constant: 0),
            self.collectionView.trailingAnchor.constraint(equalTo: self.containerView.trailingAnchor, constant: 0),
            self.collectionView.topAnchor.constraint(equalTo: self.containerView.topAnchor, constant: 0),
            self.collectionView.bottomAnchor.constraint(equalTo: self.containerView.bottomAnchor, constant: 0)
        ])
        
    }
}
