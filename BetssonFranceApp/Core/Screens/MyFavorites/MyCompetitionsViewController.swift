//
//  MyCompetitionsViewController.swift
//  Sportsbook
//
//  Created by André Lascas on 31/07/2023.
//

import UIKit
import Combine
import ServicesProvider

class MyCompetitionsViewController: UIViewController {

    // MARK: Private Properties
    private lazy var topSafeAreaView: UIView = Self.createTopSafeAreaView()
    private lazy var containerView: GradientView = Self.createContainerView()
    private lazy var tableView: UITableView = Self.createTableView()
    private lazy var bottomSafeAreaView: UIView = Self.createBottomSafeAreaView()
    private lazy var loadingScreenBaseView: UIView = Self.createLoadingScreenBaseView()
    private lazy var activityIndicatorView: UIActivityIndicatorView = Self.createActivityIndicatorView()

    private lazy var emptyStateView: UIView = Self.createEmptyStateView()
    private lazy var emptyStateImageView: UIImageView = Self.createEmptyStateImageView()
    private lazy var emptyStateTitleLabel: UILabel = Self.createEmptyStateTitleLabel()
    private lazy var emptyStateLoginButton: UIButton = Self.createEmptyStateLoginButton()

    private lazy var containerStackView: UIStackView = Self.createContainerStackView()
    private lazy var suggestedBaseView: SuggestedCompetitionsView = Self.createSuggestedBaseView()

    // Constraints
//    private lazy var tableTopConstraint: NSLayoutConstraint = Self.createTableTopConstraint()
//    private lazy var tableTopSuggestedConstraint: NSLayoutConstraint = Self.createTableTopSuggestedConstraint()

    private var cancellables = Set<AnyCancellable>()

    // MARK: Public Properties
    var viewModel: MyCompetitionsViewModel

    var isLoading: Bool = false {
        didSet {
            if isLoading {
                self.loadingScreenBaseView.isHidden = false
            }
            else {
                self.loadingScreenBaseView.isHidden = true
            }
        }
    }

    var isEmptyState: Bool = false {
        didSet {
            if isEmptyState {
                self.containerStackView.isHidden = true
                self.emptyStateView.isHidden = false
            }
            else {
                self.containerStackView.isHidden = false
                self.emptyStateView.isHidden = true
            }
        }
    }

    var hasSuggested: Bool = false {
        didSet {
            self.suggestedBaseView.isHidden = !hasSuggested
        }
    }

    // MARK: Lifetime and Cycle
    init(viewModel: MyCompetitionsViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)

