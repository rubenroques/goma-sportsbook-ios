import UIKit
import Combine
import GomaUI

/// Demo ViewController for CompactMatchHeaderView showing different modes
final class CompactMatchHeaderViewController: UIViewController {

    // MARK: - Constants

    private enum Constants {
        static let padding: CGFloat = 16
        static let spacing: CGFloat = 20
    }

    // MARK: - Properties

    private var cancellables = Set<AnyCancellable>()

    private var interactiveVM: MockCompactMatchHeaderViewModel!

    // MARK: - UI Components

    private lazy var scrollView: UIScrollView = Self.createScrollView()
    private lazy var stackView: UIStackView = Self.createStackView()

    private var interactiveHeaderView: CompactMatchHeaderView!

    // Control elements
    private lazy var modeSegmentedControl: UISegmentedControl = {
        let control = UISegmentedControl(items: ["Pre-Live", "Live"])
        control.selectedSegmentIndex = 0
        return control
    }()

    private lazy var statusTextField: UITextField = {
        let field = UITextField()
        field.placeholder = "Status text (e.g., '45' or '2ND SET')"
        field.borderStyle = .roundedRect
        field.backgroundColor = StyleProvider.Color.backgroundSecondary
        return field
    }()

    private lazy var marketCountStepper: UIStepper = {
        let stepper = UIStepper()
        stepper.minimumValue = 0
        stepper.maximumValue = 999
        stepper.value = 156
        stepper.stepValue = 10
        return stepper
    }()

