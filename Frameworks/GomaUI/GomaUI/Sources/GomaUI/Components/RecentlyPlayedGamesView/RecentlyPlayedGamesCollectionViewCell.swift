import UIKit
import Combine

final public class RecentlyPlayedGamesCollectionViewCell: UICollectionViewCell {
    
    // MARK: - UI Elements
    private let recentlyPlayedGamesView = RecentlyPlayedGamesView()
    
    // MARK: - Properties
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Callbacks
    public var onGameSelected: ((String) -> Void) {
        get { recentlyPlayedGamesView.onGameSelected }
        set { recentlyPlayedGamesView.onGameSelected = newValue }
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
        
        // Add recently played games view
        recentlyPlayedGamesView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(recentlyPlayedGamesView)
        
        // Setup constraints
        NSLayoutConstraint.activate([
            recentlyPlayedGamesView.topAnchor.constraint(equalTo: contentView.topAnchor),
            recentlyPlayedGamesView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            recentlyPlayedGamesView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            recentlyPlayedGamesView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        ])
    }
    
    // MARK: - Configuration
    public func configure(with viewModel: RecentlyPlayedGamesViewModelProtocol?) {
        // Clear existing bindings
        cancellables.removeAll()
        
        // Configure the wrapped recently played games view
        recentlyPlayedGamesView.configure(with: viewModel)
    }
    
    // MARK: - Reuse
    override public func prepareForReuse() {
        super.prepareForReuse()
        
        // Clear bindings and reset state
        cancellables.removeAll()
        recentlyPlayedGamesView.configure(with: nil) // Reset to placeholder state
        onGameSelected = { _ in } // Reset callback
    }
}