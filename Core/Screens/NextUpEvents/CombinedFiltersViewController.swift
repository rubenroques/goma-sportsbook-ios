//
//  CombinedFiltersViewController.swift
//  Sportsbook
//
//  Created by André Lascas on 29/05/2025.
//

import UIKit
import Combine
import GomaUI

public class CombinedFiltersViewModel {
    
    var popularLeagues = [SortOption]()
    var popularCountryLeagues = [CountryLeagueOptions]()
    var otherCountryLeagues = [CountryLeagueOptions]()
    
    var generalFilterSelection: GeneralFilterSelection
    
    var filterConfiguration: FilterConfiguration
    var currentContextId: String
    
    var dynamicViewModels: [String: Any] = [:]
    
    var isLoadingPublisher: CurrentValueSubject<Bool, Never> = .init(false)
    
    private var cancellables = Set<AnyCancellable>()
    
    init(filterConfiguration: FilterConfiguration,
         contextId: String = "sports") {
        
        self.generalFilterSelection = Env.filterStorage.currentFilterSelection
        self.filterConfiguration = filterConfiguration
        self.currentContextId = contextId
        
        self.getAllLeagues()
        
    }
    
    func getAllLeagues(sportId: String? = nil) {
        self.isLoadingPublisher.send(true)
        
        var currentSportId = Env.filterStorage.currentFilterSelection.sportId
        
        if let sportId {
            currentSportId = sportId
        }
        
        let currentSport = Env.sportsStore.getActiveSports().first(where: {
            $0.id == currentSportId
        })
        
        var sportType = SportType(name: currentSport?.name ?? "",
                                  numericId: currentSport?.numericId ?? "",
                                  alphaId: currentSport?.alphaId ?? "", iconId: currentSport?.id ?? "",
                                  showEventCategory: false,
                                  numberEvents: 0,
                                  numberOutrightEvents: 0,
                                  numberOutrightMarkets: 0,
                                  numberLiveEvents: 0)
        
        let sportTournamentsPublisher = Env.servicesProvider.subscribeSportTournaments(forSportType: sportType)
            .filter { content in
                if case .contentUpdate = content { return true }
                return false
            }
            .map { content -> [Competition] in
                if case .contentUpdate(let tournaments) = content {
                    return ServiceProviderModelMapper.competitions(fromTournaments: tournaments)
                }
                return []
            }
            .prefix(1) // Only take the first .contentUpdate

        let popularTournamentsPublisher = Env.servicesProvider.subscribePopularTournaments(forSportType: sportType, tournamentsCount: 10)
            .filter { content in
                if case .contentUpdate = content { return true }
                return false
            }
            .map { content -> [Competition] in
                if case .contentUpdate(let tournaments) = content {
                    return ServiceProviderModelMapper.competitions(fromTournaments: tournaments)
                }
                return []
            }
            .prefix(1) // Only take the first .contentUpdate

        Publishers.Zip(sportTournamentsPublisher, popularTournamentsPublisher)
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { completion in
                    switch completion {
                    case .finished:
                        print("All tournaments subscriptions completed")
                    case .failure(let error):
                        print("Tournaments subscriptions failed: \(error)")
                    }
                },
                receiveValue: { [weak self] sportCompetitions, popularCompetitions in
                    
                    self?.setupAllLeagues(popularCompetitions: popularCompetitions, sportCompetitions: sportCompetitions)
                }
            )
            .store(in: &cancellables)
    }
    
    func setupAllLeagues(popularCompetitions: [Competition], sportCompetitions: [Competition]) {
        isLoadingPublisher.send(true)
        
        popularLeagues.removeAll()
        popularCountryLeagues.removeAll()
        otherCountryLeagues.removeAll()

        // Popular Leagues
        var allLeaguesOption = SortOption(id: "all", icon: "league_icon", title: "All Popular Leagues", count: 0, iconTintChange: false)
        
        // Convert competitions to SortOptions
        let newSortOptions = popularCompetitions.map { competition in
            SortOption(
                id: competition.id,
                icon: "league_icon",
                title: competition.name,
                count: competition.numberEvents ?? 0,
                iconTintChange: false
            )
        }
        
        let totalCount = newSortOptions.reduce(0) { $0 + $1.count }
        
        allLeaguesOption.count = totalCount
        
        popularLeagues.append(allLeaguesOption)
        popularLeagues.append(contentsOf: newSortOptions)
        
        // Popular and Other Country Leagues
        let popularVenueIds: Set<String> = Set(popularCompetitions.compactMap { $0.venue?.id })

        var venueDict: [String: (venueName: String, leagues: [LeagueOption])] = [:]
        
        for competition in sportCompetitions {
            let venueId = competition.venue?.id ?? ""
            let venueName = competition.venue?.name ?? ""
            let league = LeagueOption(
                id: competition.id,
                icon: nil,
                title: competition.name,
                count: competition.numberEvents ?? 0
            )
            if var entry = venueDict[venueId] {
                entry.leagues.append(league)
                venueDict[venueId] = (venueName: entry.venueName, leagues: entry.leagues)
            } else {
                venueDict[venueId] = (venueName: venueName, leagues: [league])
            }
        }

        var popularCountryLeaguesArr: [CountryLeagueOptions] = []
        var otherCountryLeaguesArr: [CountryLeagueOptions] = []

        for (index, (venueId, value)) in venueDict.enumerated() {
            let countryLeague = CountryLeagueOptions(
                id: venueId,
                icon: venueId,
                title: value.venueName,
                leagues: value.leagues,
                isExpanded: index == 0
            )
            if popularVenueIds.contains(venueId) {
                popularCountryLeaguesArr.append(countryLeague)
            } else {
                otherCountryLeaguesArr.append(countryLeague)
            }
        }

        popularCountryLeagues.append(contentsOf: popularCountryLeaguesArr)
        otherCountryLeagues.append(contentsOf: otherCountryLeaguesArr)
        
        // Sort both arrays alphabetically by title
        popularCountryLeagues.sort { $0.title < $1.title }
        otherCountryLeagues.sort { $0.title < $1.title }
        
        self.refreshLeaguesFilterData()
        self.refreshCountryLeaguesFilterData()
        self.isLoadingPublisher.send(false)
       
    }
    
    // TEST
