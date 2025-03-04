//
//  PromotedCompetitionLineTableViewCell.swift
//  Sportsbook
//
//  Created by Ruben Roques on 19/02/2022.
//

import UIKit
import Combine

class PromotedCompetitionLineTableViewCell: UITableViewCell {

    var didSelectSeeAllCompetitionsAction: ((Sport, [Competition]) -> Void)?

    private lazy var titleLabel: UILabel = Self.createTitleLabel()
    private lazy var linesStackView: UIStackView = Self.createLinesStackView()
    private lazy var collectionView: UICollectionView = Self.createCollectionView()

    private var collectionViewHeightConstraint = NSLayoutConstraint()
    private let cellInternSpace: CGFloat = 2.0
    private var collectionViewHeight: CGFloat {
        let cardHeight = StyleHelper.competitionCardsStyleHeight()
        return cardHeight + cellInternSpace + cellInternSpace
    }

    private var cachedCardsStyle: CardsStyle?

    private var showingBackSliderView: Bool = false

    private var viewModel: SportMatchLineViewModel?
    private var cancellables: Set<AnyCancellable> = []

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        self.cachedCardsStyle = StyleHelper.cardsStyleActive()
        
        self.setupSubviews()
        self.setupWithTheme()

        //
        self.collectionView.delegate = self
        self.collectionView.dataSource = self

        self.collectionView.register(CompetitionWidgetCollectionViewCell.self, forCellWithReuseIdentifier: CompetitionWidgetCollectionViewCell.identifier)
        self.collectionView.register(SeeMoreMarketsCollectionViewCell.self, forCellWithReuseIdentifier: SeeMoreMarketsCollectionViewCell.identifier)
        self.collectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: UICollectionViewCell.identifier)

        self.collectionViewHeightConstraint.constant = self.collectionViewHeight

        UIView.performWithoutAnimation {
            self.setNeedsLayout()
            self.layoutIfNeeded()
        }
   }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func prepareForReuse() {
        super.prepareForReuse()

        self.viewModel = nil
        self.titleLabel.text = ""

        self.collectionView.setContentOffset(CGPoint(x: -8, y: 0), animated: false)

        if self.cachedCardsStyle != StyleHelper.cardsStyleActive() {

            self.cachedCardsStyle = StyleHelper.cardsStyleActive()

            self.collectionViewHeightConstraint.constant = self.collectionViewHeight

            UIView.performWithoutAnimation {
                self.setNeedsLayout()
                self.layoutIfNeeded()
            }
        }

        self.reloadCollections()
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        self.setupWithTheme()
    }

    func setupWithTheme() {
        self.backgroundColor = .clear
        self.backgroundView?.backgroundColor = .clear
        self.contentView.backgroundColor = UIColor.App.backgroundPrimary

        self.titleLabel.textColor = UIColor.App.textPrimary

        self.linesStackView.backgroundColor = UIColor.App.backgroundPrimary

        self.collectionView.backgroundView?.backgroundColor = UIColor.App.backgroundPrimary
        self.collectionView.backgroundColor = UIColor.App.backgroundPrimary
   }

    func configure(withViewModel viewModel: SportMatchLineViewModel) {

        self.viewModel = viewModel

        self.viewModel?.titlePublisher
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] in
                self?.titleLabel.text = $0
            })
            .store(in: &cancellables)

        self.viewModel?.refreshPublisher
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] in
                self?.reloadCollections()
            })
            .store(in: &cancellables)

        self.reloadCollections()
    }

    func reloadCollections() {
        self.collectionView.reloadData()
    }

    func didSelectSeeAllCompetitions(_ competitions: [Competition]) {
        guard
            let viewModel = self.viewModel
        else { return }

        self.didSelectSeeAllCompetitionsAction?(viewModel.sport, competitions)
    }
}

extension PromotedCompetitionLineTableViewCell: UIScrollViewDelegate {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {

        let pushScreenMargin = 100.0
        let bounceXPosition = ( (scrollView.contentOffset.x - scrollView.contentInset.left) + scrollView.frame.width) - scrollView.contentSize.width
        
        if bounceXPosition >= 0 {
            for cell in self.collectionView.visibleCells {
                if let seeMoreCell = cell as? SeeMoreMarketsCollectionViewCell {
                    seeMoreCell.setAnimationPercentage(bounceXPosition / Double(pushScreenMargin * 0.98))
                }
            }
        }
        
        if scrollView.isTracking, scrollView == self.collectionView, let viewModel = self.viewModel {
            let screenWidth = UIScreen.main.bounds.size.width
            if scrollView.contentSize.width > screenWidth {
                if scrollView.contentOffset.x + scrollView.frame.width > scrollView.contentSize.width + pushScreenMargin {
                    let generator = UIImpactFeedbackGenerator(style: .heavy)
                    generator.prepare()
                    generator.impactOccurred()
                    self.didSelectSeeAllCompetitions(viewModel.allTopCompetitions())
                    return
                }
            }
        }

    }
    
}

