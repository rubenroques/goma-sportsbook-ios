import UIKit
import Combine
import GomaUI

// MARK: - PillSelectorBarCollectionViewCell
final class PillSelectorBarCollectionViewCell: UICollectionViewCell {

    // MARK: - Properties
    static let identifier = "PillSelectorBarCollectionViewCell"

    private var pillSelectorBar: PillSelectorBarView?
    private var cancellables = Set<AnyCancellable>()

    // MARK: - Initialization
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Lifecycle
    override func prepareForReuse() {
        super.prepareForReuse()
        pillSelectorBar?.removeFromSuperview()
        pillSelectorBar = nil
        cancellables.removeAll()
    }

    // MARK: - Setup
    private func setupViews() {
        contentView.backgroundColor = UIColor.clear
    }

    // MARK: - Configuration
    func configure(
        with viewModel: PillSelectorBarViewModelProtocol,
        onPillSelected: @escaping (String) -> Void = { _ in }
    ) {
        // Remove existing pill selector bar
        pillSelectorBar?.removeFromSuperview()
        cancellables.removeAll()

        // Create new pill selector bar
        let selectorBar = PillSelectorBarView(viewModel: viewModel)
        selectorBar.translatesAutoresizingMaskIntoConstraints = false

        // Handle events
        selectorBar.onPillSelected = onPillSelected

        // Add to content view
        contentView.addSubview(selectorBar)
        pillSelectorBar = selectorBar

        // Setup constraints for dynamic height
        NSLayoutConstraint.activate([
            selectorBar.topAnchor.constraint(equalTo: contentView.topAnchor),
            selectorBar.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            selectorBar.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            selectorBar.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),

            // Set intrinsic height for the pill selector bar
            selectorBar.heightAnchor.constraint(equalToConstant: 56)
        ])
    }

    // MARK: - Dynamic Height Support
    override func preferredLayoutAttributesFitting(_ layoutAttributes: UICollectionViewLayoutAttributes) -> UICollectionViewLayoutAttributes {
        // Enable dynamic height calculation
        layoutIfNeeded()

        let targetSize = CGSize(width: layoutAttributes.frame.width, height: UIView.layoutFittingCompressedSize.height)
        let fittingSize = contentView.systemLayoutSizeFitting(
            targetSize,
            withHorizontalFittingPriority: .required,
            verticalFittingPriority: .fittingSizeLevel
        )

        guard let attributes = layoutAttributes.copy() as? UICollectionViewLayoutAttributes else {
            return layoutAttributes
        }
        attributes.frame.size.height = fittingSize.height

        return attributes
    }

}
