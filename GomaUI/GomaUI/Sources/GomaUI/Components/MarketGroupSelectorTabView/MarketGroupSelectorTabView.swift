import UIKit
import Combine

public class MarketGroupSelectorTabView: UIView {

    // MARK: - Private Properties
    private let viewModel: MarketGroupSelectorTabViewModelProtocol
    private var cancellables = Set<AnyCancellable>()
    private var tabItemViews: [String: MarketGroupTabItemView] = [:]
    private var tabItemViewModels: [String: MockMarketGroupTabItemViewModel] = [:]

    // MARK: - UI Components
    private let scrollView = UIScrollView()
    private let stackView = UIStackView()
    private let loadingIndicator = UIActivityIndicatorView(style: .medium)
    private let emptyStateLabel = UILabel()

    // MARK: - Layout Constants
    private struct Constants {
        static let horizontalPadding: CGFloat = 16.0
        static let verticalPadding: CGFloat = 8.0
        static let tabItemSpacing: CGFloat = 1.0
        static let cornerRadius: CGFloat = 8.0
        static let animationDuration: TimeInterval = 0.3
        static let minimumHeight: CGFloat = 42.0
    }

    // MARK: - Initialization
    public init(viewModel: MarketGroupSelectorTabViewModelProtocol) {
        self.viewModel = viewModel
        super.init(frame: .zero)
        setupSubviews()
        setupConstraints()
        setupBindings()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Setup Methods
    private func setupSubviews() {
        self.translatesAutoresizingMaskIntoConstraints = false
        
        addSubview(scrollView)
        addSubview(loadingIndicator)
        addSubview(emptyStateLabel)
        scrollView.addSubview(stackView)

        // Scroll view setup
        scrollView.backgroundColor = StyleProvider.Color.backgroundPrimary
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.showsVerticalScrollIndicator = false
        scrollView.contentInsetAdjustmentBehavior = .never

        // Stack view setup
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .horizontal
        stackView.spacing = Constants.tabItemSpacing
        stackView.alignment = .center
        stackView.distribution = .fill

        // Loading indicator setup
        loadingIndicator.translatesAutoresizingMaskIntoConstraints = false
        loadingIndicator.hidesWhenStopped = true
        loadingIndicator.color = StyleProvider.Color.highlightPrimary

        // Empty state label setup
        emptyStateLabel.translatesAutoresizingMaskIntoConstraints = false
        emptyStateLabel.text = "No market groups available"
        emptyStateLabel.textColor = StyleProvider.Color.textSecondary
        emptyStateLabel.font = StyleProvider.fontWith(type: .regular, size: 14)
        emptyStateLabel.textAlignment = .center
        emptyStateLabel.isHidden = true

        // View styling
        self.backgroundColor = StyleProvider.Color.backgroundPrimary
    }

    private func setupConstraints() {

        NSLayoutConstraint.activate([
            // Scroll view constraints
            scrollView.topAnchor.constraint(equalTo: topAnchor, constant: 0),
            scrollView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 0),
            scrollView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: 0),
            scrollView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: 0),
            scrollView.heightAnchor.constraint(greaterThanOrEqualToConstant: Constants.minimumHeight),

            // Stack view constraints
            stackView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            stackView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            stackView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            stackView.heightAnchor.constraint(equalTo: scrollView.heightAnchor),

            // Loading indicator constraints
            loadingIndicator.centerXAnchor.constraint(equalTo: centerXAnchor),
            loadingIndicator.centerYAnchor.constraint(equalTo: centerYAnchor),

            // Empty state label constraints
            emptyStateLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
            emptyStateLabel.centerYAnchor.constraint(equalTo: centerYAnchor),
            emptyStateLabel.leadingAnchor.constraint(greaterThanOrEqualTo: leadingAnchor, constant: Constants.horizontalPadding),
            emptyStateLabel.trailingAnchor.constraint(lessThanOrEqualTo: trailingAnchor, constant: -Constants.horizontalPadding)
        ])
    }

    private func setupBindings() {
        // Market groups binding
        viewModel.marketGroupsPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] marketGroups in
                self?.updateTabItems(marketGroups)
            }
            .store(in: &cancellables)

        // Visual state binding
        viewModel.visualStatePublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] visualState in
                self?.updateVisualState(visualState)
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

    // MARK: - Tab Management
    private func updateTabItems(_ marketGroups: [MarketGroupTabItemData]) {
        // Check if we need a full rebuild or just state updates
        let existingIds = Set(tabItemViews.keys)
        let newIds = Set(marketGroups.map { $0.id })
        
        // If the tab IDs haven't changed, just update visual states
        if existingIds == newIds && !tabItemViews.isEmpty {
            // Update existing tabs without rebuilding
            for marketGroup in marketGroups {
                if let tabViewModel = tabItemViewModels[marketGroup.id] {
                    tabViewModel.updateTabItemData(marketGroup)
                }
            }
            
            // Don't scroll here - let handleSelectionEvent handle scrolling
            // to avoid conflicts and preserve user's scroll position
            return
        }
        
        // Full rebuild needed (tabs added/removed or initial load)
        // Remove existing tab views
        clearTabItems()

        // Create new tab item views
        for marketGroup in marketGroups {
            createTabItemView(for: marketGroup)
        }

        // Scroll to selected tab if available (only on initial load/rebuild)
        if let selectedId = viewModel.currentSelectedMarketGroupId {
            scrollToTabItem(id: selectedId, animated: false)
        }
    }

    private func createTabItemView(for marketGroup: MarketGroupTabItemData) {
        let tabViewModel = MockMarketGroupTabItemViewModel(tabItemData: marketGroup)
        let tabView = MarketGroupTabItemView(viewModel: tabViewModel)

        // Store references
        tabItemViews[marketGroup.id] = tabView
        tabItemViewModels[marketGroup.id] = tabViewModel

        // Add to stack view
        stackView.addArrangedSubview(tabView)

        // Setup tab selection handling
        tabViewModel.onTapPublisher
            .sink { [weak self] tappedId in
                self?.viewModel.selectMarketGroup(id: tappedId)
            }
            .store(in: &cancellables)
    }

    private func clearTabItems() {
        // Remove all arranged subviews
        stackView.arrangedSubviews.forEach { view in
            stackView.removeArrangedSubview(view)
            view.removeFromSuperview()
        }

        // Clear references
        tabItemViews.removeAll()
        tabItemViewModels.removeAll()
    }

    // MARK: - Visual State Updates
    private func updateVisualState(_ visualState: MarketGroupSelectorTabVisualState) {
        UIView.animate(withDuration: Constants.animationDuration) {
            self.applyVisualState(visualState)
        }
    }

    private func applyVisualState(_ visualState: MarketGroupSelectorTabVisualState) {
        switch visualState {
        case .idle:
            applyIdleState()
        case .loading:
            applyLoadingState()
        case .empty:
            applyEmptyState()
        case .disabled:
            applyDisabledState()
        }
    }

    private func applyIdleState() {
        scrollView.isHidden = false
        loadingIndicator.stopAnimating()
        emptyStateLabel.isHidden = true
        isUserInteractionEnabled = true
        alpha = 1.0
    }

    private func applyLoadingState() {
        scrollView.isHidden = true
        loadingIndicator.startAnimating()
        emptyStateLabel.isHidden = true
        isUserInteractionEnabled = false
    }

    private func applyEmptyState() {
        scrollView.isHidden = true
        loadingIndicator.stopAnimating()
        emptyStateLabel.isHidden = false
        isUserInteractionEnabled = false
    }

    private func applyDisabledState() {
        scrollView.isHidden = false
        loadingIndicator.stopAnimating()
        emptyStateLabel.isHidden = true
        isUserInteractionEnabled = false
        alpha = 0.6
    }

    // MARK: - Scrolling and Navigation
    private func scrollToTabItem(id: String, animated: Bool = true) {
        guard let tabView = tabItemViews[id] else { return }

        let targetRect = stackView.convert(tabView.frame, to: scrollView)
        scrollView.scrollRectToVisible(targetRect, animated: animated)
    }

    // MARK: - Event Handling
    private func handleSelectionEvent(_ event: MarketGroupSelectionEvent) {
        // Scroll to the newly selected tab
        scrollToTabItem(id: event.selectedId)

        // Add haptic feedback for selection changes
        let selectionFeedback = UISelectionFeedbackGenerator()
        selectionFeedback.selectionChanged()

        // Log or handle analytics here if needed
        debugPrint("Market group selected: \(event.selectedId)")
    }

}

