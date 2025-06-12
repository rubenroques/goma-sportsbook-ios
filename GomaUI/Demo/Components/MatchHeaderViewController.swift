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
    private lazy var stateSegmentedControl = UISegmentedControl(items: ["Standard", "Disabled", "Favorite Only", "Minimal"])
    private lazy var favoriteToggleButton = UIButton(type: .system)
    private lazy var competitionNameTextField = UITextField()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        setupComponents()
        setupControls()
        setupBindings()
    }

    private func setupViews() {
        view.backgroundColor = StyleProvider.Color.backgroundColor
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
        controlsContainer.backgroundColor = StyleProvider.Color.toolbarBackgroundColor.withAlphaComponent(0.1)
        controlsContainer.layer.cornerRadius = 8

        controlsStackView.axis = .vertical
        controlsStackView.spacing = 12
        controlsStackView.translatesAutoresizingMaskIntoConstraints = false
        controlsContainer.addSubview(controlsStackView)

        // State control
        let stateLabel = UILabel()
        stateLabel.text = "Visual State:"
        stateLabel.font = StyleProvider.fontWith(type: .medium, size: 14)
        stateLabel.textColor = StyleProvider.Color.textColor

        stateSegmentedControl.selectedSegmentIndex = 0
        stateSegmentedControl.addTarget(self, action: #selector(stateChanged), for: .valueChanged)

        // Favorite toggle
        favoriteToggleButton.setTitle("Toggle Favorite (First Item)", for: .normal)
        favoriteToggleButton.backgroundColor = StyleProvider.Color.primaryColor
        favoriteToggleButton.setTitleColor(.white, for: .normal)
        favoriteToggleButton.layer.cornerRadius = 8
        favoriteToggleButton.contentEdgeInsets = UIEdgeInsets(top: 12, left: 16, bottom: 12, right: 16)
        favoriteToggleButton.addTarget(self, action: #selector(toggleFavorite), for: .touchUpInside)

        // Competition name field
        let nameLabel = UILabel()
        nameLabel.text = "Competition Name (First Item):"
        nameLabel.font = StyleProvider.fontWith(type: .medium, size: 14)
        nameLabel.textColor = StyleProvider.Color.textColor

        competitionNameTextField.text = "Premier League"
        competitionNameTextField.borderStyle = .roundedRect
        competitionNameTextField.font = StyleProvider.fontWith(type: .regular, size: 14)
        competitionNameTextField.addTarget(self, action: #selector(nameChanged), for: .editingChanged)

        controlsStackView.addArrangedSubview(stateLabel)
        controlsStackView.addArrangedSubview(stateSegmentedControl)
        controlsStackView.addArrangedSubview(favoriteToggleButton)
        controlsStackView.addArrangedSubview(nameLabel)
        controlsStackView.addArrangedSubview(competitionNameTextField)

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
            ("Basic Header (No Icons)", MockMatchHeaderViewModel.basicHeader)
        ]

        for (title, viewModel) in demoComponents {
            viewModels.append(viewModel)

            let componentContainer = createComponentContainer(title: title, viewModel: viewModel)
            stackView.addArrangedSubview(componentContainer)
        }
    }

    private func createComponentContainer(title: String, viewModel: MockMatchHeaderViewModel) -> UIView {
        let container = UIView()
        container.backgroundColor = StyleProvider.Color.backgroundColor
        container.layer.cornerRadius = 8
        container.layer.borderWidth = 1
        container.layer.borderColor = StyleProvider.Color.secondaryColor.withAlphaComponent(0.3).cgColor

        let titleLabel = UILabel()
        titleLabel.text = title
        titleLabel.font = StyleProvider.fontWith(type: .medium, size: 16)
        titleLabel.textColor = StyleProvider.Color.textColor

        let headerView = MatchHeaderView(viewModel: viewModel)
        headerView.backgroundColor = StyleProvider.Color.backgroundColor.withAlphaComponent(0.8)
        headerView.layer.cornerRadius = 4

        let infoLabel = UILabel()
        infoLabel.numberOfLines = 0
        infoLabel.font = StyleProvider.fontWith(type: .regular, size: 12)
        infoLabel.textColor = StyleProvider.Color.secondaryColor

        // Set info text based on visual state
        updateInfoLabel(infoLabel, for: viewModel.currentVisualState)

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

    private func updateInfoLabel(_ label: UILabel, for state: MatchHeaderVisualState) {
        switch state {
        case .standard:
            label.text = "State: Standard - All elements visible and interactive"
        case .disabled:
            label.text = "State: Disabled - Reduced opacity, no interactions"
        case .favoriteOnly:
            label.text = "State: Favorite Only - Only favorite icon and name visible"
        case .minimal:
            label.text = "State: Minimal - Only competition name visible"
        }
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

    @objc private func stateChanged() {
        let selectedState: MatchHeaderVisualState

        switch stateSegmentedControl.selectedSegmentIndex {
        case 0:
            selectedState = .standard
        case 1:
            selectedState = .disabled
        case 2:
            selectedState = .favoriteOnly
        case 3:
            selectedState = .minimal
        default:
            selectedState = .standard
        }

        // Apply to all view models
        for viewModel in viewModels {
            viewModel.setVisualState(selectedState)
        }
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
}

// MARK: - Preview Support
@available(iOS 17.0, *)
#Preview("MatchHeaderViewController") {
    let navController = UINavigationController(rootViewController: MatchHeaderViewController())
    navController.navigationBar.prefersLargeTitles = false
    return navController
}