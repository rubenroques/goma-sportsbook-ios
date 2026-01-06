import UIKit
import SwiftUI

// MARK: - Snapshot Category
enum CustomSliderSnapshotCategory: String, CaseIterable {
    case basicStates = "Basic States"
    case positionVariants = "Position Variants"
    case configurationVariants = "Configuration Variants"
}

final class CustomSliderViewSnapshotViewController: UIViewController {

    private let category: CustomSliderSnapshotCategory

    init(category: CustomSliderSnapshotCategory) {
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
        titleLabel.text = "CustomSliderView - \(category.rawValue)"
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
        case .basicStates:
            addBasicStatesVariants(to: stackView)
        case .positionVariants:
            addPositionVariants(to: stackView)
        case .configurationVariants:
            addConfigurationVariants(to: stackView)
        }
    }

    // MARK: - Category Variants

    private func addBasicStatesVariants(to stackView: UIStackView) {
        stackView.addArrangedSubview(createLabeledVariant(
            label: "Default (Enabled)",
            view: createSliderView(viewModel: MockCustomSliderViewModel.defaultMock)
        ))
        stackView.addArrangedSubview(createLabeledVariant(
            label: "Disabled",
            view: createSliderView(viewModel: MockCustomSliderViewModel.disabledMock)
        ))
        stackView.addArrangedSubview(createLabeledVariant(
            label: "Time Filter",
            view: createSliderView(viewModel: MockCustomSliderViewModel.timeFilterMock)
        ))
    }

    private func addPositionVariants(to stackView: UIStackView) {
        stackView.addArrangedSubview(createLabeledVariant(
            label: "Start Position (0.0)",
            view: createSliderView(viewModel: MockCustomSliderViewModel.defaultMock)
        ))
        stackView.addArrangedSubview(createLabeledVariant(
            label: "Mid Position (0.5)",
            view: createSliderView(viewModel: MockCustomSliderViewModel.midPositionMock)
        ))

        // End position
        let endConfig = SliderConfiguration(
            minimumValue: 0.0,
            maximumValue: 1.0,
            numberOfSteps: 5,
            trackHeight: 4.0,
            trackCornerRadius: 2.0,
            thumbSize: 24.0,
            thumbImageName: nil,
            thumbTintColor: nil
        )
        stackView.addArrangedSubview(createLabeledVariant(
            label: "End Position (1.0)",
            view: createSliderView(viewModel: MockCustomSliderViewModel.customMock(
                configuration: endConfig,
                initialValue: 1.0
            ))
        ))

        // Quarter position
        stackView.addArrangedSubview(createLabeledVariant(
            label: "Quarter Position (0.25)",
            view: createSliderView(viewModel: MockCustomSliderViewModel.customImageMock)
        ))
    }

    private func addConfigurationVariants(to stackView: UIStackView) {
        stackView.addArrangedSubview(createLabeledVariant(
            label: "Default Configuration",
            view: createSliderView(viewModel: MockCustomSliderViewModel.defaultMock)
        ))

        // Thick track
        let thickConfig = SliderConfiguration(
            minimumValue: 0.0,
            maximumValue: 1.0,
            numberOfSteps: 5,
            trackHeight: 8.0,
            trackCornerRadius: 4.0,
            thumbSize: 28.0,
            thumbImageName: nil,
            thumbTintColor: nil
        )
        stackView.addArrangedSubview(createLabeledVariant(
            label: "Thick Track (8pt)",
            view: createSliderView(viewModel: MockCustomSliderViewModel.customMock(
                configuration: thickConfig,
                initialValue: 0.5
            ))
        ))

        // Many steps
        let manyStepsConfig = SliderConfiguration(
            minimumValue: 0.0,
            maximumValue: 1.0,
            numberOfSteps: 11,
            trackHeight: 4.0,
            trackCornerRadius: 2.0,
            thumbSize: 24.0,
            thumbImageName: nil,
            thumbTintColor: nil
        )
        stackView.addArrangedSubview(createLabeledVariant(
            label: "Many Steps (11)",
            view: createSliderView(viewModel: MockCustomSliderViewModel.customMock(
                configuration: manyStepsConfig,
                initialValue: 0.6
            ))
        ))

        stackView.addArrangedSubview(createLabeledVariant(
            label: "Volume Slider",
            view: createSliderView(viewModel: MockCustomSliderViewModel.volumeSliderMock)
        ))
    }

    // MARK: - Helper Methods

    private func createSliderView(viewModel: CustomSliderViewModelProtocol) -> CustomSliderView {
        let sliderView = CustomSliderView(viewModel: viewModel)
        sliderView.translatesAutoresizingMaskIntoConstraints = false
        sliderView.heightAnchor.constraint(equalToConstant: 44).isActive = true
        return sliderView
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
#Preview("Basic States") {
    CustomSliderViewSnapshotViewController(category: .basicStates)
}

#Preview("Position Variants") {
    CustomSliderViewSnapshotViewController(category: .positionVariants)
}

#Preview("Configuration Variants") {
    CustomSliderViewSnapshotViewController(category: .configurationVariants)
}
#endif