//    func recheckAllLeagues(){
//        self.isLoadingPublisher.send(true)
//        
//        popularLeagues.removeAll()
//        popularCountryLeagues.removeAll()
//        otherCountryLeagues.removeAll()
//
//        // Popular Leagues
//        var allLeaguesOption = SortOption(id: "0", icon: "league_icon", title: "All Popular Leagues", count: 0, iconTintChange: false)
//        
//        let newSortOptions = [
//            SortOption(id: "51", icon: "league_icon", title: "NBA", count: 25, iconTintChange: false),
//            SortOption(id: "52", icon: "league_icon", title: "ACB", count: 10, iconTintChange: false),
//            SortOption(id: "53", icon: "league_icon", title: "ABA League", count: 8, iconTintChange: false),
//            SortOption(id: "54", icon: "league_icon", title: "La Liga", count: 13, iconTintChange: false),
//            SortOption(id: "55", icon: "league_icon", title: "Serie A", count: 0, iconTintChange: false)
//        ]
//        
//        let totalCount = newSortOptions.reduce(0) { $0 + $1.count }
//        
//        allLeaguesOption.count = totalCount
//        
//        popularLeagues.append(allLeaguesOption)
//        popularLeagues.append(contentsOf: newSortOptions)
//        
//        // Popular Country Leagues
//        
//        let countryLeagueOptions = [
//            CountryLeagueOptions(
//                id: "1",
//                icon: "international_flag_icon",
//                title: "United States",
//                leagues: [
//                    LeagueOption(id: "56", icon: nil, title: "NBA", count: 30),
//                    LeagueOption(id: "57", icon: nil, title: "WNBA", count: 12),
//                    LeagueOption(id: "58", icon: nil, title: "G League", count: 28)
//                ],
//                isExpanded: true
//            ),
//            CountryLeagueOptions(
//                id: "2",
//                icon: "international_flag_icon",
//                title: "Spain",
//                leagues: [
//                    LeagueOption(id: "59", icon: nil, title: "ACB", count: 18),
//                    LeagueOption(id: "60", icon: nil, title: "LEB Oro", count: 18)
//                ],
//                isExpanded: false
//            ),
//            CountryLeagueOptions(
//                id: "3",
//                icon: "international_flag_icon",
//                title: "Turkey",
//                leagues: [
//                    LeagueOption(id: "61", icon: nil, title: "ABA League", count: 14)
//                ],
//                isExpanded: false
//            ),
//            CountryLeagueOptions(
//                id: "4",
//                icon: "international_flag_icon",
//                title: "International",
//                leagues: [
//                    LeagueOption(id: "62", icon: nil, title: "EuroLeague", count: 18),
//                    LeagueOption(id: "63", icon: nil, title: "EuroCup", count: 20),
//                    LeagueOption(id: "64", icon: nil, title: "FIBA World Cup", count: 32)
//                ],
//                isExpanded: false
//            )
//        ]
//        
//        popularCountryLeagues.append(contentsOf: countryLeagueOptions)
//        
//        // Other country leagues
//        let otherCountryLeagueOptions = [
//            CountryLeagueOptions(
//                id: "7",
//                icon: "international_flag_icon",
//                title: "Portugal",
//                leagues: [
//                    LeagueOption(id: "65", icon: nil, title: "LPB 2025", count: 18)
//                ],
//                isExpanded: false
//            ),
//            CountryLeagueOptions(
//                id: "9",
//                icon: "international_flag_icon",
//                title: "Netherlands",
//                leagues: [
//                    LeagueOption(id: "68", icon: nil, title: "DBL 2025", count: 10)
//                ],
//                isExpanded: false
//            )
//        ]
//        
//        self.otherCountryLeagues.append(contentsOf: otherCountryLeagueOptions)
//        
//        // Refresh data
//        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) { [weak self] in
//            self?.refreshLeaguesFilterData()
//            self?.refreshCountryLeaguesFilterData()
//            self?.isLoadingPublisher.send(false)
//        }
//
//    }
    
    private func refreshLeaguesFilterData() {
        if let leaguesViewModel = dynamicViewModels["leaguesFilter"] as? MockSortFilterViewModel {
            
            leaguesViewModel.updateSortOptions(popularLeagues)
        }
        
    }
    
    private func refreshCountryLeaguesFilterData() {
        if let countryLeaguesViewModel = dynamicViewModels["popularCountryLeaguesFilter"] as? MockCountryLeaguesFilterViewModel {
            
            countryLeaguesViewModel.updateCountryLeagueOptions(popularCountryLeagues)
        }
        
        if let otherCountryLeaguesViewModel = dynamicViewModels["otherCountryLeaguesFilter"] as? MockCountryLeaguesFilterViewModel {
            
            otherCountryLeaguesViewModel.updateCountryLeagueOptions(otherCountryLeagues)
        }
    }
}

