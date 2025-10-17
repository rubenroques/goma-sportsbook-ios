import UIKit
import Combine
import SwiftUI

/// Main container view for language selection with radio button behavior
public final class LanguageSelectorView: UIView {
    
    // MARK: Private properties
    private lazy var containerView: UIView = Self.createContainerView()
    private lazy var stackView: UIStackView = Self.createStackView()
    
    // MARK: - Properties
    private let viewModel: LanguageSelectorViewModelProtocol
    private var cancellables = Set<AnyCancellable>()
    private var languageItemViews: [(view: LanguageItemView, language: LanguageModel)] = []
    private var currentLanguages: [LanguageModel] = []
    
    // MARK: - Lifetime and Cycle
    public init(viewModel: LanguageSelectorViewModelProtocol) {
        self.viewModel = viewModel
        super.init(frame: .zero)
        commonInit()
        setupWithTheme()
        setupBindings()
    }
    
    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented - use init(viewModel:) instead")
    }
    
    func commonInit() {
        setupSubviews()
        
        // Load languages initially
        viewModel.loadLanguages()
    }
    
    override public func layoutSubviews() {
        super.layoutSubviews()
        containerView.layer.cornerRadius = 16
        
        // Update corner radius for first and last items
        updateItemCornerRadius()
    }
    
    func setupWithTheme() {
        backgroundColor = .clear
        containerView.backgroundColor = StyleProvider.Color.backgroundPrimary
    }
    
    // MARK: Functions
    private func setupBindings() {
        // Bind languages list updates
        viewModel.languagesPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] languages in
                self?.updateLanguages(languages)
            }
            .store(in: &cancellables)
        
        // Bind selection changes
        viewModel.selectedLanguagePublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] selectedLanguage in
                self?.updateSelection(selectedLanguage)
            }
            .store(in: &cancellables)
    }
    
    private func updateLanguages(_ languages: [LanguageModel]) {
        // Store current languages
        currentLanguages = languages
        
        // Clear existing views
        clearLanguageItemViews()
        
        // Create new views with language references
        languageItemViews = languages.enumerated().map { (index, language) in
            let itemView = LanguageItemView()
            let isLastItem = index == languages.count - 1
            
            itemView.configure(with: language, isLastItem: isLastItem) { [weak self] selectedLanguage in
                self?.viewModel.selectLanguage(selectedLanguage)
            }
            
            return (view: itemView, language: language)
        }
        
        // Add views to stack
        languageItemViews.forEach { item in
            stackView.addArrangedSubview(item.view)
        }
        
        // Update corner radius for new items
        updateItemCornerRadius()
    }
    
    private func updateSelection(_ selectedLanguage: LanguageModel?) {
        // Update each item view to reflect the current selection
        for (itemView, language) in languageItemViews {
            let updatedLanguage = language.withSelection(language.id == selectedLanguage?.id)
            let isLastItem = languageItemViews.last?.language.id == language.id
            
            itemView.configure(with: updatedLanguage, isLastItem: isLastItem) { [weak self] selectedLang in
                self?.viewModel.selectLanguage(selectedLang)
            }
        }
    }
    
    private func updateItemCornerRadius() {
        guard !languageItemViews.isEmpty else { return }
        
        for (index, item) in languageItemViews.enumerated() {
            let position: LanguageItemView.CornerPosition
            
            if languageItemViews.count == 1 {
                position = .all
            } else if index == 0 {
                position = .top
            } else if index == languageItemViews.count - 1 {
                position = .bottom
            } else {
                position = .none
            }
            
            item.view.applyCornerRadius(position: position)
        }
    }
    
    private func clearLanguageItemViews() {
        languageItemViews.forEach { item in
            item.view.removeFromSuperview()
        }
        languageItemViews.removeAll()
    }
    
    // MARK: - Public API
    
    /// Refreshes the language list from the view model
    public func refresh() {
        viewModel.loadLanguages()
    }
    
    /// Gets the currently selected language
    /// - Returns: The selected language model, if any
    public func getSelectedLanguage() -> LanguageModel? {
        return viewModel.getCurrentSelection()
    }
}

// MARK: - Subviews Initialization and Setup
extension LanguageSelectorView {
    
    private static func createContainerView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }
    
    private static func createStackView() -> UIStackView {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.alignment = .fill
        stackView.distribution = .fill
        stackView.spacing = 0 // No spacing between items since they have borders
        return stackView
    }
    
    private func setupSubviews() {
        addSubview(containerView)
        containerView.addSubview(stackView)
        
        initConstraints()
    }
    
    private func initConstraints() {
        NSLayoutConstraint.activate([
            // Container
            containerView.leadingAnchor.constraint(equalTo: leadingAnchor),
            containerView.trailingAnchor.constraint(equalTo: trailingAnchor),
            containerView.topAnchor.constraint(equalTo: topAnchor),
            containerView.bottomAnchor.constraint(equalTo: bottomAnchor),
            
            // Stack view
            stackView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 8),
            stackView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -8),
            stackView.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 8),
            stackView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -8)
        ])
    }
}

// MARK: - SwiftUI Preview
#if DEBUG

@available(iOS 17.0, *)
#Preview("LanguageSelectorView") {
    PreviewUIViewController {
        let vc = UIViewController()
        vc.view.backgroundColor = .backgroundTestColor

        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.showsVerticalScrollIndicator = true

        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 24
        stackView.alignment = .fill
        stackView.distribution = .equalSpacing
        stackView.translatesAutoresizingMaskIntoConstraints = false

        // Component name label
        let titleLabel = UILabel()
        titleLabel.text = "LanguageSelectorView"
        titleLabel.font = StyleProvider.fontWith(type: .bold, size: 18)
        titleLabel.textColor = StyleProvider.Color.textPrimary
        titleLabel.textAlignment = .center
        titleLabel.translatesAutoresizingMaskIntoConstraints = false

        // Two languages (English selected)
        let twoLanguagesView = LanguageSelectorView(viewModel: MockLanguageSelectorViewModel.twoLanguagesMock)
        twoLanguagesView.translatesAutoresizingMaskIntoConstraints = false

        // Default - 4 languages (English selected)
        let defaultView = LanguageSelectorView(viewModel: MockLanguageSelectorViewModel.defaultMock)
        defaultView.translatesAutoresizingMaskIntoConstraints = false

        // Many languages (French selected) - scrollable
        let manyLanguagesView = LanguageSelectorView(viewModel: MockLanguageSelectorViewModel.manyLanguagesMock)
        manyLanguagesView.translatesAutoresizingMaskIntoConstraints = false

        stackView.addArrangedSubview(titleLabel)
        stackView.addArrangedSubview(twoLanguagesView)
        stackView.addArrangedSubview(defaultView)
        stackView.addArrangedSubview(manyLanguagesView)

        scrollView.addSubview(stackView)
        vc.view.addSubview(scrollView)

        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: vc.view.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: vc.view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: vc.view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: vc.view.bottomAnchor),

            stackView.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: 20),
            stackView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: 16),
            stackView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor, constant: -16),
            stackView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor, constant: -20),
            stackView.widthAnchor.constraint(equalTo: scrollView.widthAnchor, constant: -32)
        ])

        return vc
    }
}

#endif
