import UIKit

// MARK: - Snapshot Category
enum MatchHeaderCompactViewSnapshotCategory: String, CaseIterable {
    case basicVariants = "Basic Variants"
    case liveMatchVariants = "Live Match Variants"
}

final class MatchHeaderCompactViewSnapshotViewController: UIViewController {

    private let category: MatchHeaderCompactViewSnapshotCategory

    init(category: MatchHeaderCompactViewSnapshotCategory) {
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
        titleLabel.text = "MatchHeaderCompactView - \(category.rawValue)"
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
        case .basicVariants:
            addBasicVariants(to: stackView)
        case .liveMatchVariants:
            addLiveMatchVariants(to: stackView)
        }
    }

    // MARK: - Category Variants

    private func addBasicVariants(to stackView: UIStackView) {
        // Default
        stackView.addArrangedSubview(createLabeledVariant(
            label: "Default",
            view: createMatchHeaderCompactView(viewModel: MockMatchHeaderCompactViewModel.default)
        ))

        // Long Names
        stackView.addArrangedSubview(createLabeledVariant(
            label: "Long Names",
            view: createMatchHeaderCompactView(viewModel: MockMatchHeaderCompactViewModel.longNames)
        ))

        // Long Content
        stackView.addArrangedSubview(createLabeledVariant(
            label: "Long Content",
            view: createMatchHeaderCompactView(viewModel: MockMatchHeaderCompactViewModel.longContent)
        ))
    }

    private func addLiveMatchVariants(to stackView: UIStackView) {
        // Live Football Match
        stackView.addArrangedSubview(createLabeledVariant(
            label: "Live Football Match",
            view: createMatchHeaderCompactView(viewModel: MockMatchHeaderCompactViewModel.liveFootballMatch)
        ))

        // Live Tennis Match
        stackView.addArrangedSubview(createLabeledVariant(
            label: "Live Tennis Match",
            view: createMatchHeaderCompactView(viewModel: MockMatchHeaderCompactViewModel.liveTennisMatch)
        ))

        // Live Long Names
        stackView.addArrangedSubview(createLabeledVariant(
            label: "Live Long Names",
            view: createMatchHeaderCompactView(viewModel: MockMatchHeaderCompactViewModel.liveLongNames)
        ))
    }

    // MARK: - Helper Methods

    private func createMatchHeaderCompactView(viewModel: MockMatchHeaderCompactViewModel) -> MatchHeaderCompactView {
        let headerView = MatchHeaderCompactView(viewModel: viewModel)
        headerView.translatesAutoresizingMaskIntoConstraints = false
        return headerView
    }

    private func createLabeledVariant(label: String, view: UIView) -> UIStackView {
        let labelView = UILabel()
        labelView.text = label
        labelView.font = StyleProvider.fontWith(type: .medium, size: 12)
        labelView.textColor = StyleProvider.Color.textSecondary

        let containerView = UIView()
        containerView.backgroundColor = StyleProvider.Color.backgroundSecondary
        containerView.layer.cornerRadius = 8
        containerView.translatesAutoresizingMaskIntoConstraints = false

        containerView.addSubview(view)

        NSLayoutConstraint.activate([
            view.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 8),
            view.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 8),
            view.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -8),
            view.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -8)
        ])

        let stack = UIStackView(arrangedSubviews: [labelView, containerView])
        stack.axis = .vertical
        stack.spacing = 6
        stack.alignment = .fill
        return stack
    }
}

// MARK: - Preview
#if DEBUG
@available(iOS 17.0, *)
#Preview("Basic Variants") {
    MatchHeaderCompactViewSnapshotViewController(category: .basicVariants)
}

@available(iOS 17.0, *)
#Preview("Live Match Variants") {
    MatchHeaderCompactViewSnapshotViewController(category: .liveMatchVariants)
}
#endif
