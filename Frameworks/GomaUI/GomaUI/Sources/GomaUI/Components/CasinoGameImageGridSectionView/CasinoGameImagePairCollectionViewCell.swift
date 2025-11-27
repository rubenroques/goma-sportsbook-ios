import UIKit

/// Wrapper collection view cell for CasinoGameImagePairView
/// Used in horizontal scrolling collection views to display game pairs
final class CasinoGameImagePairCollectionViewCell: UICollectionViewCell {

    // MARK: - Private Properties

    private let pairView = CasinoGameImagePairView()

    // MARK: - Callbacks

    var onGameSelected: ((String) -> Void) = { _ in }

    // MARK: - Initialization

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupSubviews()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Configuration

    func configure(with viewModel: CasinoGameImagePairViewModelProtocol?) {
        pairView.configure(with: viewModel)
        pairView.onGameSelected = { [weak self] gameId in
            self?.onGameSelected(gameId)
        }
    }

    // MARK: - Reuse

    override func prepareForReuse() {
        super.prepareForReuse()
        pairView.configure(with: nil)
        onGameSelected = { _ in }
    }

    // MARK: - Private Setup

    private func setupSubviews() {
        pairView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(pairView)

        NSLayoutConstraint.activate([
            pairView.topAnchor.constraint(equalTo: contentView.topAnchor),
            pairView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            pairView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            pairView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        ])
    }
}
