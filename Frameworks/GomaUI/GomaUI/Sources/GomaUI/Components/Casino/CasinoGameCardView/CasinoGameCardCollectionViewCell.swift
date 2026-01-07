import UIKit
import Combine

final public class CasinoGameCardCollectionViewCell: UICollectionViewCell {
    
    // MARK: - UI Elements
    private let gameCardView = CasinoGameCardView()
    
    // MARK: - Properties
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Callbacks
    public var onGameSelected: ((String) -> Void) {
        get { gameCardView.onGameSelected }
        set { gameCardView.onGameSelected = newValue }
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
        
        // Add game card view
        gameCardView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(gameCardView)
        
        // Setup constraints
        NSLayoutConstraint.activate([
            gameCardView.topAnchor.constraint(equalTo: contentView.topAnchor),
            gameCardView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            gameCardView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            gameCardView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        ])
    }
    
    // MARK: - Configuration
    public func configure(with viewModel: CasinoGameCardViewModelProtocol?) {
        // Clear existing bindings
        cancellables.removeAll()
        
        // Configure the wrapped game card view
        gameCardView.configure(with: viewModel)
    }
    
    // MARK: - Reuse
    override public func prepareForReuse() {
        super.prepareForReuse()
        
        // Clear bindings and reset state
        cancellables.removeAll()
        gameCardView.configure(with: nil) // Reset to placeholder state
        onGameSelected = { _ in } // Reset callback
    }
}