extension PromotedCompetitionLineTableViewCell: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        guard let viewModel = self.viewModel else { return 0 }
        return viewModel.numberOfSections(forLine: 0)
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        guard let viewModel = self.viewModel else { return 0 }
        return viewModel.numberOfItems(forLine: 0, forSection: section)
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

        guard let viewModel = self.viewModel else { fatalError() }

        if indexPath.section == 1 {
            guard
                let cell = collectionView.dequeueCellType(SeeMoreMarketsCollectionViewCell.self, indexPath: indexPath)
            else {
                fatalError()
            }
            if let numberTotalOfMarkets = self.viewModel?.numberOfMatchMarket() {
                let marketsRawString = localized("number_of_markets")
                let singularMarketRawString = localized("number_of_market_singular")
                var marketString = ""
                if numberTotalOfMarkets > 1 {
                    marketString = marketsRawString.replacingOccurrences(of: "{num_markets}", with: "\(numberTotalOfMarkets)")
                }
                else {
                    marketString = singularMarketRawString.replacingOccurrences(of: "{num_markets}", with: "\(numberTotalOfMarkets)")
                }
                cell.configureWithSubtitleString(marketString)
                cell.tappedAction = { [weak self] in
                    if let weakSelf = self, let viewModel = weakSelf.viewModel {
                        weakSelf.didSelectSeeAllCompetitions(viewModel.allTopCompetitions() )
                    }
                }
                if numberTotalOfMarkets == 0 {
                    cell.hideSubtitle()
                }
            }

            return cell
        }
        
        guard
            let cell = collectionView.dequeueCellType(CompetitionWidgetCollectionViewCell.self, indexPath: indexPath),
            let viewModel = viewModel.competitionViewModel(forIndex: indexPath.row)
        else {
            fatalError()
        }
        cell.configure(withViewModel: viewModel)
        cell.didSelectCompetitionAction = { [weak self] competition in
            self?.didSelectSeeAllCompetitions([competition])
        }
        
        return cell

    }

    func collectionView(_ collectionView: UICollectionView,
                        didSelectItemAt indexPath: IndexPath) {

    }

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 16
    }

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 16
    }

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 8, bottom: 0, right: 8)
    }

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {

        var height: CGFloat = 124
        switch StyleHelper.cardsStyleActive() {
        case .small: height = 90
        case .normal: height = 124
        }

        if indexPath.section == 1 {
            return CGSize(width: 99, height: height)
        }
        else {
            let screenWidth = UIScreen.main.bounds.size.width
            var width = screenWidth*0.87
            if width > 390 {
                width = 390
            }
            return CGSize(width: width, height: height)
        }
    }
}

extension PromotedCompetitionLineTableViewCell {

    private static func createTitleLabel() -> UILabel {
        let titleLabel = UILabel()
        titleLabel.numberOfLines = 1
        titleLabel.text = ""
        titleLabel.font = AppFont.with(type: .semibold, size: 13)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        return titleLabel
    }

    private static func createLinesStackView() -> UIStackView {
        let linesStackView = UIStackView()
        linesStackView.axis = .vertical
        linesStackView.alignment = .fill
        linesStackView.distribution = .fill
        linesStackView.spacing = 8
        linesStackView.translatesAutoresizingMaskIntoConstraints = false
        return linesStackView
    }

    private static func createCollectionView() -> UICollectionView {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        let collectionView = UICollectionView.init(frame: .zero, collectionViewLayout: layout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.showsVerticalScrollIndicator = false
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.alwaysBounceHorizontal = true
        collectionView.contentInset = UIEdgeInsets(top: 0, left: 8, bottom: 0, right: 8)
        return collectionView
    }

    private func setupSubviews() {
        // Add subviews to self.view or each other
        self.contentView.clipsToBounds = true

        self.contentView.addSubview(self.titleLabel)
        self.contentView.addSubview(self.linesStackView)

        self.linesStackView.addArrangedSubview(self.collectionView)

        // Initialize constraints
        self.initConstraints()
    }

    private func initConstraints() {

        self.collectionViewHeightConstraint = self.collectionView.heightAnchor.constraint(equalToConstant: self.collectionViewHeight)

        NSLayoutConstraint.activate([
            self.titleLabel.topAnchor.constraint(equalTo: self.contentView.topAnchor, constant: 16),

            self.titleLabel.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor, constant: 24),
            self.titleLabel.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor, constant: -16),
            self.titleLabel.heightAnchor.constraint(equalToConstant: 19),

            self.linesStackView.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor),
            self.linesStackView.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor),
            self.linesStackView.topAnchor.constraint(equalTo: self.titleLabel.bottomAnchor, constant: 16),
            self.linesStackView.bottomAnchor.constraint(equalTo: self.contentView.bottomAnchor, constant: -16),

            self.collectionViewHeightConstraint,
     ])
    }
}
