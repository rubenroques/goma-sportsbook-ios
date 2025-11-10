import UIKit
import GomaUI

class SimpleNavigationBarViewController: UIViewController {

    private let scrollView = UIScrollView()
    private let contentView = UIView()
    private let stackView = UIStackView()

    private var navigationBars: [SimpleNavigationBarView] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Simple Navigation Bar"
        view.backgroundColor = StyleProvider.Color.backgroundPrimary

        setupViews()
        createNavigationBarExamples()
    }

    private func setupViews() {
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        contentView.translatesAutoresizingMaskIntoConstraints = false
        stackView.translatesAutoresizingMaskIntoConstraints = false

        stackView.axis = .vertical
        stackView.spacing = 24
        stackView.alignment = .fill

        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        contentView.addSubview(stackView)

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

            stackView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 20),
            stackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            stackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -20)
        ])
    }

    private func createNavigationBarExamples() {
        addSection(title: "Icon Only", navigationBar: createIconOnlyNavigationBar())
        addSection(title: "Icon + Back Text", navigationBar: createWithBackTextNavigationBar())
        addSection(title: "Icon + Title (Centered)", navigationBar: createWithTitleNavigationBar())
        addSection(title: "Icon + Back Text + Title", navigationBar: createWithBackTextAndTitleNavigationBar())
        addSection(title: "Title Only (No Back Button)", navigationBar: createTitleOnlyNavigationBar())
        addSection(title: "Long Title (Truncation Test)", navigationBar: createLongTitleNavigationBar())
        addDarkOverlaySection()
    }

    private func addSection(title: String, navigationBar: SimpleNavigationBarView) {
        let sectionView = UIView()
        sectionView.translatesAutoresizingMaskIntoConstraints = false

        let titleLabel = UILabel()
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.text = title
        titleLabel.font = StyleProvider.fontWith(type: .bold, size: 18)
        titleLabel.textColor = StyleProvider.Color.textPrimary

        navigationBar.translatesAutoresizingMaskIntoConstraints = false

        sectionView.addSubview(titleLabel)
        sectionView.addSubview(navigationBar)

        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: sectionView.topAnchor),
            titleLabel.leadingAnchor.constraint(equalTo: sectionView.leadingAnchor, constant: 16),
            titleLabel.trailingAnchor.constraint(equalTo: sectionView.trailingAnchor, constant: -16),

            navigationBar.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8),
            navigationBar.leadingAnchor.constraint(equalTo: sectionView.leadingAnchor),
            navigationBar.trailingAnchor.constraint(equalTo: sectionView.trailingAnchor),
            navigationBar.heightAnchor.constraint(equalToConstant: 56),
            navigationBar.bottomAnchor.constraint(equalTo: sectionView.bottomAnchor, constant: -16)
        ])

        stackView.addArrangedSubview(sectionView)
        navigationBars.append(navigationBar)
    }

    // MARK: - Navigation Bar Factory Methods

    private func createIconOnlyNavigationBar() -> SimpleNavigationBarView {
        let viewModel = MockSimpleNavigationBarViewModel.iconOnly
        let navigationBar = SimpleNavigationBarView(viewModel: viewModel)
        return navigationBar
    }

    private func createWithBackTextNavigationBar() -> SimpleNavigationBarView {
        let viewModel = MockSimpleNavigationBarViewModel.withBackText
        let navigationBar = SimpleNavigationBarView(viewModel: viewModel)
        return navigationBar
    }

    private func createWithTitleNavigationBar() -> SimpleNavigationBarView {
        let viewModel = MockSimpleNavigationBarViewModel.withTitle
        let navigationBar = SimpleNavigationBarView(viewModel: viewModel)
        return navigationBar
    }

    private func createWithBackTextAndTitleNavigationBar() -> SimpleNavigationBarView {
        let viewModel = MockSimpleNavigationBarViewModel.withBackTextAndTitle
        let navigationBar = SimpleNavigationBarView(viewModel: viewModel)
        return navigationBar
    }

    private func createTitleOnlyNavigationBar() -> SimpleNavigationBarView {
        let viewModel = MockSimpleNavigationBarViewModel.titleOnly
        let navigationBar = SimpleNavigationBarView(viewModel: viewModel)
        return navigationBar
    }

    private func createLongTitleNavigationBar() -> SimpleNavigationBarView {
        let viewModel = MockSimpleNavigationBarViewModel.longTitle
        let navigationBar = SimpleNavigationBarView(viewModel: viewModel)
        return navigationBar
    }

    // MARK: - Dark Overlay Section

    private func addDarkOverlaySection() {
        let sectionView = UIView()
        sectionView.translatesAutoresizingMaskIntoConstraints = false

        // Section title
        let titleLabel = UILabel()
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.text = "Dark Overlay (White Text/Icons)"
        titleLabel.font = StyleProvider.fontWith(type: .bold, size: 18)
        titleLabel.textColor = StyleProvider.Color.textPrimary

        // Dark background container to simulate overlay scenario
        let darkBackground = UIView()
        darkBackground.translatesAutoresizingMaskIntoConstraints = false
        darkBackground.backgroundColor = .black
        darkBackground.layer.cornerRadius = 8

        // Create navigation bar with dark overlay customization
        let viewModel = MockSimpleNavigationBarViewModel.withBackText
        let navigationBar = SimpleNavigationBarView(viewModel: viewModel)
        navigationBar.translatesAutoresizingMaskIntoConstraints = false

        // Apply dark overlay customization
        navigationBar.setCustomization(.darkOverlay())

        darkBackground.addSubview(navigationBar)
        sectionView.addSubview(titleLabel)
        sectionView.addSubview(darkBackground)

        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: sectionView.topAnchor),
            titleLabel.leadingAnchor.constraint(equalTo: sectionView.leadingAnchor, constant: 16),
            titleLabel.trailingAnchor.constraint(equalTo: sectionView.trailingAnchor, constant: -16),

            darkBackground.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8),
            darkBackground.leadingAnchor.constraint(equalTo: sectionView.leadingAnchor),
            darkBackground.trailingAnchor.constraint(equalTo: sectionView.trailingAnchor),
            darkBackground.heightAnchor.constraint(equalToConstant: 56),
            darkBackground.bottomAnchor.constraint(equalTo: sectionView.bottomAnchor, constant: -16),

            navigationBar.topAnchor.constraint(equalTo: darkBackground.topAnchor),
            navigationBar.leadingAnchor.constraint(equalTo: darkBackground.leadingAnchor),
            navigationBar.trailingAnchor.constraint(equalTo: darkBackground.trailingAnchor),
            navigationBar.bottomAnchor.constraint(equalTo: darkBackground.bottomAnchor)
        ])

        stackView.addArrangedSubview(sectionView)
        navigationBars.append(navigationBar)
    }
}
