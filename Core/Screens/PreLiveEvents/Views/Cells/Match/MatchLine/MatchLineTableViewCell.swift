//
//  MatchLineTableViewCell.swift
//  Sportsbook
//
//  Created by Ruben Roques on 30/09/2021.
//

import UIKit
import Combine
import ServicesProvider

class MatchLineTableViewCell: UITableViewCell {

    // MARK: - UI Components
    private lazy var collectionBaseView: UIView = Self.createCollectionBaseView()
    private lazy var collectionView: UICollectionView = Self.createCollectionView()
    private lazy var backSliderView: UIView = Self.createBackSliderView()
    private lazy var backSliderIconImageView: UIImageView = Self.createBackSliderIconImageView()
    private lazy var debugLabel: UILabel = Self.createDebugLabel()
    private lazy var loadingView: UIActivityIndicatorView = Self.createLoadingView()

    // MARK: - Constraints
    private var collectionViewHeightConstraint: NSLayoutConstraint!
    private var collectionViewTopMarginConstraint: NSLayoutConstraint!
    private var collectionViewBottomMarginConstraint: NSLayoutConstraint!

    private var cachedCardsStyle: CardsStyle?

    private var match: Match?

    private var shouldShowCountryFlag: Bool = true
    private var showingBackSliderView: Bool = false

    private var matchInfoPublisher: AnyCancellable?

    var tappedMatchLineAction: ((Match) -> Void)?
    var selectedOutcome: ((Match, Market, Outcome) -> Void)?
    var unselectedOutcome: ((Match, Market, Outcome) -> Void)?

    var matchWentLive: (() -> Void)?
    var didTapFavoriteMatchAction: ((Match) -> Void)?
    var didLongPressOdd: ((BettingTicket) -> Void)?
    var tappedMixMatchAction: ((Match) -> Void)?

    private let cellInternSpace: CGFloat = 2.0

    private var collectionViewHeight: CGFloat {
        let cardHeight = StyleHelper.cardsStyleHeight()
        return cardHeight + cellInternSpace + cellInternSpace
    }

    private var selectedSeeMoreMarketsCollectionViewCell: SeeMoreMarketsCollectionViewCell? {
        willSet {
            self.selectedSeeMoreMarketsCollectionViewCell?.transitionId = nil
        }
        didSet {
            self.selectedSeeMoreMarketsCollectionViewCell?.transitionId = "SeeMoreToMatchDetails"
        }
    }

    private var viewModel: MatchLineTableCellViewModel?

    var matchStatsViewModel: MatchStatsViewModel?

    private var cancellables: Set<AnyCancellable> = []

    // MARK: - Internal Types
    private enum MatchWidgetDisplayType {
        case live
        case preLive // Default pre-live / Standard
        case classic
        case boosted
        case outright
        case backgroundImage
        case topImage
        // Add any other distinct types as needed
    }