        self.title = localized("my_competitions")

    }

    @available(iOS, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        self.setupSubviews()

        self.setupWithTheme()

        self.bind(toViewModel: self.viewModel)

        self.isEmptyState = false

        self.emptyStateLoginButton.addTarget(self, action: #selector(didTapLoginButton), for: .touchUpInside)

//        Env.favoritesManager.favoriteCompetitionsIdPublisher
//            .sink(receiveValue: { [weak self] competitionIds in
//                self?.hasSuggested = competitionIds.isEmpty ? true : false
//            })
//            .store(in: &cancellables)
        
        Env.favoritesManager.showSuggestedCompetitionsPublisher
            .sink(receiveValue: { [weak self] showSuggested in
                self?.hasSuggested = showSuggested
            })
            .store(in: &cancellables)

    }

    // MARK: Layout and Theme
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)

        self.setupWithTheme()
    }

    func setupWithTheme() {
        self.view.backgroundColor = UIColor.App.backgroundPrimary

        self.topSafeAreaView.backgroundColor = UIColor.App.backgroundPrimary

        if TargetVariables.shouldUseGradientBackgrounds {
            self.containerView.colors = [(UIColor.App.backgroundGradient1, NSNumber(0.0)),
                                         (UIColor.App.backgroundGradient2, NSNumber(1.0))]
        }
        else {
            self.containerView.colors = []
            self.containerView.backgroundColor = UIColor.App.backgroundPrimary
        }

        self.tableView.backgroundColor = .clear

        self.bottomSafeAreaView.backgroundColor = UIColor.App.backgroundPrimary

        self.loadingScreenBaseView.backgroundColor = UIColor.App.backgroundPrimary.withAlphaComponent(0.7)
        self.emptyStateView.backgroundColor = .clear

        self.containerStackView.backgroundColor = .clear

    }

    // MARK: Binding
    private func bind(toViewModel viewModel: MyCompetitionsViewModel) {

        viewModel.didSelectMatchAction = { [weak self] match in
            let matchDetailsViewController = MatchDetailsViewController(viewModel: MatchDetailsViewModel(match: match))
            self?.navigationController?.pushViewController(matchDetailsViewController, animated: true)
        }

        viewModel.matchWentLiveAction = { [weak self] in
            self?.tableView.reloadData()
        }

        viewModel.isLoadingPublisher
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] isLoading in
                self?.isLoading = isLoading
            })
            .store(in: &cancellables)

        viewModel.dataChangedPublisher
            .receive(on: DispatchQueue.main).sink(receiveValue: { [weak self] in
                self?.tableView.reloadData()
            })
            .store(in: &cancellables)

        viewModel.emptyStateStatusPublisher
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] emptyStateType in
                switch emptyStateType {
                case .noLogin:
                    self?.setupEmptyStateView(emptyStateType: emptyStateType, hasLogin: true)
                case .noGames:
                    self?.setupEmptyStateView(emptyStateType: emptyStateType)
                case .noCompetitions:
                    self?.setupEmptyStateView(emptyStateType: emptyStateType)
                case .noFavorites:
                    self?.setupEmptyStateView(emptyStateType: emptyStateType)
                case .none:
                    self?.isEmptyState = false
                }
            })
            .store(in: &cancellables)

    }

    // MARK: Functions
    private func setupEmptyStateView(emptyStateType: EmptyStateType, hasLogin: Bool = false) {

        switch emptyStateType {
        case .noLogin:
            self.emptyStateTitleLabel.text = localized("need_login_favorites")
            self.isEmptyState = true
        case .noGames:
            ()
        case .noCompetitions:
            self.emptyStateTitleLabel.text = localized("empty_my_competitions")

            self.isEmptyState = true

        case .noFavorites:
            ()
        case .none:
            self.isEmptyState = false
        }

        if hasLogin {
            self.emptyStateLoginButton.isHidden = false
        }
        else {
            self.emptyStateLoginButton.isHidden = true
        }
    }

    func reloadData() {
        self.tableView.reloadData()
    }

    func reloadDataWithFilter(newFilter: FilterFavoritesValue) {
//        self.viewModel.fetchedMatchesWithMarketsPublisher.value = []
        self.viewModel.filterApplied = newFilter
        self.viewModel.refreshContent()
    }

    // MARK: Actions
    @objc func didTapLoginButton() {
        let loginViewController = LoginViewController()
        
        let navigationViewController = Router.navigationController(with: loginViewController)
        
        self.present(navigationViewController, animated: true, completion: nil)
    }

}

// MARK: TableView Protocols
extension MyCompetitionsViewController: UITableViewDataSource, UITableViewDelegate {

    func numberOfSections(in tableView: UITableView) -> Int {

        let outrightsSections = 1
        let competitionsCount = self.viewModel.competitions.count
        return  outrightsSections + competitionsCount
    }

