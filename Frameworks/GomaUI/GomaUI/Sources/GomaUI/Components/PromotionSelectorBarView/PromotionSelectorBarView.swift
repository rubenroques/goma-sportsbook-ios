import UIKit
import Combine
import SwiftUI

final public class PromotionSelectorBarView: UIView {
    
    // MARK: - Private Properties
    private let scrollView = UIScrollView()
    private let stackView = UIStackView()
    private let viewModel: PromotionSelectorBarViewModelProtocol
    
    private var cancellables = Set<AnyCancellable>()
    private var promotionItemViews: [String: PromotionItemView] = [:]
    private var promotionItemViewModels: [String: MockPromotionItemViewModel] = [:]
    private var currentDisplayState: PromotionSelectorBarDisplayState?
    
    // MARK: - Layout Constants
    private struct Constants {
        static let horizontalPadding: CGFloat = 16.0
        static let promotionItemSpacing: CGFloat = 12.0
        static let minimumHeight: CGFloat = 60.0
        static let animationDuration: TimeInterval = 0.3
    }
    
    // MARK: - Public Properties
    public var onPromotionSelected: ((String) -> Void) = { _ in }
    
    // MARK: - Public Methods
    public func updateBarData(_ barData: PromotionSelectorBarData) {
        viewModel.updateBarData(barData)
    }
    
    public func updateSelection(_ selectedId: String?) {
        // Only update selection state without recreating views
        guard let currentState = currentDisplayState else { return }
        
        let updatedBarData = PromotionSelectorBarData(
            id: currentState.barData.id,
            promotionItems: currentState.barData.promotionItems,
            selectedPromotionId: selectedId,
            isScrollEnabled: currentState.barData.isScrollEnabled,
            allowsVisualStateChanges: currentState.barData.allowsVisualStateChanges
        )
        
        let newDisplayState = PromotionSelectorBarDisplayState(
            barData: updatedBarData,
            isVisible: currentState.isVisible,
            isUserInteractionEnabled: currentState.isUserInteractionEnabled
        )
        
        updateSelectionStateOnly(newDisplayState)
    }
    
    // MARK: - Initialization
    public init(viewModel: PromotionSelectorBarViewModelProtocol) {
        self.viewModel = viewModel
        super.init(frame: .zero)
        
        setupSubviews()
        setupBindings()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
    }
    
    private func setupBindings() {
        // Display state binding
        viewModel.displayStatePublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] displayState in
                self?.updateDisplayState(displayState)
            }
            .store(in: &cancellables)
        
        // Selection event binding
        viewModel.selectionEventPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] selectionEvent in
                self?.handleSelectionEvent(selectionEvent)
            }
            .store(in: &cancellables)
    }
    
    private func setupSubviews() {
        addSubview(scrollView)
        scrollView.addSubview(stackView)
        
        setupScrollView()
        setupStackView()
        setupConstraints()
    }
    
    private func setupScrollView() {
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.showsVerticalScrollIndicator = false
        scrollView.contentInsetAdjustmentBehavior = .never
    }
    
    private func setupStackView() {
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .horizontal
        stackView.spacing = Constants.promotionItemSpacing
        stackView.alignment = .center
        stackView.distribution = .fill
    }
    
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            // Scroll view
            scrollView.leadingAnchor.constraint(equalTo: leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: trailingAnchor),
            scrollView.topAnchor.constraint(equalTo: topAnchor),
            scrollView.bottomAnchor.constraint(equalTo: bottomAnchor),
            scrollView.heightAnchor.constraint(equalToConstant: Constants.minimumHeight),
            
            // Stack view
            stackView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: Constants.horizontalPadding),
            stackView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor, constant: -Constants.horizontalPadding),
            stackView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            stackView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            stackView.heightAnchor.constraint(equalTo: scrollView.heightAnchor)
        ])
    }
    
    // MARK: - Private Methods
    private func updateDisplayState(_ displayState: PromotionSelectorBarDisplayState) {
        currentDisplayState = displayState
        
        // Update visibility
        isHidden = !displayState.isVisible
        
        // Update user interaction
        isUserInteractionEnabled = displayState.isUserInteractionEnabled
        
        // Update scroll view
        scrollView.isScrollEnabled = displayState.barData.isScrollEnabled
        
        // Update promotion items
        updatePromotionItems(displayState.barData.promotionItems, selectedId: displayState.barData.selectedPromotionId)
    }
    
    private func updateSelectionStateOnly(_ displayState: PromotionSelectorBarDisplayState) {
        currentDisplayState = displayState
        
        // Only update the selection state of existing views without recreating them
        updateSelectionStates(selectedId: displayState.barData.selectedPromotionId)
    }
    
    private func updateSelectionStates(selectedId: String?) {
        // Update selection states for existing promotion item views
        for (itemId, promotionItemView) in promotionItemViews {
            let isSelected = itemId == selectedId
            
            // Directly update the visual state without going through ViewModel
            // This preserves scroll position while updating selection
            updatePromotionItemSelectionState(promotionItemView, isSelected: isSelected)
        }
    }
    
    private func updatePromotionItemSelectionState(_ promotionItemView: PromotionItemView, isSelected: Bool) {
        // Directly update the visual state of the promotion item
        // This is a bit of a hack but necessary to preserve scroll position
        UIView.animate(withDuration: 0.2) {
            if isSelected {
                promotionItemView.backgroundColor = StyleProvider.Color.highlightPrimary
                promotionItemView.layer.borderColor = StyleProvider.Color.highlightPrimary.cgColor
                
                // Update text color to white for selected state
                if let titleLabel = promotionItemView.subviews.first(where: { $0 is UILabel }) as? UILabel {
                    titleLabel.textColor = .white
                }
            } else {
                promotionItemView.backgroundColor = StyleProvider.Color.backgroundSecondary
                promotionItemView.layer.borderColor = StyleProvider.Color.backgroundBorder.cgColor
                
                // Update text color to primary for unselected state
                if let titleLabel = promotionItemView.subviews.first(where: { $0 is UILabel }) as? UILabel {
                    titleLabel.textColor = StyleProvider.Color.textPrimary
                }
            }
        }
    }
    
    private func updatePromotionItems(_ items: [PromotionItemData], selectedId: String?) {
        // Clear existing views
        promotionItemViews.values.forEach { view in
            stackView.removeArrangedSubview(view)
            view.removeFromSuperview()
        }
        promotionItemViews.removeAll()
        promotionItemViewModels.removeAll()
        
        // Create new promotion item views
        createPromotionItemViews(for: items, selectedId: selectedId)
    }
    
    private func createPromotionItemViews(for items: [PromotionItemData], selectedId: String?) {
        for item in items {
            let updatedItemData = PromotionItemData(
                id: item.id,
                title: item.title,
                isSelected: item.id == selectedId,
                category: item.category
            )
            let isReadOnly = currentDisplayState?.barData.allowsVisualStateChanges == false
            let promotionItemViewModel = MockPromotionItemViewModel(promotionItemData: updatedItemData, isReadOnly: isReadOnly)
            let promotionItemView = PromotionItemView(viewModel: promotionItemViewModel)
            
            // Store references
            promotionItemViews[item.id] = promotionItemView
            promotionItemViewModels[item.id] = promotionItemViewModel
            
            // Add to stack view
            stackView.addArrangedSubview(promotionItemView)
            
            // Setup promotion selection handling
            promotionItemView.onPromotionSelected = { [weak self] in
                guard let self = self else { return }
                
                // Always trigger the callback for external handling
                self.onPromotionSelected(item.id)
                
                // Only update visual state if allowed
                if let currentState = self.currentDisplayState,
                   currentState.barData.allowsVisualStateChanges {
                    self.viewModel.selectPromotion(id: item.id)
                }
            }
        }
    }
    
    private func handleSelectionEvent(_ selectionEvent: PromotionSelectionEvent) {
        // Handle any additional logic based on selection events
        // This could include analytics, logging, or other side effects
        print("Promotion selected: \(selectionEvent.selectedId)")
    }
    
    private func hasContentChanged(newItems: [PromotionItemData]) -> Bool {
        guard let currentState = currentDisplayState else { return true }
        let currentItems = currentState.barData.promotionItems
        
        if currentItems.count != newItems.count { return true }
        
        for (current, new) in zip(currentItems, newItems) {
            if current != new { return true }
        }
        
        return false
    }
}