    // MARK: - Initialization
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
    }

    private func setupUI() {
        // print("BlinkDebug: line awakeFromNib")

        self.selectionStyle = .none

        self.loadingView.hidesWhenStopped = true
        self.loadingView.stopAnimating()

        self.cachedCardsStyle = StyleHelper.cardsStyleActive()

        self.debugLabel.isHidden = true

        self.backSliderView.alpha = 0.0

        setupSubviews()
        setupCollectionView()
        setupGestureRecognizers()
        setupConstraints()
        setupWithTheme()
    }

    private func setupCollectionView() {
        self.collectionView.delegate = self
        self.collectionView.dataSource = self

        self.collectionView.register(
            ClassicMatchWidgetCollectionViewCell.self,
            forCellWithReuseIdentifier: ClassicMatchWidgetCollectionViewCell.identifier
        )
        self.collectionView.register(
            PreLiveMatchWidgetCollectionViewCell.self,
            forCellWithReuseIdentifier: PreLiveMatchWidgetCollectionViewCell.identifier
        )
        self.collectionView.register(
            LiveMatchWidgetCollectionViewCell.self,
            forCellWithReuseIdentifier: LiveMatchWidgetCollectionViewCell.identifier
        )
        self.collectionView.register(
            BackgroundImageMatchWidgetCollectionViewCell.self,
            forCellWithReuseIdentifier: BackgroundImageMatchWidgetCollectionViewCell.identifier
        )
        self.collectionView.register(
            TopImageMatchWidgetCollectionViewCell.self,
            forCellWithReuseIdentifier: TopImageMatchWidgetCollectionViewCell.identifier
        )
        self.collectionView.register(
            BoostedMatchWidgetCollectionViewCell.self,
            forCellWithReuseIdentifier: BoostedMatchWidgetCollectionViewCell.identifier
        )
        self.collectionView.register(
            OutrightMatchWidgetCollectionViewCell.self,
            forCellWithReuseIdentifier: OutrightMatchWidgetCollectionViewCell.identifier
        )



        self.collectionView.register(
            MatchWidgetCollectionViewCell.self,
            forCellWithReuseIdentifier: MatchWidgetCollectionViewCell.identifier
        )
        self.collectionView.register(
            OddDoubleCollectionViewCell.nib,
            forCellWithReuseIdentifier: OddDoubleCollectionViewCell.identifier
        )
        self.collectionView.register(
            OddTripleCollectionViewCell.nib,
            forCellWithReuseIdentifier: OddTripleCollectionViewCell.identifier
        )
        self.collectionView.register(
            SeeMoreMarketsCollectionViewCell.self,
            forCellWithReuseIdentifier: SeeMoreMarketsCollectionViewCell.identifier
        )

        self.collectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "UICollectionViewCell")

        self.collectionView.clipsToBounds = false

        self.collectionView.showsVerticalScrollIndicator = false
        self.collectionView.showsHorizontalScrollIndicator = false

        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.scrollDirection = .horizontal
        self.collectionView.collectionViewLayout = flowLayout

        self.collectionView.contentInset = UIEdgeInsets(top: 0, left: 8, bottom: 0, right: 8)
    }

    private func setupGestureRecognizers() {
        let backSliderTapGesture = UITapGestureRecognizer(target: self, action: #selector(didTapBackSliderButton))
        self.backSliderView.addGestureRecognizer(backSliderTapGesture)
    }

    override func prepareForReuse() {
        super.prepareForReuse()

        self.selectionStyle = .none

        self.matchInfoPublisher?.cancel()
        self.matchInfoPublisher = nil

        self.viewModel = nil
        self.match = nil

        self.cancellables.removeAll()

        self.matchStatsViewModel = nil

        self.loadingView.hidesWhenStopped = true
        self.loadingView.stopAnimating()

        self.shouldShowCountryFlag = true

        self.backSliderView.alpha = 0.0

        self.collectionView.layoutSubviews()
        self.collectionView.setContentOffset(CGPoint(x: -self.collectionView.contentInset.left, y: 1), animated: false)

        if self.cachedCardsStyle != StyleHelper.cardsStyleActive() {

            self.cachedCardsStyle = StyleHelper.cardsStyleActive()

            self.collectionViewHeightConstraint.constant = self.collectionViewHeight
            self.collectionViewTopMarginConstraint.constant = StyleHelper.cardsStyleMargin()
            self.collectionViewBottomMarginConstraint.constant = StyleHelper.cardsStyleMargin()

            UIView.performWithoutAnimation {
                self.setNeedsLayout()
                self.layoutIfNeeded()
            }
        }
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)

        self.setupWithTheme()
    }

    func setupWithTheme() {

        self.backgroundColor = .clear
        self.backgroundView?.backgroundColor = .clear

        self.collectionBaseView.backgroundColor = .clear
        self.collectionView.backgroundColor = .clear
        self.collectionView.backgroundView?.backgroundColor = UIColor.App.backgroundCards

        self.backSliderView.backgroundColor = UIColor.App.backgroundOdds
        self.backSliderIconImageView.setTintColor(color: UIColor.App.iconPrimary)
    }

    func configure(withViewModel viewModel: MatchLineTableCellViewModel) {
        self.viewModel = viewModel

        self.matchInfoPublisher?.cancel()
        self.matchInfoPublisher = nil

        self.matchInfoPublisher = viewModel.matchPublisher
            .removeDuplicates(by: { [weak self] oldMatch, newMatch in
                let visuallySimilar = Match.visuallySimilar(lhs: oldMatch, rhs: newMatch)
                if visuallySimilar.0 {
                    return true
                }
                else {
                    return false
                }
            })
            .receive(on: DispatchQueue.main)
            .sink { completion in
                switch completion {
                case .finished: ()
                case .failure: ()
                }
            } receiveValue: { [weak self] match in
                self?.setupWithMatch(match)
                self?.loadingView.stopAnimating()
            }

    }
    private func setupWithMatch(_ newMatch: Match) {
        self.match = newMatch
        self.collectionView.reloadData()
    }

    func shouldShowCountryFlag(_ show: Bool) {
        self.shouldShowCountryFlag = show
    }

    @objc func didTapBackSliderButton() {
        self.collectionView.setContentOffset(CGPoint(x: -self.collectionView.contentInset.left, y: 1), animated: true)
    }

    func tappedMatchLine() {
        if let match = self.viewModel?.match {
            self.tappedMatchLineAction?(match)
        }
    }

}

