import UIKit

// MARK: - Snapshot Category
enum MatchParticipantsInfoViewSnapshotCategory: String, CaseIterable {
    case horizontalVariants = "Horizontal Variants"
    case verticalVariants = "Vertical Variants"
}

final class MatchParticipantsInfoViewSnapshotViewController: UIViewController {

    private let category: MatchParticipantsInfoViewSnapshotCategory

    init(category: MatchParticipantsInfoViewSnapshotCategory) {
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
        titleLabel.text = "MatchParticipantsInfoView - \(category.rawValue)"
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
        case .horizontalVariants:
            addHorizontalVariants(to: stackView)
        case .verticalVariants:
            addVerticalVariants(to: stackView)
        }
    }

    // MARK: - Category Variants

    private func addHorizontalVariants(to stackView: UIStackView) {
        // Pre-Live
        stackView.addArrangedSubview(createLabeledVariant(
            label: "Pre-Live",
            view: createMatchParticipantsInfoView(viewModel: MockMatchParticipantsInfoViewModel.horizontalPreLive)
        ))

        // Live
        stackView.addArrangedSubview(createLabeledVariant(
            label: "Live",
            view: createMatchParticipantsInfoView(viewModel: MockMatchParticipantsInfoViewModel.horizontalLive)
        ))

        // Ended
        stackView.addArrangedSubview(createLabeledVariant(
            label: "Ended",
            view: createMatchParticipantsInfoView(viewModel: MockMatchParticipantsInfoViewModel.horizontalEnded)
        ))

        // Long Team Names
        stackView.addArrangedSubview(createLabeledVariant(
            label: "Long Team Names",
            view: createMatchParticipantsInfoView(viewModel: MockMatchParticipantsInfoViewModel.longTeamNames)
        ))
    }

    private func addVerticalVariants(to stackView: UIStackView) {
        // Tennis Live
        stackView.addArrangedSubview(createLabeledVariant(
            label: "Tennis Live",
            view: createMatchParticipantsInfoView(viewModel: MockMatchParticipantsInfoViewModel.verticalTennisLive)
        ))

        // Basketball Live
        stackView.addArrangedSubview(createLabeledVariant(
            label: "Basketball Live",
            view: createMatchParticipantsInfoView(viewModel: MockMatchParticipantsInfoViewModel.verticalBasketballLive)
        ))

        // Volleyball Live
        stackView.addArrangedSubview(createLabeledVariant(
            label: "Volleyball Live",
            view: createMatchParticipantsInfoView(viewModel: MockMatchParticipantsInfoViewModel.verticalVolleyballLive)
        ))

        // Football Pre-Live
        stackView.addArrangedSubview(createLabeledVariant(
            label: "Football Pre-Live",
            view: createMatchParticipantsInfoView(viewModel: MockMatchParticipantsInfoViewModel.verticalFootballPreLive)
        ))
    }

    // MARK: - Helper Methods

    private func createMatchParticipantsInfoView(viewModel: MockMatchParticipantsInfoViewModel) -> MatchParticipantsInfoView {
        let participantsView = MatchParticipantsInfoView(viewModel: viewModel)
        participantsView.translatesAutoresizingMaskIntoConstraints = false
        return participantsView
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
#Preview("Horizontal Variants") {
    MatchParticipantsInfoViewSnapshotViewController(category: .horizontalVariants)
}

@available(iOS 17.0, *)
#Preview("Vertical Variants") {
    MatchParticipantsInfoViewSnapshotViewController(category: .verticalVariants)
}
#endif
