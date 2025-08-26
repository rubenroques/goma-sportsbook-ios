import UIKit
import Combine
import GomaUI

class CombinedFiltersDemoViewController: UIViewController {
    
    // MARK: - Properties
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
    
    var viewModel: CombinedFiltersDemoViewModel

    // Callbacks
    public var onReset: (() -> Void)?
    public var onClose: (() -> Void)?
    public var onApply: ((GeneralFilterSelection) -> Void)?

    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Initialization
    init(viewModel: CombinedFiltersDemoViewModel) {
        self.viewModel = viewModel
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
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
        // Set navigation bar appearance
        navigationController?.navigationBar.backgroundColor = .white
        navigationController?.navigationBar.barTintColor = .white
        navigationController?.navigationBar.isTranslucent = false
        
        // Title
        title = "Filters"
        navigationController?.navigationBar.titleTextAttributes = [
            .foregroundColor: StyleProvider.Color.textPrimary,
            .font: StyleProvider.fontWith(type: .bold, size: 16)
        ]
        
        // Reset button (left)
        let resetButton = UIBarButtonItem(
            title: "Reset",
            style: .plain,
            target: self,
            action: #selector(resetButtonTapped)
        )
        resetButton.setTitleTextAttributes([
            .foregroundColor: StyleProvider.Color.textPrimary,
            .font: StyleProvider.fontWith(type: .semibold, size: 14)
        ], for: .normal)
        navigationItem.leftBarButtonItem = resetButton
        
        // Close button (right)
        let closeButton = UIBarButtonItem(
            title: "Close",
            style: .plain,
            target: self,
            action: #selector(closeButtonTapped)
        )
        closeButton.setTitleTextAttributes([
            .foregroundColor: StyleProvider.Color.highlightTertiary,
            .font: StyleProvider.fontWith(type: .semibold, size: 14)
        ], for: .normal)
        navigationItem.rightBarButtonItem = closeButton
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
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
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
    private func bind(toViewModel viewModel: CombinedFiltersDemoViewModel) {
        
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
            sportViewModel.selectedId.send(viewModel.generalFilterSelection.sportId)
        }
        
        // Reset time slider
        if let timeViewModel = viewModel.dynamicViewModels["timeFilter"] as? TimeSliderViewModelProtocol {
            let selectedIndex: Float
            
            if let index = timeViewModel.timeOptions.firstIndex(where: { $0.value == viewModel.generalFilterSelection.timeValue }) {
                selectedIndex = Float(index)
            } else {
                selectedIndex = 0.0
            }
            
            timeViewModel.selectedTimeValue.send(selectedIndex)
        }
        
        // Reset sort filter
        if let sortViewModel = viewModel.dynamicViewModels["sortByFilter"] as? SortFilterViewModelProtocol {
            sortViewModel.selectedOptionId.send(viewModel.generalFilterSelection.sortTypeId)
        }
        
        // Reset leagues filter
        if let leaguesViewModel = viewModel.dynamicViewModels["leaguesFilter"] as? SortFilterViewModelProtocol {
            leaguesViewModel.selectedOptionId.send(viewModel.generalFilterSelection.leagueId)
        }
        
        // Reset popular countries filter
        if let popularCountriesViewModel = viewModel.dynamicViewModels["popularCountryLeaguesFilter"] as? CountryLeaguesFilterViewModelProtocol {
            popularCountriesViewModel.selectedOptionId.send(viewModel.generalFilterSelection.leagueId)
        }
        
        // Reset other countries filter
        if let otherCountriesViewModel = viewModel.dynamicViewModels["otherCountryLeaguesFilter"] as? CountryLeaguesFilterViewModelProtocol {
            otherCountriesViewModel.selectedOptionId.send(viewModel.generalFilterSelection.leagueId)
        }
    }
    
    // MARK: - Actions
    @objc private func resetButtonTapped() {
        self.viewModel.generalFilterSelection = self.viewModel.defaultFilterSelection
        print("RESET FILTERS: \(self.viewModel.generalFilterSelection)")
        self.resetFilters()
        onReset?()
    }
    
    @objc private func closeButtonTapped() {
        self.navigationController?.popViewController(animated: true)
        onClose?()
    }

    @objc private func applyButtonTapped() {
        print("APPLIED FILTERS: \(self.viewModel.generalFilterSelection)")
        onApply?(self.viewModel.generalFilterSelection)
        self.closeButtonTapped()
    }
    
}

// MARK: - Filter Configuration and Views Methods
extension CombinedFiltersDemoViewController {
    
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
                if selectedId == "1" {
                    self?.viewModel.getAllLeagues()
                }
                else {
                    self?.viewModel.recheckAllLeagues()
                }
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
extension CombinedFiltersDemoViewController {
    
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
        // Create mock data or use real data based on widget configuration
        let sportFilters = [
            SportFilter(id: "1", title: "Football", icon: "sportscourt.fill"),
            SportFilter(id: "2", title: "Basketball", icon: "basketball.fill"),
            SportFilter(id: "3", title: "Tennis", icon: "tennis.racket"),
            SportFilter(id: "4", title: "Cricket", icon: "figure.cricket")
        ]
        
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
            selectedId = viewModel.generalFilterSelection.leagueId
        }
        
        return MockSortFilterViewModel(
            title: widget.label,
            sortOptions: sortOptions,
            selectedId: selectedId
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
extension CombinedFiltersDemoViewController {
    static func withMockData() -> CombinedFiltersDemoViewController {
        let generalFilterSelection = GeneralFilterSelection(
            sportId: "1", timeValue: 1.0, sortTypeId: "1",
            leagueId: "all"
        )
        let configuration = createMockFilterConfiguration()
        let viewModel: CombinedFiltersDemoViewModel = CombinedFiltersDemoViewModel(
                filterSelection: generalFilterSelection,
                filterConfiguration: configuration,
                contextId: "sports"
            )
        return CombinedFiltersDemoViewController( viewModel: viewModel)
    }
    
    static func createMockFilterConfiguration() -> FilterConfiguration {
        self.createFilterConfiguration()
    }
}

#if DEBUG
import SwiftUI

@available(iOS 17.0, *)
struct CombinedFiltersDemoViewController_Preview: PreviewProvider {
    static var previews: some View {
        PreviewUIViewController {
            let viewController = CombinedFiltersDemoViewController.withMockData()
            let navigationController = UINavigationController(rootViewController: viewController)
            return navigationController
        }
    }
}

// Helper for SwiftUI previews
struct PreviewUIViewController<T: UIViewController>: UIViewControllerRepresentable {
    let viewController: () -> T
    
    init(_ viewController: @escaping () -> T) {
        self.viewController = viewController
    }
    
    func makeUIViewController(context: Context) -> T {
        return viewController()
    }
    
    func updateUIViewController(_ uiViewController: T, context: Context) {
        // No updates needed
    }
}
#endif