public class CombinedFiltersViewController: UIViewController {
    
    // MARK: - Properties
    private let navigationView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let resetButton: UIButton = {
       let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle(localized("reset"), for: .normal)
        button.titleLabel?.font = StyleProvider.fontWith(type: .semibold, size: 14)
        button.setTitleColor(StyleProvider.Color.textPrimary, for: .normal)
        button.backgroundColor = .clear
        return button
    }()
    
    private let titleLabel: UILabel = {
       let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = localized("filters")
        label.font = StyleProvider.fontWith(type: .bold, size: 16)
        label.textColor = StyleProvider.Color.textPrimary
        label.textAlignment = .center
        return label
    }()
    
    private let closeButton: UIButton = {
       let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle(localized("close"), for: .normal)
        button.titleLabel?.font = StyleProvider.fontWith(type: .semibold, size: 14)
        button.setTitleColor(StyleProvider.Color.highlightTertiary, for: .normal)
        button.backgroundColor = .clear
        return button
    }()
    
    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.showsVerticalScrollIndicator = true
        scrollView.backgroundColor = StyleProvider.Color.separatorLine
        return scrollView
    }()
    
    private let contentView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let stackView: UIStackView = {
        let stack = UIStackView()
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .vertical
        stack.spacing = 16
        stack.distribution = .fill
        return stack
    }()
    
    private let applyButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("Apply", for: .normal)
        button.titleLabel?.font = StyleProvider.fontWith(type: .bold, size: 18)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = StyleProvider.Color.buttonBackgroundPrimary
        button.layer.cornerRadius = 8
        button.layer.masksToBounds = true
        return button
    }()
    
    private let bottomContainerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .white

        // Add shadow
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOffset = CGSize(width: 0, height: -2)
        view.layer.shadowOpacity = 0.1
        view.layer.shadowRadius = 4
        view.layer.masksToBounds = false
        
        return view
    }()
    
    private let loadingView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = UIColor.black.withAlphaComponent(0.3)
        view.isHidden = true
        return view
    }()

    private let activityIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .large)
        indicator.translatesAutoresizingMaskIntoConstraints = false
        indicator.startAnimating()
        indicator.hidesWhenStopped = true
        return indicator
    }()
    
    // Dynamic storage for views
    private var dynamicFilterViews: [String: UIView] = [:]
    
    var viewModel: CombinedFiltersViewModel
    
    // Callbacks
    public var onReset: (() -> Void)?
    public var onClose: (() -> Void)?
    public var onApply: ((GeneralFilterSelection) -> Void)?

    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Initialization
    public init(viewModel: CombinedFiltersViewModel) {
        self.viewModel = viewModel
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle
    public override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationBar()
        setupView()
        
        // Create dynamic view models and setup filter views from configuration
        createDynamicViewModels(for: viewModel.filterConfiguration, contextId: viewModel.currentContextId)
        setupFilterViewsFromConfiguration(viewModel.filterConfiguration, contextId: viewModel.currentContextId)
        
        setupApplyButton()
        setupConstraints()
        
        bind(toViewModel: viewModel)
    }
    
    // MARK: - Setup
    private func setupNavigationBar() {
        
        view.addSubview(navigationView)
        
        navigationView.addSubview(resetButton)
        navigationView.addSubview(titleLabel)
        navigationView.addSubview(closeButton)

        NSLayoutConstraint.activate([
            navigationView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            navigationView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            navigationView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            navigationView.heightAnchor.constraint(equalToConstant: 40),
            
            resetButton.leadingAnchor.constraint(equalTo: navigationView.leadingAnchor, constant: 16),
            resetButton.centerYAnchor.constraint(equalTo: navigationView.centerYAnchor),
            resetButton.heightAnchor.constraint(equalToConstant: 40),
            
            closeButton.trailingAnchor.constraint(equalTo: navigationView.trailingAnchor, constant: -16),
            closeButton.centerYAnchor.constraint(equalTo: navigationView.centerYAnchor),
            closeButton.heightAnchor.constraint(equalToConstant: 40),
            
            titleLabel.leadingAnchor.constraint(equalTo: navigationView.leadingAnchor, constant: 50),
            titleLabel.trailingAnchor.constraint(equalTo: navigationView.trailingAnchor, constant: -50),
            titleLabel.centerYAnchor.constraint(equalTo: navigationView.centerYAnchor)
        ])
        
        resetButton.addTarget(self, action: #selector(resetButtonTapped), for: .primaryActionTriggered)
        
        closeButton.addTarget(self, action: #selector(closeButtonTapped), for: .primaryActionTriggered)
    }
    
    private func setupView() {
        view.backgroundColor = StyleProvider.Color.backgroundColor
        
        view.addSubview(scrollView)
        view.addSubview(bottomContainerView)
        scrollView.addSubview(contentView)
        contentView.addSubview(stackView)
        bottomContainerView.addSubview(applyButton)
        
        view.addSubview(loadingView)
        loadingView.addSubview(activityIndicator)

    }

    private func setupApplyButton() {
        applyButton.addTarget(self, action: #selector(applyButtonTapped), for: .touchUpInside)
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            // ScrollView constraints
            scrollView.topAnchor.constraint(equalTo: navigationView.bottomAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: bottomContainerView.topAnchor),
            
            // Bottom container constraints
            bottomContainerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            bottomContainerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            bottomContainerView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            bottomContainerView.heightAnchor.constraint(equalToConstant: 80),
            
            // Apply button constraints
            applyButton.leadingAnchor.constraint(equalTo: bottomContainerView.leadingAnchor, constant: 16),
            applyButton.trailingAnchor.constraint(equalTo: bottomContainerView.trailingAnchor, constant: -16),
            applyButton.topAnchor.constraint(equalTo: bottomContainerView.topAnchor, constant: 16),
            applyButton.heightAnchor.constraint(equalToConstant: 48),
            
            // ContentView constraints
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
            
            // StackView constraints
            stackView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 16),
            stackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            stackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            stackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -16),
            
            // Loading view constraints
            loadingView.topAnchor.constraint(equalTo: view.topAnchor),
            loadingView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            loadingView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            loadingView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            activityIndicator.centerXAnchor.constraint(equalTo: loadingView.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: loadingView.centerYAnchor)
        ])
    }
    
    // MARK: Binding
    private func bind(toViewModel viewModel: CombinedFiltersViewModel) {
        
        viewModel.isLoadingPublisher
            .sink(receiveValue: { [weak self] isLoading in
                self?.loadingView.isHidden = !isLoading
            })
            .store(in: &cancellables)
    }
    
    // MARK: Functions
    private func resetFilters() {
        // Reset sports filter
        if let sportViewModel = viewModel.dynamicViewModels["sportsFilter"] as? SportGamesFilterViewModelProtocol {
            sportViewModel.selectedId.send(Env.filterStorage.currentFilterSelection.sportId)

        }
        
        // Reset time slider
        if let timeViewModel = viewModel.dynamicViewModels["timeFilter"] as? TimeSliderViewModelProtocol {
            let selectedIndex: Float
            
            if let index = timeViewModel.timeOptions.firstIndex(where: { $0.value == Env.filterStorage.currentFilterSelection.timeValue }) {
                selectedIndex = Float(index)
            } else {
                selectedIndex = 0.0
            }
            
            timeViewModel.selectedTimeValue.send(selectedIndex)
        }
        
        // Reset sort filter
        if let sortViewModel = viewModel.dynamicViewModels["sortByFilter"] as? SortFilterViewModelProtocol {
            sortViewModel.selectedOptionId.send(Env.filterStorage.currentFilterSelection.sortTypeId)
        }
        
        // Reset leagues filter
        if let leaguesViewModel = viewModel.dynamicViewModels["leaguesFilter"] as? SortFilterViewModelProtocol {
            leaguesViewModel.selectedOptionId.send(Env.filterStorage.currentFilterSelection.leagueId)
        }
        
        // Reset popular countries filter
        if let popularCountriesViewModel = viewModel.dynamicViewModels["popularCountryLeaguesFilter"] as? CountryLeaguesFilterViewModelProtocol {
            popularCountriesViewModel.selectedOptionId.send(Env.filterStorage.currentFilterSelection.leagueId)
        }
        
        // Reset other countries filter
        if let otherCountriesViewModel = viewModel.dynamicViewModels["otherCountryLeaguesFilter"] as? CountryLeaguesFilterViewModelProtocol {
            otherCountriesViewModel.selectedOptionId.send(Env.filterStorage.currentFilterSelection.leagueId)
        }
    }
    
    // MARK: - Actions
    @objc private func resetButtonTapped() {
//        self.viewModel.generalFilterSelection = self.viewModel.defaultFilterSelection
//        print("RESET FILTERS: \(self.viewModel.generalFilterSelection)")
        Env.filterStorage.resetToDefault()
        self.resetFilters()
        onReset?()
    }
    
    @objc private func closeButtonTapped() {
        self.navigationController?.popViewController(animated: true)
        onClose?()
    }

    @objc private func applyButtonTapped() {
        print("APPLIED FILTERS: \(self.viewModel.generalFilterSelection)")
//        onApply?(self.viewModel.generalFilterSelection)
        Env.filterStorage.updateFilterSelection(self.viewModel.generalFilterSelection)
        self.closeButtonTapped()
    }
    
}