// MARK: - UI Setup
private extension MatchLineTableViewCell {
    func setupSubviews() {
        contentView.addSubview(collectionBaseView)
        contentView.addSubview(backSliderView)
        contentView.addSubview(debugLabel)
        contentView.addSubview(loadingView)

        collectionBaseView.addSubview(collectionView)
        backSliderView.addSubview(backSliderIconImageView)
    }

    func setupConstraints() {
        // Collection base view constraints
        NSLayoutConstraint.activate([
            collectionBaseView.topAnchor.constraint(equalTo: contentView.topAnchor),
            collectionBaseView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            collectionBaseView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            collectionBaseView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        ])

        // Collection view constraints with IBOutlet-like references
        collectionViewHeightConstraint = collectionView.heightAnchor.constraint(equalToConstant: 160)
        collectionViewTopMarginConstraint = collectionView.topAnchor.constraint(equalTo: collectionBaseView.topAnchor, constant: 8)
        collectionViewBottomMarginConstraint = collectionBaseView.bottomAnchor.constraint(equalTo: collectionView.bottomAnchor, constant: 8)

        NSLayoutConstraint.activate([
            collectionView.leadingAnchor.constraint(equalTo: collectionBaseView.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: collectionBaseView.trailingAnchor),
            collectionViewHeightConstraint,
            collectionViewTopMarginConstraint,
            collectionViewBottomMarginConstraint
        ])

        // Back slider view constraints
        NSLayoutConstraint.activate([
            backSliderView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: -36),
            backSliderView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor, constant: -6),
            backSliderView.widthAnchor.constraint(equalToConstant: 78),
            backSliderView.heightAnchor.constraint(equalToConstant: 38)
        ])

        // Back slider icon constraints
        NSLayoutConstraint.activate([
            backSliderIconImageView.trailingAnchor.constraint(equalTo: backSliderView.trailingAnchor, constant: -7),
            backSliderIconImageView.centerYAnchor.constraint(equalTo: backSliderView.centerYAnchor),
            backSliderIconImageView.widthAnchor.constraint(equalToConstant: 24),
            backSliderIconImageView.heightAnchor.constraint(equalTo: backSliderIconImageView.widthAnchor)
        ])

        // Debug label constraints
        NSLayoutConstraint.activate([
            debugLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 9),
            debugLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 30)
        ])

        // Loading view constraints
        NSLayoutConstraint.activate([
            loadingView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            loadingView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
        ])

        // Initialize constraint values
        collectionViewHeightConstraint.constant = self.collectionViewHeight
        collectionViewTopMarginConstraint.constant = StyleHelper.cardsStyleMargin()
        collectionViewBottomMarginConstraint.constant = StyleHelper.cardsStyleMargin()
    }

    // MARK: - Factory Methods
    static func createCollectionBaseView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = UIColor(white: 0.67, alpha: 1.0)
        return view
    }

    static func createCollectionView() -> UICollectionView {
        let layout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = 10
        layout.minimumInteritemSpacing = 10
        layout.scrollDirection = .horizontal

        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.backgroundColor = .systemBackground
        collectionView.clipsToBounds = true
        return collectionView
    }

    static func createBackSliderView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = UIColor(white: 0.33, alpha: 1.0)
        view.layer.cornerRadius = 6
        return view
    }

    static func createBackSliderIconImageView() -> UIImageView {
        let imageView = UIImageView(image: UIImage(named: "arrow_circle_left_icon"))
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        imageView.clipsToBounds = true
        return imageView
    }

    static func createDebugLabel() -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "-"
        label.font = .systemFont(ofSize: 14)
        label.textColor = UIColor(white: 0.67, alpha: 1.0)
        label.backgroundColor = .black
        return label
    }

    static func createLoadingView() -> UIActivityIndicatorView {
        let activityIndicator = UIActivityIndicatorView(style: .large)
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        activityIndicator.color = .systemGray4
        activityIndicator.hidesWhenStopped = true
        return activityIndicator
    }
}

