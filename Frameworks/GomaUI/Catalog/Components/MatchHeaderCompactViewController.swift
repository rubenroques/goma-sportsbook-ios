import UIKit
import GomaUI

class MatchHeaderCompactViewController: UIViewController {
    
    // MARK: - UI Components
    private let scrollView = UIScrollView()
    private let contentView = UIView()
    private let stackView = UIStackView()
    
    // MARK: - View Models
    private let defaultViewModel = MockMatchHeaderCompactViewModel.default
    private let liveFootballViewModel = MockMatchHeaderCompactViewModel.liveFootballMatch
    private let longNamesViewModel = MockMatchHeaderCompactViewModel.longNames
    private let longContentViewModel = MockMatchHeaderCompactViewModel.longContent
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupCallbacks()
    }
    
    // MARK: - Setup
    private func setupUI() {
        title = "Match Header Compact"
        view.backgroundColor = StyleProvider.Color.backgroundPrimary
        
        // Setup scroll view
        view.addSubview(scrollView)
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        
        scrollView.addSubview(contentView)
        contentView.translatesAutoresizingMaskIntoConstraints = false
        
        contentView.addSubview(stackView)
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.spacing = 24
        stackView.alignment = .fill
        
        // Add section headers and components
        addSection(title: "Default", viewModel: defaultViewModel)
        addSection(title: "Live Football Match", viewModel: liveFootballViewModel)
        addSection(title: "Long Team Names", viewModel: longNamesViewModel)
        addSection(title: "Long Content", viewModel: longContentViewModel)
        
        // Setup constraints
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
            
            stackView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 16),
            stackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            stackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            stackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -16)
        ])
    }
    
    private func addSection(title: String, viewModel: MockMatchHeaderCompactViewModel) {
        // Section title
        let titleLabel = UILabel()
        titleLabel.text = title
        titleLabel.font = StyleProvider.fontWith(type: .bold, size: 18)
        titleLabel.textColor = StyleProvider.Color.textPrimary
        stackView.addArrangedSubview(titleLabel)
        
        // Component container
        let containerView = UIView()
        containerView.backgroundColor = StyleProvider.Color.backgroundCards
        containerView.layer.cornerRadius = 8
        containerView.layer.shadowColor = StyleProvider.Color.shadow.cgColor
        containerView.layer.shadowOffset = CGSize(width: 0, height: 2)
        containerView.layer.shadowRadius = 4
        containerView.layer.shadowOpacity = 0.1
        
        // Create component
        let headerView = MatchHeaderCompactView(viewModel: viewModel)
        containerView.addSubview(headerView)
        headerView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            headerView.topAnchor.constraint(equalTo: containerView.topAnchor),
            headerView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            headerView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            headerView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor),
            headerView.heightAnchor.constraint(equalToConstant: 68)
        ])
        
        stackView.addArrangedSubview(containerView)
    }
    
    private func setupCallbacks() {
        // Setup callbacks for all view models
        let viewModels = [defaultViewModel, liveFootballViewModel, longNamesViewModel, longContentViewModel]

        for viewModel in viewModels {
            viewModel.onCountryTapped = { [weak self] countryId in
                self?.showAlert(title: "Country Tapped", message: "Country ID: \(countryId)")
            }
            viewModel.onLeagueTapped = { [weak self] leagueId in
                self?.showAlert(title: "League Tapped", message: "League ID: \(leagueId)")
            }
        }
    }
    
    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}