// MARK: - Filter Configuration and Views Methods
extension CombinedFiltersViewController {
    
    private static func createFilterConfiguration() -> FilterConfiguration {
        // Create widgets
        let widgets = [
            FilterWidget(
                id: "sportsFilter",
                type: .sportsFilter,
                label: "sports",
                icon: nil,
                details: FilterDetails(
                    isExpandable: true,
                    expandedByDefault: true,
                    options: nil
                )
            ),
            FilterWidget(
                id: "timeFilter",
                type: .timeFilter,
                label: "filter_by_time",
                icon: "filterTime",
                details: FilterDetails(
                    isExpandable: false,
                    expandedByDefault: false,
                    options: [
                        FilterOption(id: "all", label: "all", value: "0"),
                        FilterOption(id: "1h", label: "1h", value: "1"),
                        FilterOption(id: "8h", label: "8h", value: "8"),
                        FilterOption(id: "today", label: "today", value: "24"),
                        FilterOption(id: "48h", label: "48h", value: "48")
                    ]
                )
            ),
            FilterWidget(
                id: "sortByFilter",
                type: .radioFilterBasic,
                label: "sort_by",
                icon: nil,
                details: FilterDetails(
                    isExpandable: true,
                    expandedByDefault: true,
                    options: [
                        FilterOption(id: "popular", label: "popular", value: "popular"),
                        FilterOption(id: "upcoming", label: "upcoming", value: "upcoming"),
                        FilterOption(id: "favourites", label: "favourites", value: "favourites")
                    ]
                )
            ),
            FilterWidget(
                id: "leaguesFilter",
                type: .radioFilterBasic,
                label: "leagues",
                icon: nil,
                details: FilterDetails(
                    isExpandable: true,
                    expandedByDefault: true,
                    options: nil
                )
            ),
            FilterWidget(
                id: "popularCountryLeaguesFilter",
                type: .radioFilterAccordion,
                label: "popular_countries",
                icon: nil,
                details: FilterDetails(
                    isExpandable: true,
                    expandedByDefault: true,
                    options: nil
                )
            ),
            FilterWidget(
                id: "otherCountryLeaguesFilter",
                type: .radioFilterAccordion,
                label: "other_countries",
                icon: nil,
                details: FilterDetails(
                    isExpandable: true,
                    expandedByDefault: true,
                    options: nil
                )
            )
        ]
        
        // Create filter contexts
        let filtersByContext = [
            FilterContext(
                id: "sports",
                widgets: [
                    "sportsFilter",
                    "timeFilter",
                    "sortByFilter",
                    "leaguesFilter",
                    "popularCountryLeaguesFilter",
                    "otherCountryLeaguesFilter"
                ]
            ),
            FilterContext(
                id: "casino",
                widgets: []
            )
        ]
        
        return FilterConfiguration(
            widgets: widgets,
            filtersByContext: filtersByContext
        )
    }
    