extension MatchLineTableViewCell: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {

        let screenWidth = UIScreen.main.bounds.size.width
        let width = screenWidth*0.6

        let pushScreenMargin = 100.0
        let bounceXPosition = ( (scrollView.contentOffset.x - scrollView.contentInset.left) + scrollView.frame.width) - scrollView.contentSize.width

        var activeSeeMoreCell: SeeMoreMarketsCollectionViewCell?

        if bounceXPosition >= 0 {
            for cell in self.collectionView.visibleCells {
                if let seeMoreCell = cell as? SeeMoreMarketsCollectionViewCell {
                    seeMoreCell.setAnimationPercentage(bounceXPosition / Double(pushScreenMargin * 0.98))

                    activeSeeMoreCell = seeMoreCell
                }
            }
        }

        if scrollView.isTracking && scrollView.contentSize.width > screenWidth {
            if scrollView.contentOffset.x + scrollView.frame.width > scrollView.contentSize.width + pushScreenMargin {

                let generator = UIImpactFeedbackGenerator(style: .heavy)
                generator.prepare()
                generator.impactOccurred()

                self.selectedSeeMoreMarketsCollectionViewCell = activeSeeMoreCell

                if let match = self.match {
                    self.tappedMatchLineAction?(match)
                }

                return
            }
        }

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

extension MatchLineTableViewCell: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 3
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {

        guard let match = self.match else { return 0 }

        if section == 0 { // Match section
            return 1
        }

        if section == 2 { // See all section
            return 1
        }

        // Section 1
        if match.markets.isNotEmpty {
            // all the markets except thee first one
            // the first market appears in the match cell
            return match.markets.count - 1
        }

        return 0
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

        guard
            let match = self.viewModel?.match,
            let cellViewModel = self.viewModel?.matchWidgetCellViewModel
        else {
            // Return placeholder if no match
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "UICollectionViewCell", for: indexPath)
            cell.backgroundView?.backgroundColor = UIColor.App.backgroundCards
            cell.backgroundColor = UIColor.App.backgroundCards
            cell.layer.cornerRadius = 9
            return cell
        }

        switch indexPath.section {
        case 0:
             // --- Determine State and Type ---
             let state = cellViewModel.matchWidgetStatus
            let type = cellViewModel.matchWidgetType
             // --- Switch on the combination ---
             switch (state, type) {
             case (.live, _): // Explicitly match live state with live type
                 return configureLiveCell(collectionView: collectionView, indexPath: indexPath, viewModel: cellViewModel, match: match)

             case (_, .boosted): // Boosted overrides state (assuming boosted is always pre-live visually)
                 return configureBoostedCell(collectionView: collectionView, indexPath: indexPath, viewModel: cellViewModel, match: match)

             case (_, .topImageOutright): // Outright overrides state
                 return configureOutrightCell(collectionView: collectionView, indexPath: indexPath, viewModel: cellViewModel, match: match)

             case (_, .backgroundImage): // BackgroundImage overrides state
                 return configureBackgroundImageCell(collectionView: collectionView, indexPath: indexPath, viewModel: cellViewModel, match: match)

             case (_, .topImage): // TopImage overrides state
                 return configureTopImageCell(collectionView: collectionView, indexPath: indexPath, viewModel: cellViewModel, match: match)

             default:
                 return configurePreLiveCell(collectionView: collectionView, indexPath: indexPath, viewModel: cellViewModel, match: match)
             }

        case 1:
            return configureMarketCell(collectionView: collectionView, indexPath: indexPath, viewModel: cellViewModel, match: match)

        case 2:
            return configureSeeMoreCell(collectionView: collectionView, indexPath: indexPath, match: match)

        default:
            fatalError("Unexpected section index \(indexPath.section)")
        }
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {

    }

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {

        if section == 1, (self.match?.markets.count ?? 0) <= 1 {
            return 0
        }
        else {
            return 16
        }
    }

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumLineSpacingForSectionAt section: Int) -> CGFloat {

        if section == 1, (self.match?.markets.count ?? 0) <= 1 {
            return 0
        }
        else {
            return 16
        }
    }

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        insetForSectionAt section: Int) -> UIEdgeInsets {

        if section == 1, (self.match?.markets.count ?? 0) <= 1 {
            // We just need insets if we have content
            return UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        }
        else {
            return UIEdgeInsets(top: 0, left: 8, bottom: 0, right: 8)
        }

    }

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {

        let height = StyleHelper.cardsStyleHeight()

        if indexPath.section == 2 { // see all section
            return CGSize(width: 99, height: height)
        }
        else {
            let screenWidth = UIScreen.main.bounds.size.width
            var width = screenWidth*0.87

            if width > 390 {
                width = 390
            }

            return CGSize(width: width, height: height) // design width: 331
        }
    }
}

