import UIKit
import GomaUI

class GeneralFilterViewController: UIViewController {

    // MARK: - Properties
    private let filterOptionsCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.estimatedItemSize = UICollectionViewFlowLayout.automaticSize
        layout.minimumInteritemSpacing = 8
        layout.minimumLineSpacing = 8
        
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.backgroundColor = StyleProvider.Color.separatorLine
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.contentInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 130)
        
        return collectionView
    }()
    
    private let filterViewContainer: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = StyleProvider.Color.separatorLine
        
        // Add shadow
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOffset = CGSize(width: 0, height: 2)
        view.layer.shadowOpacity = 0.1
        view.layer.shadowRadius = 4
        view.layer.masksToBounds = false
        
        return view
    }()
    
    private var filterView: MainFilterPillView!
    private var stateToggleButton: UIButton!
    
    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        
        return scrollView
    }()
    
    private let containerView: UIView = {
        let containerView = UIView()
        containerView.translatesAutoresizingMaskIntoConstraints = false
        
        return containerView
    }()
    
    private var selectedFilterOptions: [FilterOptionItem] = []

    private var hasSelections: Bool = false
    
    let generalFilterSelection = GeneralFilterSelection(
        sportId: "1",
        timeValue: 1.0,
        sortTypeId: "1",
        leagueId: "all"
    )
    
    var selectedGeneralFilterSelection = GeneralFilterSelection(
        sportId: "1", timeValue: 1.0, sortTypeId: "1",
        leagueId: "all"
    )
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupViews()
        setupActions()
        layoutViews()
        
        self.selectedFilterOptions = self.buildFilterOptions(from: selectedGeneralFilterSelection)
        self.filterOptionsCollectionView.reloadData()
    }
    
    // MARK: - Setup
    private func setupViews() {
        view.backgroundColor = .gray
        
        let mainFilter = MainFilterItem(type: .mainFilter, title: "Filter", icon: "filter_icon", actionIcon: "right_arrow_icon")
        
        let mainFilterViewModel = MockMainFilterPillViewModel(mainFilter: mainFilter)
        
        filterView = MainFilterPillView(viewModel: mainFilterViewModel)
        filterView.translatesAutoresizingMaskIntoConstraints = false
        
        // State toggle button
        stateToggleButton = UIButton(type: .system)
        stateToggleButton.setTitle("Toggle Filter State", for: .normal)
        stateToggleButton.backgroundColor = StyleProvider.Color.primaryColor
        stateToggleButton.setTitleColor(StyleProvider.Color.contrastTextColor, for: .normal)
        stateToggleButton.layer.cornerRadius = 8
        stateToggleButton.translatesAutoresizingMaskIntoConstraints = false
        
        // Setup collection view
        filterOptionsCollectionView.delegate = self
        filterOptionsCollectionView.dataSource = self
        filterOptionsCollectionView.register(FilterOptionCell.self, forCellWithReuseIdentifier: "FilterOptionCell")
        filterOptionsCollectionView.register(SportSelectorCell.self, forCellWithReuseIdentifier: "SportSelectorCell")

        
        view.addSubview(filterOptionsCollectionView)
        view.addSubview(filterViewContainer)
        filterViewContainer.addSubview(filterView)
        view.addSubview(stateToggleButton)
        view.addSubview(scrollView)
        
        scrollView.addSubview(containerView)

    }
    
    private func layoutViews() {
        NSLayoutConstraint.activate([
            
            // Collection view below filter view
            filterOptionsCollectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            filterOptionsCollectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            filterOptionsCollectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            filterOptionsCollectionView.heightAnchor.constraint(equalToConstant: 56),
            
            filterViewContainer.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            filterViewContainer.centerYAnchor.constraint(equalTo: filterOptionsCollectionView.centerYAnchor),
            filterViewContainer.heightAnchor.constraint(equalTo: filterOptionsCollectionView.heightAnchor),
            
            filterView.leadingAnchor.constraint(equalTo: filterViewContainer.leadingAnchor, constant: 10),
            filterView.trailingAnchor.constraint(equalTo: filterViewContainer.trailingAnchor, constant: -10),
            filterView.centerYAnchor.constraint(equalTo: filterViewContainer.centerYAnchor),
            
            // Toggle button below description
            stateToggleButton.topAnchor.constraint(equalTo: filterOptionsCollectionView.bottomAnchor, constant: 24),
            stateToggleButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            stateToggleButton.widthAnchor.constraint(equalToConstant: 200),
            stateToggleButton.heightAnchor.constraint(equalToConstant: 44),
            
            // ScrollView constraints
            scrollView.topAnchor.constraint(equalTo: stateToggleButton.bottomAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            
            // ContainerView constraints - pin to scrollView edges and match width
            containerView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            containerView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            containerView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            containerView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            containerView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
            
        ])
    }
    
    private func setupActions() {
        
        filterView.onFilterTapped = { [weak self] mainFilterType in
            print("Main Filter clicked: \(mainFilterType)")
            self?.openCombinedFilters()
        }
        
        // Toggle button action
        stateToggleButton.addTarget(self, action: #selector(toggleState), for: .touchUpInside)
        
    }
    
    private func openCombinedFilters() {
        
        let configuration = CombinedFiltersDemoViewController.createMockFilterConfiguration()

        let viewModel = CombinedFiltersDemoViewModel(filterSelection: selectedGeneralFilterSelection, filterConfiguration: configuration,
                                                                                       contextId: "sports")
        
        let combinedFiltersViewController = CombinedFiltersDemoViewController( viewModel: viewModel)
        
        combinedFiltersViewController.onApply = { [weak self] combinedGeneralFilterSelection in
            guard let self = self else { return }
            
            self.selectedGeneralFilterSelection = combinedGeneralFilterSelection
            
            let filtersSelected = self.countDifferences(between: generalFilterSelection, and: combinedGeneralFilterSelection)
            
            // Build filter options for collection view
            self.selectedFilterOptions = self.buildFilterOptions(from: combinedGeneralFilterSelection)
            self.filterOptionsCollectionView.reloadData()
            
            if filtersSelected > 0 {
                self.hasSelections = true
                filterView.setFilterState(filterState: .selected(selections: "\(filtersSelected)"))
            }
            else {
                self.hasSelections = false
                filterView.setFilterState(filterState: .notSelected)
            }
        }
        
        self.navigationController?.pushViewController(combinedFiltersViewController, animated: true)
        
    }
    
    func countDifferences(between selection1: GeneralFilterSelection, and selection2: GeneralFilterSelection) -> Int {
        var differenceCount = 0
        
        if selection1.sportId != selection2.sportId {
            differenceCount += 1
        }
        
        if selection1.timeValue != selection2.timeValue {
            differenceCount += 1
        }
        
        if selection1.sortTypeId != selection2.sortTypeId {
            differenceCount += 1
        }
        
        if selection1.leagueId != selection2.leagueId {
            differenceCount += 1
        }
        
        return differenceCount
    }
    
    private func buildFilterOptions(from selection: GeneralFilterSelection) -> [FilterOptionItem] {
        var options: [FilterOptionItem] = []
        
        if let sportOption = getSportOption(for: selection.sportId) {
            options.append(FilterOptionItem(
                type: .sport,
                title: sportOption.title,
                icon: sportOption.icon
            ))
        }
        
        if let sortOption = getSortOption(for: selection.sortTypeId) {
            options.append(FilterOptionItem(
                type: .sortBy,
                title: sortOption.title,
                icon: sortOption.icon ?? ""
            ))
        }
        
        if let leagueOption = getLeagueOption(for: selection.leagueId) {
            options.append(FilterOptionItem(
                type: .league,
                title: leagueOption.title,
                icon: leagueOption.icon ?? ""
            ))
        }
        
        return options
    }
    
    // MARK: - Helper Methods for Filter Data
    private func getSportOption(for sportId: String) -> (title: String, icon: String)? {
        let sportOptions = [
            (id: "1", title: "Football", icon: "soccerball"),
            (id: "2", title: "Basketball", icon: "basketball.fill"),
            (id: "3", title: "Tennis", icon: "tennis.racket"),
            (id: "4", title: "Cricket", icon: "figure.cricket")
        ]
        
        return sportOptions.first { $0.id == sportId }.map { (title: $0.title, icon: $0.icon) }
    }
    
    private func getSortOption(for sortId: String) -> SortOption? {
        // Replicate the same data structure from createSortFilterViewModel
        let sortOptions = [
            SortOption(id: "0", icon: "flame.fill", title: "Popular", count: 25),
            SortOption(id: "1", icon: "clock.fill", title: "Upcoming", count: 15),
            SortOption(id: "2", icon: "heart.fill", title: "Favourites", count: 0)
        ]
        
        return sortOptions.first { $0.id == sortId }
    }

    private func getLeagueOption(for leagueId: String) -> SortOption? {
        // Replicate the same data structure from CombinedFiltersViewModel.getPopularLeagues()
        var allLeaguesOption = SortOption(id: "0", icon: "trophy.fill", title: "All Popular Leagues", count: 0)
        
        let leagueOptions = [
            allLeaguesOption,
            SortOption(id: "1", icon: "trophy.fill", title: "Premier League", count: 32),
            SortOption(id: "16", icon: "trophy.fill", title: "La Liga", count: 28),
            SortOption(id: "10", icon: "trophy.fill", title: "Bundesliga", count: 25),
            SortOption(id: "13", icon: "trophy.fill", title: "Serie A", count: 27),
            SortOption(id: "7", icon: "trophy.fill", title: "Ligue 1", count: 0),
            SortOption(id: "19", icon: "trophy.fill", title: "Champions League", count: 16),
            SortOption(id: "20", icon: "trophy.fill", title: "Europa League", count: 12),
            SortOption(id: "8", icon: "trophy.fill", title: "MLS", count: 28),
            SortOption(id: "28", icon: "trophy.fill", title: "Eredivisie", count: 18),
            SortOption(id: "24", icon: "trophy.fill", title: "Primeira Liga", count: 16)
        ]
        
        return leagueOptions.first { $0.id == leagueId }
    }

    // MARK: - Actions
    @objc private func toggleState() {
                
        // Toggle to opposite state
        let newState: MainFilterStateType = hasSelections ? .notSelected : .selected(selections: "3")
        
        hasSelections = !hasSelections
        
        filterView.setFilterState(filterState: newState)
        
    }
}

// MARK: - UICollectionViewDataSource
extension GeneralFilterViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return selectedFilterOptions.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

        let filterOption = selectedFilterOptions[indexPath.item]
        
        if filterOption.type == .sport {
            // Sport selector cell
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "SportSelectorCell", for: indexPath) as! SportSelectorCell
            
            let cellViewModel = SportSelectorCellViewModel(filterOptionItem: filterOption)
            
            cell.configure(with: cellViewModel)
            
            return cell
            
        } else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "FilterOptionCell", for: indexPath) as! FilterOptionCell
            
            let cellViewModel = FilterOptionCellViewModel(filterOptionItem: filterOption)

            cell.configure(with: cellViewModel)
            
            return cell
        }
    }
}

// MARK: - UICollectionViewDelegate
extension GeneralFilterViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let selectedItem = selectedFilterOptions[indexPath.item]
        
        if selectedItem.type == .sport {
            // Handle sport selector tap
            print("Sport selector tapped: \(selectedItem.title)")
            // You can show a sport selection modal here
        } else {
            // Handle filter option tap
            print("Tapped on filter: \(selectedItem.title)")
        }
    }
}

#if DEBUG
import SwiftUI

@available(iOS 17.0, *)
struct GeneralFilterViewController_Preview: PreviewProvider {
    static var previews: some View {
        PreviewUIViewController {
            let viewController = GeneralFilterViewController()
            let navigationController = UINavigationController(rootViewController: viewController)
            return navigationController
        }
        .previewDisplayName("General Filter View")
    }
}
#endif
