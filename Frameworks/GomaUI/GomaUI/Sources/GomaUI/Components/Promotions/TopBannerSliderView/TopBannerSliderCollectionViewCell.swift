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
            // Configure the existing view with new viewModel (synchronous)
            bannerSliderView.configure(with: viewModel)
        }
        // If viewModel is nil, keep the current viewModel
    }
    
    // MARK: - Reuse
    override public func prepareForReuse() {
        super.prepareForReuse()

        // Clear bindings and reset callbacks
        cancellables.removeAll()
        onBannerTapped = { _ in }
        onPageChanged = { _ in }

        // Clear content without using mock data
        bannerSliderView.clearContent()
    }
}