// MARK: - Intrinsic Content Size
extension MarketGroupSelectorTabView {
    public override var intrinsicContentSize: CGSize {
        let stackSize = stackView.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize)
        return CGSize(
            width: UIView.noIntrinsicMetric,
            height: max(stackSize.height + (Constants.verticalPadding * 2), Constants.minimumHeight)
        )
    }
}

// MARK: - Public Interface
extension MarketGroupSelectorTabView {

    /// Scrolls to a specific tab item
    public func scrollToTab(id: String, animated: Bool = true) {
        scrollToTabItem(id: id, animated: animated)
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

// MARK: - Preview Provider
#if DEBUG
import SwiftUI

@available(iOS 17.0, *)
#Preview("Standard Sports Markets") {
    PreviewUIView {
        MarketGroupSelectorTabView(viewModel: MockMarketGroupSelectorTabViewModel.standardSportsMarkets)
    }
    .frame(height: 70)
    .padding()
    .background(Color(UIColor.systemGroupedBackground))
}

@available(iOS 17.0, *)
#Preview("Mixed State Markets") {
    PreviewUIView {
        MarketGroupSelectorTabView(viewModel: MockMarketGroupSelectorTabViewModel.mixedStateMarkets)
    }
    .frame(height: 70)
    .padding()
    .background(Color(UIColor.systemGroupedBackground))
}

@available(iOS 17.0, *)
#Preview("Limited Markets") {
    PreviewUIView {
        MarketGroupSelectorTabView(viewModel: MockMarketGroupSelectorTabViewModel.limitedMarkets)
    }
    .frame(height: 70)
    .padding()
    .background(Color(UIColor.systemGroupedBackground))
}

@available(iOS 17.0, *)
#Preview("Loading State") {
    PreviewUIView {
        MarketGroupSelectorTabView(viewModel: MockMarketGroupSelectorTabViewModel.loadingMarkets)
    }
    .frame(height: 70)
    .padding()
    .background(Color(UIColor.systemGroupedBackground))
}

@available(iOS 17.0, *)
#Preview("Empty State") {
    PreviewUIView {
        MarketGroupSelectorTabView(viewModel: MockMarketGroupSelectorTabViewModel.emptyMarkets)
    }
    .frame(height: 70)
    .padding()
    .background(Color(UIColor.systemGroupedBackground))
}

@available(iOS 17.0, *)
#Preview("Disabled Markets") {
    PreviewUIView {
        MarketGroupSelectorTabView(viewModel: MockMarketGroupSelectorTabViewModel.disabledMarkets)
    }
    .frame(height: 70)
    .padding()
    .background(Color(UIColor.systemGroupedBackground))
}

#endif