    private func setupFilterViewsFromConfiguration(_ configuration: FilterConfiguration, contextId: String = "sports") {
        // Find the context (e.g., "sports")
        guard let context = configuration.filtersByContext.first(where: { $0.id == contextId }) else {
            return
        }
        
        // Create filter views based on the configuration order
        for widgetId in context.widgets {
            guard let widget = configuration.widgets.first(where: { $0.id == widgetId }) else {
                continue
            }
            
            let filterView = createFilterView(from: widget)
            
            // Configure the view
            filterView?.translatesAutoresizingMaskIntoConstraints = false
            filterView?.layer.cornerRadius = 8
            filterView?.backgroundColor = .white
            
            // Store references to the views for callbacks
            storeFilterViewReference(filterView, for: widget)
            
            // Add to stack view
            if let filterView = filterView {
                stackView.addArrangedSubview(filterView)
            }
        }
        
        // Setup callbacks
        setupFilterCallbacks()
    }
    
    private func createFilterView(from widget: FilterWidget) -> UIView? {
        guard let viewModel = viewModel.dynamicViewModels[widget.id] else {
            return nil
        }
        
        switch widget.type {
        case .sportsFilter:
            guard let sportViewModel = viewModel as? SportGamesFilterViewModelProtocol else { return nil }
            return SportGamesFilterView(viewModel: sportViewModel)
            
        case .timeFilter:
            guard let timeViewModel = viewModel as? TimeSliderViewModelProtocol else { return nil }
            return TimeSliderView(viewModel: timeViewModel)
            
        case .radioFilterBasic:
            guard let sortViewModel = viewModel as? SortFilterViewModelProtocol else { return nil }
            return SortFilterView(viewModel: sortViewModel)
            
        case .radioFilterAccordion:
            guard let countryViewModel = viewModel as? CountryLeaguesFilterViewModelProtocol else { return nil }
            return CountryLeaguesFilterView(viewModel: countryViewModel)
        }
    }

