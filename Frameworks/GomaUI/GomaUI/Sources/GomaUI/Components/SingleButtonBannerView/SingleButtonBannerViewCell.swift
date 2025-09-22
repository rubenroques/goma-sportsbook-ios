import UIKit

/// Collection view cell that wraps SingleButtonBannerView following proper cell reuse pattern
final class SingleButtonBannerViewCell: UICollectionViewCell {

    // MARK: - Properties
    /// The banner view that this cell owns (never nil)
    private let bannerView: SingleButtonBannerView

    // MARK: - Initialization
    override init(frame: CGRect) {
        // Initialize with empty state view model
        self.bannerView = SingleButtonBannerView(viewModel: MockSingleButtonBannerViewModel.emptyState)

        super.init(frame: frame)
        setupView()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Setup
    private func setupView() {
        // Add banner view to content view
        bannerView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(bannerView)

        // Setup constraints to fill the entire cell
        NSLayoutConstraint.activate([
            bannerView.topAnchor.constraint(equalTo: contentView.topAnchor),
            bannerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            bannerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            bannerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        ])
    }

    // MARK: - Configuration
    /// Configure the cell with a view model (synchronous)
    func configure(with viewModel: SingleButtonBannerViewModelProtocol) {
        bannerView.configure(with: viewModel)
    }

    // MARK: - Cell Reuse
    override func prepareForReuse() {
        super.prepareForReuse()
        // Reset to empty state for proper reuse
        bannerView.configure(with: MockSingleButtonBannerViewModel.emptyState)
    }
}