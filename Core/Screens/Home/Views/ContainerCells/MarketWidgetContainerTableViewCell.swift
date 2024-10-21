//
//  MarketWidgetContainerTableViewCell.swift
//  Sportsbook
//
//  Created by Ruben Roques on 20/10/2024.
//
import UIKit

class MarketWidgetContainerTableViewCell: UITableViewCell {

    var tappedMatchIdAction: ((String) -> Void) = { _ in }
    var didTapFavoriteMatchAction: ((Match) -> Void) = { _ in }
    var didLongPressOdd: ((BettingTicket) -> Void) = { _ in }
    var tappedMixMatchIdAction: ((String) -> Void)?

    private lazy var backSliderView: UIView = Self.createBackSliderView()
    private lazy var backSliderIconImageView: UIImageView = Self.createBackSliderIconImageView()
    
    private lazy var baseView: UIView = Self.createBaseView()
    private lazy var collectionView: UICollectionView = Self.createCell()

    private var collectionViewHeightConstraint: NSLayoutConstraint?

    private var showingBackSliderView: Bool = false

    private var viewModel: MarketWidgetContainerTableViewModel?

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        self.collectionViewHeightConstraint = self.collectionView.heightAnchor.constraint(equalToConstant: 300)

        self.setupSubviews()
        self.setupWithTheme()

        self.collectionView.tag = 18
        self.collectionView.delegate = self
        self.collectionView.dataSource = self
        self.collectionView.register(ProChoiceHighlightCollectionViewCell.self,
                                     forCellWithReuseIdentifier: ProChoiceHighlightCollectionViewCell.identifier)

        let centerCellCollectionViewFlowLayout = CenterCellCollectionViewFlowLayout(rightOffset: 0.0)
        centerCellCollectionViewFlowLayout.scrollDirection = .horizontal
        
        self.collectionView.collectionViewLayout = centerCellCollectionViewFlowLayout
        
        self.backSliderView.alpha = 0.0
        
        self.backSliderView.layer.cornerRadius = 6

        let backSliderTapGesture = UITapGestureRecognizer(target: self, action: #selector(didTapBackSliderButton))
        self.backSliderView.addGestureRecognizer(backSliderTapGesture)
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
        
        self.backSliderView.backgroundColor = UIColor.App.backgroundOdds
        self.backSliderIconImageView.setTintColor(color: UIColor.App.iconPrimary)
    }

    func setupWithViewModel(_ viewModel: MarketWidgetContainerTableViewModel) {

        self.viewModel = viewModel
        
        self.collectionViewHeightConstraint?.constant = viewModel.maxHeightForInnerCards()
        self.collectionView.isScrollEnabled = viewModel.isScrollEnabled
        
        self.setNeedsLayout()
        self.collectionView.reloadData()
    }
    
    @objc func didTapBackSliderButton() {
        self.collectionView.setContentOffset(CGPoint(x: -self.collectionView.contentInset.left, y: 1), animated: true)
    }
    
}


extension MarketWidgetContainerTableViewCell: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {

        let screenWidth = UIScreen.main.bounds.size.width
        let width = screenWidth*0.6

        if scrollView.contentOffset.x > width {
            if !self.showingBackSliderView {
                self.showingBackSliderView = true
                UIView.animate(withDuration: 0.2) {
                    self.backSliderView.alpha = 1.0
                }
            }
        }
        else {
            if self.showingBackSliderView {
                self.showingBackSliderView = false
                UIView.animate(withDuration: 0.2) {
                    self.backSliderView.alpha = 0.0
                }
            }
        }
    }
}

extension MarketWidgetContainerTableViewCell: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

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
        let cellIdentifier = ProChoiceHighlightCollectionViewCell.identifier

        guard
            let cell = collectionView.dequeueCellType(ProChoiceHighlightCollectionViewCell.self, indexPath: indexPath),
            let cardsViewModel = viewModel.cardsViewModels[safe: indexPath.row]
        else {
            fatalError()
        }

        return cell
    }

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {

        let heightForitem = self.viewModel?.heightForItem(atIndex: indexPath.row) ?? 0.0
        
        let screenWidth = UIScreen.main.bounds.size.width
        var width = screenWidth*0.87
        
        if width > 390 {
            width = 390
        }
        
        return CGSize(width: width, height: heightForitem)
    }

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: MarketWidgetContainerTableViewModel.topMargin,
                            left: MarketWidgetContainerTableViewModel.leftMargin,
                            bottom: MarketWidgetContainerTableViewModel.topMargin,
                            right: MarketWidgetContainerTableViewModel.leftMargin)
    }

}

extension MarketWidgetContainerTableViewCell {

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

        return collectionView
    }

    private static func createBackSliderView() -> UIView {
        let backSliderView = UIView()
        backSliderView.translatesAutoresizingMaskIntoConstraints = false
        return backSliderView
    }
    
    private static func createBackSliderIconImageView() -> UIImageView {
        let backSliderIconImageView = UIImageView()
        backSliderIconImageView.image = UIImage(named: "arrow_circle_left_icon")
        backSliderIconImageView.translatesAutoresizingMaskIntoConstraints = false
        backSliderIconImageView.contentMode = .scaleAspectFit
        return backSliderIconImageView
    }
    
    private func setupSubviews() {

        // Add subviews to self.view or each other
        self.contentView.addSubview(self.baseView)
        self.baseView.addSubview(self.collectionView)

        self.backSliderView.addSubview(self.backSliderIconImageView)
        self.baseView.addSubview(self.backSliderView)
        
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

            self.backSliderView.widthAnchor.constraint(equalToConstant: 78),
            self.backSliderView.heightAnchor.constraint(equalToConstant: 38),
            self.backSliderView.centerXAnchor.constraint(equalTo: self.baseView.leadingAnchor),
            self.backSliderView.centerYAnchor.constraint(equalTo: self.baseView.centerYAnchor),

            self.backSliderIconImageView.trailingAnchor.constraint(equalTo: self.backSliderView.trailingAnchor, constant: -7),
            self.backSliderIconImageView.centerYAnchor.constraint(equalTo: self.backSliderView.centerYAnchor),
            self.backSliderIconImageView.widthAnchor.constraint(equalToConstant: 24),
            self.backSliderIconImageView.heightAnchor.constraint(equalToConstant: 24),
            
            self.collectionViewHeightConstraint!
        ])
    }
}
