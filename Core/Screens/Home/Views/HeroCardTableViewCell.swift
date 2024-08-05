//
//  HeroCardTableViewCell.swift
//  Sportsbook
//
//  Created by André Lascas on 01/08/2024.
//

import UIKit
import Combine

class HeroCardTableViewCell: UITableViewCell {

    private lazy var outerView: UIView = Self.createOuterView()
    private lazy var baseView: UIView = Self.createBaseView()
    private lazy var topImageView: UIImageView = Self.createTopImageView()
    private lazy var gradientView: GradientView = Self.createGradientView()
    private lazy var bottomInfoBaseView: UIView = Self.createBottomInfoBaseView()
    private lazy var favoriteButton: UIButton = Self.createFavoriteButton()
    private lazy var favoriteIconImageView: UIImageView = Self.createFavoriteIconImageView()
    private lazy var sportIconImageView: UIImageView = Self.createSportIconImageView()
    private lazy var locationIconImageView: UIImageView = Self.createLocationIconImageView()
    private lazy var competitionLabel: UILabel = Self.createCompetitionLabel()
    private lazy var topSeparatorAlphaLineView: FadingView = Self.createTopSeparatorAlphaLineView()
    private lazy var collectionView: UICollectionView = Self.createCollectionView()
    private lazy var pageControl = Self.createPageControl()

    private weak var timer: Timer?
    
    private let cellHeight: CGFloat = 579.0
    private let cellInfoHeight: CGFloat = 234.0
    
    private var cancellables = Set<AnyCancellable>()
    
    private var viewModel: MatchWidgetCellViewModel? = nil
    
    var isFavorite: Bool = false {
        didSet {
            if self.isFavorite {
                self.favoriteIconImageView.image = UIImage(named: "selected_favorite_icon")
            }
            else {
                self.favoriteIconImageView.image = UIImage(named: "unselected_favorite_icon")
            }
        }
    }

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        self.setupSubviews()
        self.setupWithTheme()
        
        self.favoriteButton.addTarget(self, action: #selector(self.didTapFavoriteIcon), for: .primaryActionTriggered)
        
        self.collectionView.delegate = self
        self.collectionView.dataSource = self

        self.collectionView.register(HeroCardMarketCollectionViewCell.self, forCellWithReuseIdentifier: HeroCardMarketCollectionViewCell.identifier)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func prepareForReuse() {
        super.prepareForReuse()

        self.isFavorite = false
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        self.setupWithTheme()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        self.sportIconImageView.layer.cornerRadius = self.sportIconImageView.frame.size.width / 2
        
        self.locationIconImageView.layer.cornerRadius = self.locationIconImageView.frame.size.width / 2
        
    }

    func setupWithTheme() {
        self.backgroundColor = .clear
        self.backgroundView?.backgroundColor = .clear
        self.contentView.backgroundColor = .clear

        self.outerView.backgroundColor = .blue
        
        self.baseView.backgroundColor = .clear
        
        self.topImageView.backgroundColor = .clear
        
        self.gradientView.backgroundColor = .clear
        
        self.bottomInfoBaseView.backgroundColor = UIColor.App.backgroundPrimary
        
        self.favoriteButton.backgroundColor = .clear
        self.favoriteIconImageView.backgroundColor = .clear
        
        self.sportIconImageView.backgroundColor = .clear
        
        self.locationIconImageView.backgroundColor = .clear
        
        self.competitionLabel.textColor = UIColor.App.textSecondary
        
        self.topSeparatorAlphaLineView.backgroundColor = UIColor.App.highlightPrimary
        
        self.collectionView.backgroundView?.backgroundColor = .clear
        self.collectionView.backgroundColor = .clear

        self.pageControl.backgroundColor = .clear
        self.pageControl.pageIndicatorTintColor = .gray
        self.pageControl.currentPageIndicatorTintColor = UIColor.App.highlightPrimary

    }
    
    func configure(withViewModel viewModel: MatchWidgetCellViewModel) {
        
        self.viewModel = viewModel
        
        viewModel.promoImageURLPublisher
            .compactMap({ $0 })
            .receive(on: DispatchQueue.main)
            .sink { [weak self] promoImageURL in
                self?.topImageView.kf.setImage(with: promoImageURL)
            }
            .store(in: &self.cancellables)
        
        viewModel.countryFlagImagePublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] countryFlagImage in
                self?.locationIconImageView.image = countryFlagImage
            }
            .store(in: &self.cancellables)
        
