import UIKit
import Combine
import SwiftUI

final public class PillSelectorBarView: UIView {
    // MARK: - Private Properties
    private let scrollView = UIScrollView()
    private let stackView = UIStackView()
    private let viewModel: PillSelectorBarViewModelProtocol
    
    private var cancellables = Set<AnyCancellable>()
    private var pillViews: [String: PillItemView] = [:]
    private var pillViewModels: [String: MockPillItemViewModel] = [:]
    private var currentDisplayState: PillSelectorBarDisplayState?
    
    // MARK: - Layout Constants
    private struct Constants {
        static let horizontalPadding: CGFloat = 16.0
        static let pillSpacing: CGFloat = 12.0
        static let minimumHeight: CGFloat = 60.0
        static let animationDuration: TimeInterval = 0.3
    }
    
    // MARK: - Public Properties
    public var onPillSelected: ((String) -> Void) = { _ in }
    
    // MARK: - Initialization
    public init(viewModel: PillSelectorBarViewModelProtocol) {
        self.viewModel = viewModel
        super.init(frame: .zero)
        setupSubviews()
        setupBindings()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Setup
    private func setupSubviews() {
        backgroundColor = StyleProvider.Color.backgroundColor
        translatesAutoresizingMaskIntoConstraints = false
        
        // Setup scroll view
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.showsVerticalScrollIndicator = false
        scrollView.backgroundColor = UIColor.clear
        scrollView.contentInsetAdjustmentBehavior = .never
        addSubview(scrollView)
        
        // Setup stack view
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .horizontal
        stackView.spacing = Constants.pillSpacing
        stackView.alignment = .center
        stackView.distribution = .fill
        scrollView.addSubview(stackView)
        
        setupConstraints()
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            // Scroll view constraints
            scrollView.topAnchor.constraint(equalTo: topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: Constants.horizontalPadding),
            scrollView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -Constants.horizontalPadding),
            scrollView.bottomAnchor.constraint(equalTo: bottomAnchor),
            scrollView.heightAnchor.constraint(greaterThanOrEqualToConstant: Constants.minimumHeight),
            
            // Stack view constraints
            stackView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            stackView.leadingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.trailingAnchor),
            stackView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            stackView.heightAnchor.constraint(equalTo: scrollView.frameLayoutGuide.heightAnchor)
        ])
    }
    
    private func setupBindings() {
        // Display state binding
        viewModel.displayStatePublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] displayState in
                self?.render(state: displayState)
            }
            .store(in: &cancellables)
        
        // Selection event binding for analytics/logging
        viewModel.selectionEventPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] selectionEvent in
                self?.handleSelectionEvent(selectionEvent)
            }
            .store(in: &cancellables)
    }
    
    // MARK: - Rendering
    private func render(state: PillSelectorBarDisplayState) {
        // Store current state for later access
        currentDisplayState = state
        
        let barData = state.barData
        
        // Update visibility and interaction
        isHidden = !state.isVisible
        isUserInteractionEnabled = state.isUserInteractionEnabled
        scrollView.isScrollEnabled = barData.isScrollEnabled
        
        // Check if we need a full rebuild or just state updates
        let existingIds = Set(pillViews.keys)
        let newIds = Set(barData.pills.map { $0.id })
        
        // If the pill IDs haven't changed, just update visual states
        if existingIds == newIds && !pillViews.isEmpty {
            updateExistingPills(barData.pills, selectedId: barData.selectedPillId)
            return
        }
        
        // Full rebuild needed (pills added/removed or initial load)
        clearPillViews()
        createPillViews(for: barData.pills, selectedId: barData.selectedPillId)
        
        // Scroll to selected pill if available
        if let selectedId = barData.selectedPillId {
            scrollToPill(id: selectedId, animated: false)
        }
    }
    
    private func updateExistingPills(_ pills: [PillData], selectedId: String?) {
        // For existing pills, we need to recreate them with updated selection state
        // since MockPillItemViewModel doesn't expose a way to update the selection directly
        // without toggling (selectPill toggles the current state)
        clearPillViews()
        createPillViews(for: pills, selectedId: selectedId)
    }
    
    private func createPillViews(for pills: [PillData], selectedId: String?) {
        for pill in pills {
            let updatedPillData = pill.updatingSelection(isSelected: pill.id == selectedId)
            let pillViewModel = MockPillItemViewModel(pillData: updatedPillData)
            let pillView = PillItemView(viewModel: pillViewModel)
            
            // Store references
            pillViews[pill.id] = pillView
            pillViewModels[pill.id] = pillViewModel
            
            // Add to stack view
            stackView.addArrangedSubview(pillView)
            
            // Setup pill selection handling
            pillView.onPillSelected = { [weak self] in
                guard let self = self else { return }
                
                // Always trigger the callback for external handling
                self.onPillSelected(pill.id)
                
                // Only update visual state if allowed
                if let currentState = self.currentDisplayState,
                   currentState.barData.allowsVisualStateChanges {
                    self.viewModel.selectPill(id: pill.id)
                }
            }
        }
    }
    
    private func clearPillViews() {
        // Remove all arranged subviews
        stackView.arrangedSubviews.forEach { view in
            stackView.removeArrangedSubview(view)
            view.removeFromSuperview()
        }
        
        // Clear references
        pillViews.removeAll()
        pillViewModels.removeAll()
    }
    
    // MARK: - Scrolling
    private func scrollToPill(id: String, animated: Bool = true) {
        guard let pillView = pillViews[id] else { return }
        
        let targetRect = stackView.convert(pillView.frame, to: scrollView)
        scrollView.scrollRectToVisible(targetRect, animated: animated)
    }
    
    // MARK: - Event Handling
    private func handleSelectionEvent(_ event: PillSelectionEvent) {
        // Scroll to the newly selected pill
        scrollToPill(id: event.selectedId)
        
        // Add haptic feedback for selection changes
        let selectionFeedback = UISelectionFeedbackGenerator()
        selectionFeedback.selectionChanged()
        
        // Log for debugging
        debugPrint("Pill selected: \(event.selectedId)")
    }
    
    // MARK: - Public Methods
    public func scrollToPillWithId(_ id: String, animated: Bool = true) {
        scrollToPill(id: id, animated: animated)
    }
    
    /// Gets the current scroll position as a percentage (0.0 - 1.0)
    public var scrollProgress: CGFloat {
        let contentWidth = scrollView.contentSize.width
        let frameWidth = scrollView.frame.width
        
        guard contentWidth > frameWidth else { return 0.0 }
        
        let scrollableWidth = contentWidth - frameWidth
        return scrollView.contentOffset.x / scrollableWidth
    }
}

