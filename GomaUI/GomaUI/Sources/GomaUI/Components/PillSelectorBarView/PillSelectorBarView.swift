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
    
    // Fade overlay views and their masks
    private let leadingFadeView = UIView()
    private let trailingFadeView = UIView()
    private let leadingMask = CAGradientLayer()
    private let trailingMask = CAGradientLayer()
    
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
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        updateGradientFrames()
    }
    
    private func updateGradientFrames() {
        // Update mask frames to match their respective fade views
        leadingMask.frame = leadingFadeView.bounds
        trailingMask.frame = trailingFadeView.bounds
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
        
        let barData = state.barData
        
        // Update visibility and interaction
        isHidden = !state.isVisible
        isUserInteractionEnabled = state.isUserInteractionEnabled
        scrollView.isScrollEnabled = barData.isScrollEnabled
        
        // Check if we need a full rebuild or just state updates
        let existingIds = Set(pillViews.keys)
        let newIds = Set(barData.pills.map { $0.id })
        
        // If allowsVisualStateChanges is false, check if content has actually changed
        if !barData.allowsVisualStateChanges && existingIds == newIds && !pillViews.isEmpty {
            // Allow updates if pill content (title, icon) has changed, even in read-only mode
            let contentHasChanged = hasContentChanged(newPills: barData.pills)
            if !contentHasChanged {
                // Store current state for later access before early return
                currentDisplayState = state
                return
            }
        }
        
        // Store current state for later access
        currentDisplayState = state
        
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
            let isReadOnly = currentDisplayState?.barData.allowsVisualStateChanges == false
            let pillViewModel = MockPillItemViewModel(pillData: updatedPillData, isReadOnly: isReadOnly)
            let pillView = PillItemView(viewModel: pillViewModel)
            
            // Let PillItemView determine its own size
            
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
    
    private func hasContentChanged(newPills: [PillData]) -> Bool {
        // Store current pill data for comparison
        guard let currentState = currentDisplayState else { return true }
        let currentPills = currentState.barData.pills
        
        // If pill count differs, content has changed
        guard currentPills.count == newPills.count else { return true }
        
        // Compare content properties (ignoring selection state)
        for (index, newPill) in newPills.enumerated() {
            let currentPill = currentPills[index]
            
            if newPill.id != currentPill.id ||
               newPill.title != currentPill.title ||
               newPill.leftIconName != currentPill.leftIconName ||
               newPill.showExpandIcon != currentPill.showExpandIcon {
                return true
            }
            // Note: We intentionally ignore isSelected to allow selection state preservation
        }
        
        return false
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
    
    // MARK: - Layout
 
    // MARK: - Setup
    private func setupSubviews() {
        backgroundColor = StyleProvider.Color.navPills
        translatesAutoresizingMaskIntoConstraints = false
        
        // Setup scroll view
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.showsVerticalScrollIndicator = false
        scrollView.backgroundColor = UIColor.clear
        scrollView.contentInsetAdjustmentBehavior = .never
        scrollView.contentInset = UIEdgeInsets(top: 0,
                                               left: Constants.horizontalPadding,
                                               bottom: 0,
                                               right: Constants.horizontalPadding)
        addSubview(scrollView)
        
        // Setup stack view
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .horizontal
        stackView.spacing = Constants.pillSpacing
        stackView.alignment = .center
        stackView.distribution = .fill
        stackView.backgroundColor = UIColor.clear
        scrollView.addSubview(stackView)
        
        // Setup leading fade view (left side)
        leadingFadeView.translatesAutoresizingMaskIntoConstraints = false
        leadingFadeView.backgroundColor = StyleProvider.Color.navPills
        leadingFadeView.isUserInteractionEnabled = false
        addSubview(leadingFadeView)
        
        // Setup trailing fade view (right side)
        trailingFadeView.translatesAutoresizingMaskIntoConstraints = false
        trailingFadeView.backgroundColor = StyleProvider.Color.navPills
        trailingFadeView.isUserInteractionEnabled = false
        addSubview(trailingFadeView)
        
        // Leading mask: opaque -> transparent (left to right fade)
        leadingMask.colors = [
            UIColor.white.withAlphaComponent(1.0).cgColor,  // Opaque (covers content)
            UIColor.white.withAlphaComponent(1.0).cgColor,  // Opaque (covers content)
            UIColor.white.withAlphaComponent(0.0).cgColor   // Transparent (reveals content)
        ]
        leadingMask.locations = [0.0, 0.2, 1.0]
        leadingMask.startPoint = CGPoint(x: 0.0, y: 0.5)
        leadingMask.endPoint = CGPoint(x: 1.0, y: 0.5)
        leadingFadeView.layer.mask = leadingMask
        
        // Trailing mask: transparent -> opaque (right to left fade)
        trailingMask.colors = [
            UIColor.white.withAlphaComponent(0.0).cgColor,  // Transparent (reveals content)
            UIColor.white.withAlphaComponent(1.0).cgColor,   // Opaque (covers content)
            UIColor.white.withAlphaComponent(1.0).cgColor   // Opaque (covers content)
        ]
        trailingMask.locations = [0.0, 0.9, 1.0]
        trailingMask.startPoint = CGPoint(x: 0.0, y: 0.5)
        trailingMask.endPoint = CGPoint(x: 1.0, y: 0.5)
        trailingFadeView.layer.mask = trailingMask
        
        setupConstraints()
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            // Scroll view constraints
            scrollView.topAnchor.constraint(equalTo: topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: bottomAnchor),
            scrollView.heightAnchor.constraint(greaterThanOrEqualToConstant: Constants.minimumHeight),
            
            // Stack view constraints
            stackView.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor),
            stackView.leadingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.trailingAnchor),
            stackView.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor),
            stackView.heightAnchor.constraint(equalTo: scrollView.frameLayoutGuide.heightAnchor)
        ])
        
        NSLayoutConstraint.activate([
            // Leading fade view (left side)
            leadingFadeView.topAnchor.constraint(equalTo: topAnchor),
            leadingFadeView.bottomAnchor.constraint(equalTo: bottomAnchor),
            leadingFadeView.leadingAnchor.constraint(equalTo: leadingAnchor),
            leadingFadeView.widthAnchor.constraint(equalToConstant: Constants.horizontalPadding),
            
            // Trailing fade view (right side)
            trailingFadeView.topAnchor.constraint(equalTo: topAnchor),
            trailingFadeView.bottomAnchor.constraint(equalTo: bottomAnchor),
            trailingFadeView.trailingAnchor.constraint(equalTo: trailingAnchor),
            trailingFadeView.widthAnchor.constraint(equalToConstant: Constants.horizontalPadding)
        ])
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
    PreviewUIViewController {
        let vc = UIViewController()
        let pillSelectorView = PillSelectorBarView(viewModel: MockPillSelectorBarViewModel.sportsCategories)
        pillSelectorView.translatesAutoresizingMaskIntoConstraints = false
        vc.view.addSubview(pillSelectorView)
        
        NSLayoutConstraint.activate([
            pillSelectorView.topAnchor.constraint(equalTo: vc.view.safeAreaLayoutGuide.topAnchor, constant: 16),
            pillSelectorView.leadingAnchor.constraint(equalTo: vc.view.leadingAnchor, constant: 16),
            pillSelectorView.trailingAnchor.constraint(equalTo: vc.view.trailingAnchor, constant: -16),
            pillSelectorView.heightAnchor.constraint(equalToConstant: 60)
        ])
        
        vc.view.backgroundColor = UIColor.gray
        return vc
    }
}

