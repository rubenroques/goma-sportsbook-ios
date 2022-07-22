//
//  SuggestedBetLineTableViewCell.swift
//  Sportsbook
//
//  Created by Ruben Roques on 15/02/2022.
//

import UIKit
import Combine

class SuggestedBetLineTableViewCell: UITableViewCell {

    var betNowCallbackAction: (() -> Void)?

    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        var topCollectionView = UICollectionView.init(frame: .zero, collectionViewLayout: layout)
        topCollectionView.translatesAutoresizingMaskIntoConstraints = false
        topCollectionView.showsVerticalScrollIndicator = false
        topCollectionView.showsHorizontalScrollIndicator = false
        topCollectionView.alwaysBounceHorizontal = true
        topCollectionView.contentInset = UIEdgeInsets(top: 0, left: 18, bottom: 0, right: 18)

        return topCollectionView
    }()

    private var viewModel: SuggestedBetLineViewModel?
    private var cancellables: Set<AnyCancellable> = []

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        self.setupSubviews()
        self.setupWithTheme()

        self.collectionView.delegate = self
        self.collectionView.dataSource = self

        self.collectionView.register(BetSuggestedCollectionViewCell.nib,
                                     forCellWithReuseIdentifier: BetSuggestedCollectionViewCell.identifier)
        
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

    func configure(withViewModel viewModel: SuggestedBetLineViewModel) {

        self.viewModel = viewModel
        
        self.reloadCollections()
    }

    func reloadCollections() {
        self.collectionView.reloadData()
        
    }

}

extension SuggestedBetLineTableViewCell: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

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
            let cell = collectionView.dequeueCellType(BetSuggestedCollectionViewCell.self, indexPath: indexPath),
            let viewModel = self.viewModel?.viewModel(forIndex: indexPath.row)
        else {
            fatalError()
        }

        cell.setupWithViewModel(viewModel: viewModel)

        cell.betNowCallbackAction = { [weak self] in
            self?.betNowCallbackAction?()
        }

        return cell
    }

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: Double(collectionView.frame.size.width)*0.85, height: 300)
    }

}

extension SuggestedBetLineTableViewCell {

    private func setupSubviews() {
        // Add subviews to self.view or each other
        self.contentView.addSubview(self.collectionView)

        // Initialize constraints
        self.initConstraints()
    }

    private func initConstraints() {
        NSLayoutConstraint.activate([

            self.collectionView.heightAnchor.constraint(equalToConstant: 320),
            
            self.collectionView.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor, constant: 0),
            self.collectionView.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor, constant: 0),
            self.collectionView.topAnchor.constraint(equalTo: self.contentView.topAnchor, constant: 8),
            self.collectionView.bottomAnchor.constraint(equalTo: self.contentView.bottomAnchor, constant: -8),
     ])
    }
}
