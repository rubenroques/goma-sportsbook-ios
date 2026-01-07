import UIKit

/// Collection view cell that wraps MatchBannerView following proper cell reuse pattern
final class MatchBannerViewCell: UICollectionViewCell {

    // MARK: - Properties
    /// The match banner view that this cell owns (never nil)
    private let matchBannerView: MatchBannerView

    // MARK: - Initialization
    override init(frame: CGRect) {
        // Initialize with empty state view model
        self.matchBannerView = MatchBannerView()

        super.init(frame: frame)
        setupView()

        // Configure with empty state initially
        matchBannerView.configure(with: MockMatchBannerViewModel.emptyState)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Setup
    private func setupView() {
        // Add banner view to content view
        matchBannerView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(matchBannerView)

        // Setup constraints to fill the entire cell
        NSLayoutConstraint.activate([
            matchBannerView.topAnchor.constraint(equalTo: contentView.topAnchor),
            matchBannerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            matchBannerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            matchBannerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        ])
    }

    // MARK: - Configuration
    /// Configure the cell with a view model (synchronous)
    func configure(with viewModel: MatchBannerViewModelProtocol) {
        matchBannerView.configure(with: viewModel)
    }

    // MARK: - Cell Reuse
    override func prepareForReuse() {
        super.prepareForReuse()
        // Reset to empty state for proper reuse
        matchBannerView.configure(with: MockMatchBannerViewModel.emptyState)
    }
}