import UIKit
import GomaUI
import Combine

class LanguageSelectorViewController: UIViewController {
    
    // MARK: Private properties
    private lazy var scrollView: UIScrollView = Self.createScrollView()
    private lazy var contentView: UIView = Self.createContentView()
    private lazy var titleLabel: UILabel = Self.createTitleLabel()
    private lazy var descriptionLabel: UILabel = Self.createDescriptionLabel()
    private lazy var languageSelectorView: LanguageSelectorView = Self.createLanguageSelectorView()
    private lazy var segmentedControl: UISegmentedControl = Self.createSegmentedControl()
    private lazy var currentSelectionLabel: UILabel = Self.createCurrentSelectionLabel()
    private lazy var actionLogTextView: UITextView = Self.createActionLogTextView()
    
    // MARK: ViewModel and Properties
    private var viewModel: MockLanguageSelectorViewModel!
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViewModel()
        setupView()
        setupBindings()
        setupActions()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupWithTheme()
    }
    
    // MARK: - Setup
    private func setupViewModel() {
        viewModel = MockLanguageSelectorViewModel.interactiveMock
        
        // Recreate the language selector with the interactive model
        languageSelectorView.removeFromSuperview()
        languageSelectorView = LanguageSelectorView(viewModel: viewModel)
        languageSelectorView.translatesAutoresizingMaskIntoConstraints = false
    }
    
    private func setupView() {
        title = "Language Selector"
        setupSubviews()
    }
    
    private func setupWithTheme() {
        view.backgroundColor = StyleProvider.Color.backgroundTertiary
        titleLabel.textColor = StyleProvider.Color.textPrimary
        descriptionLabel.textColor = StyleProvider.Color.textSecondary
        currentSelectionLabel.textColor = StyleProvider.Color.textPrimary
        actionLogTextView.backgroundColor = StyleProvider.Color.backgroundSecondary
        actionLogTextView.textColor = StyleProvider.Color.textPrimary
    }
    
    private func setupBindings() {
        // Bind to language selection changes
        viewModel.selectedLanguagePublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] selectedLanguage in
                if let language = selectedLanguage {
                    self?.currentSelectionLabel.text = "Current Selection: \(language.displayName)"
                } else {
                    self?.currentSelectionLabel.text = "No language selected"
                }
            }
            .store(in: &cancellables)
        
        // Bind to language change events for logging
        viewModel.languageChangedPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] changedLanguage in
                self?.logAction("Language changed to: \(changedLanguage.displayName)")
            }
            .store(in: &cancellables)
    }
    
    private func setupActions() {
        segmentedControl.addTarget(self, action: #selector(segmentChanged), for: .valueChanged)
    }
    
    @objc private func segmentChanged() {
        switch segmentedControl.selectedSegmentIndex {
        case 0:
            // Two languages (like Figma)
            switchToViewModel(MockLanguageSelectorViewModel.twoLanguagesMock)
            logAction("Switched to Two Languages configuration")
            
        case 1:
            // Default languages
            switchToViewModel(MockLanguageSelectorViewModel.defaultMock)
            logAction("Switched to Default Languages configuration")
            
        case 2:
            // Many languages
            switchToViewModel(MockLanguageSelectorViewModel.manyLanguagesMock)
            logAction("Switched to Many Languages configuration")
            
        default:
            break
        }
    }
    
    private func switchToViewModel(_ newViewModel: MockLanguageSelectorViewModel) {
        // Update view model
        viewModel = newViewModel
        
        // Remove old language selector
        languageSelectorView.removeFromSuperview()
        
        // Create new language selector with new view model
        languageSelectorView = LanguageSelectorView(viewModel: viewModel)
        languageSelectorView.translatesAutoresizingMaskIntoConstraints = false
        
        // Add to content view
        contentView.addSubview(languageSelectorView)
        
        // Re-setup constraints
        setupLanguageSelectorConstraints()
        
        // Re-setup bindings for new view model
        setupBindings()
    }
    
    private func logAction(_ message: String) {
        let timestamp = DateFormatter.localizedString(from: Date(), dateStyle: .none, timeStyle: .medium)
        let logEntry = "[\(timestamp)] \(message)\n"
        actionLogTextView.text = logEntry + actionLogTextView.text
    }
}

// MARK: - Subviews Initialization and Setup
extension LanguageSelectorViewController {
    
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
        label.text = "Language Selector Component"
        label.font = StyleProvider.fontWith(type: .bold, size: 20)
        label.numberOfLines = 0
        return label
    }
    
    private static func createDescriptionLabel() -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Single-selection language picker with radio buttons and flag icons. Only one language can be selected at a time."
        label.font = StyleProvider.fontWith(type: .regular, size: 14)
        label.numberOfLines = 0
        return label
    }
    
    private static func createLanguageSelectorView() -> LanguageSelectorView {
        // Initial creation with a default mock - will be replaced in setupViewModel
        let viewModel = MockLanguageSelectorViewModel.defaultMock
        return LanguageSelectorView(viewModel: viewModel)
    }
    
    private static func createSegmentedControl() -> UISegmentedControl {
        let control = UISegmentedControl(items: ["Two Languages", "Default", "Many Languages"])
        control.translatesAutoresizingMaskIntoConstraints = false
        control.selectedSegmentIndex = 1 // Default
        return control
    }
    
    private static func createCurrentSelectionLabel() -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Current Selection: English"
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
        textView.text = "Language selection log will appear here...\n"
        return textView
    }
    
    private func setupSubviews() {
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        
        contentView.addSubview(titleLabel)
        contentView.addSubview(descriptionLabel)
        contentView.addSubview(segmentedControl)
        contentView.addSubview(currentSelectionLabel)
        contentView.addSubview(languageSelectorView)
        contentView.addSubview(actionLogTextView)
        
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
            
            // Current Selection Label
            currentSelectionLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            currentSelectionLabel.trailingAnchor.constraint(equalTo: titleLabel.trailingAnchor),
            currentSelectionLabel.topAnchor.constraint(equalTo: segmentedControl.bottomAnchor, constant: 16),
            
            // Action Log
            actionLogTextView.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            actionLogTextView.trailingAnchor.constraint(equalTo: titleLabel.trailingAnchor),
            actionLogTextView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -20),
            actionLogTextView.heightAnchor.constraint(equalToConstant: 120)
        ])
        
        setupLanguageSelectorConstraints()
    }
    
    private func setupLanguageSelectorConstraints() {
        NSLayoutConstraint.activate([
            // Language Selector
            languageSelectorView.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            languageSelectorView.trailingAnchor.constraint(equalTo: titleLabel.trailingAnchor),
            languageSelectorView.topAnchor.constraint(equalTo: currentSelectionLabel.bottomAnchor, constant: 16),
            languageSelectorView.bottomAnchor.constraint(lessThanOrEqualTo: actionLogTextView.topAnchor, constant: -16)
        ])
    }
}
