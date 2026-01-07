import UIKit
import Combine

/// Collection view cell wrapper for CasinoGameImageGridSectionView
/// Provides a thin wrapper for use in UICollectionView
public final class CasinoGameImageGridSectionCollectionViewCell: UICollectionViewCell {

    // MARK: - UI Elements

    private let gridSectionView = CasinoGameImageGridSectionView()

    // MARK: - Properties

    private var cancellables = Set<AnyCancellable>()

    // MARK: - Callbacks

    public var onGameSelected: ((String) -> Void) {
        get { gridSectionView.onGameSelected }
        set { gridSectionView.onGameSelected = newValue }
    }

    public var onCategoryButtonTapped: ((String) -> Void) {
        get { gridSectionView.onCategoryButtonTapped }
        set { gridSectionView.onCategoryButtonTapped = newValue }
    }

    // MARK: - Initialization

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupCell()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Setup

    private func setupCell() {
        contentView.backgroundColor = .clear

        // Add grid section view
        gridSectionView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(gridSectionView)

        // Setup constraints
        NSLayoutConstraint.activate([
            gridSectionView.topAnchor.constraint(equalTo: contentView.topAnchor),
            gridSectionView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            gridSectionView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            gridSectionView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        ])
    }

    // MARK: - Configuration

    public func configure(with viewModel: CasinoGameImageGridSectionViewModelProtocol?) {
        // Clear existing bindings
        cancellables.removeAll()

        // Configure the wrapped grid section view
        gridSectionView.configure(with: viewModel)
    }

    // MARK: - Reuse

    override public func prepareForReuse() {
        super.prepareForReuse()

        // Clear bindings and reset state
        cancellables.removeAll()
        gridSectionView.configure(with: nil) // Reset to placeholder state
        onGameSelected = { _ in } // Reset callbacks
        onCategoryButtonTapped = { _ in }
    }
}