// MARK: - Private Configuration Helpers
private extension MatchLineTableViewCell {

    // MARK: - Cell Configuration Functions
    func configureLiveCell(collectionView: UICollectionView, indexPath: IndexPath, viewModel: MatchWidgetCellViewModel, match: Match) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueCellType(LiveMatchWidgetCollectionViewCell.self, indexPath: indexPath) else {
            fatalError("Could not dequeue LiveMatchWidgetCollectionViewCell")
        }
        cell.configure(withViewModel: viewModel)
        cell.shouldShowCountryFlag(self.shouldShowCountryFlag)

        // Assign closures (standard ones for now, customize if needed)
        cell.tappedMatchWidgetAction = { [weak self] _ in self?.tappedMatchLine() }
        cell.selectedOutcome = self.selectedOutcome
        cell.unselectedOutcome = self.unselectedOutcome
        cell.didLongPressOdd = { [weak self] bettingTicket in self?.didLongPressOdd?(bettingTicket) }

        return cell
    }

    func configurePreLiveCell(collectionView: UICollectionView, indexPath: IndexPath, viewModel: MatchWidgetCellViewModel, match: Match) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueCellType(PreLiveMatchWidgetCollectionViewCell.self, indexPath: indexPath) else {
            fatalError("Could not dequeue PreLiveMatchWidgetCollectionViewCell")
        }
        cell.configure(withViewModel: viewModel)
        cell.shouldShowCountryFlag(self.shouldShowCountryFlag)

        // Assign closures
        cell.tappedMatchWidgetAction = { [weak self] _ in self?.tappedMatchLine() }
        cell.selectedOutcome = self.selectedOutcome
        cell.unselectedOutcome = self.unselectedOutcome
        cell.didLongPressOdd = { [weak self] bettingTicket in self?.didLongPressOdd?(bettingTicket) }

        return cell
    }

    func configureClassicCell(collectionView: UICollectionView, indexPath: IndexPath, viewModel: MatchWidgetCellViewModel, match: Match) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueCellType(ClassicMatchWidgetCollectionViewCell.self, indexPath: indexPath) else {
            fatalError("Could not dequeue ClassicMatchWidgetCollectionViewCell")
        }
        cell.configure(withViewModel: viewModel)
        cell.shouldShowCountryFlag(self.shouldShowCountryFlag)

        // Assign closures
        cell.tappedMatchWidgetAction = { [weak self] _ in self?.tappedMatchLine() }
        cell.selectedOutcome = self.selectedOutcome
        cell.unselectedOutcome = self.unselectedOutcome
        cell.didLongPressOdd = { [weak self] bettingTicket in self?.didLongPressOdd?(bettingTicket) }

        return cell
    }

    func configureBoostedCell(collectionView: UICollectionView, indexPath: IndexPath, viewModel: MatchWidgetCellViewModel, match: Match) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueCellType(BoostedMatchWidgetCollectionViewCell.self, indexPath: indexPath) else {
            fatalError("Could not dequeue BoostedMatchWidgetCollectionViewCell")
        }
        cell.configure(withViewModel: viewModel)
        cell.shouldShowCountryFlag(self.shouldShowCountryFlag)

        // Assign closures (maybe boosted cells have different interactions?)
        cell.tappedMatchWidgetAction = { [weak self] _ in self?.tappedMatchLine() }
        cell.selectedOutcome = self.selectedOutcome
        cell.unselectedOutcome = self.unselectedOutcome
        cell.didLongPressOdd = { [weak self] bettingTicket in self?.didLongPressOdd?(bettingTicket) }

        return cell
    }

    func configureOutrightCell(collectionView: UICollectionView, indexPath: IndexPath, viewModel: MatchWidgetCellViewModel, match: Match) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueCellType(OutrightMatchWidgetCollectionViewCell.self, indexPath: indexPath) else {
            fatalError("Could not dequeue OutrightMatchWidgetCollectionViewCell")
        }
        cell.configure(withViewModel: viewModel)
        cell.shouldShowCountryFlag(self.shouldShowCountryFlag)

        // Assign closures (Outrights might have fewer/different actions)
        cell.tappedMatchWidgetAction = { [weak self] _ in self?.tappedMatchLine() }
        // Outrights might not have standard outcomes to select/unselect?
        // cell.selectedOutcome = self.selectedOutcome
        // cell.unselectedOutcome = self.unselectedOutcome
        // cell.didLongPressOdd = { [weak self] bettingTicket in self?.didLongPressOdd?(bettingTicket) }


        return cell
    }

    func configureBackgroundImageCell(collectionView: UICollectionView, indexPath: IndexPath, viewModel: MatchWidgetCellViewModel, match: Match) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueCellType(BackgroundImageMatchWidgetCollectionViewCell.self, indexPath: indexPath) else {
            fatalError("Could not dequeue BackgroundImageMatchWidgetCollectionViewCell")
        }
        cell.configure(withViewModel: viewModel)
        cell.shouldShowCountryFlag(self.shouldShowCountryFlag)

        // Assign closures
        cell.tappedMatchWidgetAction = { [weak self] _ in self?.tappedMatchLine() }
        cell.selectedOutcome = self.selectedOutcome
        cell.unselectedOutcome = self.unselectedOutcome
        cell.didLongPressOdd = { [weak self] bettingTicket in self?.didLongPressOdd?(bettingTicket) }

        return cell
    }

    func configureTopImageCell(collectionView: UICollectionView, indexPath: IndexPath, viewModel: MatchWidgetCellViewModel, match: Match) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueCellType(TopImageMatchWidgetCollectionViewCell.self, indexPath: indexPath) else {
            fatalError("Could not dequeue TopImageMatchWidgetCollectionViewCell")
        }
        cell.configure(withViewModel: viewModel)
        cell.shouldShowCountryFlag(self.shouldShowCountryFlag)

        // Assign closures
        cell.tappedMatchWidgetAction = { [weak self] _ in self?.tappedMatchLine() }
        cell.selectedOutcome = self.selectedOutcome
        cell.unselectedOutcome = self.unselectedOutcome
        cell.didLongPressOdd = { [weak self] bettingTicket in self?.didLongPressOdd?(bettingTicket) }

        return cell
    }

    // MARK: - Market Cell Configuration
    func configureMarketCell(collectionView: UICollectionView, indexPath: IndexPath, viewModel: MatchWidgetCellViewModel, match: Match) -> UICollectionViewCell {
        // Check if we have a market to display
        guard match.markets.count > 1,
              let market = match.markets[safe: indexPath.row + 1] else {
            // Return empty cell if no market available
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "UICollectionViewCell", for: indexPath)
            cell.contentView.isHidden = true
            return cell
        }

        let teamsText = "\(match.homeParticipant.name) - \(match.awayParticipant.name)"
        let countryIso = match.venue?.isoCode ?? ""
        let isLive = viewModel.matchWidgetStatus == .live

        // Dequeue and configure the appropriate cell based on outcomes count
        if market.outcomes.count == 2 {
            guard let cell = collectionView.dequeueCellType(OddDoubleCollectionViewCell.self, indexPath: indexPath) else {
                fatalError("Could not dequeue OddDoubleCollectionViewCell")
            }

            cell.matchStatsViewModel = self.matchStatsViewModel
            cell.setupWithMarket(market, match: match, teamsText: teamsText, countryIso: countryIso, isLive: isLive)

            cell.tappedMatchWidgetAction = { [weak self] in
                self?.tappedMatchLine()
            }
            cell.didLongPressOdd = { [weak self] bettingTicket in
                self?.didLongPressOdd?(bettingTicket)
            }

            return cell
        } else {
            guard let cell = collectionView.dequeueCellType(OddTripleCollectionViewCell.self, indexPath: indexPath) else {
                fatalError("Could not dequeue OddTripleCollectionViewCell")
            }

            cell.matchStatsViewModel = self.matchStatsViewModel
            cell.setupWithMarket(market, match: match, teamsText: teamsText, countryIso: countryIso, isLive: isLive)

            cell.tappedMatchWidgetAction = { [weak self] in
                self?.tappedMatchLine()
            }
            cell.didLongPressOdd = { [weak self] bettingTicket in
                self?.didLongPressOdd?(bettingTicket)
            }

            return cell
        }
    }

    // MARK: - See More Cell Configuration
    func configureSeeMoreCell(collectionView: UICollectionView, indexPath: IndexPath, match: Match) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueCellType(SeeMoreMarketsCollectionViewCell.self, indexPath: indexPath) else {
            fatalError("Could not dequeue SeeMoreMarketsCollectionViewCell")
        }

        // Configure market count string
        let marketString: String
        if match.numberTotalOfMarkets > 1 {
            marketString = localized("number_of_markets")
                .replacingOccurrences(of: "{num_markets}", with: "\(match.numberTotalOfMarkets)")
        } else {
            marketString = localized("number_of_market_singular")
                .replacingOccurrences(of: "{num_markets}", with: "\(match.numberTotalOfMarkets)")
        }

        cell.configureWithSubtitleString(marketString)

        // Hide subtitle if no markets
        if match.numberTotalOfMarkets == 0 {
            cell.hideSubtitle()
        }

        // Configure tap action
        cell.tappedAction = { [weak self] in
            self?.tappedMatchLine()
        }

        return cell
    }

}

