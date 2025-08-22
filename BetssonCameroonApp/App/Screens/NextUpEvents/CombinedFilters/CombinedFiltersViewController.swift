//
//  CombinedFiltersViewController.swift
//  Sportsbook
//
//  Created by André Lascas on 29/05/2025.
//

import UIKit
import Combine
import GomaUI
import ServicesProvider

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
        view.backgroundColor = StyleProvider.Color.backgroundTertiary

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
    
    var viewModel: CombinedFiltersViewModelProtocol
    
    // Callbacks
    public var onReset: (() -> Void)?
    public var onClose: (() -> Void)?
    public var onApply: ((AppliedEventsFilters) -> Void)?

    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Initialization
    init(currentFilters: AppliedEventsFilters,
         filterConfiguration: FilterConfiguration,
         servicesProvider: ServicesProvider.Client,
         onApply: @escaping (AppliedEventsFilters) -> Void) {
        
        self.viewModel = CombinedFiltersViewModel(
            filterConfiguration: filterConfiguration,
            currentFilters: currentFilters,
            servicesProvider: servicesProvider
        )
        
        self.onApply = onApply
        
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
    private func bind(toViewModel viewModel: CombinedFiltersViewModelProtocol) {
        
        viewModel.isLoadingPublisher
            .sink(receiveValue: { [weak self] isLoading in
                self?.loadingView.isHidden = !isLoading
            })
            .store(in: &cancellables)
    }
    
    // MARK: Functions
    private func resetFilters() {
        let defaultFilters = AppliedEventsFilters.defaultFilters
        viewModel.appliedFilters = defaultFilters
        
        // Reset sports filter
        if let sportViewModel = viewModel.dynamicViewModels["sportsFilter"] as? SportGamesFilterViewModelProtocol {
            sportViewModel.selectedId.send(defaultFilters.sportId)
        }
        
        // Reset time slider
        if let timeViewModel = viewModel.dynamicViewModels["timeFilter"] as? TimeSliderViewModelProtocol {
            let selectedIndex: Float
            
            if let index = timeViewModel.timeOptions.firstIndex(where: { $0.value == defaultFilters.timeValue }) {
                selectedIndex = Float(index)
            } else {
                selectedIndex = 0.0
            }
            
            timeViewModel.selectedTimeValue.send(selectedIndex)
        }
        
        // Reset sort filter
        if let sortViewModel = viewModel.dynamicViewModels["sortByFilter"] as? SortFilterViewModelProtocol {
            sortViewModel.selectedOptionId.send(defaultFilters.sortTypeId)
        }
        
        // Reset leagues filter
        if let leaguesViewModel = viewModel.dynamicViewModels["leaguesFilter"] as? SortFilterViewModelProtocol {
            leaguesViewModel.selectedOptionId.send(defaultFilters.leagueId)
        }
        
        // Reset popular countries filter
        if let popularCountriesViewModel = viewModel.dynamicViewModels["popularCountryLeaguesFilter"] as? CountryLeaguesFilterViewModelProtocol {
            popularCountriesViewModel.selectedOptionId.send(defaultFilters.leagueId)
        }
        
        // Reset other countries filter
        if let otherCountriesViewModel = viewModel.dynamicViewModels["otherCountryLeaguesFilter"] as? CountryLeaguesFilterViewModelProtocol {
            otherCountriesViewModel.selectedOptionId.send(defaultFilters.leagueId)
        }
    }
    
    // MARK: - Actions
    @objc private func resetButtonTapped() {
        self.resetFilters()
        onReset?()
    }
    
    @objc private func closeButtonTapped() {
        if let navigationController = self.navigationController {
            navigationController.popViewController(animated: true)
        }
        else {
            self.dismiss(animated: true)
        }

        onClose?()
    }

    @objc private func applyButtonTapped() {
        print("APPLIED FILTERS: \(self.viewModel.appliedFilters)")
        onApply?(self.viewModel.appliedFilters)
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
                label: "Sports",
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
                label: "Filter by Time",
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
                label: "Sort by",
                icon: nil,
                details: FilterDetails(
                    isExpandable: true,
                    expandedByDefault: true,
                    options: [
                        FilterOption(id: "popular", label: "Popular", value: "popular"),
                        FilterOption(id: "upcoming", label: "Upcoming", value: "upcoming"),
                        FilterOption(id: "favourites", label: "Favourites", value: "favourites")
                    ]
                )
            ),
            FilterWidget(
                id: "leaguesFilter",
                type: .radioFilterBasic,
                label: "Leagues",
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
                label: "Popular Countries",
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
                label: "Other Countries",
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
                self?.viewModel.appliedFilters.sportId = selectedId
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
                        self.viewModel.appliedFilters.timeValue = actualTimeValue
                    }
                }
            }
        }
        
        // Sort Filter
        if let sortView = dynamicFilterViews["sortByFilter"] as? SortFilterView {
            sortView.onSortFilterSelected = { [weak self] selectedId in
                self?.viewModel.appliedFilters.sortTypeId = selectedId
            }
        }
        
        // Leagues Filter with cross-synchronization
        if let leaguesView = dynamicFilterViews["leaguesFilter"] as? SortFilterView {
            leaguesView.onSortFilterSelected = { [weak self] selectedId in
                self?.viewModel.appliedFilters.leagueId = selectedId
                self?.synchronizeLeagueSelection(selectedId, excludeWidget: "leaguesFilter")
            }
        }
        
        // Popular Countries Filter
        if let popularCountriesView = dynamicFilterViews["popularCountryLeaguesFilter"] as? CountryLeaguesFilterView {
            popularCountriesView.onLeagueFilterSelected = { [weak self] selectedId in
                self?.viewModel.appliedFilters.leagueId = selectedId
                self?.synchronizeLeagueSelection(selectedId, excludeWidget: "popularCountryLeaguesFilter")
            }
        }
        
        // Other Countries Filter
        if let otherCountriesView = dynamicFilterViews["otherCountryLeaguesFilter"] as? CountryLeaguesFilterView {
            otherCountriesView.onLeagueFilterSelected = { [weak self] selectedId in
                self?.viewModel.appliedFilters.leagueId = selectedId
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
            viewModel.appliedFilters.leagueId = selectedId
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
extension CombinedFiltersViewModel {
    
    public func createDynamicViewModels(for configuration: FilterConfiguration, contextId: String) {
        guard let context = configuration.filtersByContext.first(where: { $0.id == contextId }) else {
            return
        }
        
        for widgetId in context.widgets {
            guard let widget = configuration.widgets.first(where: { $0.id == widgetId }) else {
                continue
            }
            
            let viewModel = createViewModel(for: widget)
            self.dynamicViewModels[widgetId] = viewModel
        }
    }
    
    public func createViewModel(for widget: FilterWidget) -> Any? {
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
            selectedId: appliedFilters.sportId
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
        if let index = timeOptions.firstIndex(where: { $0.value == appliedFilters.timeValue }) {
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
                        count: -1
                    )
                }
            }
            selectedId = appliedFilters.sortTypeId
        } else if widget.id == "leaguesFilter" {
            sortOptions = popularLeagues
            sortFilterType = .league
            selectedId = appliedFilters.leagueId
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
            countryLeagueOptions = popularCountryLeagues
        } else if widget.id == "otherCountryLeaguesFilter" {
            countryLeagueOptions = otherCountryLeagues
        }
        
        return MockCountryLeaguesFilterViewModel(
            title: widget.label,
            countryLeagueOptions: countryLeagueOptions,
            selectedId: appliedFilters.leagueId
        )
    }
    
}

// MARK: - Convenience Initializer
public extension CombinedFiltersViewController {
    
    static func createMockFilterConfiguration() -> FilterConfiguration {
        self.createFilterConfiguration()
    }
}
