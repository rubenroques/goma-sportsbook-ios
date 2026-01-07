import UIKit
import Combine

/// Collection view cell wrapper for SeeMoreButtonView component
final public class SeeMoreButtonCollectionViewCell: UICollectionViewCell {
    
    // MARK: - UI Elements
    
    private let seeMoreButtonView: SeeMoreButtonView
    
    // MARK: - Properties
    
    private var cancellables = Set<AnyCancellable>()
    private var currentViewModel: SeeMoreButtonViewModelProtocol?
    
    // MARK: - Callbacks
    
    /// Callback fired when the see more button is tapped
    public var onSeeMoreTapped: (() -> Void) {
        get { seeMoreButtonView.onButtonTapped }
        set { seeMoreButtonView.onButtonTapped = newValue }
    }
    
    // MARK: - Initialization
    
    override init(frame: CGRect) {
        // Initialize with a default mock for proper setup
        self.seeMoreButtonView = SeeMoreButtonView(viewModel: MockSeeMoreButtonViewModel.defaultMock)
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
        
        // Add see more button view
        seeMoreButtonView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(seeMoreButtonView)
        
        // Setup constraints - button fills cell with padding
        NSLayoutConstraint.activate([
            seeMoreButtonView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            seeMoreButtonView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            seeMoreButtonView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            seeMoreButtonView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8)
        ])
    }
    
    // MARK: - Configuration
    
    /// Configure the cell with a SeeMoreButton ViewModel
    /// - Parameter viewModel: The ViewModel to configure the button with
    public func configure(with viewModel: SeeMoreButtonViewModelProtocol?) {
        // Clear existing bindings
        cancellables.removeAll()
        
        // Store current view model reference
        currentViewModel = viewModel
        
        // Configure the wrapped see more button view
        seeMoreButtonView.configure(with: viewModel)
    }
    
    /// Configure with button data and state (convenience method)
    /// - Parameters:
    ///   - buttonData: The button configuration data
    ///   - isLoading: Whether the button should show loading state
    ///   - isEnabled: Whether the button should be enabled
    public func configure(
        with buttonData: SeeMoreButtonData,
        isLoading: Bool = false,
        isEnabled: Bool = true
    ) {
        let mockViewModel = MockSeeMoreButtonViewModel(
            buttonData: buttonData,
            isLoading: isLoading,
            isEnabled: isEnabled
        )
        configure(with: mockViewModel)
    }
    
    // MARK: - Cell Lifecycle
    
    override public func prepareForReuse() {
        super.prepareForReuse()
        
        // Clear bindings and reset state
        cancellables.removeAll()
        currentViewModel = nil
        
        // Reset to placeholder state
        seeMoreButtonView.configure(with: nil)
        
        // Reset callback
        onSeeMoreTapped = { }
    }
    
    // MARK: - Layout
    
    override public func preferredLayoutAttributesFitting(_ layoutAttributes: UICollectionViewLayoutAttributes) -> UICollectionViewLayoutAttributes {
        // Ensure the cell has the correct size for the button
        let targetSize = CGSize(width: layoutAttributes.frame.width, height: 60) // 44pt button + 16pt padding
        
        let fittingSize = contentView.systemLayoutSizeFitting(
            targetSize,
            withHorizontalFittingPriority: .required,
            verticalFittingPriority: .fittingSizeLevel
        )
        
        layoutAttributes.frame.size = fittingSize
        return layoutAttributes
    }
    
    // MARK: - Accessibility
    
    override public var isAccessibilityElement: Bool {
        get { return seeMoreButtonView.isAccessibilityElement }
        set { seeMoreButtonView.isAccessibilityElement = newValue }
    }
    
    override public var accessibilityLabel: String? {
        get { return seeMoreButtonView.accessibilityLabel }
        set { seeMoreButtonView.accessibilityLabel = newValue }
    }
    
    override public var accessibilityHint: String? {
        get { return seeMoreButtonView.accessibilityHint }
        set { seeMoreButtonView.accessibilityHint = newValue }
    }
    
    override public var accessibilityTraits: UIAccessibilityTraits {
        get { return seeMoreButtonView.accessibilityTraits }
        set { seeMoreButtonView.accessibilityTraits = newValue }
    }
}