    private func storeFilterViewReference(_ view: UIView?, for widget: FilterWidget) {
        if let view = view {
            dynamicFilterViews[widget.id] = view
        }
    }
    
    private func setupFilterCallbacks() {
        // Sports Filter
        if let sportView = dynamicFilterViews["sportsFilter"] as? SportGamesFilterView {
            sportView.onSportSelected = { [weak self] selectedId in
                self?.viewModel.generalFilterSelection.sportId = selectedId
                self?.viewModel.getAllLeagues(sportId: selectedId)
            }
        }
        
        // Time Slider
        if let timeView = dynamicFilterViews["timeFilter"] as? TimeSliderView {
            timeView.onSliderValueChange = { [weak self] selectedValue in
                guard let self = self else { return }
                
                if let timeViewModel = self.viewModel.dynamicViewModels["timeFilter"] as? MockTimeSliderViewModel {
                    let arrayIndex = Int(selectedValue)
                    if arrayIndex >= 0 && arrayIndex < timeViewModel.timeOptions.count {
                        let actualTimeValue = timeViewModel.timeOptions[arrayIndex].value
                        print("Time filter selected: \(actualTimeValue)")
                        self.viewModel.generalFilterSelection.timeValue = actualTimeValue
                    }
                }
            }
        }
        
        // Sort Filter
        if let sortView = dynamicFilterViews["sortByFilter"] as? SortFilterView {
            sortView.onSortFilterSelected = { [weak self] selectedId in
                self?.viewModel.generalFilterSelection.sortTypeId = selectedId
            }
        }
        
        // Leagues Filter with cross-synchronization
        if let leaguesView = dynamicFilterViews["leaguesFilter"] as? SortFilterView {
            leaguesView.onSortFilterSelected = { [weak self] selectedId in
                self?.viewModel.generalFilterSelection.leagueId = selectedId
                self?.synchronizeLeagueSelection(selectedId, excludeWidget: "leaguesFilter")
            }
        }
        
        // Popular Countries Filter
        if let popularCountriesView = dynamicFilterViews["popularCountryLeaguesFilter"] as? CountryLeaguesFilterView {
            popularCountriesView.onLeagueFilterSelected = { [weak self] selectedId in
                self?.viewModel.generalFilterSelection.leagueId = selectedId
                self?.synchronizeLeagueSelection(selectedId, excludeWidget: "popularCountryLeaguesFilter")
            }
        }
        
        // Other Countries Filter
        if let otherCountriesView = dynamicFilterViews["otherCountryLeaguesFilter"] as? CountryLeaguesFilterView {
            otherCountriesView.onLeagueFilterSelected = { [weak self] selectedId in
                self?.viewModel.generalFilterSelection.leagueId = selectedId
                self?.synchronizeLeagueSelection(selectedId, excludeWidget: "otherCountryLeaguesFilter")
            }
        }
    }