@available(iOS 17.0, *)
#Preview("Market Filters") {
    PreviewUIViewController {
        let vc = UIViewController()
        let pillSelectorView = PillSelectorBarView(viewModel: MockPillSelectorBarViewModel.marketFilters)
        pillSelectorView.translatesAutoresizingMaskIntoConstraints = false
        vc.view.addSubview(pillSelectorView)
        
        NSLayoutConstraint.activate([
            pillSelectorView.topAnchor.constraint(equalTo: vc.view.safeAreaLayoutGuide.topAnchor, constant: 16),
            pillSelectorView.leadingAnchor.constraint(equalTo: vc.view.leadingAnchor, constant: 16),
            pillSelectorView.trailingAnchor.constraint(equalTo: vc.view.trailingAnchor, constant: -16),
            pillSelectorView.heightAnchor.constraint(equalToConstant: 60)
        ])
        
        vc.view.backgroundColor = UIColor.gray
        return vc
    }
}

@available(iOS 17.0, *)
#Preview("Time Periods") {
    PreviewUIViewController {
        let vc = UIViewController()
        let pillSelectorView = PillSelectorBarView(viewModel: MockPillSelectorBarViewModel.timePeriods)
        pillSelectorView.translatesAutoresizingMaskIntoConstraints = false
        vc.view.addSubview(pillSelectorView)
        
        NSLayoutConstraint.activate([
            pillSelectorView.topAnchor.constraint(equalTo: vc.view.safeAreaLayoutGuide.topAnchor, constant: 16),
            pillSelectorView.leadingAnchor.constraint(equalTo: vc.view.leadingAnchor, constant: 16),
            pillSelectorView.trailingAnchor.constraint(equalTo: vc.view.trailingAnchor, constant: -16),
            pillSelectorView.heightAnchor.constraint(equalToConstant: 60)
        ])
        
        vc.view.backgroundColor = UIColor.gray
        return vc
    }
}

@available(iOS 17.0, *)
#Preview("Read-Only States") {
    PreviewUIViewController {
        let vc = UIViewController()
        let pillSelectorView = PillSelectorBarView(viewModel: MockPillSelectorBarViewModel.readOnlyMarketFilters)
        pillSelectorView.translatesAutoresizingMaskIntoConstraints = false
        vc.view.addSubview(pillSelectorView)
        
        NSLayoutConstraint.activate([
            pillSelectorView.topAnchor.constraint(equalTo: vc.view.safeAreaLayoutGuide.topAnchor, constant: 16),
            pillSelectorView.leadingAnchor.constraint(equalTo: vc.view.leadingAnchor, constant: 16),
            pillSelectorView.trailingAnchor.constraint(equalTo: vc.view.trailingAnchor, constant: -16),
            pillSelectorView.heightAnchor.constraint(equalToConstant: 60)
        ])
        
        vc.view.backgroundColor = UIColor.gray
        return vc
    }
}

@available(iOS 17.0, *)
#Preview("Football Popular Leagues") {
    PreviewUIViewController {
        let vc = UIViewController()
        let pillSelectorView = PillSelectorBarView(viewModel: MockPillSelectorBarViewModel.footballPopularLeagues)
        pillSelectorView.translatesAutoresizingMaskIntoConstraints = false
        vc.view.addSubview(pillSelectorView)
        
        NSLayoutConstraint.activate([
            pillSelectorView.topAnchor.constraint(equalTo: vc.view.safeAreaLayoutGuide.topAnchor, constant: 16),
            pillSelectorView.leadingAnchor.constraint(equalTo: vc.view.leadingAnchor, constant: 16),
            pillSelectorView.trailingAnchor.constraint(equalTo: vc.view.trailingAnchor, constant: -16),
            pillSelectorView.heightAnchor.constraint(equalToConstant: 60)
        ])
        
        vc.view.backgroundColor = UIColor.lightText
        return vc
    }
}

#endif
