import UIKit
import SwiftUI

final class PillItemViewSnapshotViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .backgroundTestColor
        setupUI()
    }

    private func setupUI() {
        let titleLabel = UILabel()
        titleLabel.text = "PillItemView"
        titleLabel.font = .systemFont(ofSize: 16, weight: .bold)
        titleLabel.textColor = .darkGray
        titleLabel.translatesAutoresizingMaskIntoConstraints = false

        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 20
        stackView.alignment = .leading
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

        // Selected state
        let selectedVM = MockPillItemViewModel(
            pillData: PillData(
                id: "1",
                title: "Football",
                leftIconName: "sportscourt.fill",
                showExpandIcon: true,
                isSelected: true
            )
        )
        stackView.addArrangedSubview(makeVariant("Selected", PillItemView(viewModel: selectedVM)))

        // Unselected state
        let unselectedVM = MockPillItemViewModel(
            pillData: PillData(
                id: "2",
                title: "Popular",
                leftIconName: "flame.fill",
                showExpandIcon: false,
                isSelected: false
            )
        )
        stackView.addArrangedSubview(makeVariant("Unselected", PillItemView(viewModel: unselectedVM)))

        // Text only (no icon)
        let textOnlyVM = MockPillItemViewModel(
            pillData: PillData(
                id: "3",
                title: "All Sports",
                leftIconName: nil,
                showExpandIcon: false,
                isSelected: false
            )
        )
        stackView.addArrangedSubview(makeVariant("Text Only", PillItemView(viewModel: textOnlyVM)))

        // Long text
        let longTextVM = MockPillItemViewModel(
            pillData: PillData(
                id: "4",
                title: "International Championships",
                leftIconName: "trophy.fill",
                showExpandIcon: true,
                isSelected: false
            )
        )
        stackView.addArrangedSubview(makeVariant("Long Text", PillItemView(viewModel: longTextVM)))
    }

    private func makeVariant(_ name: String, _ component: UIView) -> UIStackView {
        let label = UILabel()
        label.text = name
        label.font = .systemFont(ofSize: 12, weight: .medium)
        label.textColor = .gray

        let stack = UIStackView(arrangedSubviews: [label, component])
        stack.axis = .vertical
        stack.spacing = 6
        stack.alignment = .leading
        return stack
    }
}

// MARK: - Preview
#if DEBUG
@available(iOS 17.0, *)
#Preview {
    PillItemViewSnapshotViewController()
}
#endif