// MARK: - SwiftUI Preview
#if DEBUG
@available(iOS 17.0, *)
#Preview("Component States") {
    PreviewUIViewController {
        let vc = UIViewController()
        let scrollView = UIScrollView()
        let stackView = UIStackView()
        
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        stackView.axis = .vertical
        stackView.spacing = 30
        stackView.alignment = .fill
        stackView.distribution = .fill
        
        vc.view.addSubview(scrollView)
        scrollView.addSubview(stackView)
        
        // Basic selector bar
        let basicItems = [
            PromotionItemData(id: "1", title: "Welcome", isSelected: true),
            PromotionItemData(id: "2", title: "Sports", isSelected: false),
            PromotionItemData(id: "3", title: "Casino", isSelected: false),
            PromotionItemData(id: "4", title: "Bonuses", isSelected: false)
        ]
        let basicBarData = PromotionSelectorBarData(id: "main", promotionItems: basicItems, selectedPromotionId: "1")
        let basicViewModel = MockPromotionSelectorBarViewModel(barData: basicBarData)
        let basicSelectorBar = PromotionSelectorBarView(viewModel: basicViewModel)
        stackView.addArrangedSubview(basicSelectorBar)
        
        // Extended selector bar (scrollable)
        let extendedItems = [
            PromotionItemData(id: "1", title: "Welcome", isSelected: true),
            PromotionItemData(id: "2", title: "Sports", isSelected: false),
            PromotionItemData(id: "3", title: "Casino", isSelected: false),
            PromotionItemData(id: "4", title: "Bonuses", isSelected: false),
            PromotionItemData(id: "5", title: "Live Casino", isSelected: false),
            PromotionItemData(id: "6", title: "Virtual Sports", isSelected: false)
        ]
        let extendedBarData = PromotionSelectorBarData(id: "extended", promotionItems: extendedItems, selectedPromotionId: "1")
        let extendedViewModel = MockPromotionSelectorBarViewModel(barData: extendedBarData)
        let extendedSelectorBar = PromotionSelectorBarView(viewModel: extendedViewModel)
        stackView.addArrangedSubview(extendedSelectorBar)
        
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: vc.view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: vc.view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: vc.view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: vc.view.bottomAnchor),
            
            stackView.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: 20),
            stackView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            stackView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor, constant: -20),
            stackView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
            
            basicSelectorBar.heightAnchor.constraint(equalToConstant: 60),
            extendedSelectorBar.heightAnchor.constraint(equalToConstant: 60)
        ])
        
        vc.view.backgroundColor = .systemBackground
        return vc
    }
}
#endif
