//
//  HeroCardTableViewCell.swift
//  Sportsbook
//
//  Created by André Lascas on 01/08/2024.
//

import UIKit
import Combine

class HeroCardTableViewCell: UITableViewCell {

    var tappedMatchLineAction: ((Match) -> Void) = { _ in }
    
    private lazy var outerView: UIView = Self.createOuterView()
    private lazy var baseView: UIView = Self.createBaseView()
    private lazy var topImageView: UIImageView = Self.createTopImageView()
    private lazy var topInfoBaseView: UIView = Self.createTopInfoBaseView()
    private lazy var gradientPatternView: UIView = Self.createGradientPatternView()
    private lazy var imageGradientPatternView: UIImageView = Self.createImageGradientPatternView()
    private lazy var gradientView: GradientView = Self.createGradientView()
    private lazy var bottomInfoBaseView: UIView = Self.createBottomInfoBaseView()
    private lazy var favoriteButton: UIButton = Self.createFavoriteButton()
    private lazy var favoriteIconImageView: UIImageView = Self.createFavoriteIconImageView()
    private lazy var sportIconImageView: UIImageView = Self.createSportIconImageView()
    private lazy var locationIconImageView: UIImageView = Self.createLocationIconImageView()
    private lazy var competitionLabel: UILabel = Self.createCompetitionLabel()
    private lazy var topSeparatorAlphaLineView: FadingView = Self.createTopSeparatorAlphaLineView()
    private lazy var collectionView: UICollectionView = Self.createCollectionView()
    private lazy var pageControlBaseView: UIView = Self.createPageControlBaseView()
    private lazy var pageControl: CustomPageControl = Self.createPageControl()

    private weak var timer: Timer?
    
    private let cellHeight: CGFloat = 500.0
    
    private var cancellables = Set<AnyCancellable>()
    
    private var viewModel: MatchWidgetCellViewModel?
    
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
        
