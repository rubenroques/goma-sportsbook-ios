import UIKit

/// Wrapper collection view cell for CasinoGameImageView
/// Used in grid collection views to display casino game images
public final class CasinoGameImageCollectionViewCell: UICollectionViewCell {

    // MARK: - Private Properties

    private let gameImageView = CasinoGameImageView()

    // MARK: - Initialization

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupSubviews()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Configuration

    public func configure(with viewModel: CasinoGameImageViewModelProtocol?) {
        gameImageView.configure(with: viewModel)
    }

    // MARK: - Reuse

    public override func prepareForReuse() {
        super.prepareForReuse()
        gameImageView.prepareForReuse()
    }

    // MARK: - Private Setup

    private func setupSubviews() {
        gameImageView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(gameImageView)

        NSLayoutConstraint.activate([
            gameImageView.topAnchor.constraint(equalTo: contentView.topAnchor),
            gameImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            gameImageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            gameImageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        ])
    }
}
