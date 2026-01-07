import UIKit

// MARK: - Snapshot Category
enum TimeSliderViewSnapshotCategory: String, CaseIterable {
    case sliderStates = "Slider States"
}

final class TimeSliderViewSnapshotViewController: UIViewController {

    private let category: TimeSliderViewSnapshotCategory

    init(category: TimeSliderViewSnapshotCategory) {
        self.category = category
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .backgroundTestColor
        setupUI()
    }

    private func setupUI() {
        let titleLabel = UILabel()
        titleLabel.text = "TimeSliderView - \(category.rawValue)"
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
        case .sliderStates:
            addSliderStatesVariants(to: stackView)
        }
    }

    // MARK: - Category Variants

    private func addSliderStatesVariants(to stackView: UIStackView) {
        let timeOptions = [
            TimeOption(title: "1H", value: 0),
            TimeOption(title: "3H", value: 1),
            TimeOption(title: "6H", value: 2),
            TimeOption(title: "12H", value: 3),
            TimeOption(title: "24H", value: 4)
        ]

        // Initial state (first option)
        let initialViewModel = MockTimeSliderViewModel(
            title: "Starting matches within",
            timeOptions: timeOptions,
            selectedValue: 0
        )
        stackView.addArrangedSubview(createLabeledVariant(
            label: "Initial State (1H)",
            view: createTimeSliderView(viewModel: initialViewModel)
        ))

        // Middle option selected
        let middleViewModel = MockTimeSliderViewModel(
            title: "Starting matches within",
            timeOptions: timeOptions,
            selectedValue: 2
        )
        stackView.addArrangedSubview(createLabeledVariant(
            label: "Middle Option (6H)",
            view: createTimeSliderView(viewModel: middleViewModel)
        ))

        // Last option selected
        let lastViewModel = MockTimeSliderViewModel(
            title: "Starting matches within",
            timeOptions: timeOptions,
            selectedValue: 4
        )
        stackView.addArrangedSubview(createLabeledVariant(
            label: "Last Option (24H)",
            view: createTimeSliderView(viewModel: lastViewModel)
        ))
    }

    // MARK: - Helper Methods

    private func createTimeSliderView(viewModel: MockTimeSliderViewModel) -> TimeSliderView {
        let slider = TimeSliderView(viewModel: viewModel)
        slider.translatesAutoresizingMaskIntoConstraints = false
        return slider
    }

    private func createLabeledVariant(label: String, view: UIView) -> UIStackView {
        let labelView = UILabel()
        labelView.text = label
        labelView.font = StyleProvider.fontWith(type: .medium, size: 12)
        labelView.textColor = StyleProvider.Color.textSecondary

        let stack = UIStackView(arrangedSubviews: [labelView, view])
        stack.axis = .vertical
        stack.spacing = 6
        stack.alignment = .fill
        return stack
    }
}

// MARK: - Preview
#if DEBUG
#Preview("Slider States") {
    TimeSliderViewSnapshotViewController(category: .sliderStates)
}
#endif