    private func synchronizeLeagueSelection(_ selectedId: String, excludeWidget: String) {
        
        // Synchronize with leagues filter
        if excludeWidget != "leaguesFilter",
           let leaguesViewModel = viewModel.dynamicViewModels["leaguesFilter"] as? SortFilterViewModelProtocol,
           leaguesViewModel.selectedOptionId.value != selectedId {
            leaguesViewModel.selectedOptionId.send(selectedId)
            viewModel.generalFilterSelection.leagueId = selectedId
        }
        
        // Synchronize with popular countries
        if excludeWidget != "popularCountryLeaguesFilter",
           let popularViewModel = viewModel.dynamicViewModels["popularCountryLeaguesFilter"] as? CountryLeaguesFilterViewModelProtocol,
           popularViewModel.selectedOptionId.value != selectedId {
            popularViewModel.selectedOptionId.send(selectedId)
        }
        
        // Synchronize with other countries
        if excludeWidget != "otherCountryLeaguesFilter",
           let otherViewModel = viewModel.dynamicViewModels["otherCountryLeaguesFilter"] as? CountryLeaguesFilterViewModelProtocol,
           otherViewModel.selectedOptionId.value != selectedId {
            otherViewModel.selectedOptionId.send(selectedId)
        }
    }
}

// MARK: - Filter View Models Setup
extension CombinedFiltersViewController {
    
    private func createDynamicViewModels(for configuration: FilterConfiguration, contextId: String) {
        guard let context = configuration.filtersByContext.first(where: { $0.id == contextId }) else {
            return
        }
        
        for widgetId in context.widgets {
            guard let widget = configuration.widgets.first(where: { $0.id == widgetId }) else {
                continue
            }
            
            let viewModel = createViewModel(for: widget)
            self.viewModel.dynamicViewModels[widgetId] = viewModel
        }
    }
    
    private func createViewModel(for widget: FilterWidget) -> Any? {
        switch widget.type {
        case .sportsFilter:
            return createSportGamesViewModel(for: widget)
            
        case .timeFilter:
            return createTimeSliderViewModel(for: widget)
            
        case .radioFilterBasic:
            return createSortFilterViewModel(for: widget)
            
        case .radioFilterAccordion:
            return createCountryLeaguesViewModel(for: widget)
        }
    }
    
    private func createSportGamesViewModel(for widget: FilterWidget) -> SportGamesFilterViewModelProtocol {
        
        let activeSports = Env.sportsStore.getActiveSports().sorted {
            (Int($0.id) ?? 0) < (Int($1.id) ?? 0)
        }
        
        let sportFilters: [SportFilter] = activeSports.map { sport in
            SportFilter(
                id: sport.id,
                title: sport.name,
                icon: "sport_type_icon_\(sport.id)"
            )
        }
        
        return MockSportGamesFilterViewModel(
            title: widget.label, sportFilters: sportFilters,
            selectedId: viewModel.generalFilterSelection.sportId
        )
    }
    
