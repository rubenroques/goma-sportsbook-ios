//
//  ChipsTypeView.swift
//  Sportsbook
//
//  Created by Ruben Roques on 22/01/2025.
//

import UIKit
import Combine

class ChipsTypeView: UIView {
    
    static let height: CGFloat = 70.0
 
    lazy var collectionView: UICollectionView = {
        // Market Types CollectionView
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.estimatedItemSize = UICollectionViewFlowLayout.automaticSize
        layout.minimumInteritemSpacing = 10
        layout.minimumLineSpacing = 10
        layout.sectionInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        
        var collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.collectionViewLayout = layout
        collectionView.showsVerticalScrollIndicator = false
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.alwaysBounceHorizontal = true
        collectionView.register(ListTypeCollectionViewCell.self,
                                                forCellWithReuseIdentifier: ListTypeCollectionViewCell.identifier)
        collectionView.register(ListBackgroundCollectionViewCell.self,
                                       forCellWithReuseIdentifier: ListBackgroundCollectionViewCell.identifier)
        
        collectionView.register(CompetitionListIconCollectionViewCell.self,
                                       forCellWithReuseIdentifier: CompetitionListIconCollectionViewCell.identifier)
        return collectionView
    }()
    
    var contentInset: UIEdgeInsets = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16) {
        didSet {
            if let layout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout {
                layout.sectionInset = contentInset
            }
        }
    }
    

    // MARK: - Properties
    private let viewModel: ChipsTypeViewModel
    private var cancellables = Set<AnyCancellable>()

    init(viewModel: ChipsTypeViewModel) {
        self.viewModel = viewModel
        super.init(frame: .zero)
        
        self.commonInit()
        self.setupBindings()
    }
    
    @available(*, unavailable)
    override init(frame: CGRect) {
        fatalError("init(frame:) has not been unavailable")
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
        
    private func commonInit() {
        self.translatesAutoresizingMaskIntoConstraints = false
        
        self.addSubview(self.collectionView)
        
        self.backgroundColor = .darkGray
        
        self.collectionView.backgroundView?.backgroundColor = .clear
        self.collectionView.backgroundColor = .clear
        self.collectionView.delegate = self
        self.collectionView.dataSource = self
  
        NSLayoutConstraint.activate([
            self.heightAnchor.constraint(equalToConstant: ChipsTypeView.height),
            self.collectionView.topAnchor.constraint(equalTo: self.topAnchor),
            self.collectionView.bottomAnchor.constraint(equalTo: self.bottomAnchor),
            self.collectionView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            self.collectionView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
        ])
        
    }

    private func setupBindings() {
        self.viewModel.$tabs
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                guard let self = self else { return }

                // Reload the collection view
                self.collectionView.reloadData()

                // Restore selection if valid
                self.restoreSelection()
            }
            .store(in: &self.cancellables)

        self.viewModel.$selectedIndex
            .receive(on: DispatchQueue.main)
            .sink { [weak self] index in
                guard let self = self else { return }

                // Select the item if valid
                self.selectTab(at: index)
            }
            .store(in: &self.cancellables)
    }

    /// Restores the selected index after a reload if it's valid.
    private func restoreSelection() {
        guard let selectedIndex = self.viewModel.selectedIndex else { return }
        self.selectTab(at: selectedIndex)
    }

    /// Selects a tab at the given index if it's valid.
    private func selectTab(at index: Int?) {
        guard let index = index,
              index >= 0, // Ensure non-negative index
              index < self.collectionView.numberOfItems(inSection: 0) else {
            return
        }

        let indexPath = IndexPath(item: index, section: 0)
        self.collectionView.selectItem(at: indexPath, animated: true, scrollPosition: .centeredHorizontally)
    }

    
}

// MARK: - UICollectionView DataSource & Delegate
extension ChipsTypeView: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.numberOfTabs()
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard
            let tab = viewModel.tab(at: indexPath.item)
        else {
            fatalError()
        }
        
        switch tab {
        case .textual(let title):
            guard
                let cell = collectionView.dequeueCellType(ListTypeCollectionViewCell.self, indexPath: indexPath)
            else {
                fatalError()
            }
            
            cell.isSelected = indexPath.item == viewModel.selectedIndex
            cell.setupWithTitle(title)
            cell.isCustomDesign = false
            
            return cell
            
        case .icon(let title, let iconName):
            guard
                let cell = collectionView.dequeueCellType(CompetitionListIconCollectionViewCell.self, indexPath: indexPath)
            else {
                fatalError()
            }
            
            cell.isSelected = (indexPath.item == viewModel.selectedIndex)
            cell.setupInfo(title: title, iconName: iconName)
            
            return cell
            
        case .backgroungImage(let title, let iconName, let backgroundName):
            guard
                let cell = collectionView.dequeueCellType(ListBackgroundCollectionViewCell.self, indexPath: indexPath)
            else {
                fatalError()
            }
            
            cell.isSelected = (indexPath.item == viewModel.selectedIndex)
            cell.setupInfo(title: title, iconName: iconName, backgroundName: backgroundName)
            cell.isCustomDesign = true
            // self.shouldShowTabTooltip?()
            
            return cell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        self.viewModel.selectTab(at: indexPath.row)
    }
}