#if DEBUG
import SwiftUI

// MARK: - Preview View Controller
private class MatchLinePreviewViewController: UIViewController {
    private let tableView = UITableView(frame: .zero, style: .plain)

    // Define our preview states
    private enum PreviewState {
        case standard
        case live
        case multipleMarkets
        case loading

        var title: String {
            switch self {
            case .standard: return "Default State"
            case .live: return "Live Match"
            case .multipleMarkets: return "Multiple Markets"
            case .loading: return "Loading State"
            }
        }
    }

    private let states: [PreviewState] = [.standard, .live, .multipleMarkets, .loading]

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        setupTableView()
    }

    private func setupTableView() {
        view.addSubview(tableView)
        tableView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])

        tableView.register(MatchLineTableViewCell.self, forCellReuseIdentifier: "MatchLineTableViewCell")
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "HeaderCell")

        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = .none
        tableView.backgroundColor = .systemGroupedBackground
    }
}

// MARK: - UITableView Delegate & DataSource
extension MatchLinePreviewViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return states.count
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "MatchLineTableViewCell") as? MatchLineTableViewCell else {
            return UITableViewCell()
        }

        let state = states[indexPath.section]

        // Configure cell based on state
        switch state {
        case .standard:
            let match = PreviewModelsHelper.createFootballMatch()
            let viewModel = MatchLineTableCellViewModel(match: match)
            cell.configure(withViewModel: viewModel)

        case .live:
            let match = PreviewModelsHelper.createLiveFootballMatch()
            let viewModel = MatchLineTableCellViewModel(match: match)
            cell.configure(withViewModel: viewModel)

        case .multipleMarkets:
            let match = PreviewModelsHelper.createFootballMatchWithMultipleMarkets()
            let viewModel = MatchLineTableCellViewModel(match: match)
            cell.configure(withViewModel: viewModel)

        case .loading:
            let match = PreviewModelsHelper.createFootballMatch()
            let viewModel = MatchLineTableCellViewModel(match: match)
            cell.configure(withViewModel: viewModel)
            if let loadingView = cell.value(forKey: "loadingView") as? UIActivityIndicatorView {
                loadingView.startAnimating()
            }
        }

        return cell
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView()
        headerView.backgroundColor = .systemGroupedBackground

        let label = UILabel()
        label.text = states[section].title
        label.font = .boldSystemFont(ofSize: 16)
        label.textColor = .label

        headerView.addSubview(label)
        label.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            label.leadingAnchor.constraint(equalTo: headerView.leadingAnchor, constant: 16),
            label.centerYAnchor.constraint(equalTo: headerView.centerYAnchor)
        ])

        return headerView
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 44
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 176
    }
}

// MARK: - SwiftUI Previews
@available(iOS 17.0, *)
#Preview("MatchLineTableViewCell States") {
    PreviewUIViewController {
        MatchLinePreviewViewController()
    }
}

@available(iOS 17.0, *)
#Preview("MatchLineTableViewCell States (Dark)") {
    PreviewUIViewController {
        MatchLinePreviewViewController()
    }
    .preferredColorScheme(.dark)
}

#endif

