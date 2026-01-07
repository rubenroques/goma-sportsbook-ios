import UIKit
import Combine

final public class CasinoCategorySectionCollectionViewCell: UICollectionViewCell {
    
    // MARK: - UI Elements
    private let categorySectionView = CasinoCategorySectionView()
    
    // MARK: - Properties
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Callbacks
    public var onGameSelected: ((String) -> Void) {
        get { categorySectionView.onGameSelected }
        set { categorySectionView.onGameSelected = newValue }
    }
    
    public var onCategoryButtonTapped: ((String) -> Void) {
        get { categorySectionView.onCategoryButtonTapped }
        set { categorySectionView.onCategoryButtonTapped = newValue }
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
        
        // Add casino category section view
        categorySectionView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(categorySectionView)
        
        // Setup constraints
        NSLayoutConstraint.activate([
            categorySectionView.topAnchor.constraint(equalTo: contentView.topAnchor),
            categorySectionView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            categorySectionView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            categorySectionView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        ])
    }
    
    // MARK: - Configuration
    public func configure(with viewModel: CasinoCategorySectionViewModelProtocol?) {
        // Clear existing bindings
        cancellables.removeAll()
        
        // Configure the wrapped casino category section view
        categorySectionView.configure(with: viewModel)
    }
    
    // MARK: - Reuse
    override public func prepareForReuse() {
        super.prepareForReuse()
        
        // Clear bindings and reset state
        cancellables.removeAll()
        categorySectionView.configure(with: nil) // Reset to placeholder state
        onGameSelected = { _ in } // Reset callbacks
        onCategoryButtonTapped = { _ in }
    }
}
