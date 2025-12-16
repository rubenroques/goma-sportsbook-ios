import UIKit
import GomaUI
import Combine

class ProfileMenuListViewController: UIViewController {
    
    // MARK: Private properties
    private lazy var scrollView: UIScrollView = Self.createScrollView()
    private lazy var contentView: UIView = Self.createContentView()
    private lazy var titleLabel: UILabel = Self.createTitleLabel()
    private lazy var descriptionLabel: UILabel = Self.createDescriptionLabel()
    private lazy var profileMenuView: ProfileMenuListView = Self.createProfileMenuView()
    private lazy var segmentedControl: UISegmentedControl = Self.createSegmentedControl()
    private lazy var languageLabel: UILabel = Self.createLanguageLabel()
    private lazy var actionLogTextView: UITextView = Self.createActionLogTextView()
    
    // MARK: ViewModel
    private let viewModel = MockProfileMenuListViewModel.interactiveMock
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        setupBindings()
        setupActions()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupWithTheme()
    }
    
    // MARK: - Setup
    private func setupView() {
        title = "Profile Menu List"
        setupSubviews()
    }
    
    private func setupWithTheme() {
        view.backgroundColor = StyleProvider.Color.backgroundTertiary
        titleLabel.textColor = StyleProvider.Color.textPrimary
        descriptionLabel.textColor = StyleProvider.Color.textSecondary
        languageLabel.textColor = StyleProvider.Color.textPrimary
        actionLogTextView.backgroundColor = StyleProvider.Color.backgroundSecondary
        actionLogTextView.textColor = StyleProvider.Color.textPrimary
    }
    
    private func setupBindings() {
        viewModel.currentLanguagePublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] language in
                self?.languageLabel.text = "Current Language: \(language)"
            }
            .store(in: &cancellables)
    }
    
    private func setupActions() {
        segmentedControl.addTarget(self, action: #selector(segmentChanged), for: .valueChanged)
    }
    
    @objc private func segmentChanged() {
        switch segmentedControl.selectedSegmentIndex {
        case 0:
            // Default configuration
            viewModel.loadConfiguration(from: nil)
            logAction("Loaded default configuration")
            
        case 1:
            // JSON configuration
            viewModel.loadConfiguration(from: "ProfileMenuConfiguration")
            logAction("Loaded JSON configuration")
            
        case 2:
            // French preset
            viewModel.updateCurrentLanguage("Français")
            logAction("Switched to French language")
            
        default:
            break
        }
    }
    
    private func logAction(_ message: String) {
        let timestamp = DateFormatter.localizedString(from: Date(), dateStyle: .none, timeStyle: .medium)
        let logEntry = "[\(timestamp)] \(message)\n"
        actionLogTextView.text = logEntry + actionLogTextView.text
    }
}

// MARK: - Subviews Initialization and Setup
extension ProfileMenuListViewController {
    
    private static func createScrollView() -> UIScrollView {
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.showsVerticalScrollIndicator = true
        scrollView.showsHorizontalScrollIndicator = false
        return scrollView
    }
    
    private static func createContentView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }
    
    private static func createTitleLabel() -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Profile Menu List Component"
        label.font = StyleProvider.fontWith(type: .bold, size: 20)
        label.numberOfLines = 0
        return label
    }
    
    private static func createDescriptionLabel() -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Interactive profile menu with multiple item types: navigation, actions, and selections. Tap items to see different behaviors."
        label.font = StyleProvider.fontWith(type: .regular, size: 14)
        label.numberOfLines = 0
        return label
    }
    
    private static func createProfileMenuView() -> ProfileMenuListView {
        let viewModel = MockProfileMenuListViewModel { item in
            print("🎯 Demo: Selected \(item.title) - \(item.action)")
        }
        return ProfileMenuListView(viewModel: viewModel)
    }
    
    private static func createSegmentedControl() -> UISegmentedControl {
        let control = UISegmentedControl(items: ["Default", "JSON Config", "French"])
        control.translatesAutoresizingMaskIntoConstraints = false
        control.selectedSegmentIndex = 0
        return control
    }
    
    private static func createLanguageLabel() -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Current Language: English"
        label.font = StyleProvider.fontWith(type: .semibold, size: 14)
        label.numberOfLines = 1
        return label
    }
    
    private static func createActionLogTextView() -> UITextView {
        let textView = UITextView()
        textView.translatesAutoresizingMaskIntoConstraints = false
        textView.font = StyleProvider.fontWith(type: .regular, size: 12)
        textView.isEditable = false
        textView.layer.cornerRadius = 8
        textView.text = "Action log will appear here...\n"
        return textView
    }
    
    private func setupSubviews() {
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        
        contentView.addSubview(titleLabel)
        contentView.addSubview(descriptionLabel)
        contentView.addSubview(segmentedControl)
        contentView.addSubview(languageLabel)
        contentView.addSubview(profileMenuView)
        contentView.addSubview(actionLogTextView)
        
        // Recreate profile menu with the actual viewModel
        profileMenuView.removeFromSuperview()
        profileMenuView = ProfileMenuListView(viewModel: viewModel)
        profileMenuView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(profileMenuView)
        
        initConstraints()
    }
    
    private func initConstraints() {
        NSLayoutConstraint.activate([
            // ScrollView
            scrollView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            
            // ContentView
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
            
            // Title
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 20),
            
            // Description
            descriptionLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            descriptionLabel.trailingAnchor.constraint(equalTo: titleLabel.trailingAnchor),
            descriptionLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8),
            
            // Segmented Control
            segmentedControl.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            segmentedControl.trailingAnchor.constraint(equalTo: titleLabel.trailingAnchor),
            segmentedControl.topAnchor.constraint(equalTo: descriptionLabel.bottomAnchor, constant: 16),
            
            // Language Label
            languageLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            languageLabel.trailingAnchor.constraint(equalTo: titleLabel.trailingAnchor),
            languageLabel.topAnchor.constraint(equalTo: segmentedControl.bottomAnchor, constant: 16),
            
            // Profile Menu
            profileMenuView.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            profileMenuView.trailingAnchor.constraint(equalTo: titleLabel.trailingAnchor),
            profileMenuView.topAnchor.constraint(equalTo: languageLabel.bottomAnchor, constant: 16),
            
            // Action Log
            actionLogTextView.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            actionLogTextView.trailingAnchor.constraint(equalTo: titleLabel.trailingAnchor),
            actionLogTextView.topAnchor.constraint(equalTo: profileMenuView.bottomAnchor, constant: 16),
            actionLogTextView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -20),
            actionLogTextView.heightAnchor.constraint(equalToConstant: 120)
        ])
    }
}
