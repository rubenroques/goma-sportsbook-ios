import UIKit
import SwiftUI
import Combine

// MARK: - Snapshot Category
enum ProfileMenuListSnapshotCategory: String, CaseIterable {
    case defaultConfiguration = "Default Configuration"
    case languageVariants = "Language Variants"
    case itemCountVariants = "Item Count Variants"
}

final class ProfileMenuListViewSnapshotViewController: UIViewController {

    private let category: ProfileMenuListSnapshotCategory
    private var cancellables = Set<AnyCancellable>()

    init(category: ProfileMenuListSnapshotCategory) {
        self.category = category
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = StyleProvider.Color.backgroundTertiary
        setupUI()
    }

    private func setupUI() {
        let titleLabel = UILabel()
        titleLabel.text = "ProfileMenuListView - \(category.rawValue)"
        titleLabel.font = StyleProvider.fontWith(type: .bold, size: 16)
        titleLabel.textColor = StyleProvider.Color.textPrimary
        titleLabel.translatesAutoresizingMaskIntoConstraints = false

        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 24
        stackView.alignment = .fill
        stackView.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(titleLabel)
        view.addSubview(stackView)

        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),

            stackView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 24),
            stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16)
        ])

        addVariants(to: stackView)
    }

    private func addVariants(to stackView: UIStackView) {
        switch category {
        case .defaultConfiguration:
            addDefaultConfigurationVariants(to: stackView)
        case .languageVariants:
            addLanguageVariants(to: stackView)
        case .itemCountVariants:
            addItemCountVariants(to: stackView)
        }
    }

    // MARK: - Category Variants

    private func addDefaultConfigurationVariants(to stackView: UIStackView) {
        stackView.addArrangedSubview(createLabeledVariant(
            label: "Default Menu (All Items)",
            view: createProfileMenuListView(viewModel: MockProfileMenuListViewModel.defaultMock)
        ))
    }

    private func addLanguageVariants(to stackView: UIStackView) {
        // English language
        let englishMock = MockProfileMenuListViewModel.defaultMock
        englishMock.updateCurrentLanguage("English")
        stackView.addArrangedSubview(createLabeledVariant(
            label: "English Language",
            view: createProfileMenuListView(viewModel: englishMock)
        ))

        // French language
        stackView.addArrangedSubview(createLabeledVariant(
            label: "French Language",
            view: createProfileMenuListView(viewModel: MockProfileMenuListViewModel.frenchLanguageMock)
        ))

        // Spanish language
        let spanishMock = MockProfileMenuListViewModel.defaultMock
        spanishMock.updateCurrentLanguage("Spanish")
        stackView.addArrangedSubview(createLabeledVariant(
            label: "Spanish Language",
            view: createProfileMenuListView(viewModel: spanishMock)
        ))
    }

    private func addItemCountVariants(to stackView: UIStackView) {
        // Minimal items (3 items)
        stackView.addArrangedSubview(createLabeledVariant(
            label: "Minimal (3 Items)",
            view: createProfileMenuListView(viewModel: createMinimalMock())
        ))

        // Full items (7 items - default)
        stackView.addArrangedSubview(createLabeledVariant(
            label: "Full (7 Items)",
            view: createProfileMenuListView(viewModel: MockProfileMenuListViewModel.defaultMock)
        ))
    }

    // MARK: - Helper Methods

    private func createProfileMenuListView(viewModel: ProfileMenuListViewModelProtocol) -> ProfileMenuListView {
        let view = ProfileMenuListView(viewModel: viewModel)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }

    private func createMinimalMock() -> MinimalProfileMenuListViewModel {
        return MinimalProfileMenuListViewModel()
    }

    private func createLabeledVariant(label: String, view: UIView) -> UIStackView {
        let labelView = UILabel()
        labelView.text = label
        labelView.font = StyleProvider.fontWith(type: .medium, size: 12)
        labelView.textColor = StyleProvider.Color.textSecondary

        let stack = UIStackView(arrangedSubviews: [labelView, view])
        stack.axis = .vertical
        stack.spacing = 8
        stack.alignment = .fill
        return stack
    }
}

// MARK: - Minimal Mock for Item Count Variants

private final class MinimalProfileMenuListViewModel: ProfileMenuListViewModelProtocol {

    @Published private var menuItems: [ActionRowItem] = []
    @Published private var currentLanguage: String = "English"

    var menuItemsPublisher: AnyPublisher<[ActionRowItem], Never> {
        $menuItems.eraseToAnyPublisher()
    }

    var currentLanguagePublisher: AnyPublisher<String, Never> {
        $currentLanguage.eraseToAnyPublisher()
    }

    var onItemSelected: ((ActionRowItem) -> Void)?

    init() {
        loadMinimalConfiguration()
    }

    func didSelectItem(_ item: ActionRowItem) {
        onItemSelected?(item)
    }

    func loadConfiguration(from jsonFileName: String?) {
        loadMinimalConfiguration()
    }

    func updateCurrentLanguage(_ language: String) {
        currentLanguage = language
    }

    private func loadMinimalConfiguration() {
        menuItems = [
            ActionRowItem(
                id: "notifications",
                icon: "bell",
                title: LocalizationProvider.string("notifications"),
                type: .navigation,
                action: .notifications
            ),
            ActionRowItem(
                id: "help_center",
                icon: "questionmark.circle",
                title: LocalizationProvider.string("support_helpcenter_button_text"),
                type: .navigation,
                action: .helpCenter
            ),
            ActionRowItem(
                id: "logout",
                icon: "rectangle.portrait.and.arrow.right",
                title: LocalizationProvider.string("logout"),
                type: .action,
                action: .logout
            )
        ]
    }
}

// MARK: - Preview
#if DEBUG
#Preview("Default Configuration") {
    ProfileMenuListViewSnapshotViewController(category: .defaultConfiguration)
}

#Preview("Language Variants") {
    ProfileMenuListViewSnapshotViewController(category: .languageVariants)
}

#Preview("Item Count Variants") {
    ProfileMenuListViewSnapshotViewController(category: .itemCountVariants)
}
#endif
