import UIKit
import SwiftUI

// MARK: - Snapshot Category
enum SportTypeSelectorItemSnapshotCategory: String, CaseIterable {
    case sportTypes = "Sport Types"
    case textLengths = "Text Lengths"
}

final class SportTypeSelectorItemViewSnapshotViewController: UIViewController {

    private let category: SportTypeSelectorItemSnapshotCategory

    init(category: SportTypeSelectorItemSnapshotCategory) {
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
        titleLabel.text = "SportTypeSelectorItemView - \(category.rawValue)"
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
        case .sportTypes:
            addSportTypesVariants(to: stackView)
        case .textLengths:
            addTextLengthsVariants(to: stackView)
        }
    }

    // MARK: - Category Variants

    private func addSportTypesVariants(to stackView: UIStackView) {
        // Row 1: Football, Basketball, Tennis
        let row1 = createHorizontalRow(items: [
            ("Football", MockSportTypeSelectorItemViewModel.footballMock),
            ("Basketball", MockSportTypeSelectorItemViewModel.basketballMock),
            ("Tennis", MockSportTypeSelectorItemViewModel.tennisMock)
        ])
        stackView.addArrangedSubview(createLabeledVariant(label: "Row 1", view: row1))

        // Row 2: Baseball, Hockey, Golf
        let row2 = createHorizontalRow(items: [
            ("Baseball", MockSportTypeSelectorItemViewModel.baseballMock),
            ("Hockey", MockSportTypeSelectorItemViewModel.hockeyMock),
            ("Golf", MockSportTypeSelectorItemViewModel.golfMock)
        ])
        stackView.addArrangedSubview(createLabeledVariant(label: "Row 2", view: row2))

        // Row 3: Volleyball, Soccer
        let row3 = createHorizontalRow(items: [
            ("Volleyball", MockSportTypeSelectorItemViewModel.volleyballMock),
            ("Soccer", MockSportTypeSelectorItemViewModel.soccerMock)
        ])
        stackView.addArrangedSubview(createLabeledVariant(label: "Row 3", view: row3))
    }

    private func addTextLengthsVariants(to stackView: UIStackView) {
        // Short name
        let shortSportData = SportTypeData(id: "ice", name: "Ice", iconName: "hockey")
        let shortVM = MockSportTypeSelectorItemViewModel(sportData: shortSportData)
        stackView.addArrangedSubview(createLabeledVariant(
            label: "Short Name (Ice)",
            view: createSportTypeView(viewModel: shortVM)
        ))

        // Medium name
        stackView.addArrangedSubview(createLabeledVariant(
            label: "Medium Name (Football)",
            view: createSportTypeView(viewModel: MockSportTypeSelectorItemViewModel.footballMock)
        ))

        // Longer name
        let longSportData = SportTypeData(id: "volleyball", name: "Volleyball", iconName: "volleyball")
        let longVM = MockSportTypeSelectorItemViewModel(sportData: longSportData)
        stackView.addArrangedSubview(createLabeledVariant(
            label: "Longer Name (Volleyball)",
            view: createSportTypeView(viewModel: longVM)
        ))

        // Very long name
        let veryLongSportData = SportTypeData(id: "table_tennis", name: "Table Tennis", iconName: "tennis")
        let veryLongVM = MockSportTypeSelectorItemViewModel(sportData: veryLongSportData)
        stackView.addArrangedSubview(createLabeledVariant(
            label: "Very Long Name (Table Tennis)",
            view: createSportTypeView(viewModel: veryLongVM)
        ))
    }

    // MARK: - Helper Methods

    private func createHorizontalRow(items: [(String, MockSportTypeSelectorItemViewModel)]) -> UIStackView {
        let rowStack = UIStackView()
        rowStack.axis = .horizontal
        rowStack.spacing = 8
        rowStack.distribution = .fillEqually

        for (_, viewModel) in items {
            let view = createSportTypeView(viewModel: viewModel)
            rowStack.addArrangedSubview(view)
        }

        return rowStack
    }

    private func createSportTypeView(viewModel: MockSportTypeSelectorItemViewModel) -> SportTypeSelectorItemView {
        let view = SportTypeSelectorItemView(viewModel: viewModel)
        view.translatesAutoresizingMaskIntoConstraints = false
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
#Preview("Sport Types") {
    SportTypeSelectorItemViewSnapshotViewController(category: .sportTypes)
}

#Preview("Text Lengths") {
    SportTypeSelectorItemViewSnapshotViewController(category: .textLengths)
}
#endif