        viewModel.sportIconImagePublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] sportIconImage in
                self?.sportIconImageView.image = sportIconImage
            }
            .store(in: &self.cancellables)
        
        viewModel.isFavoriteMatchPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isFavoriteMatch in
                self?.isFavorite = isFavoriteMatch
            }
            .store(in: &self.cancellables)
        
        viewModel.competitionNamePublisher
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] competitionName in
                self?.competitionLabel.text = competitionName
            })
            .store(in: &self.cancellables)
        
        self.pageControl.numberOfPages = viewModel.match.markets.count
        self.pageControl.currentPage = 0

        if viewModel.match.markets.count > 1 {
            self.pageControl.isHidden = false
            self.startCollectionViewTimer()
        }
        else {
            self.pageControl.isHidden = true
        }
    }
    
    func markAsFavorite(match: Match) {
        
        if Env.favoritesManager.isEventFavorite(eventId: match.id) {
//            Env.favoritesManager.removeFavorite(eventId: match.id, favoriteType: .match)
            print("NOT FAVORITE")
            self.isFavorite = false
        }
        else {
//            Env.favoritesManager.addFavorite(eventId: match.id, favoriteType: .match)
            print("FAVORITE")
            self.isFavorite = true
        }
        
    }
    
    func reloadData() {
        self.collectionView.reloadData()
    }


    func startCollectionViewTimer() {
        self.resetTime()
    }

    func resetTime() {
        self.timer?.invalidate()
        self.timer = nil

        self.timer = Timer.scheduledTimer(timeInterval: 6.0, target: self, selector: #selector(self.autoScrollCollectionView), userInfo: nil, repeats: true)
    }
    
    // MARK: Actions
    @objc func didTapFavoriteIcon() {
        if Env.userSessionStore.isUserLogged() {
            if let match = self.viewModel?.match {
                self.markAsFavorite(match: match)
            }
        }
        else {
            let loginViewController = Router.navigationController(with: LoginViewController())
            self.viewController?.present(loginViewController, animated: true, completion: nil)
        }
    }
    
    @objc func autoScrollCollectionView(_ timer1: Timer) {

        let bannersCount = self.viewModel?.match.markets.count ?? 0

        guard bannersCount != 0 else {
            return
        }
        
        let visibleRect = CGRect(origin: collectionView.contentOffset, size: collectionView.bounds.size)
        let visiblePoint = CGPoint(x: visibleRect.midX, y: visibleRect.midY)
        guard let visibleIndexPath = collectionView.indexPathForItem(at: visiblePoint) else { return }
        
        let nextItem = visibleIndexPath.item + 1
        if nextItem < bannersCount {
            let nextIndexPath = IndexPath(item: nextItem, section: visibleIndexPath.section)
            collectionView.scrollToItem(at: nextIndexPath, at: .centeredHorizontally, animated: true)
        } else {
            let firstIndexPath = IndexPath(item: 0, section: visibleIndexPath.section)
            collectionView.scrollToItem(at: firstIndexPath, at: .centeredHorizontally, animated: true)
        }

    }
}

extension HeroCardTableViewCell: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return  self.viewModel?.match.markets.count ?? 0
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

        guard
            let cell = collectionView.dequeueCellType(HeroCardMarketCollectionViewCell.self, indexPath: indexPath),
            let match = self.viewModel?.match,
            let market = self.viewModel?.match.markets[safe: indexPath.row]
        else {
            fatalError()
        }
        
        cell.configure(market: market, match: match)
        
        return cell

    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let topMargin: CGFloat = 5.0
        let leftMargin: CGFloat = 10.0
        return CGSize(width: collectionView.frame.size.width - (leftMargin * 2),
                      height: collectionView.frame.size.height + (topMargin * 2))
    }

    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        
        self.pageControl.currentPage = indexPath.row

        self.resetTime()
    }

}

extension HeroCardTableViewCell {
    
