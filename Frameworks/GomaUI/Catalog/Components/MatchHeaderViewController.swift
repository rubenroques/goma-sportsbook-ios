import UIKit
import GomaUI
import Combine

class MatchHeaderViewController: UIViewController {

    private let scrollView = UIScrollView()
    private let stackView = UIStackView()
    private var viewModels: [MockMatchHeaderViewModel] = []
    private var cancellables = Set<AnyCancellable>()

    // Control section
    private lazy var controlsStackView = UIStackView()
    private lazy var stateSegmentedControl = UISegmentedControl(items: ["Standard"])
    private lazy var favoriteToggleButton = UIButton(type: .system)
    private lazy var competitionNameTextField = UITextField()
    
    // Visibility controls
    private lazy var countryFlagToggleButton = UIButton(type: .system)
    private lazy var sportIconToggleButton = UIButton(type: .system)
    private lazy var favoriteButtonToggleButton = UIButton(type: .system)
    
    // Track visibility state for first item
    private var isCountryFlagVisible = true
    private var isSportIconVisible = true
    private var isFavoriteButtonVisible = true

    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        setupComponents()
        setupControls()
        setupBindings()
    }

    private func setupViews() {
        view.backgroundColor = StyleProvider.Color.backgroundPrimary
        title = "Match Header View"

        // Setup scroll view
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scrollView)

        // Setup stack view
        stackView.axis = .vertical
        stackView.spacing = 24
        stackView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(stackView)

        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            stackView.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: 16),
            stackView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: 16),
            stackView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor, constant: -16),
            stackView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor, constant: -16),
            stackView.widthAnchor.constraint(equalTo: scrollView.widthAnchor, constant: -32)
        ])
    }

    private func setupControls() {
        // Controls container
        let controlsContainer = UIView()
        controlsContainer.backgroundColor = StyleProvider.Color.highlightPrimary.withAlphaComponent(0.1)
        controlsContainer.layer.cornerRadius = 8

        controlsStackView.axis = .vertical
        controlsStackView.spacing = 12
        controlsStackView.translatesAutoresizingMaskIntoConstraints = false
        controlsContainer.addSubview(controlsStackView)

        // State control
        let stateLabel = UILabel()
        stateLabel.text = "Visual State:"
        stateLabel.font = StyleProvider.fontWith(type: .medium, size: 14)
        stateLabel.textColor = StyleProvider.Color.textPrimary

        stateSegmentedControl.selectedSegmentIndex = 0

        // Favorite toggle
        favoriteToggleButton.setTitle("Toggle Favorite (First Item)", for: .normal)
        favoriteToggleButton.backgroundColor = StyleProvider.Color.highlightPrimary
        favoriteToggleButton.setTitleColor(.white, for: .normal)
        favoriteToggleButton.layer.cornerRadius = 8
        favoriteToggleButton.contentEdgeInsets = UIEdgeInsets(top: 12, left: 16, bottom: 12, right: 16)
        favoriteToggleButton.addTarget(self, action: #selector(toggleFavorite), for: .touchUpInside)

        // Competition name field
        let nameLabel = UILabel()
        nameLabel.text = "Competition Name (First Item):"
        nameLabel.font = StyleProvider.fontWith(type: .medium, size: 14)
        nameLabel.textColor = StyleProvider.Color.textPrimary

        competitionNameTextField.text = "Premier League"
        competitionNameTextField.borderStyle = .roundedRect
        competitionNameTextField.font = StyleProvider.fontWith(type: .regular, size: 14)
        competitionNameTextField.addTarget(self, action: #selector(nameChanged), for: .editingChanged)

        // Visibility toggle buttons
        countryFlagToggleButton.setTitle("Hide Country Flag (First Item)", for: .normal)
        countryFlagToggleButton.backgroundColor = StyleProvider.Color.highlightSecondary
        countryFlagToggleButton.setTitleColor(.white, for: .normal)
        countryFlagToggleButton.layer.cornerRadius = 8
        countryFlagToggleButton.contentEdgeInsets = UIEdgeInsets(top: 12, left: 16, bottom: 12, right: 16)
        countryFlagToggleButton.addTarget(self, action: #selector(toggleCountryFlag), for: .touchUpInside)

        sportIconToggleButton.setTitle("Hide Sport Icon (First Item)", for: .normal)
        sportIconToggleButton.backgroundColor = StyleProvider.Color.highlightSecondary
        sportIconToggleButton.setTitleColor(.white, for: .normal)
        sportIconToggleButton.layer.cornerRadius = 8
        sportIconToggleButton.contentEdgeInsets = UIEdgeInsets(top: 12, left: 16, bottom: 12, right: 16)
        sportIconToggleButton.addTarget(self, action: #selector(toggleSportIcon), for: .touchUpInside)

        favoriteButtonToggleButton.setTitle("Hide Favorite Button (First Item)", for: .normal)
        favoriteButtonToggleButton.backgroundColor = StyleProvider.Color.highlightSecondary
        favoriteButtonToggleButton.setTitleColor(.white, for: .normal)
        favoriteButtonToggleButton.layer.cornerRadius = 8
        favoriteButtonToggleButton.contentEdgeInsets = UIEdgeInsets(top: 12, left: 16, bottom: 12, right: 16)
        favoriteButtonToggleButton.addTarget(self, action: #selector(toggleFavoriteButton), for: .touchUpInside)

        controlsStackView.addArrangedSubview(stateLabel)
        controlsStackView.addArrangedSubview(stateSegmentedControl)
        controlsStackView.addArrangedSubview(favoriteToggleButton)
        controlsStackView.addArrangedSubview(nameLabel)
        controlsStackView.addArrangedSubview(competitionNameTextField)
        
        // Add visibility controls
        controlsStackView.addArrangedSubview(countryFlagToggleButton)
        controlsStackView.addArrangedSubview(sportIconToggleButton)
        controlsStackView.addArrangedSubview(favoriteButtonToggleButton)

        NSLayoutConstraint.activate([
            controlsStackView.topAnchor.constraint(equalTo: controlsContainer.topAnchor, constant: 16),
            controlsStackView.leadingAnchor.constraint(equalTo: controlsContainer.leadingAnchor, constant: 16),
            controlsStackView.trailingAnchor.constraint(equalTo: controlsContainer.trailingAnchor, constant: -16),
            controlsStackView.bottomAnchor.constraint(equalTo: controlsContainer.bottomAnchor, constant: -16)
        ])

        stackView.addArrangedSubview(controlsContainer)
    }

    private func setupComponents() {
        // Create all demo components
        let demoComponents = [
            ("Premier League", MockMatchHeaderViewModel.premierLeagueHeader),
            ("La Liga (Favorited)", MockMatchHeaderViewModel.laLigaFavoriteHeader),
            ("Serie A Basketball", MockMatchHeaderViewModel.serieABasketballHeader),
            ("NBA (Disabled)", MockMatchHeaderViewModel.disabledNBAHeader),
            ("Champions League (Minimal)", MockMatchHeaderViewModel.minimalModeHeader),
            ("ATP Tennis (Favorite Only)", MockMatchHeaderViewModel.favoriteOnlyHeader),
            ("Long Competition Name", MockMatchHeaderViewModel.longNameHeader),
            ("Basic Header (No Icons)", MockMatchHeaderViewModel.basicHeader),
            
            // New visibility examples
            ("No Country Flag", MockMatchHeaderViewModel.noCountryFlagHeader),
            ("No Sport Icon", MockMatchHeaderViewModel.noSportIconHeader),
            ("No Favorite Button", MockMatchHeaderViewModel.noFavoriteButtonHeader),
            ("Text Only (All Hidden)", MockMatchHeaderViewModel.minimalVisibilityHeader)
        ]

        for (title, viewModel) in demoComponents {
            viewModels.append(viewModel)

            let componentContainer = createComponentContainer(title: title, viewModel: viewModel)
            stackView.addArrangedSubview(componentContainer)
        }
    }

    private func createComponentContainer(title: String, viewModel: MockMatchHeaderViewModel) -> UIView {
        let container = UIView()
        container.backgroundColor = StyleProvider.Color.backgroundPrimary
        container.layer.cornerRadius = 8
        container.layer.borderWidth = 1
        container.layer.borderColor = StyleProvider.Color.highlightSecondary.withAlphaComponent(0.3).cgColor

        let titleLabel = UILabel()
        titleLabel.text = title
        titleLabel.font = StyleProvider.fontWith(type: .medium, size: 16)
        titleLabel.textColor = StyleProvider.Color.textPrimary

        let headerView = MatchHeaderView(viewModel: viewModel)
        headerView.backgroundColor = StyleProvider.Color.backgroundPrimary.withAlphaComponent(0.8)
        headerView.layer.cornerRadius = 4

        let infoLabel = UILabel()
        infoLabel.numberOfLines = 0
        infoLabel.font = StyleProvider.fontWith(type: .regular, size: 12)
        infoLabel.textColor = StyleProvider.Color.highlightSecondary

        let stackView = UIStackView(arrangedSubviews: [titleLabel, headerView, infoLabel])
        stackView.axis = .vertical
        stackView.spacing = 8
        stackView.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(stackView)

        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: container.topAnchor, constant: 16),
            stackView.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 16),
            stackView.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -16),
            stackView.bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: -16)
        ])

        return container
    }

    private func setupBindings() {
        // Setup favorite toggle callbacks for demonstration
        for (index, viewModel) in viewModels.enumerated() {
            viewModel.favoriteToggleCallback = { [weak self] isFavorite in
                print("ViewModel \(index) favorite toggled: \(isFavorite)")
                DispatchQueue.main.async {
                    self?.showFavoriteAlert(for: index, isFavorite: isFavorite)
                }
            }
        }
    }

    private func showFavoriteAlert(for index: Int, isFavorite: Bool) {
        let title = isFavorite ? "Added to Favorites" : "Removed from Favorites"
        let message = "Competition at position \(index + 1) has been \(isFavorite ? "favorited" : "unfavorited")"

        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }

    @objc private func toggleFavorite() {
        // Toggle the first view model
        if let firstViewModel = viewModels.first {
            firstViewModel.toggleFavorite()
        }
    }

    @objc private func nameChanged() {
        // Update the first view model's competition name
        if let firstViewModel = viewModels.first,
           let newName = competitionNameTextField.text {
            firstViewModel.updateCompetitionName(newName)
        }
    }
    
    @objc private func toggleCountryFlag() {
        // Toggle the first view model's country flag visibility
        if let firstViewModel = viewModels.first {
            isCountryFlagVisible.toggle()
            firstViewModel.setCountryFlagVisible(isCountryFlagVisible)
            let newTitle = isCountryFlagVisible ? "Hide Country Flag (First Item)" : "Show Country Flag (First Item)"
            countryFlagToggleButton.setTitle(newTitle, for: .normal)
        }
    }
    
    @objc private func toggleSportIcon() {
        // Toggle the first view model's sport icon visibility
        if let firstViewModel = viewModels.first {
            isSportIconVisible.toggle()
            firstViewModel.setSportIconVisible(isSportIconVisible)
            let newTitle = isSportIconVisible ? "Hide Sport Icon (First Item)" : "Show Sport Icon (First Item)"
            sportIconToggleButton.setTitle(newTitle, for: .normal)
        }
    }
    
    @objc private func toggleFavoriteButton() {
        // Toggle the first view model's favorite button visibility
        if let firstViewModel = viewModels.first {
            isFavoriteButtonVisible.toggle()
            firstViewModel.setFavoriteButtonVisible(isFavoriteButtonVisible)
            let newTitle = isFavoriteButtonVisible ? "Hide Favorite Button (First Item)" : "Show Favorite Button (First Item)"
            favoriteButtonToggleButton.setTitle(newTitle, for: .normal)
        }
    }
}

// MARK: - Preview Support
@available(iOS 17.0, *)
#Preview("MatchHeaderViewController") {
    let navController = UINavigationController(rootViewController: MatchHeaderViewController())
    navController.navigationBar.prefersLargeTitles = false
    return navController
}