    func hasContentForSelectedListType() -> Bool {

        self.viewModel.competitions.isNotEmpty

    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

        if section == 0 {
            return self.viewModel.outrightCompetitions.count
        }
        if let competition = self.viewModel.competitions[safe: section-1] {
            return competition.matches.count
        }
        else {
            return 0
        }

    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        if indexPath.section == 0 {
            guard
                let cell = tableView.dequeueReusableCell(withIdentifier: OutrightCompetitionLargeLineTableViewCell.identifier)
                    as? OutrightCompetitionLargeLineTableViewCell,
                let competition = self.viewModel.outrightCompetitions[safe: indexPath.row]
            else {
                fatalError()
            }

            cell.configure(withViewModel: OutrightCompetitionLargeLineViewModel(competition: competition))
            cell.didSelectCompetitionAction = { [weak self] competition in
                self?.viewModel.didSelectCompetitionAction?(competition)
            }
            return cell
        }
        else {
            guard
                let cell = tableView.dequeueCellType(MatchLineTableViewCell.self),
                let competition = self.viewModel.competitions[safe: indexPath.section-1],
                let match = competition.matches[safe: indexPath.row]
            else {
                fatalError()
            }

            if let matchStatsViewModel = self.viewModel.matchStatsViewModelForMatch?(match) {
                cell.matchStatsViewModel = matchStatsViewModel
            }

            if !self.viewModel.collapsedCompetitionsSections.contains(indexPath.section) {

                let viewModel = MatchLineTableCellViewModel(match: match)
                cell.configure(withViewModel: viewModel)

                // cell.shouldShowCountryFlag(false)
                cell.tappedMatchLineAction = { [weak self] match in
                    self?.viewModel.didSelectMatchAction?(match)
                }
                cell.matchWentLive = { [weak self] in
                    self?.viewModel.matchWentLiveAction?()
                }
            }

            return cell
        }
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {

        if section == 0 {
            return nil
        }
        else {

            guard
                let headerView = tableView.dequeueReusableHeaderFooterView(withIdentifier: TournamentTableViewHeader.identifier)
                    as? TournamentTableViewHeader,
                let competition = self.viewModel.competitions[safe: section-1]
            else {
                if let headerView = tableView.dequeueReusableHeaderFooterView(withIdentifier: TitleTableViewHeader.identifier)
                    as? TitleTableViewHeader {
                    headerView.configureWithTitle(localized("my_competitions"))
                    return headerView
                }
                return UIView()
            }

            headerView.nameTitleLabel.text = competition.name
            headerView.countryFlagImageView.image = UIImage(named: Assets.flagName(withCountryCode: competition.venue?.isoCode ?? ""))
            headerView.sectionIndex = section
            headerView.competition = competition
            headerView.didToggleHeaderViewAction = { [weak self, weak tableView] section in
                guard
                    let weakSelf = self,
                    let weakTableView = tableView
                else { return }

                if weakSelf.viewModel.collapsedCompetitionsSections.contains(section) {
                    weakSelf.viewModel.collapsedCompetitionsSections.remove(section)
                }
                else {
                    weakSelf.viewModel.collapsedCompetitionsSections.insert(section)
                }

                weakSelf.needReloadSection(section, tableView: weakTableView)

                if weakSelf.viewModel.collapsedCompetitionsSections.contains(section) {
                    headerView.collapseImageView.image = UIImage(named: "arrow_down_icon")
                }
                else {
                    headerView.collapseImageView.image = UIImage(named: "arrow_up_icon")
                }
            }
            if self.viewModel.collapsedCompetitionsSections.contains(section) {
                headerView.collapseImageView.image = UIImage(named: "arrow_down_icon")
            }
            else {
                headerView.collapseImageView.image = UIImage(named: "arrow_up_icon")
            }

            headerView.didTapFavoriteCompetitionAction = {[weak self] competition in
                self?.viewModel.didTapFavoriteCompetitionAction?(competition)
            }

            return headerView
        }

    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {

        if indexPath.section == 0 {
            switch StyleHelper.cardsStyleActive() {
            case .small: return  125
            case .normal: return 154
            }
        }
        else if self.viewModel.collapsedCompetitionsSections.contains(indexPath.section) {
            return .leastNormalMagnitude
        }
        else if self.viewModel.competitions.isEmpty {
            return 600
        }
        else {
            return UITableView.automaticDimension
        }

    }

    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {

        if indexPath.section == 0 {
            switch StyleHelper.cardsStyleActive() {
            case .small: return  125
            case .normal: return 154
            }
        }
        else if self.viewModel.collapsedCompetitionsSections.contains(indexPath.section) {
            return .leastNormalMagnitude
        }
        else if self.viewModel.competitions.isEmpty {
            return 600
        }
        else {
            return StyleHelper.cardsStyleHeight() + 20
        }

    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {

        if section == 0 {
            if self.viewModel.outrightCompetitions.isEmpty {
                return 0.01
            }

            return .leastNormalMagnitude
        }
        else {
            return 54
        }

    }

    func tableView(_ tableView: UITableView, estimatedHeightForHeaderInSection section: Int) -> CGFloat {

        if section == 0 {
            if self.viewModel.outrightCompetitions.isEmpty {
                return 0.01
            }
            
            return .leastNormalMagnitude
        }
        else {
            return 54
        }

    }

    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.01
    }

    func tableView(_ tableView: UITableView, estimatedHeightForFooterInSection section: Int) -> CGFloat {
        return 0.01
    }

    func needReloadSection(_ section: Int, tableView: UITableView) {

        guard let competition = self.viewModel.competitions[safe: section-1] else { return }

        let rows = (0 ..< competition.matches.count).map({ IndexPath(row: $0, section: section) }) // all section rows

        tableView.beginUpdates()
        tableView.reloadRows(at: rows, with: .automatic)
        tableView.endUpdates()
    }

}

//
// MARK: Subviews initialization and setup
//
extension MyCompetitionsViewController {

    private static func createTopSafeAreaView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }

    private static func createContainerView() -> GradientView {
        let view = GradientView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }

    private static func createTableView() -> UITableView {
        let tableView = UITableView()
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.separatorStyle = .none
        tableView.contentInsetAdjustmentBehavior = .never
        if #available(iOS 15.0, *) {
            tableView.sectionHeaderTopPadding = 0
        }
        return tableView
    }

