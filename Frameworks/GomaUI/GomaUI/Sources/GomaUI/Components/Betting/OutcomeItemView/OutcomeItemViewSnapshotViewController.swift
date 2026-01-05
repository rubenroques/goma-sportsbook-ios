import UIKit
import SwiftUI

// MARK: - Snapshot Category
enum OutcomeItemSnapshotCategory: String, CaseIterable {
    case basicStates = "Basic States"
    case displayStates = "Display States"
    case oddsChange = "Odds Change"
    case fontCustomization = "Font Customization"
    case sizeVariants = "Size Variants"
}

final class OutcomeItemViewSnapshotViewController: UIViewController {

    private let category: OutcomeItemSnapshotCategory

    init(category: OutcomeItemSnapshotCategory) {
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
        titleLabel.text = "OutcomeItemView - \(category.rawValue)"
        titleLabel.font = StyleProvider.fontWith(type: .bold, size: 16)
        titleLabel.textColor = StyleProvider.Color.textPrimary
        titleLabel.translatesAutoresizingMaskIntoConstraints = false

        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 16
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
        case .displayStates:
            addDisplayStatesVariants(to: stackView)
        case .oddsChange:
            addOddsChangeVariants(to: stackView)
        case .fontCustomization:
            addFontCustomizationVariants(to: stackView)
        case .sizeVariants:
            addSizeVariants(to: stackView)
        }
    }

    // MARK: - Category Variants

    private func addBasicStatesVariants(to stackView: UIStackView) {
        stackView.addArrangedSubview(createLabeledVariant(
            label: "Selected (Home)",
            view: createOutcomeView(viewModel: MockOutcomeItemViewModel.homeOutcome)
        ))
        stackView.addArrangedSubview(createLabeledVariant(
            label: "Unselected (Draw)",
            view: createOutcomeView(viewModel: MockOutcomeItemViewModel.drawOutcome)
        ))
        stackView.addArrangedSubview(createLabeledVariant(
            label: "Unselected (Away)",
            view: createOutcomeView(viewModel: MockOutcomeItemViewModel.awayOutcome)
        ))
        stackView.addArrangedSubview(createLabeledVariant(
            label: "Disabled",
            view: createOutcomeView(viewModel: MockOutcomeItemViewModel.disabledOutcome)
        ))
    }

    private func addDisplayStatesVariants(to stackView: UIStackView) {
        stackView.addArrangedSubview(createLabeledVariant(
            label: "Loading",
            view: createOutcomeView(viewModel: MockOutcomeItemViewModel.loadingOutcome)
        ))
        stackView.addArrangedSubview(createLabeledVariant(
            label: "Locked",
            view: createOutcomeView(viewModel: MockOutcomeItemViewModel.lockedOutcome)
        ))
        stackView.addArrangedSubview(createLabeledVariant(
            label: "Unavailable",
            view: createOutcomeView(viewModel: MockOutcomeItemViewModel.unavailableOutcome)
        ))
        stackView.addArrangedSubview(createLabeledVariant(
            label: "Boosted (Unselected)",
            view: createOutcomeView(viewModel: MockOutcomeItemViewModel.boostedOutcome)
        ))
        stackView.addArrangedSubview(createLabeledVariant(
            label: "Boosted (Selected)",
            view: createOutcomeView(viewModel: MockOutcomeItemViewModel.boostedOutcomeSelected)
        ))
    }

    private func addOddsChangeVariants(to stackView: UIStackView) {
        stackView.addArrangedSubview(createLabeledVariant(
            label: "Odds Up (Over 2.5)",
            view: createOutcomeView(viewModel: MockOutcomeItemViewModel.overOutcomeUp)
        ))
        stackView.addArrangedSubview(createLabeledVariant(
            label: "Odds Down (Under 2.5)",
            view: createOutcomeView(viewModel: MockOutcomeItemViewModel.underOutcomeDown)
        ))
        stackView.addArrangedSubview(createLabeledVariant(
            label: "No Change",
            view: createOutcomeView(viewModel: MockOutcomeItemViewModel.drawOutcome)
        ))
    }

    private func addFontCustomizationVariants(to stackView: UIStackView) {
        // Default configuration (12pt title, 16pt value)
        stackView.addArrangedSubview(createLabeledVariant(
            label: "Default (Title: 12pt, Value: 16pt)",
            view: createOutcomeView(viewModel: MockOutcomeItemViewModel.homeOutcome, configuration: .default)
        ))

        // Compact configuration (10pt title, 14pt value)
        stackView.addArrangedSubview(createLabeledVariant(
            label: "Compact (Title: 10pt, Value: 14pt)",
            view: createOutcomeView(viewModel: MockOutcomeItemViewModel.homeOutcome, configuration: .compact)
        ))

        // Large custom configuration
        let largeConfig = OutcomeItemConfiguration(
            titleFontSize: 14.0,
            titleFontType: .medium,
            valueFontSize: 20.0,
            valueFontType: .bold
        )
        stackView.addArrangedSubview(createLabeledVariant(
            label: "Large (Title: 14pt Medium, Value: 20pt Bold)",
            view: createOutcomeView(viewModel: MockOutcomeItemViewModel.homeOutcome, configuration: largeConfig)
        ))

        // Small custom configuration
        let smallConfig = OutcomeItemConfiguration(
            titleFontSize: 9.0,
            titleFontType: .light,
            valueFontSize: 12.0,
            valueFontType: .semibold
        )
        stackView.addArrangedSubview(createLabeledVariant(
            label: "Small (Title: 9pt Light, Value: 12pt Semibold)",
            view: createOutcomeView(viewModel: MockOutcomeItemViewModel.homeOutcome, configuration: smallConfig)
        ))
    }

    private func addSizeVariants(to stackView: UIStackView) {
        // Standard size (100x52)
        stackView.addArrangedSubview(createLabeledVariant(
            label: "Standard (100x52pt)",
            view: createOutcomeView(viewModel: MockOutcomeItemViewModel.homeOutcome, width: 100, height: 52)
        ))

        // Compact size (80x40)
        stackView.addArrangedSubview(createLabeledVariant(
            label: "Compact (80x40pt)",
            view: createOutcomeView(viewModel: MockOutcomeItemViewModel.homeOutcome, configuration: .compact, width: 80, height: 40)
        ))

        // Wide size (140x52)
        stackView.addArrangedSubview(createLabeledVariant(
            label: "Wide (140x52pt)",
            view: createOutcomeView(viewModel: MockOutcomeItemViewModel.homeOutcome, width: 140, height: 52)
        ))

        // Tall size (100x70)
        stackView.addArrangedSubview(createLabeledVariant(
            label: "Tall (100x70pt)",
            view: createOutcomeView(viewModel: MockOutcomeItemViewModel.homeOutcome, width: 100, height: 70)
        ))

        // Three-way row (simulating inline card)
        let rowStack = UIStackView()
        rowStack.axis = .horizontal
        rowStack.spacing = 4
        rowStack.distribution = .fillEqually

        let homeView = createOutcomeView(viewModel: MockOutcomeItemViewModel.homeOutcome, configuration: .compact, width: nil, height: 40)
        homeView.setPosition(.singleFirst)
        let drawView = createOutcomeView(viewModel: MockOutcomeItemViewModel.drawOutcome, configuration: .compact, width: nil, height: 40)
        drawView.setPosition(.middle)
        let awayView = createOutcomeView(viewModel: MockOutcomeItemViewModel.awayOutcome, configuration: .compact, width: nil, height: 40)
        awayView.setPosition(.singleLast)

        rowStack.addArrangedSubview(homeView)
        rowStack.addArrangedSubview(drawView)
        rowStack.addArrangedSubview(awayView)

        stackView.addArrangedSubview(createLabeledVariant(
            label: "Three-Way Row (Compact, 40pt height)",
            view: rowStack
        ))
    }

    // MARK: - Helper Methods

    private func createOutcomeView(
        viewModel: MockOutcomeItemViewModel,
        configuration: OutcomeItemConfiguration? = nil,
        width: CGFloat? = 100,
        height: CGFloat? = 52
    ) -> OutcomeItemView {
        let view = OutcomeItemView(viewModel: viewModel, configuration: configuration)
        view.translatesAutoresizingMaskIntoConstraints = false

        var constraints: [NSLayoutConstraint] = []
        if let width = width {
            constraints.append(view.widthAnchor.constraint(equalToConstant: width))
        }
        if let height = height {
            constraints.append(view.heightAnchor.constraint(equalToConstant: height))
        }
        NSLayoutConstraint.activate(constraints)

        return view
    }

    private func createLabeledVariant(label: String, view: UIView) -> UIStackView {
        let labelView = UILabel()
        labelView.text = label
        labelView.font = StyleProvider.fontWith(type: .medium, size: 12)
        labelView.textColor = StyleProvider.Color.textSecondary

        let stack = UIStackView(arrangedSubviews: [labelView, view])
        stack.axis = .vertical
        stack.spacing = 6
        stack.alignment = .leading
        return stack
    }
}

// MARK: - Preview
#if DEBUG
@available(iOS 17.0, *)
#Preview("Basic States") {
    OutcomeItemViewSnapshotViewController(category: .basicStates)
}

@available(iOS 17.0, *)
#Preview("Display States") {
    OutcomeItemViewSnapshotViewController(category: .displayStates)
}

@available(iOS 17.0, *)
#Preview("Odds Change") {
    OutcomeItemViewSnapshotViewController(category: .oddsChange)
}

@available(iOS 17.0, *)
#Preview("Font Customization") {
    OutcomeItemViewSnapshotViewController(category: .fontCustomization)
}

@available(iOS 17.0, *)
#Preview("Size Variants") {
    OutcomeItemViewSnapshotViewController(category: .sizeVariants)
}
#endif
