import UIKit
import Combine

/// Collection view cell wrapper for NotificationCardView
final public class NotificationCardCollectionViewCell: UICollectionViewCell {
    
    // MARK: - Static Properties
    public static let reuseIdentifier = "NotificationCardCollectionViewCell"
    
    // MARK: - UI Elements
    private let notificationCardView = NotificationCardView()
    
    // MARK: - Properties
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Callbacks
    public var onActionTapped: ((NotificationData) -> Void) {
        get { notificationCardView.onActionTapped ?? { _ in } }
        set { notificationCardView.onActionTapped = newValue }
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
        backgroundColor = .clear
        
        // Add notification card view
        notificationCardView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(notificationCardView)
        
        // Setup constraints - card fills entire cell
        NSLayoutConstraint.activate([
            notificationCardView.topAnchor.constraint(equalTo: contentView.topAnchor),
            notificationCardView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            notificationCardView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            notificationCardView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        ])
    }
    
    // MARK: - Configuration
    public func configure(with notification: NotificationData, onActionTapped: @escaping (NotificationData) -> Void) {
        // Clear existing bindings
        cancellables.removeAll()
        
        // Configure the wrapped notification card view
        notificationCardView.configure(with: notification, onActionTapped: onActionTapped)
    }
    
    // MARK: - Reuse
    override public func prepareForReuse() {
        super.prepareForReuse()
        
        // Clear bindings and reset state
        cancellables.removeAll()
        onActionTapped = { _ in } // Reset callback
    }
}