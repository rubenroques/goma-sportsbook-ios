import UIKit
import Combine

final public class TopBannerSliderCollectionViewCell: UICollectionViewCell {
    
    // MARK: - UI Elements
    private let bannerSliderView = TopBannerSliderView(viewModel: MockTopBannerSliderViewModel.defaultMock)
    
    // MARK: - Properties
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Callbacks
    public var onBannerTapped: ((Int) -> Void) {
        get { bannerSliderView.onBannerTapped }
        set { bannerSliderView.onBannerTapped = newValue }
    }
    
    public var onPageChanged: ((Int) -> Void) {
        get { bannerSliderView.onPageChanged }
        set { bannerSliderView.onPageChanged = newValue }
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
        
        // Add banner slider view
        bannerSliderView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(bannerSliderView)
        
        // Setup constraints
        NSLayoutConstraint.activate([
            bannerSliderView.topAnchor.constraint(equalTo: contentView.topAnchor),
            bannerSliderView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            bannerSliderView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            bannerSliderView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        ])
    }
    
    // MARK: - Configuration
    public func configure(with viewModel: TopBannerSliderViewModelProtocol?) {
        // Clear existing bindings
        cancellables.removeAll()
        
        if let viewModel = viewModel {
            // Create new banner slider view with actual viewModel
            let newBannerSliderView = TopBannerSliderView(viewModel: viewModel)
            
            // Remove old view
            bannerSliderView.removeFromSuperview()
            
            // Add new view with proper constraints
            newBannerSliderView.translatesAutoresizingMaskIntoConstraints = false
            contentView.addSubview(newBannerSliderView)
            
            NSLayoutConstraint.activate([
                newBannerSliderView.topAnchor.constraint(equalTo: contentView.topAnchor),
                newBannerSliderView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
                newBannerSliderView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
                newBannerSliderView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
            ])
        }
        // If viewModel is nil, keep the placeholder mock viewModel
    }
    
    // MARK: - Reuse
    override public func prepareForReuse() {
        super.prepareForReuse()
        
        // Clear bindings and reset callbacks
        cancellables.removeAll()
        onBannerTapped = { _ in }
        onPageChanged = { _ in }
        
        // Reset to placeholder state if needed
        configure(with: MockTopBannerSliderViewModel.defaultMock)
    }
}