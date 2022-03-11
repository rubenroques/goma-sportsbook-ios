//
//  OutrightCompetitionLineTableViewCell.swift
//  Sportsbook
//
//  Created by Ruben Roques on 21/02/2022.
//

import UIKit
import Combine

class OutrightCompetitionLineViewModel {

    var competition: Competition
    var numberOfMarkets: Int

    private var shouldShowSeeAllOption: Bool

    init(competition: Competition, shouldShowSeeAllOption: Bool = true) {
        self.competition = competition
        self.numberOfMarkets = competition.outrightMarkets
        self.shouldShowSeeAllOption = shouldShowSeeAllOption
    }

    func numberOfSection() -> Int {
        return shouldShowSeeAllOption ? 2 : 1
    }

    func numberOfItems(forSection section: Int) -> Int {
        return 1
    }

    func outrightCompetitionWidgetViewModel() -> OutrightCompetitionWidgetViewModel {
        return OutrightCompetitionWidgetViewModel(competition: self.competition)
    }
}

class OutrightCompetitionLineTableViewCell: UITableViewCell {

    var didSelectCompetitionAction: ((Competition) -> Void)?

    private lazy var linesStackView: UIStackView = Self.createLinesStackView()
    private lazy var collectionView: UICollectionView = Self.createCollectionView()

    private var showingBackSliderView: Bool = false

    private var viewModel: OutrightCompetitionLineViewModel?
    private var cancellables: Set<AnyCancellable> = []

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        self.setupSubviews()
        self.setupWithTheme()

        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(didTapSeeAll))
        self.linesStackView.addGestureRecognizer(tapGestureRecognizer)
   }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func prepareForReuse() {
        super.prepareForReuse()

        self.viewModel = nil
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

        self.linesStackView.backgroundColor = UIColor.App.backgroundPrimary

        self.collectionView.backgroundView?.backgroundColor = UIColor.App.backgroundPrimary
        self.collectionView.backgroundColor = UIColor.App.backgroundPrimary
   }

    func configure(withViewModel viewModel: OutrightCompetitionLineViewModel) {

        self.viewModel = viewModel

        self.reloadCollections()
    }

    func reloadCollections() {
        self.collectionView.reloadData()
    }

    @objc func didTapSeeAll() {
        guard
            let viewModel = self.viewModel
        else { return }

        self.didSelectCompetitionAction?(viewModel.competition)
    }
}

extension OutrightCompetitionLineTableViewCell: UIScrollViewDelegate {

    func scrollViewDidScroll(_ scrollView: UIScrollView) {

        if scrollView == self.collectionView,
           let viewModel = self.viewModel {
            let screenWidth = UIScreen.main.bounds.size.width
            if scrollView.isTracking && scrollView.contentSize.width > screenWidth {
                if scrollView.contentOffset.x + scrollView.frame.width > scrollView.contentSize.width + 100 {
                    let generator = UIImpactFeedbackGenerator(style: .heavy)
                    generator.prepare()
                    generator.impactOccurred()
                    self.didSelectCompetitionAction?(viewModel.competition)
                    return
                }
            }
        }

    }

}

extension OutrightCompetitionLineTableViewCell: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        guard let viewModel = self.viewModel else { return 0 }
        return viewModel.numberOfSection()
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        guard let viewModel = self.viewModel else { return 0 }
        return viewModel.numberOfItems(forSection: section)
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

        guard let viewModel = self.viewModel else { fatalError() }

        if indexPath.section == 1 {
            guard
                let cell = collectionView.dequeueCellType(SeeMoreMarketsCollectionViewCell.self, indexPath: indexPath)
            else {
                fatalError()
            }

            if let numberTotalOfMarkets = self.viewModel?.numberOfMarkets {
                let marketsRawString = localized("number_of_markets")
                let singularMarketRawString = localized("number_of_market_singular")
                var marketString = ""
                if numberTotalOfMarkets > 1 {
                    marketString = marketsRawString.replacingOccurrences(of: "%s", with: "\(numberTotalOfMarkets)")
                }
                else {
                    marketString = singularMarketRawString.replacingOccurrences(of: "%s", with: "\(numberTotalOfMarkets)")
                }
                cell.configureWithSubtitleString(marketString)

                if numberTotalOfMarkets == 0 {
                    cell.hideSubtitle()
                }
            }

            return cell
        }
        else if let cell = collectionView.dequeueCellType(OutrightCompetitionWidgetCollectionViewCell.self, indexPath: indexPath) {
            let cellViewModel = viewModel.outrightCompetitionWidgetViewModel()
            cell.configure(withViewModel: cellViewModel)
            cell.tappedLineAction = { [weak self] competition in
                self?.didTapSeeAll()
            }
            return cell
        }
        fatalError()
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

        if indexPath.section == 1 {
            return CGSize(width: 99, height: 124)
        }
        else {
            let screenWidth = UIScreen.main.bounds.size.width
            var width = screenWidth*0.87
            if width > 390 {
                width = 390
            }
            return CGSize(width: width, height: 124)
        }
    }
}

extension OutrightCompetitionLineTableViewCell {

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

        self.contentView.clipsToBounds = true

        self.linesStackView.addArrangedSubview(self.collectionView)

        self.contentView.addSubview(self.linesStackView)

        self.collectionView.delegate = self
        self.collectionView.dataSource = self

        self.collectionView.register(OutrightCompetitionWidgetCollectionViewCell.self, forCellWithReuseIdentifier: OutrightCompetitionWidgetCollectionViewCell.identifier)
        self.collectionView.register(SeeMoreMarketsCollectionViewCell.nib, forCellWithReuseIdentifier: SeeMoreMarketsCollectionViewCell.identifier)
        self.collectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: UICollectionViewCell.identifier)

        // Initialize constraints
        self.initConstraints()
    }

    private func initConstraints() {
        NSLayoutConstraint.activate([

            self.linesStackView.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor),
            self.linesStackView.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor),
            self.linesStackView.topAnchor.constraint(equalTo: self.contentView.topAnchor, constant: 8),
            self.linesStackView.bottomAnchor.constraint(equalTo: self.contentView.bottomAnchor, constant: -8),

            self.collectionView.heightAnchor.constraint(equalToConstant: 160),
     ])
    }
}


