import UIKit
import SwiftUI

// MARK: - Snapshot Category
enum CopyableCodeSnapshotCategory: String, CaseIterable {
    case basicStates = "Basic States"
    case contentVariants = "Content Variants"
}

final class CopyableCodeViewSnapshotViewController: UIViewController {

    private let category: CopyableCodeSnapshotCategory

    init(category: CopyableCodeSnapshotCategory) {
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
        titleLabel.text = "CopyableCodeView - \(category.rawValue)"
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
        case .contentVariants:
            addContentVariants(to: stackView)
        }
    }

    // MARK: - Category Variants

    private func addBasicStatesVariants(to stackView: UIStackView) {
        stackView.addArrangedSubview(createLabeledVariant(
            label: "Booking Code",
            view: CopyableCodeView(viewModel: MockCopyableCodeViewModel.bookingCodeMock)
        ))
        stackView.addArrangedSubview(createLabeledVariant(
            label: "Promo Code",
            view: CopyableCodeView(viewModel: MockCopyableCodeViewModel.promoCodeMock)
        ))
        stackView.addArrangedSubview(createLabeledVariant(
            label: "Referral Code",
            view: CopyableCodeView(viewModel: MockCopyableCodeViewModel.referralCodeMock)
        ))
    }

    private func addContentVariants(to stackView: UIStackView) {
        stackView.addArrangedSubview(createLabeledVariant(
            label: "Standard Code",
            view: CopyableCodeView(viewModel: MockCopyableCodeViewModel.bookingCodeMock)
        ))
        stackView.addArrangedSubview(createLabeledVariant(
            label: "Long Code",
            view: CopyableCodeView(viewModel: MockCopyableCodeViewModel.longCodeMock)
        ))

        // Short code variant
        let shortCodeVM = MockCopyableCodeViewModel(
            code: "AB",
            label: "Copy Code"
        )
        stackView.addArrangedSubview(createLabeledVariant(
            label: "Short Code",
            view: CopyableCodeView(viewModel: shortCodeVM)
        ))

        // Long label variant
        let longLabelVM = MockCopyableCodeViewModel(
            code: "CODE123",
            label: "Copy Your Special Promotional Code Here"
        )
        stackView.addArrangedSubview(createLabeledVariant(
            label: "Long Label",
            view: CopyableCodeView(viewModel: longLabelVM)
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
#Preview("Basic States") {
    CopyableCodeViewSnapshotViewController(category: .basicStates)
}

#Preview("Content Variants") {
    CopyableCodeViewSnapshotViewController(category: .contentVariants)
}
#endif