    private lazy var marketCountLabel: UILabel = {
        let label = UILabel()
        label.text = "Markets: 156"
        label.font = StyleProvider.fontWith(type: .regular, size: 14)
        label.textColor = StyleProvider.Color.textSecondary
        return label
    }()

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigation()
        setupViews()
        setupConstraints()
        setupComponents()
        setupControls()
    }

    // MARK: - Setup

    private func setupNavigation() {
        title = "Compact Match Header"
        navigationController?.navigationBar.prefersLargeTitles = false
        view.backgroundColor = StyleProvider.Color.backgroundPrimary
    }

    private func setupViews() {
        view.addSubview(scrollView)
        scrollView.addSubview(stackView)
    }

    private func setupConstraints() {
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        stackView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            stackView.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: Constants.padding),
            stackView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: Constants.padding),
            stackView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor, constant: -Constants.padding),
            stackView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor, constant: -Constants.padding),
            stackView.widthAnchor.constraint(equalTo: scrollView.widthAnchor, constant: -2 * Constants.padding)
        ])
    }

    private func setupComponents() {
        // Interactive header
        addSection(title: "Interactive Header", description: "Use controls below to modify") {
            self.interactiveVM = MockCompactMatchHeaderViewModel.preLiveToday
            self.interactiveHeaderView = CompactMatchHeaderView(viewModel: self.interactiveVM)
            return self.interactiveHeaderView
        }

        // Pre-live examples
        addSection(title: "Pre-Live Today", description: "Shows 'TODAY, 14:00' format") {
            CompactMatchHeaderView(viewModel: MockCompactMatchHeaderViewModel.preLiveToday)
        }

        addSection(title: "Pre-Live Future Date", description: "Shows '17/07, 11:00' format") {
            CompactMatchHeaderView(viewModel: MockCompactMatchHeaderViewModel.preLiveFutureDate)
        }

        addSection(title: "Pre-Live No Icons", description: "Without feature icons") {
            CompactMatchHeaderView(viewModel: MockCompactMatchHeaderViewModel.preLiveNoIcons)
        }

        // Live examples
        addSection(title: "Live Tennis", description: "Shows 'LIVE' badge + '2ND SET'") {
            CompactMatchHeaderView(viewModel: MockCompactMatchHeaderViewModel.liveTennis)
        }

        addSection(title: "Live Football", description: "Shows 'LIVE' badge + '45''") {
            CompactMatchHeaderView(viewModel: MockCompactMatchHeaderViewModel.liveFootball)
        }

        addSection(title: "Live Halftime", description: "Shows 'LIVE' badge + 'HT'") {
            CompactMatchHeaderView(viewModel: MockCompactMatchHeaderViewModel.liveHalftime)
        }

        addSection(title: "High Market Count", description: "With 500+ markets") {
            CompactMatchHeaderView(viewModel: MockCompactMatchHeaderViewModel.highMarketCount)
        }
    }

    private func setupControls() {
        addSeparator()

        // Controls title
        let controlsTitle = UILabel()
        controlsTitle.text = "Interactive Controls"
        controlsTitle.font = StyleProvider.fontWith(type: .semibold, size: 18)
        controlsTitle.textColor = StyleProvider.Color.textPrimary
        stackView.addArrangedSubview(controlsTitle)

        // Mode selector
        let modeLabel = UILabel()
        modeLabel.text = "Mode:"
        modeLabel.font = StyleProvider.fontWith(type: .medium, size: 14)
        modeLabel.textColor = StyleProvider.Color.textSecondary
        stackView.addArrangedSubview(modeLabel)

        modeSegmentedControl.addTarget(self, action: #selector(modeChanged), for: .valueChanged)
        stackView.addArrangedSubview(modeSegmentedControl)

        // Status text
        let statusLabel = UILabel()
        statusLabel.text = "Status/Date Text:"
        statusLabel.font = StyleProvider.fontWith(type: .medium, size: 14)
        statusLabel.textColor = StyleProvider.Color.textSecondary
        stackView.addArrangedSubview(statusLabel)

        statusTextField.delegate = self
        stackView.addArrangedSubview(statusTextField)

        // Apply status button
        let applyStatusButton = createButton(title: "Apply Status Text")
        applyStatusButton.addTarget(self, action: #selector(applyStatusTapped), for: .touchUpInside)
        stackView.addArrangedSubview(applyStatusButton)

        // Market count
        let marketCountStack = UIStackView(arrangedSubviews: [marketCountLabel, marketCountStepper])
        marketCountStack.axis = .horizontal
        marketCountStack.spacing = 12
        marketCountStepper.addTarget(self, action: #selector(marketCountChanged), for: .valueChanged)
        stackView.addArrangedSubview(marketCountStack)

        // Toggle icons button
        let toggleIconsButton = createButton(title: "Toggle Icons", color: .systemOrange)
        toggleIconsButton.addTarget(self, action: #selector(toggleIconsTapped), for: .touchUpInside)
        stackView.addArrangedSubview(toggleIconsButton)
    }

    // MARK: - Helpers

    private func addSection(title: String, description: String, componentFactory: () -> UIView) {
        let titleLabel = UILabel()
        titleLabel.text = title
        titleLabel.font = StyleProvider.fontWith(type: .semibold, size: 18)
        titleLabel.textColor = StyleProvider.Color.textPrimary
        stackView.addArrangedSubview(titleLabel)

        let descLabel = UILabel()
        descLabel.text = description
        descLabel.font = StyleProvider.fontWith(type: .regular, size: 14)
        descLabel.textColor = StyleProvider.Color.textSecondary
        descLabel.numberOfLines = 0
        stackView.addArrangedSubview(descLabel)

        let container = UIView()
        container.backgroundColor = StyleProvider.Color.backgroundSecondary
        container.layer.cornerRadius = 8

        let component = componentFactory()
        component.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(component)

        NSLayoutConstraint.activate([
            component.topAnchor.constraint(equalTo: container.topAnchor, constant: 12),
            component.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 12),
            component.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -12),
            component.bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: -12)
        ])

        stackView.addArrangedSubview(container)
    }

    private func addSeparator() {
        let separator = UIView()
        separator.backgroundColor = StyleProvider.Color.separatorLine
        separator.heightAnchor.constraint(equalToConstant: 1).isActive = true
        stackView.addArrangedSubview(separator)
    }

    private func createButton(title: String, color: UIColor = StyleProvider.Color.highlightPrimary) -> UIButton {
        let button = UIButton(type: .system)
        button.setTitle(title, for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = color
        button.layer.cornerRadius = 8
        button.titleLabel?.font = StyleProvider.fontWith(type: .semibold, size: 16)
        button.heightAnchor.constraint(equalToConstant: 44).isActive = true
        return button
    }

    // MARK: - Actions

    @objc private func modeChanged() {
        let statusText = statusTextField.text ?? ""

        if modeSegmentedControl.selectedSegmentIndex == 0 {
            // Pre-live
            let dateText = statusText.isEmpty ? "TODAY, 14:00" : statusText
            interactiveVM.updateMode(.preLive(dateText: dateText))
            print("[Demo] Mode changed to Pre-Live: \(dateText)")
        } else {
            // Live
            let liveText = statusText.isEmpty ? "45'" : statusText
            interactiveVM.updateMode(.live(statusText: liveText))
            print("[Demo] Mode changed to Live: \(liveText)")
        }
    }

    @objc private func applyStatusTapped() {
        let statusText = statusTextField.text ?? ""
        guard !statusText.isEmpty else { return }

        if modeSegmentedControl.selectedSegmentIndex == 0 {
            interactiveVM.updateMode(.preLive(dateText: statusText))
        } else {
            interactiveVM.updateMode(.live(statusText: statusText))
        }

        print("[Demo] Status updated: \(statusText)")
        statusTextField.resignFirstResponder()
    }

    @objc private func marketCountChanged() {
        let count = Int(marketCountStepper.value)
        marketCountLabel.text = "Markets: \(count)"
        interactiveVM.updateMarketCount(count > 0 ? count : nil)
        print("[Demo] Market count: \(count)")
    }

    @objc private func toggleIconsTapped() {
        let currentIcons = interactiveVM.currentDisplayState.icons
        if currentIcons.isEmpty {
            interactiveVM.updateIcons([
                CompactMatchHeaderIcon(id: "1", iconName: "erep_short_info"),
                CompactMatchHeaderIcon(id: "2", iconName: "bet_builder_info")
            ])
            print("[Demo] Icons shown")
        } else {
            interactiveVM.updateIcons([])
            print("[Demo] Icons hidden")
        }
    }

    // MARK: - Factory Methods

    private static func createScrollView() -> UIScrollView {
        let scrollView = UIScrollView()
        scrollView.showsVerticalScrollIndicator = true
        scrollView.alwaysBounceVertical = true
        return scrollView
    }

    private static func createStackView() -> UIStackView {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = Constants.spacing
        stackView.alignment = .fill
        return stackView
    }
}

// MARK: - UITextFieldDelegate

extension CompactMatchHeaderViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        applyStatusTapped()
        return true
    }
}