        let panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(handlePanGesture(_:)))
        panGestureRecognizer.delegate = self
        self.baseView.addGestureRecognizer(panGestureRecognizer)
        
        self.favoriteButton.addTarget(self, action: #selector(self.didTapFavoriteIcon), for: .primaryActionTriggered)
        
        self.collectionView.delegate = self
        self.collectionView.dataSource = self

        self.collectionView.register(
            HeroCardMarketCollectionViewCell.self,
            forCellWithReuseIdentifier: HeroCardMarketCollectionViewCell.identifier
        )
        self.collectionView.register(
            HeroCardSecondaryMarketCollectionViewCell.self,
            forCellWithReuseIdentifier: HeroCardSecondaryMarketCollectionViewCell.identifier
        )
        
        let tapMatchView = UITapGestureRecognizer(target: self, action: #selector(didTapMatchView))
        self.addGestureRecognizer(tapMatchView)
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

        self.outerView.backgroundColor = UIColor.App.highlightPrimary
        
        self.baseView.backgroundColor = UIColor.App.backgroundPrimary
        
        self.topImageView.backgroundColor = .clear
        
        self.topInfoBaseView.backgroundColor = UIColor.black.withAlphaComponent(0.55)
        
        self.gradientView.backgroundColor = .clear
        
        self.bottomInfoBaseView.backgroundColor = .clear
        
        self.imageGradientPatternView.backgroundColor = .clear
        
        self.gradientPatternView.backgroundColor = UIColor.black.withAlphaComponent(0.8)
                
        self.favoriteButton.backgroundColor = .clear
        self.favoriteIconImageView.backgroundColor = .clear
        
        self.sportIconImageView.backgroundColor = .clear
        
        self.locationIconImageView.backgroundColor = .clear
        
        self.competitionLabel.textColor = UIColor.App.textHeroCard
        
        self.topSeparatorAlphaLineView.backgroundColor = UIColor.App.highlightPrimary
        
        self.collectionView.backgroundView?.backgroundColor = .clear
        self.collectionView.backgroundColor = .clear

        self.pageControlBaseView.backgroundColor = .clear
        
        self.pageControl.backgroundColor = .clear

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
        
        viewModel.countryFlagImageNamePublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] countryFlagImageName in
                if let countryFlagImageName, let countryFlagImage = UIImage(named: countryFlagImageName) {
                    self?.locationIconImageView.image = countryFlagImage
                }
                else {
                    self?.locationIconImageView.image = nil
                }
            }
            .store(in: &self.cancellables)
        
        viewModel.sportIconImageNamePublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] sportIconImageName in
                if let sportIconImageName, let sportIconImage = UIImage(named: sportIconImageName) {
                    self?.sportIconImageView.image = sportIconImage.withRenderingMode(.alwaysTemplate)
                    self?.sportIconImageView.tintColor = UIColor.App.iconSportsHeroCard
                }
                else {
                    self?.sportIconImageView.image = nil
                }
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
        self.pageControl.currentPage = self.viewModel?.currentCollectionPage.value ?? 0

        if viewModel.match.markets.count > 1 {
            self.pageControl.isHidden = false
            self.startCollectionViewTimer()
        }
        else {
            self.pageControl.isHidden = true
        }
        
        self.pageControl.didTapIndicator = { [weak self] page in
            let indexPath = IndexPath(item: page, section: 0)
            
            self?.collectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
        }

        self.reloadData()
    }

    func stopTimer() {
        self.timer?.invalidate()
        self.timer = nil
    }

    @objc func handlePanGesture(_ gestureRecognizer: UIPanGestureRecognizer) {
        let translation = gestureRecognizer.translation(in: collectionView)

        if abs(translation.x) > abs(translation.y) {
            if gestureRecognizer.state == .ended {
                let velocity = gestureRecognizer.velocity(in: collectionView)
                
                if velocity.x > 0 {
                    // Swiped right
                    self.getCollectionViewPage(isPrevious: true)
                }
                else {
                    // Swiped left
                    self.getCollectionViewPage()
                }
            }
        }
        else {
            return
        }
    }
    
    func markAsFavorite(match: Match) {
        
        if Env.favoritesManager.isEventFavorite(eventId: match.id) {
            Env.favoritesManager.removeFavorite(eventId: match.id, favoriteType: .match)
            self.isFavorite = false
        }
        else {
            Env.favoritesManager.addFavorite(eventId: match.id, favoriteType: .match)
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

        self.timer = Timer.scheduledTimer(timeInterval: 5.0, target: self, selector: #selector(self.autoScrollCollectionView), userInfo: nil, repeats: true)
    }
    
    private func getCollectionViewPage(isPrevious: Bool = false) {
        let bannersCount = self.viewModel?.match.markets.count ?? 0
        guard bannersCount != 0 else {
            return
        }
        
        let visibleRect = CGRect(origin: collectionView.contentOffset, size: collectionView.bounds.size)
        let visiblePoint = CGPoint(x: visibleRect.midX, y: visibleRect.midY)
        guard let visibleIndexPath = collectionView.indexPathForItem(at: visiblePoint) else { return }
        
        let currentItem = visibleIndexPath.item
        
        let desiredItem = isPrevious ? currentItem - 1 : currentItem + 1
        
        if desiredItem < bannersCount {
            let nextIndexPath = IndexPath(item: desiredItem, section: visibleIndexPath.section)
            collectionView.scrollToItem(at: nextIndexPath, at: .centeredHorizontally, animated: true)
        }
        else {
            let firstIndexPath = IndexPath(item: 0, section: visibleIndexPath.section)
            collectionView.scrollToItem(at: firstIndexPath, at: .centeredHorizontally, animated: true)
        }
        
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
        }
        else {
            let firstIndexPath = IndexPath(item: 0, section: visibleIndexPath.section)
            collectionView.scrollToItem(at: firstIndexPath, at: .centeredHorizontally, animated: true)
        }
        
    }
    
    @IBAction private func didTapMatchView() {
        
        if let viewModel = self.viewModel {
            self.tappedMatchLineAction(viewModel.match)
        }
        
    }
    
}

extension HeroCardTableViewCell {
    override func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
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
        if indexPath.row == 0 {
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
        else {
            guard
                let cell = collectionView.dequeueCellType(HeroCardSecondaryMarketCollectionViewCell.self, indexPath: indexPath),
                let match = self.viewModel?.match,
                let market = self.viewModel?.match.markets[safe: indexPath.row]
            else {
                fatalError()
            }
            cell.configure(market: market, match: match)
            return cell
        }
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let topMargin: CGFloat = 5.0
        let leftMargin: CGFloat = 10.0
        return CGSize(width: collectionView.frame.size.width - (leftMargin * 2),
                      height: collectionView.frame.size.height + (topMargin * 2))
    }

    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        self.pageControl.currentPage = indexPath.row
        self.viewModel?.currentCollectionPage.send(indexPath.row)
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
    
    private static func createTopInfoBaseView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }
    
    private static func createImageGradientPatternView() -> UIImageView {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.image = UIImage(named: "gradient_pattern")
        imageView.contentMode = .scaleAspectFill
        return imageView
    }
    
    private static func createGradientPatternView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }
    
    private static func createGradientView() -> GradientView {
        let gradientView = GradientView()
        gradientView.translatesAutoresizingMaskIntoConstraints = false
        gradientView.colors = [(.clear, NSNumber(0.0)),
                               (UIColor.black.withAlphaComponent(0.8), NSNumber(1.0))]
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
        imageView.layer.borderWidth = 1
        imageView.layer.borderColor = UIColor.App.buttonTextPrimary.cgColor
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
//        collectionView.isPagingEnabled = true
        return collectionView
    }
    
