import UIKit
import GomaUI

// MARK: - Categories Table View Controller
class CategoriesTableViewController: UITableViewController {
    
    // MARK: - Properties
    private let searchController = UISearchController()
    private var searchResults: [UIComponent] = []
    private var isSearching = false
    
    private let categories = ComponentCategory.allCases
    
    // MARK: - View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "GomaUI Components"
        setupTableView()
        setupSearchController()
    }
    
    // MARK: - Setup Methods
    private func setupTableView() {
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "CategoryCell")
        tableView.register(ComponentPreviewTableViewCell.self, forCellReuseIdentifier: "SearchResultCell")
        
        tableView.backgroundColor = .systemGroupedBackground
        tableView.separatorStyle = .singleLine
        tableView.separatorInset = UIEdgeInsets(top: 0, left: 60, bottom: 0, right: 0)
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 120
        
        // Add some padding
        tableView.contentInset = UIEdgeInsets(top: 8, left: 0, bottom: 8, right: 0)
    }
    
    private func setupSearchController() {
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search all components..."
        searchController.searchBar.delegate = self
        
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false
        definesPresentationContext = true
    }
    
    // MARK: - Helper Methods
    private func componentCount(for category: ComponentCategory) -> Int {
        return ComponentRegistry.components(for: category).count
    }
}

// MARK: - Table View Data Source
extension CategoriesTableViewController {
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return isSearching ? searchResults.count : categories.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if isSearching {
            return configureSearchResultCell(for: indexPath)
        } else {
            return configureCategoryCell(for: indexPath)
        }
    }
    
    private func configureCategoryCell(for indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CategoryCell", for: indexPath)
        let category = categories[indexPath.row]
        
        // Configure cell appearance
        cell.backgroundColor = .systemBackground
        cell.layer.cornerRadius = 8
        cell.layer.masksToBounds = true
        cell.selectionStyle = .default
        
        // Configure content
        var configuration = cell.defaultContentConfiguration()
        configuration.text = category.rawValue
        configuration.secondaryText = "\(componentCount(for: category)) components"
        
        // Icon
        let iconImage = UIImage(systemName: category.icon)?
            .withConfiguration(UIImage.SymbolConfiguration(pointSize: 24, weight: .medium))
        configuration.image = iconImage
        configuration.imageProperties.tintColor = category.color
        configuration.imageProperties.maximumSize = CGSize(width: 32, height: 32)
        
        // Text styling
        configuration.textProperties.font = .systemFont(ofSize: 17, weight: .medium)
        configuration.secondaryTextProperties.font = .systemFont(ofSize: 15, weight: .regular)
        configuration.secondaryTextProperties.color = .systemGray
        
        cell.contentConfiguration = configuration
        cell.accessoryType = .disclosureIndicator
        
        return cell
    }
    
    private func configureSearchResultCell(for indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SearchResultCell", for: indexPath) as! ComponentPreviewTableViewCell
        let component = searchResults[indexPath.row]
        
        // Create preview instance
        let previewView = component.previewFactory()
        previewView.isUserInteractionEnabled = false
        
        // Configure cell with component and preview
        cell.configure(with: component, previewView: previewView)
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if isSearching {
            return UITableView.automaticDimension
        } else {
            return 60
        }
    }
    
    override func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return isSearching ? 160 : 60
    }
}

// MARK: - Table View Delegate
extension CategoriesTableViewController {
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        if isSearching {
            // Navigate to specific component
            let component = searchResults[indexPath.row]
            let viewController = component.viewController.init()
            viewController.title = component.title
            navigationController?.pushViewController(viewController, animated: true)
        } else {
            // Navigate to category
            let category = categories[indexPath.row]
            let componentsVC = ComponentsTableViewController(category: category)
            componentsVC.title = category.rawValue
            navigationController?.pushViewController(componentsVC, animated: true)
        }
    }
}

// MARK: - Search Results Updating
extension CategoriesTableViewController: UISearchResultsUpdating {
    
    func updateSearchResults(for searchController: UISearchController) {
        guard let searchText = searchController.searchBar.text?.trimmingCharacters(in: .whitespacesAndNewlines) else {
            return
        }
        
        if searchText.isEmpty {
            searchResults.removeAll()
            isSearching = false
        } else {
            isSearching = true
            searchResults = ComponentRegistry.allComponents.filter { component in
                component.title.localizedCaseInsensitiveContains(searchText) ||
                component.description.localizedCaseInsensitiveContains(searchText)
            }
        }
        
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
}

// MARK: - Search Bar Delegate
extension CategoriesTableViewController: UISearchBarDelegate {
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchResults.removeAll()
        isSearching = false
        tableView.reloadData()
    }
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        // Optional: Add any behavior when search begins
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        // Optional: Add any behavior when search ends
    }
}