// MARK: - Intrinsic Content Size
extension PillSelectorBarView {
    public override var intrinsicContentSize: CGSize {
        let stackSize = stackView.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize)
        return CGSize(
            width: UIView.noIntrinsicMetric,
            height: max(stackSize.height, Constants.minimumHeight)
        )
    }
}

// MARK: - Helper Extension for PillData
extension PillData {
    func updatingSelection(isSelected: Bool) -> PillData {
        return PillData(
            id: self.id,
            title: self.title,
            leftIconName: self.leftIconName,
            showExpandIcon: self.showExpandIcon,
            isSelected: isSelected
        )
    }
}

// MARK: - Preview Provider
#if DEBUG

@available(iOS 17.0, *)
#Preview("Sports Categories") {
    PreviewUIView {
        PillSelectorBarView(viewModel: MockPillSelectorBarViewModel.sportsCategories)
    }
    .frame(height: 60)
    .padding()
    .background(Color(UIColor.systemGroupedBackground))
}

@available(iOS 17.0, *)
#Preview("Market Filters") {
    PreviewUIView {
        PillSelectorBarView(viewModel: MockPillSelectorBarViewModel.marketFilters)
    }
    .frame(height: 60)
    .padding()
    .background(Color(UIColor.systemGroupedBackground))
}

@available(iOS 17.0, *)
#Preview("Time Periods") {
    PreviewUIView {
        PillSelectorBarView(viewModel: MockPillSelectorBarViewModel.timePeriods)
    }
    .frame(height: 60)
    .padding()
    .background(Color(UIColor.systemGroupedBackground))
}

@available(iOS 17.0, *)
#Preview("Read-Only States") {
    PreviewUIView {
        PillSelectorBarView(viewModel: MockPillSelectorBarViewModel.readOnlyMarketFilters)
    }
    .frame(height: 60)
    .padding()
    .background(Color(UIColor.systemGroupedBackground))
}

@available(iOS 17.0, *)
#Preview("Football Popular Leagues") {
    PreviewUIView {
        PillSelectorBarView(viewModel: MockPillSelectorBarViewModel.footballPopularLeagues)
    }
    .frame(height: 60)
    .padding()
    .background(Color(UIColor.systemGroupedBackground))
}

#endif