    private static func createOuterView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.cornerRadius = CornerRadius.card
        view.clipsToBounds = true
        return view
    }
    
    private static func createBaseView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.cornerRadius = CornerRadius.card
        view.clipsToBounds = true
        return view
    }
    
    private static func createTopImageView() -> UIImageView {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.image = nil
        imageView.contentMode = .scaleAspectFill
        return imageView
    }
    
    private static func createGradientView() -> GradientView {
        let gradientView = GradientView()
        gradientView.translatesAutoresizingMaskIntoConstraints = false
        gradientView.colors = [(.clear, NSNumber(0.0)),
                               (UIColor.App.backgroundPrimary, NSNumber(1.0))]
        gradientView.startPoint = CGPoint(x: 0.0, y: 0.0)
        gradientView.endPoint = CGPoint(x: 0.0, y: 1.0)
        return gradientView
    }
    
    private static func createBottomInfoBaseView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }
    
    private static func createFavoriteButton() -> UIButton {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("", for: .normal)
        button.setImage(nil, for: .normal)
        return button
    }
    
    private static func createFavoriteIconImageView() -> UIImageView {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.image = UIImage(named: "unselected_favorite_icon")
        imageView.contentMode = .scaleAspectFit
        return imageView
    }
    
    private static func createSportIconImageView() -> UIImageView {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.image = UIImage(named: "sport_type_icon_default")
        imageView.contentMode = .scaleAspectFit
        imageView.clipsToBounds = true
        return imageView
    }
    
    private static func createLocationIconImageView() -> UIImageView {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.image = UIImage(named: "country_flag_240")
        imageView.contentMode = .scaleAspectFit
        imageView.clipsToBounds = true
        return imageView
    }
    
    private static func createCompetitionLabel() -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Competition"
        label.font = AppFont.with(type: .semibold, size: 11)
        label.textAlignment = .left
        return label
    }
    
    private static func createTopSeparatorAlphaLineView() -> FadingView {
        let fadingView = FadingView()
        fadingView.translatesAutoresizingMaskIntoConstraints = false
        fadingView.colors = [.clear, .black, .black, .clear]
        fadingView.startPoint = CGPoint(x: 0.0, y: 0.5)
        fadingView.endPoint = CGPoint(x: 1.0, y: 0.5)
        fadingView.fadeLocations = [0.0, 0.42, 0.58, 1.0]
        return fadingView
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
        return collectionView
    }
    
    private static func createPageControl() -> UIPageControl {
        let pageControl = UIPageControl()
        pageControl.translatesAutoresizingMaskIntoConstraints = false
        return pageControl
    }
    
    private func setupSubviews() {

        self.contentView.addSubview(self.outerView)
        
        self.contentView.addSubview(self.baseView)
        
        self.baseView.addSubview(self.topImageView)
        
        self.baseView.addSubview(self.gradientView)
                
        self.baseView.addSubview(self.bottomInfoBaseView)
        
        self.bottomInfoBaseView.addSubview(self.favoriteButton)
        self.bottomInfoBaseView.addSubview(self.favoriteIconImageView)
                
        self.bottomInfoBaseView.addSubview(self.sportIconImageView)
        
        self.bottomInfoBaseView.addSubview(self.locationIconImageView)
        
        self.bottomInfoBaseView.addSubview(self.competitionLabel)
        
        self.baseView.bringSubviewToFront(self.favoriteButton)
        
        self.bottomInfoBaseView.addSubview(self.topSeparatorAlphaLineView)
        
        self.bottomInfoBaseView.addSubview(self.collectionView)
        
        self.bottomInfoBaseView.addSubview(self.pageControl)

        self.initConstraints()
        
        self.setNeedsLayout()
        self.layoutIfNeeded()
    }
    
    private func initConstraints() {
        NSLayoutConstraint.activate([
            self.outerView.heightAnchor.constraint(equalToConstant: self.cellHeight),
            
            self.outerView.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor),
            self.outerView.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor),
            self.outerView.topAnchor.constraint(equalTo: self.contentView.topAnchor),
            self.outerView.bottomAnchor.constraint(equalTo: self.contentView.bottomAnchor),
            
            self.baseView.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor, constant: 1),
            self.baseView.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor, constant: -1),
            self.baseView.topAnchor.constraint(equalTo: self.contentView.topAnchor, constant: 1),
            self.baseView.bottomAnchor.constraint(equalTo: self.contentView.bottomAnchor, constant: -1),
            
            self.topImageView.topAnchor.constraint(equalTo: self.baseView.topAnchor),
            self.topImageView.leadingAnchor.constraint(equalTo: self.baseView.leadingAnchor),
            self.topImageView.trailingAnchor.constraint(equalTo: self.baseView.trailingAnchor),
            self.topImageView.bottomAnchor.constraint(equalTo: self.baseView.bottomAnchor)
        ])
        
        // Bottom info
        NSLayoutConstraint.activate([
            self.bottomInfoBaseView.leadingAnchor.constraint(equalTo: self.baseView.leadingAnchor),
            self.bottomInfoBaseView.trailingAnchor.constraint(equalTo: self.baseView.trailingAnchor),
            self.bottomInfoBaseView.bottomAnchor.constraint(equalTo: self.baseView.bottomAnchor),
//            self.bottomInfoBaseView.heightAnchor.constraint(equalToConstant: self.cellInfoHeight),
            
            self.gradientView.leadingAnchor.constraint(equalTo: self.baseView.leadingAnchor),
            self.gradientView.trailingAnchor.constraint(equalTo: self.baseView.trailingAnchor),
            self.gradientView.bottomAnchor.constraint(equalTo: self.bottomInfoBaseView.topAnchor),
            self.gradientView.heightAnchor.constraint(equalToConstant: 100),
            
            self.favoriteButton.leadingAnchor.constraint(equalTo: self.bottomInfoBaseView.leadingAnchor),
            self.favoriteButton.topAnchor.constraint(equalTo: self.bottomInfoBaseView.topAnchor),
            self.favoriteButton.widthAnchor.constraint(equalToConstant: 40),
            self.favoriteButton.heightAnchor.constraint(equalTo: self.favoriteButton.widthAnchor),
            
            self.favoriteIconImageView.leadingAnchor.constraint(equalTo: self.bottomInfoBaseView.leadingAnchor, constant: 12),
            self.favoriteIconImageView.topAnchor.constraint(equalTo: self.bottomInfoBaseView.topAnchor, constant: 12),
            self.favoriteIconImageView.widthAnchor.constraint(equalToConstant: 15),
            self.favoriteIconImageView.heightAnchor.constraint(equalTo: self.favoriteIconImageView.widthAnchor),
            
            self.sportIconImageView.leadingAnchor.constraint(equalTo: self.favoriteIconImageView.trailingAnchor, constant: 7),
            self.sportIconImageView.centerYAnchor.constraint(equalTo: self.favoriteIconImageView.centerYAnchor),
            self.sportIconImageView.widthAnchor.constraint(equalToConstant: 15),
            self.sportIconImageView.heightAnchor.constraint(equalTo: self.sportIconImageView.widthAnchor),
            
            self.locationIconImageView.leadingAnchor.constraint(equalTo: self.sportIconImageView.trailingAnchor, constant: 7),
            self.locationIconImageView.centerYAnchor.constraint(equalTo: self.favoriteIconImageView.centerYAnchor),
            self.locationIconImageView.widthAnchor.constraint(equalToConstant: 15),
            self.locationIconImageView.heightAnchor.constraint(equalTo: self.locationIconImageView.widthAnchor),
            
            self.competitionLabel.leadingAnchor.constraint(equalTo: self.locationIconImageView.trailingAnchor, constant: 7),
            self.competitionLabel.trailingAnchor.constraint(equalTo: self.bottomInfoBaseView.trailingAnchor, constant: -12),
            self.competitionLabel.centerYAnchor.constraint(equalTo: self.favoriteIconImageView.centerYAnchor),
            
            self.topSeparatorAlphaLineView.leadingAnchor.constraint(equalTo: self.bottomInfoBaseView.leadingAnchor),
            self.topSeparatorAlphaLineView.trailingAnchor.constraint(equalTo: self.bottomInfoBaseView.trailingAnchor),
            self.topSeparatorAlphaLineView.heightAnchor.constraint(equalToConstant: 1),
            self.topSeparatorAlphaLineView.topAnchor.constraint(equalTo: self.favoriteIconImageView.bottomAnchor, constant: 10),
            
            self.collectionView.leadingAnchor.constraint(equalTo: self.baseView.leadingAnchor, constant: 0),
            self.collectionView.trailingAnchor.constraint(equalTo: self.baseView.trailingAnchor, constant: 0),
            self.collectionView.topAnchor.constraint(equalTo: self.topSeparatorAlphaLineView.bottomAnchor, constant: 10),
            self.collectionView.heightAnchor.constraint(equalToConstant: 100),
            
            self.pageControl.centerXAnchor.constraint(equalTo: self.baseView.centerXAnchor),
            self.pageControl.topAnchor.constraint(equalTo: self.collectionView.bottomAnchor, constant: -5),
            self.pageControl.bottomAnchor.constraint(equalTo: self.baseView.bottomAnchor, constant: 0),
        ])
    }
}
