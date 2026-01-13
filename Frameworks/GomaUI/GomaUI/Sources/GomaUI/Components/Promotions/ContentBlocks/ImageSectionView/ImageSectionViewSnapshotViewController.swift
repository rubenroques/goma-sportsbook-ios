import UIKit
import SwiftUI

// MARK: - Snapshot Category
enum ImageSectionSnapshotCategory: String, CaseIterable {
    case urlVariants = "URL Variants"
}

final class ImageSectionViewSnapshotViewController: UIViewController {

    private let category: ImageSectionSnapshotCategory

    init(category: ImageSectionSnapshotCategory) {
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
        titleLabel.text = "ImageSectionView - \(category.rawValue)"
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
        case .urlVariants:
            addUrlVariants(to: stackView)
        }
    }

    // MARK: - Category Variants

    private func addUrlVariants(to stackView: UIStackView) {
        stackView.addArrangedSubview(createLabeledVariant(
            label: "Default Mock",
            view: createImageSectionView(viewModel: MockImageSectionViewModel.defaultMock)
        ))
        stackView.addArrangedSubview(createLabeledVariant(
            label: "Valid URL Mock",
            view: createImageSectionView(viewModel: MockImageSectionViewModel.validUrlMock)
        ))
        stackView.addArrangedSubview(createLabeledVariant(
            label: "Invalid URL Mock",
            view: createImageSectionView(viewModel: MockImageSectionViewModel.invalidUrlMock)
        ))
    }

    // MARK: - Helper Methods

    private func createImageSectionView(
        viewModel: MockImageSectionViewModel,
        height: CGFloat = 120
    ) -> ImageSectionView {
        let view = ImageSectionView(viewModel: viewModel)
        view.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            view.heightAnchor.constraint(equalToConstant: height)
        ])
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
        stack.alignment = .fill
        return stack
    }
}

// MARK: - Preview
#if DEBUG
#Preview("URL Variants") {
    ImageSectionViewSnapshotViewController(category: .urlVariants)
}
#endif
