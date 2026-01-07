import UIKit
import SwiftUI

final class InlineScoreViewSnapshotViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .backgroundTestColor
        setupUI()
    }

    private func setupUI() {
        let titleLabel = UILabel()
        titleLabel.text = "InlineScoreView"
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

        // Tennis match (multiple sets + points)
        stackView.addArrangedSubview(makeVariant("Tennis Match", InlineScoreView(viewModel: MockInlineScoreViewModel.tennisMatch)))

        // Football match (single score)
        stackView.addArrangedSubview(makeVariant("Football Match", InlineScoreView(viewModel: MockInlineScoreViewModel.footballMatch)))

        // Football tied
        stackView.addArrangedSubview(makeVariant("Football Tied", InlineScoreView(viewModel: MockInlineScoreViewModel.footballMatchTied)))

        // Basketball match (quarters)
        stackView.addArrangedSubview(makeVariant("Basketball Match", InlineScoreView(viewModel: MockInlineScoreViewModel.basketballMatch)))

        // Empty state
        stackView.addArrangedSubview(makeVariant("Empty", InlineScoreView(viewModel: MockInlineScoreViewModel.empty)))
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
#Preview {
    InlineScoreViewSnapshotViewController()
}
#endif
