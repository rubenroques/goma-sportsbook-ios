import UIKit
import Combine

final public class SportTypeSelectorCollectionViewCell: UICollectionViewCell {
    
    // MARK: - Static Properties
    public static let reuseIdentifier = "SportTypeSelectorCollectionViewCell"
    
    // MARK: - Private Properties
    private var sportItemView: SportTypeSelectorItemView?
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Initialization
    public override init(frame: CGRect) {
        super.init(frame: frame)
        setupCell()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle
    public override func prepareForReuse() {
        super.prepareForReuse()
        cancellables.removeAll()
        sportItemView?.removeFromSuperview()
        sportItemView = nil
    }
    
    // MARK: - Setup
    private func setupCell() {
        contentView.backgroundColor = .clear
        backgroundColor = .clear
    }
    
    // MARK: - Configuration
    public func configure(
        with viewModel: SportTypeSelectorItemViewModelProtocol,
        onTap: @escaping (SportTypeData) -> Void
    ) {
        // Remove existing view if any
        sportItemView?.removeFromSuperview()
        
        // Create new sport item view
        let itemView = SportTypeSelectorItemView(viewModel: viewModel)
        itemView.onTap = onTap
        itemView.translatesAutoresizingMaskIntoConstraints = false
        
        contentView.addSubview(itemView)
        
        NSLayoutConstraint.activate([
            itemView.topAnchor.constraint(equalTo: contentView.topAnchor),
            itemView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            itemView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            itemView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        ])
        
        self.sportItemView = itemView
    }
}