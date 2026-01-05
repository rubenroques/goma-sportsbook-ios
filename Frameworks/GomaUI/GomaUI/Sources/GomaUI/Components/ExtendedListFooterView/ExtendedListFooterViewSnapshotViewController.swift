import UIKit
import SwiftUI

// MARK: - Snapshot Category
enum ExtendedListFooterSnapshotCategory: String, CaseIterable {
    case basicStates = "Basic States"
    case partnerVariants = "Partner Variants"
}

final class ExtendedListFooterViewSnapshotViewController: UIViewController {

    private let category: ExtendedListFooterSnapshotCategory

    init(category: ExtendedListFooterSnapshotCategory) {
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
        titleLabel.text = "ExtendedListFooterView - \(category.rawValue)"
        titleLabel.font = StyleProvider.fontWith(type: .bold, size: 16)
        titleLabel.textColor = StyleProvider.Color.textPrimary
        titleLabel.translatesAutoresizingMaskIntoConstraints = false

        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false

        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 24
        stackView.alignment = .fill
        stackView.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(titleLabel)
        view.addSubview(scrollView)
        scrollView.addSubview(stackView)

        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),

            scrollView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 16),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            stackView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            stackView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: 16),
            stackView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor, constant: -16),
            stackView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            stackView.widthAnchor.constraint(equalTo: scrollView.widthAnchor, constant: -32)
        ])

        addVariants(to: stackView)
    }

    private func addVariants(to stackView: UIStackView) {
        switch category {
        case .basicStates:
            addBasicStatesVariants(to: stackView)
        case .partnerVariants:
            addPartnerVariants(to: stackView)
        }
    }

    // MARK: - Category Variants

    private func addBasicStatesVariants(to stackView: UIStackView) {
        stackView.addArrangedSubview(createLabeledVariant(
            label: "Cameroon Footer (Full)",
            view: ExtendedListFooterView(viewModel: MockExtendedListFooterViewModel.cameroonFooter)
        ))
    }

    private func addPartnerVariants(to stackView: UIStackView) {
        stackView.addArrangedSubview(createLabeledVariant(
            label: "Minimal Footer",
            view: ExtendedListFooterView(viewModel: MockExtendedListFooterViewModel.minimalFooter)
        ))
        stackView.addArrangedSubview(createLabeledVariant(
            label: "Single Partner",
            view: ExtendedListFooterView(viewModel: MockExtendedListFooterViewModel.singlePartnerFooter)
        ))
        stackView.addArrangedSubview(createLabeledVariant(
            label: "Three Partners",
            view: ExtendedListFooterView(viewModel: MockExtendedListFooterViewModel.threePartnersFooter)
        ))
    }

    // MARK: - Helper Methods

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
@available(iOS 17.0, *)
#Preview("Basic States") {
    ExtendedListFooterViewSnapshotViewController(category: .basicStates)
}

@available(iOS 17.0, *)
#Preview("Partner Variants") {
    ExtendedListFooterViewSnapshotViewController(category: .partnerVariants)
}
#endif