    private func createTimeSliderViewModel(for widget: FilterWidget) -> TimeSliderViewModelProtocol {
        // Extract time options from widget configuration
        let timeOptions: [TimeOption]
        
        if let options = widget.details.options {
            timeOptions = options.compactMap { option in
                guard let value = Float(option.value) else { return nil }
                return TimeOption(title: option.label, value: value)
            }
        } else {
            // Default time options
            timeOptions = [
                TimeOption(title: "All", value: 0),
                TimeOption(title: "1h", value: 1),
                TimeOption(title: "8h", value: 8),
                TimeOption(title: "Today", value: 24),
                TimeOption(title: "48h", value: 48)
            ]
        }
        
        // Find the index of the time option that matches the current timeValue
        let selectedIndex: Float
        if let index = timeOptions.firstIndex(where: { $0.value == viewModel.generalFilterSelection.timeValue }) {
            selectedIndex = Float(index)
        } else {
            selectedIndex = 0.0
        }
        
        return MockTimeSliderViewModel(
            title: widget.label, timeOptions: timeOptions,
            selectedValue: selectedIndex
        )
    }
    
    private func createSortFilterViewModel(for widget: FilterWidget) -> SortFilterViewModelProtocol {
        var sortOptions: [SortOption] = []
        var selectedId: String = "0"
        var sortFilterType: SortFilterType = .regular
        
        if widget.id == "sortByFilter" {
            if let options = widget.details.options {
                sortOptions = options.enumerated().map { index, option in
                    let iconName: String
                    switch option.id {
                    case "popular":
                        iconName = "popular_icon"
                    case "upcoming":
                        iconName = "timelapse_icon"
                    case "favourites":
                        iconName = "favourites_icon"
                    default:
                        iconName = "circle.fill"
                    }
                    
                    return SortOption(
                        id: "\(index+1)",
                        icon: iconName,
                        title: option.label,
                        count: self.getCountForSortOption(option.id)
                    )
                }
            }
            selectedId = viewModel.generalFilterSelection.sortTypeId
        } else if widget.id == "leaguesFilter" {
            sortOptions = viewModel.popularLeagues
            sortFilterType = .league
            selectedId = viewModel.generalFilterSelection.leagueId
        }
        
        return MockSortFilterViewModel(
            title: widget.label,
            sortOptions: sortOptions,
            selectedId: selectedId,
            sortFilterType: sortFilterType
        )
    }
    
    private func createCountryLeaguesViewModel(for widget: FilterWidget) -> CountryLeaguesFilterViewModelProtocol {
        var countryLeagueOptions: [CountryLeagueOptions] = []
        
        if widget.id == "popularCountryLeaguesFilter" {
            countryLeagueOptions = self.viewModel.popularCountryLeagues
        } else if widget.id == "otherCountryLeaguesFilter" {
            countryLeagueOptions = self.viewModel.otherCountryLeagues
        }
        
        return MockCountryLeaguesFilterViewModel(
            title: widget.label,
            countryLeagueOptions: countryLeagueOptions,
            selectedId: viewModel.generalFilterSelection.leagueId
        )
    }
    
    // Helper for getting sort count values
    // TODO: Use actual values when data is available
    private func getCountForSortOption(_ optionId: String) -> Int {
        switch optionId {
        case "popular":
            return 25
        case "upcoming":
            return 15
        case "favourites":
            return 0
        default:
            return 0
        }
    }
    
}

// MARK: - Convenience Initializer
public extension CombinedFiltersViewController {
    
    static func withMockData() -> CombinedFiltersViewController {
        
        let generalFilterSelection = GeneralFilterSelection(
            sportId: "1", timeValue: 1.0, sortTypeId: "1",
            leagueId: "0"
        )
        
        let configuration = createMockFilterConfiguration()

        let viewModel = CombinedFiltersViewModel(filterConfiguration: configuration,
                                                 contextId: "sports")
        
        return CombinedFiltersViewController( viewModel: viewModel)
    }
    
    static func createMockFilterConfiguration() -> FilterConfiguration {
        self.createFilterConfiguration()
    }
}

#if DEBUG
import SwiftUI
import ServicesProvider

@available(iOS 17.0, *)
struct CombinedFiltersViewController_Preview: PreviewProvider {
    static var previews: some View {
        PreviewUIViewController {
            let viewController = CombinedFiltersViewController.withMockData()
            let navigationController = UINavigationController(rootViewController: viewController)
            return navigationController
        }
    }
}

#endif