    private static func createBottomSafeAreaView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }

    private static func createLoadingScreenBaseView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }

    private static func createActivityIndicatorView() -> UIActivityIndicatorView {
        let activityIndicatorView = UIActivityIndicatorView.init(style: .large)
        activityIndicatorView.translatesAutoresizingMaskIntoConstraints = false
        activityIndicatorView.hidesWhenStopped = true
        activityIndicatorView.startAnimating()
        return activityIndicatorView
    }

    private static func createEmptyStateView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }

    private static func createEmptyStateImageView() -> UIImageView {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.image = UIImage(named: "no_favourites_icon")
        imageView.contentMode = .scaleAspectFit
        return imageView
    }

    private static func createEmptyStateTitleLabel() -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = localized("empty_my_games")
        label.font = AppFont.with(type: .semibold, size: 20)
        label.numberOfLines = 0
        label.textAlignment = .center
        return label
    }

    private static func createEmptyStateLoginButton() -> UIButton {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle(localized("login"), for: .normal)
        StyleHelper.styleButton(button: button)
        return button
    }

    private static func createContainerStackView() -> UIStackView {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.distribution = .fill
        stackView.spacing = 8
        return stackView
    }

    private static func createSuggestedBaseView() -> SuggestedCompetitionsView {
        let view = SuggestedCompetitionsView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.configure(title: localized("no_favorite_competitions"), subtitle: localized("add_some_favorites"), icon: "unselected_favorite_icon")
        return view
    }

    private func setupSubviews() {
        self.view.addSubview(self.topSafeAreaView)

        self.view.addSubview(self.containerView)

        self.containerView.addSubview(self.containerStackView)

        self.containerStackView.addArrangedSubview(self.suggestedBaseView)
        self.containerStackView.addArrangedSubview(self.tableView)

        self.containerView.addSubview(self.loadingScreenBaseView)

        self.loadingScreenBaseView.addSubview(self.activityIndicatorView)
        self.loadingScreenBaseView.bringSubviewToFront(self.activityIndicatorView)

        tableView.register(MatchLineTableViewCell.self, forCellReuseIdentifier: MatchLineTableViewCell.identifier)
        tableView.register(OutrightCompetitionLargeLineTableViewCell.self, forCellReuseIdentifier: OutrightCompetitionLargeLineTableViewCell.identifier)
        tableView.register(BannerScrollTableViewCell.nib, forCellReuseIdentifier: BannerScrollTableViewCell.identifier)
        tableView.register(LoadingMoreTableViewCell.self, forCellReuseIdentifier: LoadingMoreTableViewCell.identifier)
        tableView.register(TitleTableViewHeader.nib, forHeaderFooterViewReuseIdentifier: TitleTableViewHeader.identifier)
        tableView.register(TournamentTableViewHeader.nib, forHeaderFooterViewReuseIdentifier: TournamentTableViewHeader.identifier)

        tableView.register(ActivationAlertScrollableTableViewCell.nib, forCellReuseIdentifier: ActivationAlertScrollableTableViewCell.identifier)
        tableView.register(EmptyCardTableViewCell.nib, forCellReuseIdentifier: EmptyCardTableViewCell.identifier)

        tableView.register(SportSectionHeaderView.self, forHeaderFooterViewReuseIdentifier: SportSectionHeaderView.identifier)

        self.tableView.delegate = self
        self.tableView.dataSource = self

        self.view.addSubview(self.bottomSafeAreaView)

        self.containerView.addSubview(self.emptyStateView)

        self.emptyStateView.addSubview(self.emptyStateImageView)
        self.emptyStateView.addSubview(self.emptyStateTitleLabel)
        self.emptyStateView.addSubview(self.emptyStateLoginButton)

        self.initConstraints()

        self.containerView.layoutSubviews()
    }

    private func initConstraints() {

        // Top Safe Area View
        NSLayoutConstraint.activate([
            self.topSafeAreaView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            self.topSafeAreaView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            self.topSafeAreaView.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor),
            self.topSafeAreaView.bottomAnchor.constraint(equalTo: self.view.topAnchor)
        ])

        // Bottom Safe Area View
        NSLayoutConstraint.activate([
            self.bottomSafeAreaView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            self.bottomSafeAreaView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            self.bottomSafeAreaView.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor),
            self.bottomSafeAreaView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor)
        ])

        // ContainerView
        NSLayoutConstraint.activate([
            self.containerView.topAnchor.constraint(equalTo: self.topSafeAreaView.bottomAnchor),
            self.containerView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            self.containerView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            self.containerView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor),

            self.containerStackView.leadingAnchor.constraint(equalTo: self.containerView.leadingAnchor),
            self.containerStackView.trailingAnchor.constraint(equalTo: self.containerView.trailingAnchor),
            self.containerStackView.topAnchor.constraint(equalTo: self.containerView.topAnchor),
            self.containerStackView.bottomAnchor.constraint(equalTo: self.containerView.bottomAnchor)
        ])

        // TableView
        NSLayoutConstraint.activate([
//            self.tableView.topAnchor.constraint(equalTo: self.containerView.topAnchor),
//            self.tableView.leadingAnchor.constraint(equalTo: self.containerView.leadingAnchor),
//            self.tableView.trailingAnchor.constraint(equalTo: self.containerView.trailingAnchor),
//            self.tableView.bottomAnchor.constraint(equalTo: self.bottomSafeAreaView.topAnchor)
            self.tableView.leadingAnchor.constraint(equalTo: self.containerStackView.leadingAnchor),
            self.tableView.trailingAnchor.constraint(equalTo: self.containerStackView.trailingAnchor)
        ])

        // Loading Screen
        NSLayoutConstraint.activate([
            self.loadingScreenBaseView.topAnchor.constraint(equalTo: self.containerView.topAnchor),
            self.loadingScreenBaseView.leadingAnchor.constraint(equalTo: self.containerView.leadingAnchor),
            self.loadingScreenBaseView.trailingAnchor.constraint(equalTo: self.containerView.trailingAnchor),
            self.loadingScreenBaseView.bottomAnchor.constraint(equalTo: self.containerView.bottomAnchor),

            self.activityIndicatorView.centerXAnchor.constraint(equalTo: self.loadingScreenBaseView.centerXAnchor),
            self.activityIndicatorView.centerYAnchor.constraint(equalTo: self.loadingScreenBaseView.centerYAnchor)
        ])

        // Empty state view
        NSLayoutConstraint.activate([
            self.emptyStateView.leadingAnchor.constraint(equalTo: self.containerView.leadingAnchor),
            self.emptyStateView.trailingAnchor.constraint(equalTo: self.containerView.trailingAnchor),
            self.emptyStateView.topAnchor.constraint(equalTo: self.containerView.topAnchor),
            self.emptyStateView.bottomAnchor.constraint(equalTo: self.containerView.bottomAnchor),

            self.emptyStateImageView.widthAnchor.constraint(equalToConstant: 160),
            self.emptyStateImageView.heightAnchor.constraint(equalToConstant: 160),
            self.emptyStateImageView.topAnchor.constraint(equalTo: self.emptyStateView.topAnchor, constant: 30),
            self.emptyStateImageView.centerXAnchor.constraint(equalTo: self.emptyStateView.centerXAnchor),

            self.emptyStateTitleLabel.leadingAnchor.constraint(equalTo: self.emptyStateView.leadingAnchor, constant: 30),
            self.emptyStateTitleLabel.trailingAnchor.constraint(equalTo: self.emptyStateView.trailingAnchor, constant: -30),
            self.emptyStateTitleLabel.topAnchor.constraint(equalTo: self.emptyStateImageView.bottomAnchor, constant: 30),

            self.emptyStateLoginButton.leadingAnchor.constraint(equalTo: self.emptyStateView.leadingAnchor, constant: 30),
            self.emptyStateLoginButton.trailingAnchor.constraint(equalTo: self.emptyStateView.trailingAnchor, constant: -30),
            self.emptyStateLoginButton.topAnchor.constraint(equalTo: self.emptyStateTitleLabel.bottomAnchor, constant: 30),
            self.emptyStateLoginButton.heightAnchor.constraint(equalToConstant: 50)

        ])

        // Suggested view
        NSLayoutConstraint.activate([
            self.suggestedBaseView.leadingAnchor.constraint(equalTo: self.containerStackView.leadingAnchor),
            self.suggestedBaseView.trailingAnchor.constraint(equalTo: self.containerStackView.trailingAnchor)
        ])

    }

}
