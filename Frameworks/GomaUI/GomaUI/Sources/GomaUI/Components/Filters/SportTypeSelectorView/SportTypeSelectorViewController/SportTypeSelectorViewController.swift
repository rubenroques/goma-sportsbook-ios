import UIKit
import Combine

final public class SportTypeSelectorViewController: UIViewController {
    
    // MARK: - Properties
    private let viewModel: SportTypeSelectorViewModelProtocol
    private var sportSelectorView: SportTypeSelectorView!
    
    // MARK: - Public Properties
    public var onSportSelected: ((SportTypeData) -> Void) = { _ in }
    public var onCancel: (() -> Void) = { }
    
    // MARK: - Initialization
    public init(viewModel: SportTypeSelectorViewModelProtocol) {
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
        setupSportSelectorView()
    }
    
    // MARK: - Setup
    private func setupNavigationBar() {
        title = LocalizationProvider.string("select_sport")
        view.backgroundColor = StyleProvider.Color.backgroundSecondary
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .cancel,
            target: self,
            action: #selector(cancelButtonTapped)
        )
        
        // Style navigation bar
        navigationController?.navigationBar.titleTextAttributes = [
            .foregroundColor: StyleProvider.Color.textPrimary
        ]
        navigationController?.navigationBar.tintColor = StyleProvider.Color.textPrimary
        navigationController?.navigationBar.backgroundColor = StyleProvider.Color.backgroundSecondary
    }
    
    private func setupSportSelectorView() {
        sportSelectorView = SportTypeSelectorView(viewModel: viewModel)
        sportSelectorView.translatesAutoresizingMaskIntoConstraints = false
        
        sportSelectorView.onSportSelected = { [weak self] sport in
            guard let self = self else { return }
            self.sportSelected(sport: sport)
        }
        
        
        view.addSubview(sportSelectorView)
        
        NSLayoutConstraint.activate([
            sportSelectorView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            sportSelectorView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            sportSelectorView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            sportSelectorView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    // MARK: - Actions
    @objc private func cancelButtonTapped() {
        self.onCancel()
    }
    
    private func sportSelected(sport: SportTypeData) {
        self.viewModel.selectSport(sport)
        self.onSportSelected(sport)
    }
    
    // MARK: - Public Methods
    public func presentModally(from parentViewController: UIViewController, animated: Bool = true) {
        let navigationController = UINavigationController(rootViewController: self)
        navigationController.modalPresentationStyle = .pageSheet
        parentViewController.present(navigationController, animated: animated)
    }
    
    public override func dismiss(animated: Bool = true, completion: (() -> Void)? = nil) {
        if let navigationController = navigationController {
            navigationController.dismiss(animated: animated, completion: completion)
        } else {
            super.dismiss(animated: animated, completion: completion)
        }
    }
}

// MARK: - Factory Methods
extension SportTypeSelectorViewController {
    public static func create(with viewModel: SportTypeSelectorViewModelProtocol) -> SportTypeSelectorViewController {
        return SportTypeSelectorViewController(viewModel: viewModel)
    }
    
    public static func createWithMockData() -> SportTypeSelectorViewController {
        let mockViewModel = MockSportTypeSelectorViewModel.defaultMock
        return SportTypeSelectorViewController(viewModel: mockViewModel)
    }
}