//    private static func createPageControl() -> UIPageControl {
//        let pageControl = UIPageControl()
//        pageControl.translatesAutoresizingMaskIntoConstraints = false
//        return pageControl
//    }
    private static func createPageControlBaseView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }
    
    private static func createPageControl() -> CustomPageControl {
        let customPageControl = CustomPageControl()
        customPageControl.translatesAutoresizingMaskIntoConstraints = false
        return customPageControl
    }
    
    private func setupSubviews() {

        self.contentView.addSubview(self.outerView)
        
        self.contentView.addSubview(self.baseView)
        
        self.baseView.addSubview(self.topImageView)
        
        self.baseView.addSubview(self.topInfoBaseView)
        
        self.topInfoBaseView.addSubview(self.favoriteButton)
        self.topInfoBaseView.addSubview(self.favoriteIconImageView)
                
        self.topInfoBaseView.addSubview(self.sportIconImageView)
        
        self.topInfoBaseView.addSubview(self.locationIconImageView)
        
        self.topInfoBaseView.addSubview(self.competitionLabel)
        
        self.baseView.bringSubviewToFront(self.favoriteButton)

        self.baseView.addSubview(self.topSeparatorAlphaLineView)

        self.baseView.addSubview(self.gradientView)
        
        self.baseView.addSubview(self.gradientPatternView)
        
        self.baseView.addSubview(self.imageGradientPatternView)
        
        self.baseView.addSubview(self.bottomInfoBaseView)
                        
        self.bottomInfoBaseView.addSubview(self.collectionView)
        
        self.bottomInfoBaseView.addSubview(self.pageControlBaseView)
        
        self.pageControlBaseView.addSubview(self.pageControl)

        self.initConstraints()
        
        self.setNeedsLayout()
        self.layoutIfNeeded()
    }
    
    private func initConstraints() {
        NSLayoutConstraint.activate([
            self.outerView.heightAnchor.constraint(equalToConstant: self.cellHeight),
            
            self.outerView.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor, constant: 15),
            self.outerView.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor, constant: -15),
            self.outerView.topAnchor.constraint(equalTo: self.contentView.topAnchor, constant: 5),
            self.outerView.bottomAnchor.constraint(equalTo: self.contentView.bottomAnchor, constant: -5),
            
            self.baseView.leadingAnchor.constraint(equalTo: self.outerView.leadingAnchor, constant: 1),
            self.baseView.trailingAnchor.constraint(equalTo: self.outerView.trailingAnchor, constant: -1),
            self.baseView.topAnchor.constraint(equalTo: self.outerView.topAnchor, constant: 1),
            self.baseView.bottomAnchor.constraint(equalTo: self.outerView.bottomAnchor, constant: -1),
            
            self.topImageView.topAnchor.constraint(equalTo: self.baseView.topAnchor),
            self.topImageView.leadingAnchor.constraint(equalTo: self.baseView.leadingAnchor),
            self.topImageView.trailingAnchor.constraint(equalTo: self.baseView.trailingAnchor),
            self.topImageView.bottomAnchor.constraint(equalTo: self.baseView.bottomAnchor),
            
            self.topInfoBaseView.leadingAnchor.constraint(equalTo: self.baseView.leadingAnchor),
            self.topInfoBaseView.trailingAnchor.constraint(equalTo: self.baseView.trailingAnchor),
            self.topInfoBaseView.topAnchor.constraint(equalTo: self.baseView.topAnchor),
            self.topInfoBaseView.heightAnchor.constraint(equalToConstant: 31),
            
            self.favoriteButton.leadingAnchor.constraint(equalTo: self.topInfoBaseView.leadingAnchor),
            self.favoriteButton.topAnchor.constraint(equalTo: self.topInfoBaseView.topAnchor),
            self.favoriteButton.widthAnchor.constraint(equalToConstant: 40),
            self.favoriteButton.heightAnchor.constraint(equalTo: self.favoriteButton.widthAnchor),
            
            self.favoriteIconImageView.leadingAnchor.constraint(equalTo: self.topInfoBaseView.leadingAnchor, constant: 9),
            self.favoriteIconImageView.topAnchor.constraint(equalTo: self.topInfoBaseView.topAnchor, constant: 9),
            self.favoriteIconImageView.widthAnchor.constraint(equalToConstant: 12),
            self.favoriteIconImageView.heightAnchor.constraint(equalTo: self.favoriteIconImageView.widthAnchor),
            
            self.sportIconImageView.leadingAnchor.constraint(equalTo: self.favoriteIconImageView.trailingAnchor, constant: 7),
            self.sportIconImageView.centerYAnchor.constraint(equalTo: self.favoriteIconImageView.centerYAnchor),
            self.sportIconImageView.widthAnchor.constraint(equalToConstant: 12),
            self.sportIconImageView.heightAnchor.constraint(equalTo: self.sportIconImageView.widthAnchor),
            
            self.locationIconImageView.leadingAnchor.constraint(equalTo: self.sportIconImageView.trailingAnchor, constant: 7),
            self.locationIconImageView.centerYAnchor.constraint(equalTo: self.favoriteIconImageView.centerYAnchor),
            self.locationIconImageView.widthAnchor.constraint(equalToConstant: 12),
            self.locationIconImageView.heightAnchor.constraint(equalTo: self.locationIconImageView.widthAnchor),
            
            self.competitionLabel.leadingAnchor.constraint(equalTo: self.locationIconImageView.trailingAnchor, constant: 7),
            self.competitionLabel.trailingAnchor.constraint(equalTo: self.topInfoBaseView.trailingAnchor, constant: -9),
            self.competitionLabel.centerYAnchor.constraint(equalTo: self.favoriteIconImageView.centerYAnchor),
            
            self.topSeparatorAlphaLineView.leadingAnchor.constraint(equalTo: self.baseView.leadingAnchor),
            self.topSeparatorAlphaLineView.trailingAnchor.constraint(equalTo: self.baseView.trailingAnchor),
            self.topSeparatorAlphaLineView.heightAnchor.constraint(equalToConstant: 1),
            self.topSeparatorAlphaLineView.topAnchor.constraint(equalTo: self.topInfoBaseView.bottomAnchor),
        ])
        
        // Bottom info
        NSLayoutConstraint.activate([
            self.bottomInfoBaseView.leadingAnchor.constraint(equalTo: self.baseView.leadingAnchor),
            self.bottomInfoBaseView.trailingAnchor.constraint(equalTo: self.baseView.trailingAnchor),
            self.bottomInfoBaseView.bottomAnchor.constraint(equalTo: self.baseView.bottomAnchor),
            
            self.gradientView.leadingAnchor.constraint(equalTo: self.baseView.leadingAnchor),
            self.gradientView.trailingAnchor.constraint(equalTo: self.baseView.trailingAnchor),
            self.gradientView.bottomAnchor.constraint(equalTo: self.bottomInfoBaseView.topAnchor),
            self.gradientView.heightAnchor.constraint(equalToConstant: 100),
            
            self.gradientPatternView.leadingAnchor.constraint(equalTo: self.baseView.leadingAnchor),
            self.gradientPatternView.trailingAnchor.constraint(equalTo: self.baseView.trailingAnchor),
            self.gradientPatternView.bottomAnchor.constraint(equalTo: self.baseView.bottomAnchor),
            self.gradientPatternView.topAnchor.constraint(equalTo: self.bottomInfoBaseView.topAnchor),
            
            self.imageGradientPatternView.leadingAnchor.constraint(equalTo: self.baseView.leadingAnchor),
            self.imageGradientPatternView.trailingAnchor.constraint(equalTo: self.baseView.trailingAnchor),
            self.imageGradientPatternView.bottomAnchor.constraint(equalTo: self.baseView.bottomAnchor),
            self.imageGradientPatternView.topAnchor.constraint(equalTo: self.gradientView.topAnchor),
            
            self.collectionView.leadingAnchor.constraint(equalTo: self.baseView.leadingAnchor, constant: 0),
            self.collectionView.trailingAnchor.constraint(equalTo: self.baseView.trailingAnchor, constant: 0),
            self.collectionView.topAnchor.constraint(equalTo: self.bottomInfoBaseView.topAnchor, constant: 10),
            self.collectionView.heightAnchor.constraint(equalToConstant: 120),
            
            self.pageControlBaseView.leadingAnchor.constraint(equalTo: self.bottomInfoBaseView.leadingAnchor),
            self.pageControlBaseView.trailingAnchor.constraint(equalTo: self.bottomInfoBaseView.trailingAnchor),
            self.pageControlBaseView.topAnchor.constraint(equalTo: self.collectionView.bottomAnchor),
            self.pageControlBaseView.bottomAnchor.constraint(equalTo: self.bottomInfoBaseView.bottomAnchor),
            self.pageControlBaseView.heightAnchor.constraint(equalToConstant: 30),
            
            self.pageControl.centerXAnchor.constraint(equalTo: self.pageControlBaseView.centerXAnchor),
//            self.pageControl.topAnchor.constraint(equalTo: self.collectionView.bottomAnchor, constant: 0),
//            self.pageControl.bottomAnchor.constraint(equalTo: self.baseView.bottomAnchor, constant: 0),
            self.pageControl.centerYAnchor.constraint(equalTo: self.pageControlBaseView.centerYAnchor)
        ])
    }
}
